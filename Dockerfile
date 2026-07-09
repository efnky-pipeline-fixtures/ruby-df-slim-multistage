# Multi-stage build on ruby:3.x-slim (Debian glibc).
# Builder installs gems + precompiles assets; runtime is a lean slim image.
FROM ruby:3.3-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
    && bundle install

COPY . .

# Precompile assets with a throwaway secret (Rails 7.1+ SECRET_KEY_BASE_DUMMY).
RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# ---- runtime ----
FROM ruby:3.3-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Neutralise the systemic Rails-prod confound so this test isolates the
# slim/multistage/glibc variable (SSL + secret_key_base handled here, not by komuta).
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=dummy0000000000000000000000000000000000000000000000000000000000000000

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

RUN mkdir -p tmp/pids

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
