module ExternalApi
  class AppointmentSyncService < BaseService
    def sync_appointments
      log_sync_activity(nil, 'start', { service: 'AppointmentSyncService' })
      
      begin
        # Fetch appointments from external API
        external_appointments = fetch_external_appointments
        
        # Process each external appointment
        synced_count = 0
        error_count = 0
        
        external_appointments.each do |external_appointment|
          begin
            sync_single_appointment(external_appointment)
            synced_count += 1
          rescue StandardError => e
            error_count += 1
            Rails.logger.error "Failed to sync appointment #{external_appointment['id']}: #{e.message}"
          end
        end
        
        log_sync_activity(nil, 'complete', { 
          synced: synced_count, 
          errors: error_count,
          total: external_appointments.count 
        })
        
        { success: true, synced: synced_count, errors: error_count }
      rescue ExternalApiError => e
        log_sync_activity(nil, 'error', { error: e.message })
        { success: false, error: e.message }
      end
    end
    
    private
    
    def fetch_external_appointments
      # Fetch appointments from external API
      make_request(:get, '/appointments', { limit: 100, offset: 0 })
    end
    
    def sync_single_appointment(external_appointment)
      # Find existing appointment by external_id or create new one
      appointment = Appointment.find_or_initialize_by(external_id: external_appointment['id'])
      
      # Find or create the client
      client = find_or_create_client(external_appointment['client'])
      
      # Parse the appointment time
      appointment_time = parse_appointment_time(external_appointment['scheduled_at'])
      
      # Update appointment attributes
      appointment.assign_attributes(
        client: client,
        time: appointment_time,
        notes: external_appointment['notes'],
        status: external_appointment['status'] || 'Pending',
        last_synced_at: Time.current,
        sync_status: 'synced',
        sync_errors: nil
      )
      
      if appointment.save
        log_sync_activity(appointment, 'synced', { external_id: external_appointment['id'] })
      else
        appointment.update!(
          sync_status: 'error',
          sync_errors: appointment.errors.full_messages.join(', ')
        )
        log_sync_activity(appointment, 'sync_error', { errors: appointment.errors.full_messages })
      end
    end
    
    def find_or_create_client(client_data)
      # Try to find by external_id first, then by email
      client = Client.find_by(external_id: client_data['id']) ||
               Client.find_by(email: client_data['email'])
      
      unless client
        # Create new client if not found
        client = Client.create!(
          external_id: client_data['id'],
          name: client_data['name'],
          email: client_data['email'],
          phone: client_data['phone'],
          sync_status: 'synced',
          last_synced_at: Time.current
        )
        log_sync_activity(client, 'created', { external_id: client_data['id'] })
      end
      
      client
    end
    
    def parse_appointment_time(time_string)
      # Parse various time formats from external API
      if time_string.present?
        begin
          Time.parse(time_string)
        rescue ArgumentError
          # Fallback to current time if parsing fails
          Rails.logger.warn "Could not parse appointment time: #{time_string}"
          Time.current
        end
      else
        Time.current
      end
    end
    

  end
end
