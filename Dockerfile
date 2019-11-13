FROM ruby:2.6.5-stretch

# Set local timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install your app's runtime dependencies in the container
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /pia-back
WORKDIR /pia-back
COPY Gemfile /pia-back/Gemfile
COPY Gemfile.lock /pia-back/Gemfile.lock

# RUN gem install bundler
RUN gem install bundler
RUN bundle install

COPY . /pia-back
