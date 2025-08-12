class ClientSyncJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info "Starting client sync job at #{Time.current}"
    
    begin
      result = ExternalApi::ClientSyncService.new.sync_clients
      
      if result[:success]
        Rails.logger.info "Client sync completed successfully: #{result[:synced]} synced, #{result[:errors]} errors"
      else
        Rails.logger.error "Client sync failed: #{result[:error]}"
      end
    rescue StandardError => e
      Rails.logger.error "Client sync job failed with error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Re-raise the error to trigger Sidekiq retry mechanism
      raise e
    end
  end
end
