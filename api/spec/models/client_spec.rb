require 'rails_helper'

RSpec.describe Client, type: :model do
  describe "associations" do
    it { should have_many(:appointments).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone) }
    
    it { should validate_uniqueness_of(:email) }
    
    it "validates email format" do
      valid_emails = ['test@example.com', 'user.name@domain.co.uk', 'user+tag@example.org']
      invalid_emails = ['invalid-email', '@example.com', 'user@', 'user@.com']
      
      valid_emails.each do |email|
        client = build(:client, email: email)
        expect(client).to be_valid
      end
      
      invalid_emails.each do |email|
        client = build(:client, email: email)
        expect(client).not_to be_valid
        expect(client.errors[:email]).to include('is invalid')
      end
    end
    
    it "validates sync_status inclusion" do
      valid_statuses = %w[pending syncing synced error]
      invalid_statuses = %w[invalid_status completed failed]
      
      valid_statuses.each do |status|
        client = build(:client, sync_status: status)
        expect(client).to be_valid
      end
      
      invalid_statuses.each do |status|
        client = build(:client, sync_status: status)
        expect(client).not_to be_valid
        expect(client.errors[:sync_status]).to include('is not included in the list')
      end
    end
  end

  describe "scopes" do
    let!(:synced_client) { create(:client, :synced) }
    let!(:pending_client) { create(:client, :pending_sync) }
    let!(:error_client) { create(:client, :sync_error) }
    let!(:recently_synced_client) { create(:client, :synced, last_synced_at: 30.minutes.ago) }
    let!(:old_synced_client) { create(:client, :synced, last_synced_at: 2.hours.ago) }

    describe ".synced" do
      it "returns only synced clients" do
        expect(Client.synced).to include(synced_client, recently_synced_client, old_synced_client)
        expect(Client.synced).not_to include(pending_client, error_client)
      end
    end

    describe ".pending_sync" do
      it "returns only pending sync clients" do
        expect(Client.pending_sync).to include(pending_client)
        expect(Client.pending_sync).not_to include(synced_client, error_client)
      end
    end

    describe ".sync_errors" do
      it "returns only clients with sync errors" do
        expect(Client.sync_errors).to include(error_client)
        expect(Client.sync_errors).not_to include(synced_client, pending_client)
      end
    end

    describe ".recently_synced" do
      it "returns clients synced within the last hour" do
        expect(Client.recently_synced).to include(recently_synced_client)
        expect(Client.recently_synced).not_to include(old_synced_client, pending_client, error_client)
      end
    end
  end

  describe "callbacks" do
    it "sets default sync_status to pending on creation" do
      client = create(:client)
      expect(client.sync_status).to eq('pending')
    end
  end

  describe "instance methods" do
    let(:client) { create(:client) }

    describe "#sync_successful!" do
      it "updates sync status to synced" do
        client.sync_successful!
        
        expect(client.reload.sync_status).to eq('synced')
        expect(client.last_synced_at).to be_present
        expect(client.sync_errors).to be_nil
      end
    end

    describe "#sync_failed!" do
      it "updates sync status to error with error message" do
        error_message = "API timeout occurred"
        client.sync_failed!(error_message)
        
        expect(client.reload.sync_status).to eq('error')
        expect(client.sync_errors).to eq(error_message)
      end
    end

    describe "#needs_sync?" do
      it "returns true for new clients" do
        expect(client.needs_sync?).to be true
      end

      it "returns false for recently synced clients" do
        client.sync_successful!
        expect(client.needs_sync?).to be false
      end

      it "returns true for clients synced more than 6 hours ago" do
        client.sync_successful!
        travel_to(7.hours.from_now) do
          expect(client.needs_sync?).to be true
        end
      end
    end

    describe "#sync_age" do
      it "returns nil for never synced clients" do
        expect(client.sync_age).to be_nil
      end

      it "returns time since last sync" do
        client.sync_successful!
        travel_to(2.hours.from_now) do
          expect(client.sync_age).to be_within(1.second).of(2.hours)
        end
      end
    end
  end

  describe "sync behavior" do
    let(:client) { create(:client) }
    
    describe "sync status" do
      it "has default sync status" do
        expect(client.sync_status).to eq('pending')
      end

      it "can mark sync as successful" do
        client.sync_successful!
        expect(client.reload.sync_status).to eq('synced')
        expect(client.last_synced_at).to be_present
      end

      it "can mark sync as failed" do
        client.sync_failed!("API error")
        expect(client.reload.sync_status).to eq('error')
        expect(client.sync_errors).to include("API error")
      end

      it "can check if sync is needed" do
        expect(client.needs_sync?).to be true
        
        client.sync_successful!
        expect(client.needs_sync?).to be false
        
        travel_to(7.hours.from_now) do
          expect(client.reload.needs_sync?).to be true
        end
      end

      it "can calculate sync age" do
        expect(client.sync_age).to be_nil
        
        client.sync_successful!
        travel_to(2.hours.from_now) do
          expect(client.reload.sync_age).to be_within(1.second).of(2.hours)
        end
      end
    end
  end
end
