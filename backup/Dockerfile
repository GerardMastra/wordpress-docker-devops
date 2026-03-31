FROM alpine:3.18

# Instalar herramientas necesarias
RUN apk add --no-cache \
    bash \
    mysql-client \
    curl \
    aws-cli \
    tar

# Crear carpeta de trabajo
WORKDIR /app

# Copiar scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Copiar cron
COPY crontab /etc/crontabs/root

# Crear carpeta de backups
RUN mkdir -p /backup

# Ejecutar cron en foreground
CMD ["crond", "-f"]
