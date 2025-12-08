PROJECT=proyecto-wordpress

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose down && docker compose up -d

logs:
	docker compose logs -f

ps:
	docker compose ps

backup-db:
	docker exec wp-mysql mysqldump --no-tablespaces -u wpuser -pwppass wordpress > mysql/backups/backup_$$(date +%Y%m%d_%H%M%S).sql

bash-php:
	docker exec -it wp-php bash

bash-nginx:
	docker exec -it wp-nginx bash
