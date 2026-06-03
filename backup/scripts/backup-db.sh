#!/bin/sh

set -e

DATE=$(date +%Y-%m-%d_%H-%M)

echo "📦 Iniciando backup DB..."

mysqldump \
  -h mysql \
  -u "$MYSQL_USER" \
  -p"$MYSQL_PASSWORD" \
  --no-tablespaces \
  "$MYSQL_DATABASE" \
  > /backup/db_"$DATE".sql

echo "✅ Backup DB completado"

# 🔥 CONTROL DE ENTORNO
if [ "$DISABLE_S3" != "true" ]; then
  echo "☁️ Subiendo backups a S3..."

  if /scripts/upload-s3.sh; then
    echo "✅ Upload completado"
#    rm -rf /backup/*
    echo "🧹 Backups locales eliminados"
  else
    echo "❌ Error en upload a S3 - NO se eliminan backups locales"
    exit 1
  fi

else
  echo "⚠️ Upload a S3 deshabilitado"
fi
