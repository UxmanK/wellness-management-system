class Appointment < ApplicationRecord
  belongs_to :client
  
  # Validations
  validates :status, inclusion: { in: %w[Pending Confirmed Cancelled] }, allow_nil: true
  validates :time, presence: true
  validates :sync_status, inclusion: { in: %w[pending syncing synced error] }, allow_nil: true
  
  # Scopes
  scope :synced, -> { where(sync_status: 'synced') }
  scope :pending_sync, -> { where(sync_status: 'pending') }
  scope :sync_errors, -> { where(sync_status: 'error') }
  scope :recently_synced, -> { where('last_synced_at > ?', 1.hour.ago) }
  scope :upcoming, -> { where('time > ?', Time.current).order(:time) }
  scope :past, -> { where('time < ?', Time.current).order(time: :desc) }
  
  # Callbacks
  before_create :set_default_status
  before_create :set_default_sync_status
  
  # Instance methods
  def sync_successful!
    update!(
      sync_status: 'synced',
      last_synced_at: Time.current,
      sync_errors: nil
    )
  end
  
  def sync_failed!(error_message)
    update!(
      sync_status: 'error',
      sync_errors: error_message
    )
  end
  
  def needs_sync?
    sync_status != 'synced' || last_synced_at.nil? || last_synced_at < 2.hours.ago
  end
  
  def sync_age
    return nil if last_synced_at.nil?
    Time.current - last_synced_at
  end
  
  def upcoming?
    time > Time.current
  end
  
  def past?
    time < Time.current
  end
  
  def status_color
    case status
    when 'Confirmed'
      'green'
    when 'Cancelled'
      'red'
    else
      'yellow'
    end
  end
  
  private
  
  def set_default_status
    self.status ||= 'Pending'
  end
  
  def set_default_sync_status
    self.sync_status ||= 'pending'
  end
end
