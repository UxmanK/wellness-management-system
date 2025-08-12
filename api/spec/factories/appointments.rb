FactoryBot.define do
  factory :appointment do
    association :client
    time { 1.day.from_now }
    notes { "Regular checkup appointment" }
    status { 'Pending' }
    
    trait :confirmed do
      status { 'Confirmed' }
    end
    
    trait :cancelled do
      status { 'Cancelled' }
    end
    
    trait :past do
      time { 1.day.ago }
    end
    
    trait :upcoming do
      time { 1.day.from_now }
    end
    
    trait :synced do
      sync_status { 'synced' }
      last_synced_at { 1.hour.ago }
      external_id { "ext_#{SecureRandom.hex(8)}" }
    end
    
    trait :pending_sync do
      sync_status { 'pending' }
      last_synced_at { nil }
    end
    
    trait :sync_error do
      sync_status { 'error' }
      sync_errors { 'API timeout error' }
      last_synced_at { 2.hours.ago }
    end
    
    trait :with_api_id do
      api_id { "api_#{SecureRandom.hex(8)}" }
    end
  end
end
