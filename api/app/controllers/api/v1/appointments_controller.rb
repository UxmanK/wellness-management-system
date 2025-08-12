class Api::V1::AppointmentsController < ApplicationController
  def index
    render json: Appointment.includes(:client).all, each_serializer: AppointmentSerializer
  end

  def create
    # Log the incoming parameters for debugging
    Rails.logger.info "Creating appointment with params: #{appointment_params}"

    # Create appointment locally first
    appt = Appointment.create!(
      client_id: appointment_params[:client_id],
      time: appointment_params[:time],
      notes: appointment_params[:notes],
      status: appointment_params[:status] || 'Pending',
      sync_status: 'pending',
      last_synced_at: Time.current
    )

    # Log the created appointment for debugging
    Rails.logger.info "Created appointment: #{appt.attributes}"

    render json: appt, serializer: AppointmentSerializer, status: :created
  end

  def update
    appt = Appointment.find(params[:id])
    
    # Log the incoming parameters for debugging
    Rails.logger.info "Updating appointment #{params[:id]} with params: #{appointment_params}"
    
    appt.update!(
      time: appointment_params[:time],
      notes: appointment_params[:notes],
      status: appointment_params[:status],
      sync_status: 'pending',
      last_synced_at: Time.current
    )
    
    # Reload the appointment to get the latest data
    appt.reload
    
    # Log the updated appointment for debugging
    Rails.logger.info "Updated appointment: #{appt.attributes}"
    
    render json: appt, serializer: AppointmentSerializer
  end

  def destroy
    appt = Appointment.find(params[:id])
    appt.destroy!
    head :no_content
  end

  def cancel
    appt = Appointment.find(params[:id])
    appt.update!(status: 'Cancelled', sync_status: 'pending', last_synced_at: Time.current)
    render json: appt, serializer: AppointmentSerializer
  end
  
  private

  def appointment_params
    params.require(:appointment).permit(:client_id, :time, :notes, :status)
  end
end
