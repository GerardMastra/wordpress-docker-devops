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

.PHONY: ssl-init ssl-http ssl-https

ssl-http:
	@echo "🌐 Activando Nginx en modo HTTP (bootstrap SSL)"
	cp nginx/default.http.conf nginx/default.conf
	docker-compose up -d nginx

ssl-init: ssl-http
	@echo "🔐 Generando certificado SSL Let's Encrypt"
	docker-compose run --rm certbot certonly \
	  --webroot \
	  --webroot-path=/var/www/certbot \
	  --email tu-email@dominio.com \
	  --agree-tos \
	  --no-eff-email \
	  -d gerardo-devops-wp.duckdns.org

ssl-https:
	@echo "🔒 Activando Nginx en modo HTTPS"
	cp nginx/default.https.conf nginx/default.conf
	docker-compose restart nginx
