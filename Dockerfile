FROM ruby:3

WORKDIR /wikirate

RUN apt-get update && \
    apt-get install -y imagemagick

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

COPY . .

ENV RAILS_ENV=production

RUN cp -R config/sample/* config && \
    rm -R config/sample

RUN bundle config without test cucumber cypress development profile
RUN bundle install
RUN bundle exec rake card:mod:symlink

CMD bundle exec decko server -b 0.0.0.0
