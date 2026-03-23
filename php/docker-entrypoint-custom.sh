#!/bin/bash
set -e

# Generar wp-config.php desde el template usando las variables de entorno de Docker
echo "🔧 Generando wp-config.php dinámicamente..."
export VARS='$WP_DB_NAME,$WP_DB_USER,$WP_DB_PASSWORD,$WP_DB_HOST,$WP_HOME,$WP_SITEURL'
envsubst "$VARS" < /usr/src/wordpress/wp-config.php.template > /var/www/html/wp-config.php

# Asegurar permisos
chown www-data:www-data /var/www/html/wp-config.php

# Ejecutar el entrypoint original de la imagen oficial de WordPress
exec docker-entrypoint.sh "$@"
