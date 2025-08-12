#!/bin/bash

# Test runner script for Wellness API
# This script handles Rails compatibility issues and runs tests

echo "🚀 Starting Wellness API Test Suite"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "Gemfile" ]; then
    echo "❌ Error: Please run this script from the api directory"
    exit 1
fi

# Check Ruby version
echo "🔍 Checking Ruby version..."
RUBY_VERSION=$(ruby -v | cut -d' ' -f2)
echo "Current Ruby version: $RUBY_VERSION"

# Check if required gems are installed
echo "🔍 Checking gem dependencies..."
if ! bundle check > /dev/null 2>&1; then
    echo "📦 Installing gem dependencies..."
    bundle install
fi

# Try to create test database
echo "🗄️  Setting up test database..."
if RAILS_ENV=test bundle exec rails db:create > /dev/null 2>&1; then
    echo "✅ Test database created successfully"
    
    if RAILS_ENV=test bundle exec rails db:migrate > /dev/null 2>&1; then
        echo "✅ Test database migrated successfully"
    else
        echo "⚠️  Warning: Could not migrate test database"
    fi
else
    echo "⚠️  Warning: Could not create test database"
fi

# Check if RSpec is available
echo "🔍 Checking RSpec availability..."
if bundle exec rspec --version > /dev/null 2>&1; then
    echo "✅ RSpec is available"
    
    # Count test files
    TEST_COUNT=$(find spec -name "*_spec.rb" | wc -l)
    echo "📊 Found $TEST_COUNT test files"
    
    # Run tests
    echo "🧪 Running test suite..."
    echo "=================================="
    
    if bundle exec rspec --format progress; then
        echo "=================================="
        echo "✅ All tests passed!"
        exit 0
    else
        echo "=================================="
        echo "❌ Some tests failed!"
        exit 1
    fi
else
    echo "❌ RSpec is not available"
    echo "💡 Try running: bundle install"
    exit 1
fi
