FactoryBot.define do
  factory :client do
    sequence(:name) { |n| "Client #{n}" }
    sequence(:email) { |n| "client#{n}@example.com" }
    sequence(:phone) { |n| "+1-555-#{n.to_s.rjust(3, '0')}-#{n.to_s.rjust(4, '0')}" }
    
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
    
    trait :with_appointments do
      after(:create) do |client|
        create_list(:appointment, 3, client: client)
      end
    end
  end
end
