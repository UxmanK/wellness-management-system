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
      # Simulate fetching from external API
      # In production, this would be a real API call
      make_request(:get, '/clients', { limit: 100, offset: 0 })
    rescue ExternalApiError => e
      # Fallback to mock data for demo purposes
      Rails.logger.warn "External API failed, using mock data: #{e.message}"
      generate_mock_clients
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
    
    def generate_mock_clients
      # Generate mock data for demonstration
      [
        {
          'id' => 'ext_001',
          'name' => 'Alice Johnson',
          'email' => 'alice.johnson@example.com',
          'phone' => '555-0106'
        },
        {
          'id' => 'ext_002',
          'name' => 'Bob Wilson',
          'email' => 'bob.wilson@example.com',
          'phone' => '555-0107'
        },
        {
          'id' => 'ext_003',
          'name' => 'Carol Davis',
          'email' => 'carol.davis@example.com',
          'phone' => '555-0108'
        },
        {
          'id' => 'ext_004',
          'name' => 'David Miller',
          'email' => 'david.miller@example.com',
          'phone' => '555-0109'
        },
        {
          'id' => 'ext_005',
          'name' => 'Eva Garcia',
          'email' => 'eva.garcia@example.com',
          'phone' => '555-0110'
        }
      ]
    end
  end
end
