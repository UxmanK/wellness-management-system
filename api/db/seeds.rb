# This file runs the external API sync services to populate the database
# with real data from external sources. It can be run multiple times safely.

puts "Starting external API sync to populate database..."

# Ensure we have the required environment variables
unless ENV['MOCK_API_URL']
  puts "Error: MOCK_API_URL not set. Please set this environment variable to continue."
  exit 1
else
  puts "Using external API: #{ENV['MOCK_API_URL']}"
end

unless ENV['MOCK_API_KEY']
  puts "Error: MOCK_API_KEY not set. Please set this environment variable to continue."
  exit 1
else
  puts "API key configured: #{ENV['MOCK_API_KEY'][0..10]}..."
end

# Set the external API configuration for the sync services
ExternalApi::BaseService.configure do |config|
  config.base_url = ENV['MOCK_API_URL']
  config.api_key = ENV['MOCK_API_KEY']
end

puts "External API configuration set successfully"

# Helper method to safely clear data
def clear_existing_data
  puts "Clearing existing data..."
  
  # Use transaction for safety
  ActiveRecord::Base.transaction do
    Appointment.destroy_all
    Client.destroy_all
  end
  
  puts "Existing data cleared successfully"
rescue => e
  puts "Error clearing data: #{e.message}"
  raise e
end

# Helper method to sync clients
def sync_clients
  puts "\nSyncing clients from external API..."
  client_service = ExternalApi::ClientSyncService.new
  client_result = client_service.sync_clients

  if client_result[:success]
    puts "Clients synced successfully:"
    puts "  - Synced: #{client_result[:synced]}"
    puts "  - Errors: #{client_result[:errors]}"
    puts "  - Total clients in database: #{Client.count}"
    client_result
  else
    puts "Client sync failed: #{client_result[:error]}"
    client_result
  end
end

# Helper method to sync appointments
def sync_appointments
  puts "\nSyncing appointments from external API..."
  appointment_service = ExternalApi::AppointmentSyncService.new
  appointment_result = appointment_service.sync_appointments

  if appointment_result[:success]
    puts "Appointments synced successfully:"
    puts "  - Synced: #{appointment_result[:synced]}"
    puts "  - Errors: #{appointment_result[:errors]}"
    puts "  - Total appointments in database: #{Appointment.count}"
    appointment_result
  else
    puts "Appointment sync failed: #{appointment_result[:error]}"
    appointment_result
  end
end

# Helper method to display summary
def display_summary
  puts "\nDatabase Population Summary:"
  puts "=" * 50
  puts "Clients: #{Client.count}"
  puts "Appointments: #{Appointment.count}"
  puts "Last sync: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}"
  
  # Show some sample data
  if Client.count > 0
    puts "\nSample Clients:"
    Client.limit(3).each do |client|
      puts "  - #{client.name} (#{client.email}) - ID: #{client.external_id || client.id}"
    end
  end

  if Appointment.count > 0
    puts "\nSample Appointments:"
    Appointment.includes(:client).limit(3).each do |apt|
      puts "  - #{apt.client.name} - #{apt.time.strftime('%Y-%m-%d %H:%M')} - #{apt.status}"
    end
  end
end

# Main execution
begin
  # Clear existing data
  clear_existing_data
  
  # Sync data from external APIs
  client_result = sync_clients
  appointment_result = sync_appointments
  
  # Display summary
  display_summary
  
  # Final status
  if client_result[:success] && appointment_result[:success]
    puts "\nDatabase population completed successfully!"
    puts "You can now run the application with populated data."
  else
    puts "\nDatabase population completed with some errors:"
    puts "  - Clients: #{client_result[:success] ? 'SUCCESS' : 'FAILED'}"
    puts "  - Appointments: #{appointment_result[:success] ? 'SUCCESS' : 'FAILED'}"
  end
  
  puts "To re-sync data, run: rails db:seed"
  
rescue => e
  puts "\nFatal error during database population: #{e.message}"
  puts "Stack trace: #{e.backtrace.first(5).join("\n")}"
  raise e
end
