require 'rails_helper'

RSpec.describe ClientSerializer, type: :serializer do
  let(:client) { create(:client, :synced) }
  let(:serializer) { described_class.new(client) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  describe "attributes" do
    subject { JSON.parse(serialization.to_json) }

    it "includes id" do
      expect(subject['id']).to eq(client.id)
    end

    it "includes name" do
      expect(subject['name']).to eq(client.name)
    end

    it "includes email" do
      expect(subject['email']).to eq(client.email)
    end

    it "includes phone" do
      expect(subject['phone']).to eq(client.phone)
    end

    it "includes created_at" do
      expect(subject['created_at']).to be_present
    end

    it "includes updated_at" do
      expect(subject['updated_at']).to be_present
    end

    it "includes sync_status" do
      expect(subject['sync_status']).to eq(client.sync_status)
    end

    it "includes last_synced_at" do
      expect(subject['last_synced_at']).to be_present
    end

    it "includes external_id" do
      expect(subject['external_id']).to eq(client.external_id)
    end
  end

  describe "with appointments" do
    let!(:appointments) { create_list(:appointment, 3, client: client) }
    let(:serialization_with_appointments) { ActiveModelSerializers::Adapter.create(serializer, include: :appointments) }

    it "includes appointments when requested" do
      json = JSON.parse(serialization_with_appointments.to_json)
      expect(json['appointments']).to be_an(Array)
      expect(json['appointments'].length).to eq(3)
    end

    it "serializes appointments correctly" do
      json = JSON.parse(serialization_with_appointments.to_json)
      appointment = json['appointments'].first
      
      expect(appointment['id']).to be_present
      expect(appointment['time']).to be_present
      expect(appointment['status']).to be_present
    end
  end

  describe "sync error handling" do
    let(:client_with_errors) { create(:client, :sync_error) }
    let(:error_serializer) { described_class.new(client_with_errors) }
    let(:error_serialization) { ActiveModelSerializers::Adapter.create(error_serializer) }

    it "includes sync_errors when present" do
      json = JSON.parse(error_serialization.to_json)
      expect(json['sync_errors']).to eq(client_with_errors.sync_errors)
    end

    it "handles nil sync_errors gracefully" do
      client_with_errors.update!(sync_errors: nil)
      json = JSON.parse(error_serialization.to_json)
      expect(json['sync_errors']).to be_nil
    end
  end

  describe "date formatting" do
    it "formats timestamps consistently" do
      json = JSON.parse(serialization.to_json)
      
      expect(json['created_at']).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
      expect(json['updated_at']).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
      expect(json['last_synced_at']).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end
  end

  describe "nil value handling" do
    let(:client_with_nils) { create(:client, external_id: nil, last_synced_at: nil) }
    let(:nil_serializer) { described_class.new(client_with_nils) }
    let(:nil_serialization) { ActiveModelSerializers::Adapter.create(nil_serializer) }

    it "handles nil values gracefully" do
      json = JSON.parse(nil_serialization.to_json)
      
      expect(json['external_id']).to be_nil
      expect(json['last_synced_at']).to be_nil
    end
  end
end
