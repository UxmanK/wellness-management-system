class ActiveJobWrapperWorker
  include Sidekiq::Worker

  # You can override the queue if needed, but we'll keep "default"
  sidekiq_options queue: 'default'

  def perform(job_class_name)
    job_class = job_class_name.constantize

    unless job_class < ActiveJob::Base
      raise ArgumentError, "#{job_class_name} is not an ActiveJob class"
    end

    job_class.perform_later
  end
end


