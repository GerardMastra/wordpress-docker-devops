#!/bin/sh

DATE=$(date +%Y-%m-%d_%H-%M)

echo "📦 Iniciando backup wp-content..."

tar -czf /backup/wp-content_$DATE.tar.gz /var/www/html/wp-content

echo "✅ Backup archivos completado"

# 🔥 CONTROL DE ENTORNO
if [ "$DISABLE_S3" != "true" ]; then
  /scripts/upload-s3.sh
else
  echo "⚠️ Upload a S3 deshabilitado"
fi
