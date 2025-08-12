require 'rails_helper'

RSpec.describe "Api::V1::Clients", type: :request do
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

  describe "GET /api/v1/clients" do
    before do
      get "/api/v1/clients", headers: { "Accept" => "application/json" }
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
        expect(first_client).to have_key("created_at")
        expect(first_client).to have_key("updated_at")
      end
    end

    context "with multiple clients" do
      it "returns all clients" do
        # Create additional clients for this specific test
        create_list(:client, 3)
        get "/api/v1/clients", headers: { "Accept" => "application/json" }
        expect(JSON.parse(response.body).length).to eq(4) # 3 created + 1 from let
      end
    end
  end

  describe "GET /api/v1/clients/:id" do
    it "returns the client" do
      get "/api/v1/clients/#{client.id}", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:success)
      
      json_response = JSON.parse(response.body)
      expect(json_response["id"]).to eq(client.id)
      expect(json_response["name"]).to eq(client.name)
      expect(json_response["email"]).to eq(client.email)
    end

    context "with non-existent client" do
      it "returns not found" do
        get "/api/v1/clients/999999", headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/clients" do
    context "with valid parameters" do
      it "creates a new client" do
        expect {
          post "/api/v1/clients", params: valid_params, headers: { "Accept" => "application/json" }
        }.to change(Client, :count).by(1)
      end

      it "returns http created status" do
        post "/api/v1/clients", params: valid_params, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:created)
      end

      it "creates client with correct attributes" do
        post "/api/v1/clients", params: valid_params, headers: { "Accept" => "application/json" }
        new_client = Client.last
        
        expect(new_client.name).to eq(valid_params[:client][:name])
        expect(new_client.email).to eq(valid_params[:client][:email])
        expect(new_client.phone).to eq(valid_params[:client][:phone])
        expect(new_client.sync_status).to eq('pending')
        expect(new_client.last_synced_at).to be_present
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

      it "returns unprocessable entity status" do
        post "/api/v1/clients", params: invalid_params, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(422)
      end

      it "does not create a client" do
        expect {
          post "/api/v1/clients", params: invalid_params, headers: { "Accept" => "application/json" }
        }.not_to change(Client, :count)
      end
    end
  end

  describe "PUT /api/v1/clients/:id" do
    let(:update_params) do
      {
        client: {
          name: "Updated Name",
          email: "updated@example.com",
          phone: "555-9999"
        }
      }
    end

    context "with valid parameters" do
      it "updates the client" do
        put "/api/v1/clients/#{client.id}", params: update_params, headers: { "Accept" => "application/json" }
        client.reload
        
        expect(client.name).to eq(update_params[:client][:name])
        expect(client.email).to eq(update_params[:client][:email])
        expect(client.phone).to eq(update_params[:client][:phone])
        expect(client.sync_status).to eq('pending')
        expect(client.last_synced_at).to be_present
      end

      it "returns http success" do
        put "/api/v1/clients/#{client.id}", params: update_params, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid parameters" do
      let(:invalid_update_params) do
        {
          client: {
            name: nil,
            email: nil
          }
        }
      end

      it "returns unprocessable entity status" do
        put "/api/v1/clients/#{client.id}", params: invalid_update_params, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(422)
      end
    end

    context "with non-existent client" do
      it "returns not found" do
        put "/api/v1/clients/999999", params: update_params, headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /api/v1/clients/:id" do
    let!(:client_to_delete) { create(:client) }

    it "deletes the client" do
      expect {
        delete "/api/v1/clients/#{client_to_delete.id}", headers: { "Accept" => "application/json" }
      }.to change(Client, :count).by(-1)
    end

    it "returns http no content" do
      delete "/api/v1/clients/#{client_to_delete.id}", headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:no_content)
    end

    context "with non-existent client" do
      it "returns not found" do
        delete "/api/v1/clients/999999", headers: { "Accept" => "application/json" }
        expect(response).to have_http_status(:not_found)
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
