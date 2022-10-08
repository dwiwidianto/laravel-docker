ARG COMPOSER_VERSION=2.4.2
ARG PHP_VERSION=7.4

# Stage 1 Composer
FROM composer:${COMPOSER_VERSION} AS composer-build

WORKDIR /var/www/html
RUN install-php-extensions gd

COPY database database
COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install --prefer-dist --no-scripts --no-autoloader

# Stage 2 PHP
FROM php:${PHP_VERSION}-fpm-alpine

WORKDIR /var/www/html/
RUN apk add --no-cache	libzip-dev unzip libpng-dev 

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions gd xdebug zip opcache pdo pdo_mysql pcntl redis 

COPY ./docker/php/opcache.ini $PHP_INI_DIR/conf.d/
COPY ./docker/php/php.ini /usr/local/etc/php/conf.d/local.ini

COPY --from=composer:${COMPOSER_VERSION} /usr/bin/composer /usr/bin/composer
COPY --chown=www-data --from=composer-build /var/www/html/vendor/ /var/www/html/vendor/
COPY --chown=www-data . /var/www/html

COPY ./docker/scripts/entrypoint.sh /

RUN composer dump -o \
    && composer check-platform-reqs \
    && rm -rf /usr/bin/composer 

ENTRYPOINT ["sh", "/entrypoint.sh"]