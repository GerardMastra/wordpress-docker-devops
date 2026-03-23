FROM wordpress:php8.2-fpm-alpine

RUN apk add --no-cache gettext bash

# 1. Copiamos wp-content (que ya descargamos y descomprimimos en el paso anterior)
# Ojo: si en el paso anterior hiciste 'cd ./php && tar', la carpeta está dentro de ./php
COPY ./php/wp-content /var/www/html/wp-content

# 2. Copiamos el template desde la carpeta wordpress
COPY ./wordpress/wp-config.php.template /usr/src/wordpress/wp-config.php.template

# 3. Copiamos el script de entrada
COPY ./php/docker-entrypoint-custom.sh /usr/local/bin/docker-entrypoint-custom.sh

# Aseguramos permisos de ejecución
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

# CORRECCIÓN CLAVE: Usar la ruta absoluta en el ENTRYPOINT
ENTRYPOINT ["/usr/local/bin/docker-entrypoint-custom.sh"]
CMD ["php-fpm"]
