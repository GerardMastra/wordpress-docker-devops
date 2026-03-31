#!/bin/sh

echo "☁️ Subiendo backups a S3..."

aws s3 cp /backup s3://$S3_BUCKET/backups/ --recursive

echo "✅ Upload completado"
