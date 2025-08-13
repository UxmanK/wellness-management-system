module ExternalApi
  class BaseService
    include ActiveSupport::Configurable
    
    config_accessor :base_url, :api_key, :timeout, :retry_attempts
    
    # Configure default values
    configure do |config|
      config.base_url = ENV['MOCK_API_URL']
      config.api_key = ENV['MOCK_API_KEY'] || 'demo_key'
      config.timeout = ENV['EXTERNAL_API_TIMEOUT']&.to_i || 30
      config.retry_attempts = ENV['EXTERNAL_API_RETRY_ATTEMPTS']&.to_i || 3
    end
    
    private
    
    def http_client
      @http_client ||= Faraday.new(url: base_url) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.options.timeout = timeout
        faraday.options.open_timeout = timeout
      end
    end
    
    def make_request(method, endpoint, params = {})
      retry_count = 0
      
      begin
        response = http_client.send(method) do |req|
          req.url endpoint
          req.headers['Authorization'] = "Bearer #{api_key}"
          req.headers['Content-Type'] = 'application/json'
          
          case method
          when :get
            req.params.update(params)
          when :post, :put, :patch
            req.body = params.to_json
          end
        end
        
        handle_response(response)
      rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
        retry_count += 1
        if retry_count <= retry_attempts
          Rails.logger.warn "External API request failed, retrying (#{retry_count}/#{retry_attempts}): #{e.message}"
          sleep(2 ** retry_count) # Exponential backoff
          retry
        else
          raise ExternalApiError, "Request failed after #{retry_attempts} attempts: #{e.message}"
        end
      rescue StandardError => e
        raise ExternalApiError, "Unexpected error: #{e.message}"
      end
    end
    
    def handle_response(response)
      case response.status
      when 200..299
        JSON.parse(response.body)
      when 401
        raise ExternalApiError, "Authentication failed: #{response.body}"
      when 403
        raise ExternalApiError, "Access forbidden: #{response.body}"
      when 404
        raise ExternalApiError, "Resource not found: #{response.body}"
      when 429
        raise ExternalApiError, "Rate limit exceeded: #{response.body}"
      when 500..599
        raise ExternalApiError, "Server error: #{response.body}"
      else
        raise ExternalApiError, "Unexpected response: #{response.status} - #{response.body}"
      end
    rescue JSON::ParserError => e
      raise ExternalApiError, "Invalid JSON response: #{e.message}"
    end
    
    def log_sync_activity(model, action, details = {})
      Rails.logger.info "External API Sync: #{model.class.name} #{action} - #{details}"
    end
  end
  
  class ExternalApiError < StandardError; end
end
