# Periodic Syncing System

This document describes the periodic syncing system implemented for the Wellness App backend, which automatically fetches clients and appointments from an external API at regular intervals.

## Overview

The system uses **Sidekiq** for background job processing and **Sidekiq-cron** for scheduling periodic sync operations. It's designed to be robust, with error handling, retry mechanisms, and fallback to mock data for demonstration purposes.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   External API  │    │   Sync Services  │    │   Background    │
│                 │    │                  │    │     Jobs        │
│ • /clients      │◄──►│ • ClientSync     │◄──►│ • ClientSyncJob │
│ • /appointments │    │ • AppointmentSync│    │ • Appointment   │
└─────────────────┘    └──────────────────┘    │   SyncJob       │
                                              └─────────────────┘
                                                       │
                                                       ▼
                                              ┌──────────────────┐
                                              │   Sidekiq-cron   │
                                              │                  │
                                              │ • Every 6 hours  │
                                              │ • Every 2 hours  │
                                              └──────────────────┘
```

## Components

### 1. External API Services

#### Base Service (`app/services/external_api/base_service.rb`)

- **Purpose**: Common HTTP client configuration and error handling
- **Features**:
  - Configurable base URL, API key, timeout, and retry attempts
  - Automatic retry with exponential backoff
  - Comprehensive error handling for different HTTP status codes
  - Logging for debugging and monitoring

#### Client Sync Service (`app/services/external_api/client_sync_service.rb`)

- **Purpose**: Syncs clients from external API
- **Features**:
  - Fetches clients from external endpoint
  - Creates new clients or updates existing ones
  - Tracks sync status and errors
  - Fallback to mock data if external API fails

#### Appointment Sync Service (`app/services/external_api/appointment_sync_service.rb`)

- **Purpose**: Syncs appointments from external API
- **Features**:
  - Fetches appointments from external endpoint
  - Creates new appointments and associated clients
  - Handles various time formats
  - Tracks sync status and errors

### 2. Background Jobs

#### Client Sync Job (`app/jobs/client_sync_job.rb`)

- **Purpose**: Background processing for client syncing
- **Features**:
  - Queued in Sidekiq for asynchronous processing
  - Comprehensive error logging
  - Automatic retry on failure

#### Appointment Sync Job (`app/jobs/appointment_sync_job.rb`)

- **Purpose**: Background processing for appointment syncing
- **Features**:
  - Queued in Sidekiq for asynchronous processing
  - Comprehensive error logging
  - Automatic retry on failure

### 3. Models

Both `Client` and `Appointment` models have been enhanced with sync-related fields:

- **`external_id`**: Unique identifier from external API
- **`last_synced_at`**: Timestamp of last successful sync
- **`sync_status`**: Current sync status (pending, syncing, synced, error)
- **`sync_errors`**: Error messages from failed syncs

### 4. Configuration

#### Sidekiq Configuration (`config/sidekiq.yml`)

- **Concurrency**: 5 workers
- **Queues**: sync (priority 2), default (priority 1), mailers (priority 1)
- **Retry**: 3 attempts with 60-second intervals
- **Redis**: Configurable via environment variables

#### Cron Schedule (`config/initializers/sidekiq.rb`)

- **Client Sync**: Every 6 hours (`0 */6 * * *`)
- **Appointment Sync**: Every 2 hours (`0 */2 * * *`)

## API Endpoints

### Sync Status

```
GET /api/v1/sync/status
```

Returns current sync status for clients and appointments, including counts and scheduled job information.

### Manual Sync Triggers

```
POST /api/v1/sync/clients      # Sync only clients
POST /api/v1/sync/appointments # Sync only appointments
POST /api/v1/sync/all          # Sync both
POST /api/v1/sync/force        # Force immediate sync
```

## Environment Variables

```bash
# External API Configuration
MOCK_API_URL=https://api.example.com
MOCK_API_KEY=your_api_key_here
EXTERNAL_API_TIMEOUT=30
EXTERNAL_API_RETRY_ATTEMPTS=3

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Sidekiq Configuration
SIDEKIQ_CONCURRENCY=5
SIDEKIQ_RETRY_INTERVAL=60
SIDEKIQ_MAX_RETRIES=3
```

## Usage

### Starting the System

1. **Start Redis** (required for Sidekiq):

   ```bash
   redis-server
   ```

2. **Start Sidekiq**:

   ```bash
   bundle exec sidekiq
   ```

3. **Start Rails server**:
   ```bash
   rails server
   ```

### Monitoring

- **Sidekiq Web UI**: Available at `/sidekiq` for job monitoring
- **Logs**: Check `log/sidekiq.log` for detailed job execution logs
- **API Status**: Use `/api/v1/sync/status` to check sync health

### Manual Testing

```bash
# Check sync status
curl http://localhost:3000/api/v1/sync/status

# Trigger client sync
curl -X POST http://localhost:3000/api/v1/sync/clients

# Force immediate sync
curl -X POST http://localhost:3000/api/v1/sync/force
```

## Error Handling

### Retry Mechanism

- **Automatic Retries**: Failed jobs are automatically retried up to 3 times
- **Exponential Backoff**: Retry intervals increase with each attempt
- **Error Logging**: All errors are logged with full context

### Fallback Strategy

- **Mock Data**: If external API fails, system falls back to generated mock data
- **Graceful Degradation**: System continues to function even when external API is unavailable
- **Error Tracking**: Failed syncs are tracked and can be reviewed

## Monitoring and Alerts

### Key Metrics

- **Sync Success Rate**: Percentage of successful syncs
- **Sync Frequency**: Time between successful syncs
- **Error Count**: Number of failed sync attempts
- **Data Freshness**: Age of most recent sync

### Health Checks

- **Database Connectivity**: Ensures database is accessible
- **Redis Connectivity**: Verifies Sidekiq can process jobs
- **External API**: Checks if external API is responding
- **Job Queue**: Monitors job queue length and processing

## Production Considerations

### Scaling

- **Horizontal Scaling**: Multiple Sidekiq workers can be deployed
- **Queue Prioritization**: Sync jobs have higher priority than other background tasks
- **Database Connections**: Monitor connection pool usage

### Security

- **API Key Management**: Use secure environment variable management
- **Network Security**: Ensure secure communication with external API
- **Access Control**: Limit access to sync endpoints in production

### Monitoring

- **Application Performance Monitoring (APM)**: Track job execution times
- **Log Aggregation**: Centralize logs for analysis
- **Alerting**: Set up alerts for sync failures

## Troubleshooting

### Common Issues

1. **Redis Connection Failed**

   - Verify Redis is running
   - Check `REDIS_URL` environment variable

2. **External API Timeout**

   - Increase `EXTERNAL_API_TIMEOUT`
   - Check network connectivity

3. **Job Queue Backlog**

   - Increase Sidekiq concurrency
   - Check for long-running jobs

4. **Database Lock Timeouts**
   - Optimize database queries
   - Check for long-running transactions

### Debug Commands

```bash
# Check Sidekiq status
bundle exec sidekiq -V

# View scheduled jobs
bundle exec rails console
Sidekiq::Cron::Job.all

# Check Redis
redis-cli ping
```

## Future Enhancements

- **Real-time Sync**: WebSocket-based real-time updates
- **Incremental Sync**: Only sync changed records
- **Multi-tenant Support**: Sync data for multiple organizations
- **Advanced Scheduling**: Dynamic cron schedules based on usage patterns
- **Sync Analytics**: Detailed reporting on sync performance and data quality
