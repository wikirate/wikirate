FROM phusion/passenger-full:3.0.7

RUN bash -lc "rvm --default use ruby-3.3.4"

RUN apt-get update && \
    apt-get install -y imagemagick libcurl4-openssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L -O https://github.com/a8m/envsubst/releases/download/v1.4.2/envsubst-Linux-x86_64 && \
    echo "19b99358ec5db9205209072febdcbf5a  envsubst-Linux-x86_64" | md5sum -c - && \
    chmod +x envsubst-Linux-x86_64 && \
    mv envsubst-Linux-x86_64 /usr/local/bin/envsubst

RUN rm -f /etc/service/nginx/down && \
    rm /etc/nginx/sites-enabled/default

USER app

WORKDIR /home/app/decko

COPY --chown=app:app . .

RUN cp -R config/sample/* config && \
    rm -R config/sample

RUN bundle config without test cucumber cypress development profile && \
    bundle install && \
    bundle exec rake card:mod:symlink

USER root

ENV RAILS_ENV=production

CMD ["/bin/bash", "/home/app/decko/docker/entrypoint.sh"]
