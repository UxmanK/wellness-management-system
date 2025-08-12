class Client < ApplicationRecord
  has_many :appointments, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :sync_status, inclusion: { in: %w[pending syncing synced error] }, allow_nil: true
  
  # Scopes
  scope :synced, -> { where(sync_status: 'synced') }
  scope :pending_sync, -> { where(sync_status: 'pending') }
  scope :sync_errors, -> { where(sync_status: 'error') }
  scope :recently_synced, -> { where('last_synced_at > ?', 1.hour.ago) }
  
  # Callbacks
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
    sync_status != 'synced' || last_synced_at.nil? || last_synced_at < 6.hours.ago
  end
  
  def sync_age
    return nil if last_synced_at.nil?
    Time.current - last_synced_at
  end
  
  private
  
  def set_default_sync_status
    self.sync_status ||= 'pending'
  end
end
