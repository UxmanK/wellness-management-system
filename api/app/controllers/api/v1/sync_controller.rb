module Api
  module V1
    class SyncController < ApplicationController
      def status
        render json: {
          clients: {
            total: Client.count,
            synced: Client.where(sync_status: 'synced').count,
            pending: Client.where(sync_status: 'pending').count,
            error: Client.where(sync_status: 'error').count,
            last_sync: Client.maximum(:last_synced_at)
          },
          appointments: {
            total: Appointment.count,
            synced: Appointment.where(sync_status: 'synced').count,
            pending: Appointment.where(sync_status: 'pending').count,
            error: Appointment.where(sync_status: 'error').count,
            last_sync: Appointment.maximum(:last_synced_at)
          },
          scheduled_jobs: Sidekiq::Cron::Job.all.map do |job|
            {
              name: job.name,
              cron: job.cron,
              last_run: job.last_run_time,
              next_run: job.next_run_time,
              enabled: job.enabled?
            }
          end
        }
      end
      
      def sync_clients
        begin
          # Enqueue the sync job
          ClientSyncJob.perform_later
          
          render json: {
            message: 'Client sync job enqueued successfully',
            job_id: SecureRandom.uuid,
            timestamp: Time.current
          }
        rescue StandardError => e
          render json: {
            error: 'Failed to enqueue client sync job',
            message: e.message
          }, status: :internal_server_error
        end
      end
      
      def sync_appointments
        begin
          # Enqueue the sync job
          AppointmentSyncJob.perform_later
          
          render json: {
            message: 'Appointment sync job enqueued successfully',
            job_id: SecureRandom.uuid,
            timestamp: Time.current
          }
        rescue StandardError => e
          render json: {
            error: 'Failed to enqueue appointment sync job',
            message: e.message
          }, status: :internal_server_error
        end
      end
      
      def sync_all
        begin
          # Enqueue both sync jobs
          ClientSyncJob.perform_later
          AppointmentSyncJob.perform_later
          
          render json: {
            message: 'All sync jobs enqueued successfully',
            jobs: [
              { type: 'clients', job_id: SecureRandom.uuid },
              { type: 'appointments', job_id: SecureRandom.uuid }
            ],
            timestamp: Time.current
          }
        rescue StandardError => e
          render json: {
            error: 'Failed to enqueue sync jobs',
            message: e.message
          }, status: :internal_server_error
        end
      end
      
      def force_sync
        begin
          # Force immediate sync (synchronous)
          client_result = ExternalApi::ClientSyncService.new.sync_clients
          appointment_result = ExternalApi::AppointmentSyncService.new.sync_appointments
          
          render json: {
            message: 'Force sync completed',
            clients: client_result,
            appointments: appointment_result,
            timestamp: Time.current
          }
        rescue StandardError => e
          render json: {
            error: 'Force sync failed',
            message: e.message
          }, status: :internal_server_error
        end
      end
    end
  end
end
