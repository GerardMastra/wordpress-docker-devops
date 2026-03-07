FROM wordpress:php8.1-fpm

# Instalar extensiones útiles
RUN docker-php-ext-install mysqli

# Healthcheck para WordPress
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD php-fpm -t || exit 1

WORKDIR /var/www/html
