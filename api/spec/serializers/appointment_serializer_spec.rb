require 'rails_helper'

RSpec.describe AppointmentSerializer, type: :serializer do
  let(:client) { create(:client) }
  let(:appointment) { create(:appointment, client: client, sync_status: 'synced') }
  let(:serializer) { described_class.new(appointment) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  describe "attributes" do
    subject { JSON.parse(serialization.to_json) }

    it "includes id" do
      expect(subject['id']).to eq(appointment.id)
    end

    it "includes api_id" do
      expect(subject['api_id']).to eq(appointment.api_id)
    end

    it "includes client_id" do
      expect(subject['client_id']).to eq(appointment.client_id)
    end

    it "includes time" do
      expect(subject['time']).to be_present
    end

    it "includes notes" do
      expect(subject['notes']).to eq(appointment.notes)
    end

    it "includes status" do
      expect(subject['status']).to eq(appointment.status)
    end

    it "includes created_at" do
      expect(subject['created_at']).to be_present
    end

    it "includes updated_at" do
      expect(subject['updated_at']).to be_present
    end

    it "includes sync_status" do
      expect(subject['sync_status']).to eq(appointment.sync_status)
    end

    it "includes external_id" do
      expect(subject['external_id']).to eq(appointment.external_id)
    end
  end

  describe "with client" do
    let(:serialization_with_client) { ActiveModelSerializers::Adapter.create(serializer, include: :client) }

    it "includes client when requested" do
      json = JSON.parse(serialization_with_client.to_json)
      expect(json['client']).to be_present
    end

    it "serializes client correctly" do
      json = JSON.parse(serialization_with_client.to_json)
      client_data = json['client']
      
      expect(client_data['id']).to eq(client.id)
      expect(client_data['name']).to eq(client.name)
      expect(client_data['email']).to eq(client.email)
    end
  end

  describe "sync error handling" do
    let(:appointment_with_errors) { create(:appointment, :sync_error, client: client) }
    let(:error_serializer) { described_class.new(appointment_with_errors) }
    let(:error_serialization) { ActiveModelSerializers::Adapter.create(error_serializer) }

    it "includes sync_errors when present" do
      json = JSON.parse(error_serialization.to_json)
      expect(json['sync_errors']).to eq(appointment_with_errors.sync_errors)
    end

    it "handles nil sync_errors gracefully" do
      appointment_with_errors.update!(sync_errors: nil)
      json = JSON.parse(error_serialization.to_json)
      expect(json['sync_errors']).to be_nil
    end
  end

  describe "nil value handling" do
    let(:appointment_with_nils) { create(:appointment, client: client, api_id: nil, external_id: nil, last_synced_at: nil) }
    let(:nil_serializer) { described_class.new(appointment_with_nils) }
    let(:nil_serialization) { ActiveModelSerializers::Adapter.create(nil_serializer) }

    it "handles nil values gracefully" do
      json = JSON.parse(nil_serialization.to_json)
      
      expect(json['api_id']).to be_nil
      expect(json['external_id']).to be_nil
      expect(json['last_synced_at']).to be_nil
    end
  end

  describe "status values" do
    it "correctly serializes different statuses" do
      %w[Pending Confirmed Cancelled].each do |status|
        appointment.update!(status: status)
        json = JSON.parse(serialization.to_json)
        expect(json['status']).to eq(status)
      end
    end
  end

  describe "sync status values" do
    it "correctly serializes different sync statuses" do
      %w[pending syncing synced error].each do |sync_status|
        appointment.update!(sync_status: sync_status)
        json = JSON.parse(serialization.to_json)
        expect(json['sync_status']).to eq(sync_status)
      end
    end
  end

  describe "notes handling" do
    it "handles long notes" do
      long_notes = "This is a very long note that contains a lot of information about the appointment and what needs to be done during the session. It might include special instructions, patient concerns, or other relevant details."
      appointment.update!(notes: long_notes)
      
      json = JSON.parse(serialization.to_json)
      expect(json['notes']).to eq(long_notes)
    end

    it "handles empty notes" do
      appointment.update!(notes: "")
      json = JSON.parse(serialization.to_json)
      expect(json['notes']).to eq("")
    end

    it "handles nil notes" do
      appointment.update!(notes: nil)
      json = JSON.parse(serialization.to_json)
      expect(json['notes']).to be_nil
    end
  end
end
