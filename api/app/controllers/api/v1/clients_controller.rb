class Api::V1::ClientsController < ApplicationController
  def index
    render json: Client.all, each_serializer: ClientSerializer
  end

  def show
    client = Client.find(params[:id])
    render json: client, serializer: ClientSerializer
  end

  def create
    # Log the incoming parameters for debugging
    Rails.logger.info "Creating client with params: #{client_params}"

    # Create client locally
    client = Client.create!(
      name: client_params[:name],
      email: client_params[:email],
      phone: client_params[:phone],
      sync_status: 'pending',
      last_synced_at: Time.current
    )

    # Log the created client for debugging
    Rails.logger.info "Created client: #{client.attributes}"

    render json: client, serializer: ClientSerializer, status: :created
  end

  def update
    client = Client.find(params[:id])
    
    # Log the incoming parameters for debugging
    Rails.logger.info "Updating client #{params[:id]} with params: #{client_params}"
    
    client.update!(
      name: client_params[:name],
      email: client_params[:email],
      phone: client_params[:phone],
      sync_status: 'pending',
      last_synced_at: Time.current
    )
    
    # Reload the client to get the latest data
    client.reload
    
    # Log the updated client for debugging
    Rails.logger.info "Updated client: #{client.attributes}"
    
    render json: client, serializer: ClientSerializer
  end

  def destroy
    client = Client.find(params[:id])
    client.destroy!
    head :no_content
  end

  private

  def client_params
    params.require(:client).permit(:name, :email, :phone)
  end
end
