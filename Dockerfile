FROM ruby:2.3.0

ENV APP_PATH=/app BUNDLE_JOBS=4 BUNDLE_RETRY=3 BUNDLE_PATH=/gems

RUN mkdir ${APP_PATH}
WORKDIR ${APP_PATH}

ADD . ${APP_PATH}

CMD bundle check || bundle install; bundle exec rspec spec
