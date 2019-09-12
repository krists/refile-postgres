FROM ruby:2.6.3

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update -qq \
    && apt-get install -y build-essential libpq-dev postgresql-client-11 postgresql-contrib-11


ARG INSTALL_BUNDLER_VERSION=2.0.2

RUN gem install bundler --version=${INSTALL_BUNDLER_VERSION}

ENV BUNDLER_VERSION=${INSTALL_BUNDLER_VERSION}

ENV APP_PATH=/app

RUN mkdir ${APP_PATH}

WORKDIR ${APP_PATH}

ADD . ${APP_PATH}

CMD bundle check || bundle install; bundle exec rspec spec
