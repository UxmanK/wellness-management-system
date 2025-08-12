require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }

  # Error handler for logging
  config.error_handlers << ->(ex, context, _job_json) do
    Rails.logger.error "Sidekiq error: #{ex.message}"
    Rails.logger.error "Context: #{context}"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }
end

Rails.application.config.after_initialize do
  # First job: Client Sync every minute
  Sidekiq::Cron::Job.create(
    name: 'Client Sync - Every 1 minute',
    cron: '* * * * *', # every minute
    class: 'ActiveJobWrapperWorker',
    args: ['ClientSyncJob']
  )

  # Second job: Appointment Sync every minute, delayed by 30 seconds
  Sidekiq::Cron::Job.create(
    name: 'Appointment Sync - Every 1 minute (offset)',
    cron: '*/1 * * * *', # every minute
    class: 'ActiveJobWrapperWorker',
    args: ['AppointmentSyncJob']
  )
end
