require 'rails_helper'

RSpec.describe AppointmentSyncJob, type: :job do
  let(:sync_service) { instance_double(ExternalApi::AppointmentSyncService) }
  let(:success_result) { { success: true, synced: 5, errors: 0 } }
  let(:failure_result) { { success: false, error: 'API timeout' } }

  before do
    allow(ExternalApi::AppointmentSyncService).to receive(:new).and_return(sync_service)
  end

  describe "#perform" do
    context "when sync is successful" do
      before do
        allow(sync_service).to receive(:sync_appointments).and_return(success_result)
      end

      it "calls the appointment sync service" do
        expect(sync_service).to receive(:sync_appointments)
        AppointmentSyncJob.perform_now
      end
    end

    context "when sync service raises an error" do
      let(:error) { StandardError.new("Unexpected error") }

      before do
        allow(sync_service).to receive(:sync_appointments).and_raise(error)
      end
      it "re-raises the error to trigger Sidekiq retry" do
        expect { AppointmentSyncJob.perform_now }.to raise_error(StandardError, "Unexpected error")
      end
    end
  end

  describe "job configuration" do
    it "uses the default queue" do
      expect(AppointmentSyncJob.queue_name).to eq('default')
    end

    it "can be enqueued" do
      expect { AppointmentSyncJob.perform_later }.to have_enqueued_job(AppointmentSyncJob)
    end

    it "can be performed immediately" do
      allow(sync_service).to receive(:sync_appointments).and_return(success_result)
      expect { AppointmentSyncJob.perform_now }.not_to raise_error
    end
  end
end
