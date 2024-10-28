#!/bin/bash

set -euo pipefail

if [[ $PASSENGER_MEMCACHED == "true" ]]; then
  echo "Enabling embedded Memcached"
  rm -f /etc/service/memcached/down
fi

envsubst < /home/app/wikirate/docker/nginx.conf > /etc/nginx/sites-enabled/nginx.conf

/sbin/my_init
