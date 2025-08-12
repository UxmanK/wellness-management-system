class ClientSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :phone, :created_at, :updated_at, :sync_status, :last_synced_at, :external_id, :sync_errors
  
  has_many :appointments
end
