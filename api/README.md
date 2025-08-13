# Wellness API Backend

A Rails API that manages wellness appointments and clients with automatic external system synchronization.

## 🚀 What It Does

- **Client Management**: Store and manage client information
- **Appointment Scheduling**: Create and manage wellness appointments
- **External Sync**: Automatically sync data with external wellness platforms
- **Background Processing**: Handle sync operations without blocking requests

## 🏗️ Quick Start

### 1. Setup

```bash
# Install dependencies
bundle install

# Setup database
bundle exec rails db:create
bundle exec rails db:migrate
```

### 2. Start Services

```bash
# Terminal 1: Rails API
bundle exec rails server

# Terminal 2: Background jobs
bundle exec sidekiq
```

### 3. Test It

```bash
# Check if it's working
curl http://localhost:3000/api/v1/clients
```

## 📚 API Endpoints

### Clients

```
GET    /api/v1/clients          # List all clients
GET    /api/v1/clients/:id      # Get specific client
POST   /api/v1/clients          # Create new client
PUT    /api/v1/clients/:id      # Update client
DELETE /api/v1/clients/:id      # Delete client
```

### Appointments

```
GET    /api/v1/appointments           # List all appointments
GET    /api/v1/appointments/:id       # Get specific appointment
POST   /api/v1/appointments           # Create new appointment
PUT    /api/v1/appointments/:id       # Update appointment
DELETE /api/v1/appointments/:id       # Delete appointment
PATCH  /api/v1/appointments/:id/cancel # Cancel appointment
```

### Sync Operations

```
GET    /api/v1/sync/status      # Check sync status
POST   /api/v1/sync/clients     # Trigger client sync
POST   /api/v1/sync/appointments # Trigger appointment sync
POST   /api/v1/sync/all         # Sync everything
POST   /api/v1/sync/force       # Force immediate sync
```

## 🔄 How Sync Works

1. **Local Changes**: Data saved locally with `sync_status: 'pending'`
2. **Background Sync**: Sidekiq jobs sync every 2-6 hours automatically
3. **Manual Sync**: Use endpoints for immediate synchronization

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test suites
bundle exec rspec spec/controllers/
bundle exec rspec spec/models/
bundle exec rspec spec/services/
```

## 🔧 Configuration

### Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost/wellness_dev

# Redis
REDIS_URL=redis://localhost:6379

# External API
MOCK_API_URL=https://api.wellness-platform.com
MOCK_API_KEY=your_api_key_here
```

### Sidekiq Settings

- **Client Sync**: Every 6 hours
- **Appointment Sync**: Every 2 hours
- **Retry Logic**: 3 attempts with exponential backoff

## 📊 Monitoring

### Sidekiq Dashboard

Access at `/sidekiq` to monitor:

- Background job status
- Failed jobs and retries
- Job queue performance

### Sync Status

```bash
curl http://localhost:3000/api/v1/sync/status
```

## 🚨 Troubleshooting

**Database Connection Failed**

```bash
# Check if PostgreSQL is running
brew services list | grep postgresql
brew services start postgresql
```

**Redis Connection Failed**

```bash
# Check if Redis is running
redis-cli ping
brew services start redis
```

**Sync Jobs Not Running**

```bash
# Check Sidekiq logs
tail -f log/sidekiq.log

# Verify Sidekiq is running
ps aux | grep sidekiq
```

## 🚀 Deployment

### Production Checklist

- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] Redis configured for production
- [ ] SSL/TLS certificates installed

### Docker Support

```bash
# Build and run
docker build -t wellness-api .
docker run -p 3000:3000 wellness-api
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Standards

- Follow Ruby style guidelines
- Write tests for new features
- Update documentation as needed

---

**Need help?** Check the logs or create a GitHub issue!
