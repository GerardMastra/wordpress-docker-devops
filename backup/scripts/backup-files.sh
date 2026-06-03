#!/bin/sh

set -e

DATE=$(date +%Y-%m-%d_%H-%M)

echo "📦 Iniciando backup wp-content..."

# 🔍 VALIDACIÓN: existe wp-content
if [ ! -d /var/www/html/wp-content ]; then
  echo "❌ Error: wp-content no existe"
  exit 1
fi

# 🔍 VALIDACIÓN: no está vacío
if [ -z "$(ls -A /var/www/html/wp-content)" ]; then
  echo "⚠️ wp-content está vacío. No se genera backup."
  exit 0
fi

# 📦 BACKUP
tar -czf /backup/wp-content_"$DATE".tar.gz -C /var/www/html wp-content

# 🔍 VALIDACIÓN: archivo generado
if [ ! -f /backup/wp-content_"$DATE".tar.gz ]; then
  echo "❌ Error: backup no generado"
  exit 1
fi

echo "✅ Backup archivos completado"

# 🔥 CONTROL DE ENTORNO
if [ "$DISABLE_S3" != "true" ]; then
  echo "☁️ Subiendo backups a S3..."

  if /scripts/upload-s3.sh; then
    echo "✅ Upload completado"
    rm -f /backup/*"$DATE"*
    echo "🧹 Backups locales eliminados"
  else
    echo "❌ Error en upload a S3 - NO se eliminan backups locales"
    exit 1
  fi

else
  echo "⚠️ Upload a S3 deshabilitado"
fi
