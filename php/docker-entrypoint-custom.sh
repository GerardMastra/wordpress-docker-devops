#!/bin/bash
set -e

echo "🔧 Generando wp-config.php desde el template..."
export VARS='$WP_DB_NAME,$WP_DB_USER,$WP_DB_PASSWORD,$WP_DB_HOST,$WP_HOME,$WP_SITEURL'

# El template lo pusimos en /usr/src/wordpress/
envsubst "$VARS" < /usr/src/wordpress/wp-config.php.template > /var/www/html/wp-config.php

chown www-data:www-data /var/www/html/wp-config.php

# Ejecutar el entrypoint oficial de la imagen de WordPress
exec docker-entrypoint.sh "$@"
