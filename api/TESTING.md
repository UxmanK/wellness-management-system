# Testing Guide for Wellness API

This document describes the comprehensive testing setup for the Wellness API backend.

## Overview

The testing infrastructure uses:

- **RSpec** as the testing framework
- **FactoryBot** for test data factories
- **Shoulda Matchers** for validation and association testing
- **Database Cleaner** for test isolation
- **VCR** and **WebMock** for HTTP request mocking
- **Timecop** for time-based testing

## Test Structure

```
spec/
├── factories/           # Test data factories
│   ├── clients.rb
│   └── appointments.rb
├── models/             # Model unit tests
│   ├── client_spec.rb
│   └── appointment_spec.rb
├── controllers/        # Controller tests
│   └── api/v1/
│       ├── clients_controller_spec.rb
│       └── appointments_controller_spec.rb
├── services/          # Service layer tests
│   └── external_api/
│       └── base_service_spec.rb
├── jobs/              # Background job tests
│   └── appointment_sync_job_spec.rb
├── serializers/       # Serializer tests
│   ├── client_serializer_spec.rb
│   └── appointment_serializer_spec.rb
├── support/           # Shared test utilities
│   ├── shared_examples.rb
│   └── test_helper.rb
├── rails_helper.rb    # Rails-specific RSpec configuration
└── spec_helper.rb     # Base RSpec configuration
```

## Running Tests

### Prerequisites

1. Ensure you have the correct Ruby version (3.2.2)
2. Install dependencies: `bundle install`
3. Set up test database: `RAILS_ENV=test bundle exec rails db:create db:migrate`

### Running All Tests

```bash
bundle exec rspec
```

### Running Specific Test Files

```bash
# Run only model tests
bundle exec rspec spec/models/

# Run only controller tests
bundle exec rspec spec/controllers/

# Run a specific test file
bundle exec rspec spec/models/client_spec.rb
```

### Running Tests with Coverage

```bash
# Run tests with detailed output
bundle exec rspec --format documentation

# Run tests with coverage report
COVERAGE=true bundle exec rspec
```

## Test Categories

### 1. Model Tests (`spec/models/`)

Tests for ActiveRecord models including:

- **Validations**: Presence, format, inclusion, uniqueness
- **Associations**: Has many, belongs to relationships
- **Scopes**: Named queries and filters
- **Callbacks**: Before/after hooks
- **Instance methods**: Business logic methods
- **Sync behavior**: External API synchronization logic

**Example:**

```ruby
RSpec.describe Client, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end

  describe "associations" do
    it { should have_many(:appointments).dependent(:destroy) }
  end
end
```

### 2. Controller Tests (`spec/controllers/`)

Tests for API controllers including:

- **HTTP responses**: Status codes, response format
- **Parameter handling**: Valid/invalid parameters
- **Authentication**: Access control (when implemented)
- **Error handling**: Validation errors, not found errors
- **Serialization**: JSON response structure

**Example:**

```ruby
RSpec.describe Api::V1::ClientsController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
```

### 3. Service Tests (`spec/services/`)

Tests for service layer classes including:

- **HTTP client configuration**: Timeout, retry settings
- **Request handling**: GET, POST, PUT, DELETE methods
- **Error handling**: Network errors, API errors
- **Retry logic**: Exponential backoff, retry limits
- **Response parsing**: JSON parsing, error mapping

### 4. Job Tests (`spec/jobs/`)

Tests for background jobs including:

- **Job execution**: Perform method behavior
- **Service integration**: External service calls
- **Error handling**: Exception handling and logging
- **Retry mechanism**: Sidekiq retry behavior
- **Logging**: Info, warning, error logging

### 5. Serializer Tests (`spec/serializers/`)

Tests for JSON serializers including:

- **Attribute inclusion**: Required and optional fields
- **Association handling**: Nested object serialization
- **Data formatting**: Date/time, number formatting
- **Nil value handling**: Graceful handling of null values
- **Performance**: Large dataset serialization

## Test Data Management

### Factories

Factories provide realistic test data with traits for different scenarios:

```ruby
# Basic client
client = create(:client)

# Client with specific sync status
synced_client = create(:client, :synced)

# Client with appointments
client_with_appointments = create(:client, :with_appointments)
```

### Database Cleaner

Tests use database transactions for isolation:

- Each test runs in a transaction
- Tests are automatically rolled back
- No test data persists between tests

## Shared Examples

Common test patterns are extracted into shared examples:

```ruby
# Test syncable behavior for any model
it_behaves_like "syncable model", Client

# Test API controller behavior
it_behaves_like "api controller", Api::V1::ClientsController
```

## Mocking and Stubbing

### External API Calls

External API calls are mocked to avoid network dependencies:

```ruby
let(:api_service) { instance_double(ExternalApi::AppointmentSyncService) }
allow(api_service).to receive(:sync_appointments).and_return(success_result)
```

### Time-based Testing

Time-sensitive tests use Timecop for predictable results:

```ruby
travel_to(7.hours.from_now) do
  expect(client.needs_sync?).to be true
end
```

## Best Practices

### 1. Test Organization

- Group related tests using `describe` blocks
- Use context blocks for different scenarios
- Keep test descriptions clear and descriptive

### 2. Test Data

- Use factories for test data creation
- Create only necessary data for each test
- Use traits for common variations

### 3. Assertions

- Test one behavior per example
- Use descriptive expectation messages
- Test both positive and negative cases

### 4. Performance

- Avoid creating unnecessary objects
- Use `let` for lazy-loaded test data
- Use `build` instead of `create` when possible

## Common Test Patterns

### Testing Validations

```ruby
it "validates email format" do
  valid_emails = ['test@example.com', 'user.name@domain.co.uk']
  invalid_emails = ['invalid-email', '@example.com']

  valid_emails.each { |email| expect(build(:client, email: email)).to be_valid }
  invalid_emails.each { |email| expect(build(:client, email: email)).not_to be_valid }
end
```

### Testing Scopes

```ruby
describe ".synced" do
  it "returns only synced clients" do
    synced_client = create(:client, :synced)
    pending_client = create(:client, :pending_sync)

    expect(Client.synced).to include(synced_client)
    expect(Client.synced).not_to include(pending_client)
  end
end
```

### Testing Callbacks

```ruby
it "sets default sync_status to pending on creation" do
  client = create(:client)
  expect(client.sync_status).to eq('pending')
end
```

### Testing Instance Methods

```ruby
describe "#sync_successful!" do
  it "updates sync status to synced" do
    client.sync_successful!

    expect(client.reload.sync_status).to eq('synced')
    expect(client.last_synced_at).to be_present
    expect(client.sync_errors).to be_nil
  end
end
```

## Troubleshooting

### Common Issues

1. **Database Connection**: Ensure test database exists and is accessible
2. **Gem Dependencies**: Run `bundle install` to install all required gems
3. **Rails Environment**: Set `RAILS_ENV=test` for database operations
4. **Time Zone Issues**: Use `Time.current` instead of `Time.now` in tests

### Debugging Tests

1. **Verbose Output**: Use `--format documentation` for detailed test output
2. **Single Test**: Use `--example "test description"` to run specific tests
3. **Debugging**: Add `binding.pry` or `byebug` for interactive debugging

## Continuous Integration

Tests should be run automatically in CI/CD pipelines:

- Run on every pull request
- Ensure all tests pass before merging
- Generate coverage reports
- Fail builds on test failures

## Coverage Goals

Target test coverage:

- **Models**: 100% (business logic, validations, associations)
- **Controllers**: 95% (all endpoints, error cases)
- **Services**: 90% (core functionality, error handling)
- **Jobs**: 85% (execution flow, error handling)
- **Overall**: 90% minimum coverage

## Future Improvements

1. **Integration Tests**: Add end-to-end API testing
2. **Performance Tests**: Add load and stress testing
3. **Security Tests**: Add authentication and authorization testing
4. **API Documentation**: Generate OpenAPI specs from tests
5. **Contract Testing**: Add consumer-driven contract tests
