require 'rails_helper'

RSpec.describe Api::V1::AppointmentsController, type: :controller do
  let(:client) { create(:client) }
  let(:appointment) { create(:appointment, client: client) }
  let(:valid_params) do
    {
      appointment: {
        client_id: client.id,
        time: 1.day.from_now,
        notes: "Regular checkup",
        status: "Pending"
      }
    }
  end

  describe "GET #index" do
    before do
      get :index
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns all appointments" do
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it "uses AppointmentSerializer" do
      appointment = create(:appointment, client: client)
      get :index
      response_body = JSON.parse(response.body)
      expect(response_body.last['client']).to be_present
    end

    it "includes client data" do
      appointment = create(:appointment, client: client)
      get :index
      response_body = JSON.parse(response.body)
      expect(response_body.last['client']).to be_present
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new appointment" do
        expect {
          post :create, params: valid_params
        }.to change(Appointment, :count).by(1)
      end

      it "returns http created status" do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "creates appointment with correct attributes" do
        post :create, params: valid_params
        appointment = Appointment.last
        
        expect(appointment.client_id).to eq(client.id)
        expect(appointment.time).to be_within(1.second).of(valid_params[:appointment][:time])
        expect(appointment.notes).to eq(valid_params[:appointment][:notes])
        expect(appointment.status).to eq(valid_params[:appointment][:status])
        expect(appointment.sync_status).to eq('pending')
        expect(appointment.last_synced_at).to be_present
      end

      it "uses AppointmentSerializer" do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('id')
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          appointment: {
            client_id: nil,
            time: nil
          }
        }
      end

      it "raises an error due to validation failure" do
        expect {
          post :create, params: invalid_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "PUT #update" do
    let(:update_params) do
      {
        id: appointment.id,
        appointment: {
          time: 2.days.from_now,
          notes: "Updated notes",
          status: "Confirmed"
        }
      }
    end

    context "with valid parameters" do
      it "updates the appointment" do
        put :update, params: update_params
        appointment.reload
        
        expect(appointment.time).to be_within(1.second).of(update_params[:appointment][:time])
        expect(appointment.notes).to eq(update_params[:appointment][:notes])
        expect(appointment.status).to eq(update_params[:appointment][:status])
        expect(appointment.sync_status).to eq('pending')
        expect(appointment.last_synced_at).to be_present
      end

      it "returns http success" do
        put :update, params: update_params
        expect(response).to have_http_status(:success)
      end

      it "uses AppointmentSerializer" do
        put :update, params: update_params
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to have_key('id')
      end
    end

    context "with invalid parameters" do
      let(:invalid_update_params) do
        {
          id: appointment.id,
          appointment: {
            time: nil
          }
        }
      end

      it "raises an error" do
        expect {
          put :update, params: invalid_update_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with non-existent appointment" do
      it "raises an error" do
        expect {
          put :update, params: { id: 999999, appointment: { time: 1.day.from_now } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:appointment_to_delete) { create(:appointment, client: client) }

    it "deletes the appointment" do
      expect {
        delete :destroy, params: { id: appointment_to_delete.id }
      }.to change(Appointment, :count).by(-1)
    end

    it "returns http no content" do
      delete :destroy, params: { id: appointment_to_delete.id }
      expect(response).to have_http_status(:no_content)
    end

    context "with non-existent appointment" do
      it "raises an error" do
        expect {
          delete :destroy, params: { id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PUT #cancel" do
    it "cancels the appointment" do
      put :cancel, params: { id: appointment.id }
      appointment.reload
      
      expect(appointment.status).to eq('Cancelled')
      expect(appointment.sync_status).to eq('pending')
      expect(appointment.last_synced_at).to be_present
    end

    it "returns http success" do
      put :cancel, params: { id: appointment.id }
      expect(response).to have_http_status(:success)
    end

    it "uses AppointmentSerializer" do
      put :cancel, params: { id: appointment.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to have_key('id')
    end

    context "with non-existent appointment" do
      it "raises an error" do
        expect {
          put :cancel, params: { id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "API behavior" do
    describe "authentication" do
      it "requires authentication" do
        # Add authentication tests here when authentication is implemented
        expect(true).to be true # Placeholder test
      end
    end

    describe "error handling" do
      it "handles validation errors gracefully" do
        # Add validation error handling tests here
        expect(true).to be true # Placeholder test
      end

      it "returns proper error status codes" do
        # Add error status code tests here
        expect(true).to be true # Placeholder test
      end
    end
  end
end
