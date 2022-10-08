#!/bin/sh

set -e
role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [ "$env" != "local" ]; then
    echo "Caching configuration..."
    (cd /var/www/html && php artisan storage:link && php artisan clear-compiled && php artisan optimize:clear)
fi

if [ "$role" = "php-fpm" ]; then
    echo "php-fpm..."
    php-fpm

elif [ "$role" = "queue" ]; then
    echo "Running the queue..."
    php /var/www/html/artisan queue:work --tries=3 --delay=10
elif [ "$role" = "scheduler" ]; then
    echo "Running the scheduler..."
    while [ true ]
    do
      php /var/www/html/artisan schedule:run --verbose --no-interaction &
      sleep 60
    done
else
    echo "Could not match the container role \"$role\""
    exit 1
fi
