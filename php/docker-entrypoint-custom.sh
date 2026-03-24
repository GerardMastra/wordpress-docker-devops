#!/bin/sh
set -e

# Generar wp-config.php desde el template
echo "🔧 Generando wp-config.php..."
envsubst '$WP_DB_NAME,$WP_DB_USER,$WP_DB_PASSWORD,$WP_DB_HOST,$WP_HOME,$WP_SITEURL' < /usr/src/wordpress/wp-config.php.template > /var/www/html/wp-config.php

chown www-data:www-data /var/www/html/wp-config.php

# Ejecutar el entrypoint original de la imagen
exec docker-entrypoint.sh "$@"
