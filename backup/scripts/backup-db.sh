#!/bin/sh

DATE=$(date +%Y-%m-%d_%H-%M)

echo "📦 Iniciando backup DB..."

mysqldump \
  -h mysql \
  -u$MYSQL_USER \
  -p$MYSQL_PASSWORD \
  $MYSQL_DATABASE \
  > /backup/db_$DATE.sql

echo "✅ Backup DB completado"

# 🔥 CONTROL DE ENTORNO
if [ "$DISABLE_S3" != "true" ]; then
  /scripts/upload-s3.sh
else
  echo "⚠️ Upload a S3 deshabilitado"
fi
