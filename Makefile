PROJECT=proyecto-wordpress

up:
	docker-compose up -d

down:
	docker-compose down

restart:
	docker-compose down && docker-compose up -d

logs:
	docker-compose logs -f

ps:
	docker-compose ps

backup-db:
	docker exec wp-mysql mysqldump --no-tablespaces -u wpuser -pwppass wordpress > mysql/backups/backup_$$(date +%Y%m%d_%H%>

bash-php:
	docker exec -it wp-php bash

bash-nginx:
	docker exec -it wp-nginx bash
ssl-init:
	@echo "▶️ Inicializando certificados SSL con Let's Encrypt..."
	docker-compose up -d nginx
	docker-compose run --rm certbot certonly \
	  --webroot \
	  --webroot-path=/var/www/certbot \
	  --email tu-email@dominio.com \
	  --agree-tos \
	  --no-eff-email \
	  -d gerardo-devops-wp.duckdns.org
	@echo "✅ Certificado SSL creado correctamente"

