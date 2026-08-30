#!/bin/bash

set -e

echo "Starting Vtiger CRM 8.4.0..."

if [ ! -f /var/www/html/index.php ]; then
    echo "Initializing Vtiger application files..."

    cp -a /opt/vtiger/. /var/www/html/

    mkdir -p \
        /var/www/html/cache \
        /var/www/html/storage \
        /var/www/html/logs \
        /var/www/html/test

    echo "Vtiger files copied."
else
    echo "Existing Vtiger installation found."
fi

chown -R www-data:www-data /var/www/html

chmod -R 775 \
    /var/www/html/cache \
    /var/www/html/storage \
    /var/www/html/logs \
    /var/www/html/test

mkdir -p /var/www/html/test/logo

echo "Vtiger permissions configured."

exec "$@"
