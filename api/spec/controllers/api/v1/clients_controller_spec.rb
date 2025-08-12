require 'rails_helper'

RSpec.describe Api::V1::ClientsController, type: :controller do
  let!(:client) { create(:client) }
  let(:valid_params) do
    {
      client: {
        name: "John Doe",
        email: "john.doe@example.com",
        phone: "555-0123"
      }
    }
  end

  describe "GET #index" do
    before do
      get :index, format: :json
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns all clients" do
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it "uses ClientSerializer" do
      json_response = JSON.parse(response.body)
      if json_response.any?
        first_client = json_response.first
        expect(first_client).to have_key("id")
        expect(first_client).to have_key("name")
        expect(first_client).to have_key("email")
        expect(first_client).to have_key("phone")
      end
    end

    context "with multiple clients" do
      let!(:clients) { create_list(:client, 3) }

      it "returns all clients" do
        get :index, format: :json
        expect(JSON.parse(response.body).length).to eq(4) # 3 created + 1 from let
      end
    end
  end

  describe "GET #show" do
    it "returns the client" do
      get :show, params: { id: client.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to have_key('id')
    end

    context "with non-existent client" do
      it "raises an error" do
        expect {
          get :show, params: { id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new client" do
        expect {
          post :create, params: valid_params
        }.to change(Client, :count).by(1)
      end

      it "returns http created status" do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "creates client with correct attributes" do
        post :create, params: valid_params
        new_client = Client.last
        
        expect(new_client.name).to eq(valid_params[:client][:name])
        expect(new_client.email).to eq(valid_params[:client][:email])
        expect(new_client.phone).to eq(valid_params[:client][:phone])
        expect(new_client.sync_status).to eq('pending')
        expect(new_client.last_synced_at).to be_present
      end

      it "uses ClientSerializer" do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('id')
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          client: {
            name: nil,
            email: nil
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
        id: client.id,
        client: {
          name: "Updated Name",
          email: "updated@example.com",
          phone: "555-9999"
        }
      }
    end

    context "with valid parameters" do
      it "updates the client" do
        put :update, params: update_params
        client.reload
        
        expect(client.name).to eq(update_params[:client][:name])
        expect(client.email).to eq(update_params[:client][:email])
        expect(client.phone).to eq(update_params[:client][:phone])
        expect(client.sync_status).to eq('pending')
        expect(client.last_synced_at).to be_present
      end

      it "returns http success" do
        put :update, params: update_params
        expect(response).to have_http_status(:success)
      end

      it "uses ClientSerializer" do
        put :update, params: update_params
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to have_key('id')
      end
    end

    context "with invalid parameters" do
      let(:invalid_update_params) do
        {
          id: client.id,
          client: {
            name: nil,
            email: nil
          }
        }
      end

      it "raises an error" do
        expect {
          put :update, params: invalid_update_params
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with non-existent client" do
      it "raises an error" do
        expect {
          put :update, params: { id: 999999, client: { name: "New Name" } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:client_to_delete) { create(:client) }

    it "deletes the client" do
      expect {
        delete :destroy, params: { id: client_to_delete.id }
      }.to change(Client, :count).by(-1)
    end

    it "returns http no content" do
      delete :destroy, params: { id: client_to_delete.id }
      expect(response).to have_http_status(:no_content)
    end

    context "with non-existent client" do
      it "raises an error" do
        expect {
          delete :destroy, params: { id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
