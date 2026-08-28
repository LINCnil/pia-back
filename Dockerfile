# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development.
# docker build -t app .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name app app

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.8
# FROM dhi.io/ruby:$RUBY_VERSION-dev AS base
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# In case of proxy invoke the composer with: proxy_url=http://yourproxy.org:port docker compose up --build
# If you don'nt have a proxy comment the following lines
ARG proxy_url
ENV HTTP_PROXY=${proxy_url}
ENV HTTPS_PROXY=${proxy_url}
ENV NO_PROXY=localhost,127.0.0.1,.protezionecivile.fvg.it
ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}

# # Source - https://stackoverflow.com/a/78336399
# # Posted by Jose Diaz-Gonzalez
# # Retrieved 2026-02-18, License - CC BY-SA 4.0

# # set the argument default to a dummy value
# ARG SECRET_KEY_BASE=1

# # assign it to an environment variable
# # we can wrap the variable in brackets
# ENV SECRET_KEY_BASE ${SECRET_KEY_BASE}


# Rails app lives here
WORKDIR /rails

# Install base packages
# Replace libpq-dev with sqlite3 if using SQLite, or libmysqlclient-dev if using MySQL
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips libpq-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git pkg-config libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives


# Install JavaScript dependencies and Node.js for asset compilation
#
# Uncomment the following lines if you are using NodeJS need to compile assets
#
# ARG NODE_VERSION=18.12.0
# ARG YARN_VERSION=1.22.19
# ENV PATH=/usr/local/node/bin:$PATH
# RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
#     /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
#     npm install -g yarn@$YARN_VERSION && \
#     npm install -g mjml && \
#     rm -rf /tmp/node-build-master

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
#
# Uncomment the following lines if you are using NodeJS need to compile assets
#
# COPY package.json yarn.lock ./
# RUN --mount=type=cache,id=yarn,target=/rails/.cache/yarn YARN_CACHE_FOLDER=/rails/.cache/yarn \
#     yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
#RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails


# Generate secrets
# RUN mv .env.base .env
RUN secret=$(bin/rails secret) && sed -i "s/{{devise_secret_key}}/$secret/g" .env
RUN secret=$(bin/rails secret) && sed -i "s/{{devise_pepper}}/$secret/g" .env
RUN secret=$(bin/rails secret) && sed -i "s/{{secret_key_base}}/$secret/g" .env
RUN secret=$(bin/rails secret) && sed -i "s/{{rails_master_key}}/$secret/g" .env


# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log tmp
#	chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
# EXPOSE 80
# CMD ["./bin/thrust", "./bin/rails", "server"]
EXPOSE 3000
CMD ["./bin/rails", "server"]
