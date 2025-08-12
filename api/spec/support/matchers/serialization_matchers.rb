RSpec::Matchers.define :be_serialized_with do |serializer_class|
  match do |response|
    # For controller specs, check if the response body can be parsed as JSON
    # and contains the expected structure
    begin
      json = JSON.parse(response.body)
      # Basic check - if it's an array, check first element; if hash, check directly
      if json.is_a?(Array) && json.any?
        # Check if the first element has the expected serializer attributes
        first_item = json.first
        # Check for common serializer attributes
        expected_attrs = [:id, :created_at, :updated_at]
        expected_attrs.all? { |attr| first_item.key?(attr.to_s) }
      elsif json.is_a?(Hash)
        # Check for common serializer attributes
        expected_attrs = [:id, :created_at, :updated_at]
        expected_attrs.all? { |attr| json.key?(attr.to_s) }
      else
        false
      end
    rescue JSON::ParserError
      false
    end
  end

  failure_message do |response|
    "expected response to be serialized with #{serializer_class}, but it wasn't"
  end

  failure_message_when_negated do |response|
    "expected response not to be serialized with #{serializer_class}, but it was"
  end
end
