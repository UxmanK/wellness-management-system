require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe "associations" do
    it { should belong_to(:client) }
  end

  describe "validations" do
    it { should validate_presence_of(:time) }
    
    it "validates status inclusion" do
      valid_statuses = %w[Pending Confirmed Cancelled]
      invalid_statuses = %w[invalid_status completed failed]
      
      valid_statuses.each do |status|
        appointment = build(:appointment, status: status)
        expect(appointment).to be_valid
      end
      
      invalid_statuses.each do |status|
        appointment = build(:appointment, status: status)
        expect(appointment).not_to be_valid
        expect(appointment.errors[:status]).to include('is not included in the list')
      end
    end
    
    it "validates sync_status inclusion" do
      valid_statuses = %w[pending syncing synced error]
      invalid_statuses = %w[invalid_status completed failed]
      
      valid_statuses.each do |status|
        appointment = build(:appointment, sync_status: status)
        expect(appointment).to be_valid
      end
      
      invalid_statuses.each do |status|
        appointment = build(:appointment, sync_status: status)
        expect(appointment).not_to be_valid
        expect(appointment.errors[:sync_status]).to include('is not included in the list')
      end
    end
  end

  describe "scopes" do
    let!(:synced_appointment) { create(:appointment, :synced) }
    let!(:pending_appointment) { create(:appointment, :pending_sync) }
    let!(:error_appointment) { create(:appointment, :sync_error) }
    let!(:upcoming_appointment) { create(:appointment, :upcoming) }
    let!(:past_appointment) { create(:appointment, :past) }
    let!(:recently_synced_appointment) { create(:appointment, :synced, last_synced_at: 30.minutes.ago) }
    let!(:old_synced_appointment) { create(:appointment, :synced, last_synced_at: 3.hours.ago) }

    describe ".synced" do
      it "returns only synced appointments" do
        expect(Appointment.synced).to include(synced_appointment, recently_synced_appointment, old_synced_appointment)
        expect(Appointment.synced).not_to include(pending_appointment, error_appointment)
      end
    end

    describe ".pending_sync" do
      it "returns only pending sync appointments" do
        expect(Appointment.pending_sync).to include(pending_appointment)
        expect(Appointment.pending_sync).not_to include(synced_appointment, error_appointment)
      end
    end

    describe ".sync_errors" do
      it "returns only appointments with sync errors" do
        expect(Appointment.sync_errors).to include(error_appointment)
        expect(Appointment.sync_errors).not_to include(synced_appointment, pending_appointment)
      end
    end

    describe ".recently_synced" do
      it "returns appointments synced within the last hour" do
        expect(Appointment.recently_synced).to include(recently_synced_appointment)
        expect(Appointment.recently_synced).not_to include(old_synced_appointment, pending_appointment, error_appointment)
      end
    end

    describe ".upcoming" do
      it "returns only upcoming appointments" do
        expect(Appointment.upcoming).to include(upcoming_appointment)
        expect(Appointment.upcoming).not_to include(past_appointment)
      end
    end

    describe ".past" do
      it "returns only past appointments" do
        expect(Appointment.past).to include(past_appointment)
        expect(Appointment.past).not_to include(upcoming_appointment)
      end
    end
  end

  describe "callbacks" do
    it "sets default status to Pending on creation" do
      appointment = create(:appointment, status: nil)
      expect(appointment.status).to eq('Pending')
    end

    it "sets default sync_status to pending on creation" do
      appointment = create(:appointment)
      expect(appointment.sync_status).to eq('pending')
    end
  end

  describe "instance methods" do
    let(:appointment) { create(:appointment) }

    describe "#sync_successful!" do
      it "updates sync status to synced" do
        appointment.sync_successful!
        
        expect(appointment.reload.sync_status).to eq('synced')
        expect(appointment.last_synced_at).to be_present
        expect(appointment.sync_errors).to be_nil
      end
    end

    describe "#sync_failed!" do
      it "updates sync status to error with error message" do
        error_message = "API timeout occurred"
        appointment.sync_failed!(error_message)
        
        expect(appointment.reload.sync_status).to eq('error')
        expect(appointment.sync_errors).to eq(error_message)
      end
    end

    describe "#needs_sync?" do
      it "returns true for new appointments" do
        expect(appointment.needs_sync?).to be true
      end

      it "returns false for recently synced appointments" do
        appointment.sync_successful!
        expect(appointment.needs_sync?).to be false
      end

      it "returns true for appointments synced more than 2 hours ago" do
        appointment.sync_successful!
        travel_to(3.hours.from_now) do
          expect(appointment.needs_sync?).to be true
        end
      end
    end

    describe "#sync_age" do
      it "returns nil for never synced appointments" do
        expect(appointment.sync_age).to be_nil
      end

      it "returns time since last sync" do
        appointment.sync_successful!
        travel_to(2.hours.from_now) do
          expect(appointment.sync_age).to be_within(1.second).of(2.hours)
        end
      end
    end

    describe "#upcoming?" do
      it "returns true for future appointments" do
        appointment = create(:appointment, :upcoming)
        expect(appointment.upcoming?).to be true
      end

      it "returns false for past appointments" do
        appointment = create(:appointment, :past)
        expect(appointment.upcoming?).to be false
      end
    end

    describe "#past?" do
      it "returns true for past appointments" do
        appointment = create(:appointment, :past)
        expect(appointment.past?).to be true
      end

      it "returns false for future appointments" do
        appointment = create(:appointment, :upcoming)
        expect(appointment.past?).to be false
      end
    end

    describe "#status_color" do
      it "returns green for confirmed appointments" do
        appointment = create(:appointment, :confirmed)
        expect(appointment.status_color).to eq('green')
      end

      it "returns red for cancelled appointments" do
        appointment = create(:appointment, :cancelled)
        expect(appointment.status_color).to eq('red')
      end

      it "returns yellow for pending appointments" do
        appointment = create(:appointment, status: 'Pending')
        expect(appointment.status_color).to eq('yellow')
      end
    end
  end

  describe "sync behavior" do
    let(:appointment) { create(:appointment) }
    
    describe "sync status" do
      it "has default sync status" do
        expect(appointment.sync_status).to eq('pending')
      end

      it "can mark sync as successful" do
        appointment.sync_successful!
        expect(appointment.reload.sync_status).to eq('synced')
        expect(appointment.last_synced_at).to be_present
      end

      it "can mark sync as failed" do
        appointment.sync_failed!("API error")
        expect(appointment.reload.sync_status).to eq('error')
        expect(appointment.sync_errors).to include("API error")
      end

      it "can check if sync is needed" do
        expect(appointment.needs_sync?).to be true
        
        appointment.sync_successful!
        expect(appointment.needs_sync?).to be false
        
        travel_to(3.hours.from_now) do
          expect(appointment.reload.needs_sync?).to be true
        end
      end

      it "can calculate sync age" do
        expect(appointment.sync_age).to be_nil
        
        appointment.sync_successful!
        travel_to(2.hours.from_now) do
          expect(appointment.reload.sync_age).to be_within(1.second).of(2.hours)
        end
      end
    end
  end
end
