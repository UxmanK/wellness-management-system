class AppointmentSyncJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info "Starting appointment sync job at #{Time.current}"
    
    begin
      result = ExternalApi::AppointmentSyncService.new.sync_appointments
      
      if result[:success]
        Rails.logger.info "Appointment sync completed successfully: #{result[:synced]} synced, #{result[:errors]} errors"
      else
        Rails.logger.error "Appointment sync failed: #{result[:error]}"
      end
    rescue StandardError => e
      Rails.logger.error "Appointment sync job failed with error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Re-raise the error to trigger Sidekiq retry mechanism
      raise e
    end
  end
end
