FROM wordpress:php8.2-fpm-alpine

RUN apk add --no-cache gettext bash

COPY wordpress/wp-config.php.template /usr/src/wordpress/wp-config.php.template
COPY php/docker-entrypoint-custom.sh /usr/local/bin/docker-entrypoint-custom.sh

RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-custom.sh"]
CMD ["php-fpm"]
