#!/bin/sh

set -e

aws s3 cp /backup s3://$S3_BUCKET/backups/ --recursive
