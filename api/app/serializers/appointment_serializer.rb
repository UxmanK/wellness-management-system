class AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :api_id, :client_id, :time, :notes, :status, :created_at, :updated_at, :client_name, :sync_status, :last_synced_at, :external_id, :sync_errors
  
  belongs_to :client
  
  # Add client name for easier frontend access
  def client_name
    object.client&.name
  end
  
  # Format the time for frontend consumption
  def time
    object.time&.iso8601
  end
end
