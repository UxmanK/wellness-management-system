module ExternalApi
  class AppointmentSyncService < BaseService
    def sync_appointments
      log_sync_activity(nil, 'start', { service: 'AppointmentSyncService' })

      synced_count = 0
      error_count = 0
      error_details = []

      begin
        external_appointments = fetch_external_appointments

        external_appointments.each do |external_appointment|
          begin
            sync_single_appointment(external_appointment)
            synced_count += 1
          rescue StandardError => e
            error_count += 1
            error_message = "Failed to sync appointment #{external_appointment['id']}: #{e.message}"
            error_details << error_message
            Rails.logger.error error_message
          end
        end

        log_sync_activity(nil, 'complete', {
          synced: synced_count,
          errors: error_count,
          total: external_appointments.count
        })

        { success: true, synced: synced_count, errors: error_count, detailed_errors: error_details }
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
      appointment = Appointment.find_or_initialize_by(external_id: external_appointment['id'])

      # Find client by external_id from the appointment's client_id field
      client = Client.find_by(external_id: external_appointment['client_id'])
      unless client
        raise StandardError, "Client with external_id #{external_appointment['client_id']} not found"
      end

      # Parse appointment time from 'time' field
      appointment_time = parse_appointment_time(external_appointment['time'])

      appointment.assign_attributes(
        client: client,
        time: appointment_time,
        notes: nil,          # No notes provided in API response
        status: 'Pending',   # Default status if missing
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

    def parse_appointment_time(time_string)
      if time_string.present?
        begin
          Time.parse(time_string)
        rescue ArgumentError
          Rails.logger.warn "Could not parse appointment time: #{time_string}"
          Time.current
        end
      else
        Time.current
      end
    end
  end
end
