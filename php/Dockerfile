FROM wordpress:php8.2-fpm-alpine

RUN apk add --no-cache gettext bash

# Copiamos el contenido de wp-content que GitHub Actions preparará
COPY ./wp-content /var/www/html/wp-content
COPY ./wordpress/wp-config.php.template /usr/src/wordpress/wp-config.php.template
COPY ./php/docker-entrypoint-custom.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh
RUN chown -R www-data:www-data /var/www/html/wp-content

ENTRYPOINT ["docker-entrypoint-custom.sh"]
CMD ["php-fpm"]
