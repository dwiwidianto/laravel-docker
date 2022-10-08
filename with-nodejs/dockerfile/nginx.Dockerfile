ARG NODE_VERSION=16.17.1
ARG NGINX_VERSION=1.23.1

# Stage 1 Node
FROM node:${NODE_VERSION}-alpine AS npm-build

WORKDIR /var/www/html
COPY package.json package-lock.json webpack.mix.js /var/www/html
COPY resource /var/www/html/resource/
COPY public /var/www/public/

RUN npm install
RUN npm run dev

# Stage 2 Nginx
FROM nginx:${NGINX_VERSION}-alpine

WORKDIR /var/www/html
RUN apk add --no-cache bash \
    && (delgroup www-data || true) \
    && adduser -D -H -u 1000 -s /bin/bash www-data \
    && apk del --no-cache bash

COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --chown=www-data --from=npm-build /var/www/html/public /var/www/html/public
COPY --chown=www-data . /var/www/html