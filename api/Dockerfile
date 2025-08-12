FROM ruby:3.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    nodejs \
    npm \
    git

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
