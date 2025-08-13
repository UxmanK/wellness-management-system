FROM ruby:3.2.2-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    nodejs \
    npm \
    git \
    libxml2-dev \
    libxslt-dev

# Set working directory
WORKDIR /app

# Install specific bundler version to match lockfile
RUN gem install bundler -v 2.4.10

# Install gems (copy only Gemfile first, then install, then copy lockfile)
COPY Gemfile ./
RUN bundle _2.4.10_ install --jobs 4 --retry 3

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
