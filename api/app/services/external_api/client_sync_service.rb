module ExternalApi
  class ClientSyncService < BaseService
    def sync_clients
      log_sync_activity(nil, 'start', { service: 'ClientSyncService' })
      
      begin
        # Fetch clients from external API
        external_clients = fetch_external_clients
        
        # Process each external client
        synced_count = 0
        error_count = 0
        
        external_clients.each do |external_client|
          begin
            sync_single_client(external_client)
            synced_count += 1
          rescue StandardError => e
            error_count += 1
            Rails.logger.error "Failed to sync client #{external_client['id']}: #{e.message}"
          end
        end
        
        log_sync_activity(nil, 'complete', { 
          synced: synced_count, 
          errors: error_count,
          total: external_clients.count 
        })
        
        { success: true, synced: synced_count, errors: error_count }
      rescue ExternalApiError => e
        log_sync_activity(nil, 'error', { error: e.message })
        { success: false, error: e.message }
      end
    end
    
    private
    
    def fetch_external_clients
      # Fetch clients from external API
      make_request(:get, '/clients', { limit: 100, offset: 0 })
    end
    
    def sync_single_client(external_client)
      # Find existing client by external_id or create new one
      client = Client.find_or_initialize_by(external_id: external_client['id'])
      
      # Update client attributes
      client.assign_attributes(
        name: external_client['name'],
        email: external_client['email'],
        phone: external_client['phone'],
        last_synced_at: Time.current,
        sync_status: 'synced',
        sync_errors: nil
      )
      
      if client.save
        log_sync_activity(client, 'synced', { external_id: external_client['id'] })
      else
        client.update!(
          sync_status: 'error',
          sync_errors: client.errors.full_messages.join(', ')
        )
        log_sync_activity(client, 'sync_error', { errors: client.errors.full_messages })
      end
    end
    

  end
end
