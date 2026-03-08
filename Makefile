# ==============================
# MULTI-ENVIRONMENT CONFIG
# ==============================

ENV ?= local
ENV_FILE := .env.$(ENV)
COMPOSE_FILES := -f docker-compose.yml -f docker-compose.$(ENV).yml

DC := docker compose --env-file $(ENV_FILE) $(COMPOSE_FILES)

-include $(ENV_FILE)
export

# Variables 
GREEN  := $(shell tput -Txterm setaf 2) 
YELLOW := $(shell tput -Txterm setaf 3) 
RESET  := $(shell tput -Txterm sgr0) 

.PHONY: help deploy up down restart logs ps fix-perms ssl-init ssl-http ssl-https restore-s3 db-import

help: ## Muestra esta ayuda 
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' 

# --- SECCIÓN: DESPLIEGUE Y AUTOMATIZACIÓN --- 

deploy: fix-perms generate-wp-config ## Despliegue completo: Valida .env.$(ENV), fija permisos y levanta el stack
	@echo "$(GREEN)🚀 Iniciando despliegue automatizado...$(RESET)"
	@if [ ! -f .env.$(ENV) ]; then echo "$(YELLOW)⚠️ Archivo .env.$(ENV) no encontrado.$(RESET)"; fi
	$(DC) up -d

	@echo "$(GREEN)✅ Stack levantado. Revisa el estado con 'make ps'$(RESET)"

fix-perms: ## Permisos finales para contenedores
	@echo "$(YELLOW)🔒 Aplicando permisos de ejecución Docker...$(RESET)"
	sudo mkdir -p $(RUNTIME_DIR)/mysql/data
	sudo mkdir -p $(RUNTIME_DIR)/mysql/backups
	sudo mkdir -p $(RUNTIME_DIR)/wordpress
	sudo mkdir -p $(RUNTIME_DIR)/certbot/conf
	sudo mkdir -p $(RUNTIME_DIR)/certbot/www
	sudo chown -R 33:33 $(RUNTIME_DIR)/wordpress
	sudo chown -R 999:999 $(RUNTIME_DIR)/mysql/data
	sudo chown -R root:root $(RUNTIME_DIR)/certbot
	@echo "$(GREEN)✔️ Permisos runtime OK.$(RESET)"

setup-wp:
	$(DC) run --rm wp-cli wp theme activate zilom
	$(DC) run --rm wp-cli wp plugin activate zilom-themer elementor meta-box contact-form-7
	@echo "$(YELLOW)🧹 Limpiando caché de Elementor...$(RESET)"
	$(DC) run --rm wp-cli wp elementor flush_css --timeout=60
	$(DC) run --rm wp-cli wp elementor sync_library
	@echo "✅ WordPress configurado y optimizado."

generate-wp-config: ## Genera wp-config.php desde template
	@echo "$(YELLOW)🧩 Generando wp-config.php de forma segura...$(RESET)"
	@# Definimos qué variables queremos que envsubst reemplace
	@export VARS='$$WP_DB_NAME,$$WP_DB_USER,$$WP_DB_PASSWORD,$$WP_DB_HOST,$$WP_HOME,$$WP_SITEURL'; \
	sudo sh -c "envsubst '$$VARS' < wordpress/wp-config.php.template > $(RUNTIME_DIR)/wordpress/wp-config.php"
	sudo chown 33:33 $(RUNTIME_DIR)/wordpress/wp-config.php

up-prod: ## 🚀 EJECUCIÓN TOTAL: Infra, SSL y Restauración de datos
	@echo "$(GREEN)🔥 Iniciando automatización completa V1.2...$(RESET)"
	$(MAKE) deploy
	@echo "$(YELLOW)⏳ Esperando a que los servicios estén Healthy...$(RESET)"
	sleep 10
	$(MAKE) ssl-http
	$(MAKE) ssl-init
	$(MAKE) ssl-https
	$(MAKE) restore-s3
	$(MAKE) db-import
	$(MAKE) setup-wp
	@echo "$(GREEN)✨ ¡Stack desplegado, securizado y restaurado!$(RESET)"
	$(MAKE) ps

up-local: ## 🚀 EJECUCIÓN LOCAL: Infra, Configuración y Restauración de datos
	@grep -q "gerardo-devops-wp.duckdns.org" /etc/hosts || \
		(echo "127.0.0.1 gerardo-devops-wp.duckdns.org" | sudo tee -a /etc/hosts > /dev/null)
	$(MAKE) generate-wp-config
	$(MAKE) ssl-http
	$(MAKE) restore-s3
	$(MAKE) db-import
	$(MAKE) fix-domain
	$(MAKE) setup-wp
	$(MAKE) up
	@echo "$(GREEN)✨ ¡Stack desplegado localmente, securizado y restaurado!$(RESET)"
	$(MAKE) ps

# --- SECCIÓN: COMANDOS DOCKER (Mejorados) ---

up: ## Levanta los contenedores
	$(DC) up -d

down: ## Detiene y elimina los contenedores y limpia hosts
	$(DC) down
	sudo sed -i '/gerardo-devops-wp.duckdns.org/d' /etc/hosts
	@echo "$(YELLOW)🗑️  Servicios detenidos y dominio removido de /etc/hosts$(RESET)"

restart: ## Reinicia servicios
	$(DC) restart

logs: ## Logs en tiempo real
	$(DC) logs -f

ps: ## Estado de contenedores y Healthchecks
	$(DC) ps

# --- SECCIÓN: SSL (Tu lógica original mejorada) --- 

ssl-http: ## Activando Nginx en modo HTTP (bootstrap SSL)
	@echo "$(YELLOW)🌐 Configurando Nginx para validación de Certbot...$(RESET)"
	cp nginx/default.http.conf nginx/default.conf
	$(DC) up -d nginx

ssl-init: ssl-http ## Generando certificado SSL Let's Encrypt
	@echo "$(YELLOW)🔐 Ejecutando Certbot...$(RESET)"
	$(DC) --profile tools run --rm certbot certonly \
		--webroot \
		--webroot-path=/var/www/certbot \
		--email $(SSL_EMAIL) \
		--agree-tos \
		--no-eff-email \
		--non-interactive \
		--expand \
		--keep-until-expiring \
		--cert-name $(DOMAIN_NAME) \
		-d $(DOMAIN_NAME)

ssl-https: ## Activando Nginx en modo HTTPS
	@echo "$(GREEN)🔒 Aplicando configuración HTTPS...$(RESET)"
	cp nginx/default.https.conf nginx/default.conf
	docker compose restart nginx

# --- SECCIÓN: DATOS (S3 y DB) ---

prepare-restore: ## Ajusta permisos antes de restaurar
	@echo "$(YELLOW)🔓 Preparando permisos para restauración...$(RESET)"
	sudo chown -R $(USER):$(USER) \
	  $(RUNTIME_DIR)/wordpress \
	  $(RUNTIME_DIR)/mysql

restore-s3: prepare-restore ## Descarga assets desde S3
	@echo "$(YELLOW)📥 Restaurando desde S3...$(RESET)"

	# WordPress assets
	rm -rf $(RUNTIME_DIR)/wordpress/wp-content
	aws s3 cp s3://$(S3_BUCKET)/$(S3_PATH_WP) /tmp/wp-content.tar.gz
	tar -xzf /tmp/wp-content.tar.gz -C $(RUNTIME_DIR)/wordpress/

	# MySQL dump lógico
	aws s3 cp s3://$(S3_BUCKET)/$(S3_PATH_DB) /tmp/mysql-bootstrap.tar.gz
	tar -xzf /tmp/mysql-bootstrap.tar.gz -C $(RUNTIME_DIR)/mysql/

	$(MAKE) fix-perms
	rm -f /tmp/wp-content.tar.gz /tmp/mysql-bootstrap.tar.gz

fix-domain: ## Reemplaza dominio en base de datos para entorno local
	@echo "$(YELLOW)🔁 Reemplazando dominio en base de datos...$(RESET)"
	$(DC) run --rm wp-cli wp search-replace \
	'https://gerardo-devops-wp.duckdns.org' \
	'http://localhost' \
	--skip-columns=guid
	@echo "$(GREEN)✔️ Dominio actualizado.$(RESET)"

db-import: ## Importa el dump SQL a MySQL
	@echo "Importando base de datos... (esto puede tardar, no canceles)"
	docker exec -i wp-mysql \
	  mysql -u root -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE) \
	  < $(RUNTIME_DIR)/mysql/backups/dump.sql
	@echo "¡Importación finalizada!"

bash-php: ## Accede al contenedor PHP
	docker exec -it wp-php bash
