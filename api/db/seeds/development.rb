# Development-specific seeds
# This file runs additional development data setup

puts "\nSetting up development environment..."

# Ensure the external API configuration is set for development
unless ENV['MOCK_API_URL'] && ENV['MOCK_API_KEY']
  puts "Warning: MOCK_API_URL or MOCK_API_KEY not set, some features may not work properly"
end

# Create some additional test data if needed
if Client.count == 0
  puts "Creating sample development clients..."
  
  clients = [
    { name: 'Test User 1', email: 'test1@example.com', phone: '555-0001' },
    { name: 'Test User 2', email: 'test2@example.com', phone: '555-0002' },
    { name: 'Test User 3', email: 'test3@example.com', phone: '555-0003' }
  ]
  
  clients.each do |client_data|
    Client.create!(
      name: client_data[:name],
      email: client_data[:email],
      phone: client_data[:phone],
      sync_status: 'synced',
      last_synced_at: Time.current
    )
  end
  
  puts "Created #{clients.count} development clients successfully"
end

if Appointment.count == 0 && Client.count > 0
  puts "Creating sample development appointments..."
  
  # Get a client to create appointments for
  client = Client.first
  
  appointments = [
    { time: 1.day.from_now, status: 'Confirmed', notes: 'Development test appointment' },
    { time: 2.days.from_now, status: 'Pending', notes: 'Another test appointment' },
    { time: 3.days.from_now, status: 'Confirmed', notes: 'Third test appointment' }
  ]
  
  appointments.each do |apt_data|
    Appointment.create!(
      client: client,
      time: apt_data[:time],
      status: apt_data[:status],
      notes: apt_data[:notes],
      sync_status: 'synced',
      last_synced_at: Time.current
    )
  end
  
  puts "Created #{appointments.count} development appointments successfully"
end

puts "Development environment setup completed successfully"
