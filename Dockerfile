FROM ruby:2.4.0-alpine
RUN apk update && apk --update add ruby ruby-irb ruby-json ruby-rake \
    ruby-bigdecimal ruby-io-console libstdc++ tzdata postgresql-client nodejs git && \
    npm install -g yarn

RUN mkdir /app

WORKDIR /app

ADD Gemfile /app/Gemfile

ADD Gemfile.lock /app/Gemfile.lock


RUN apk --update add --virtual build-dependencies build-base ruby-dev openssl-dev \
    postgresql-dev libc-dev linux-headers && \
    gem update --system '2.6.1' && \
    gem install bundler && \
    gem install rails && \
    cd /app && bundle install && \
    apk del build-dependencies

ADD . /app

RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "rails", 's', "-p", "3000", "-b", "0.0.0.0"]

