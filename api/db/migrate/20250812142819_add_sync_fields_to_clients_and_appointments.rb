class AddSyncFieldsToClientsAndAppointments < ActiveRecord::Migration[7.1]
  def change
    # Add sync fields to clients table
    add_column :clients, :external_id, :string
    add_column :clients, :last_synced_at, :datetime
    add_column :clients, :sync_status, :string, default: 'pending'
    add_column :clients, :sync_errors, :text
    
    # Add sync fields to appointments table
    add_column :appointments, :external_id, :string
    add_column :appointments, :last_synced_at, :datetime
    add_column :appointments, :sync_status, :string, default: 'pending'
    add_column :appointments, :sync_errors, :text
    
    # Add indexes for better performance
    add_index :clients, :external_id
    add_index :clients, :sync_status
    add_index :appointments, :external_id
    add_index :appointments, :sync_status
  end
end
