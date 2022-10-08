ARG NGINX_VERSION=1.23.1
FROM nginx:${NGINX_VERSION}-alpine

WORKDIR /var/www/html

RUN apk add --no-cache bash \
    && (delgroup www-data || true) \
    && adduser -D -H -u 1000 -s /bin/bash www-data \
    && apk del --no-cache bash

COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --chown=www-data . /var/www/html