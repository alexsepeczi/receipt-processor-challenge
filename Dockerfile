FROM ruby:3.3.6

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs

# Set working directory
WORKDIR /app

# Copy gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the server
CMD ["rails", "server", "-b", "0.0.0.0"]
