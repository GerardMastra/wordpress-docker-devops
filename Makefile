-include .env
export

RUNTIME_DIR := /opt/wordpress-runtime

# Variables 
GREEN  := $(shell tput -Txterm setaf 2) 
YELLOW := $(shell tput -Txterm setaf 3) 
RESET  := $(shell tput -Txterm sgr0) 

.PHONY: help deploy up down restart logs ps fix-perms ssl-init ssl-http ssl-https restore-s3 db-import

help: ## Muestra esta ayuda 
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' 

# --- SECCIÓN: DESPLIEGUE Y AUTOMATIZACIÓN --- 

deploy: fix-perms generate-wp-config ## Despliegue completo: Valida .env, fija permisos y levanta el stack
	@echo "$(GREEN)🚀 Iniciando despliegue automatizado...$(RESET)"
	@if [ ! -f .env ]; then echo "$(YELLOW)⚠️ Archivo .env no encontrado. Creando desde .env.example...$(RESET)"; cp .env.example .env; fi
	docker compose up -d
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

setup-wp: ## Activa tema, plugins y limpia caché
	docker compose run --rm wp-cli wp theme activate zilom
	docker compose run --rm wp-cli wp plugin activate zilom-themer elementor meta-box contact-form-7
	@echo "$(YELLOW)🧹 Limpiando caché de Elementor...$(RESET)"
	docker compose run --rm wp-cli wp elementor flush_css --timeout=60
	docker compose run --rm wp-cli wp elementor sync_library
	@echo "✅ WordPress configurado y optimizado."

generate-wp-config:
	@echo "$(YELLOW)🧩 Generando wp-config.php de forma segura...$(RESET)"
	@# Definimos qué variables queremos que envsubst reemplace
	@export VARS='$$WP_DB_NAME,$$WP_DB_USER,$$WP_DB_PASSWORD,$$WP_DB_HOST,$$WP_HOME,$$WP_SITEURL'; \
	envsubst "$$VARS" < wordpress/wp-config.php.template | sudo tee $(RUNTIME_DIR)/wordpress/wp-config.php > /dev/null
	sudo chown 33:33 $(RUNTIME_DIR)/wordpress/wp-config.php

full-deploy: ## 🚀 EJECUCIÓN TOTAL: Infra, SSL y Restauración de datos
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

# --- SECCIÓN: COMANDOS DOCKER (Mejorados) ---

up: ## Levanta los contenedores
	docker compose up -d

down: ## Detiene y elimina los contenedores
	docker compose down

restart: ## Reinicia servicios
	docker compose restart

logs: ## Logs en tiempo real
	docker compose logs -f

ps: ## Estado de contenedores y Healthchecks
	docker compose ps

# --- SECCIÓN: SSL (Tu lógica original mejorada) --- 

ssl-http: ## Activando Nginx en modo HTTP (bootstrap SSL)
	@echo "$(YELLOW)🌐 Configurando Nginx para validación de Certbot...$(RESET)"
	cp nginx/default.http.conf nginx/default.conf
	docker compose up -d nginx

ssl-init: ssl-http ## Generando certificado SSL Let's Encrypt
	@echo "$(YELLOW)🔐 Ejecutando Certbot...$(RESET)"
	docker compose run --rm certbot certonly \
	--webroot \
	--webroot-path=/var/www/certbot \
	--email $(SSL_EMAIL) \
	--agree-tos \
	--no-eff-email \
	-d $(DOMAIN_NAME)

ssl-https: ## Activando Nginx en modo HTTPS
	@echo "$(GREEN)🔒 Aplicando configuración HTTPS...$(RESET)"
	cp nginx/default.https.conf nginx/default.conf
	docker compose restart nginx

# --- SECCIÓN: DATOS (S3 y DB) ---

prepare-restore:
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

db-import: ## Importa el dump SQL a MySQL
	@echo "Importando base de datos... (esto puede tardar, no canceles)"
	docker exec -i wp-mysql \
	  mysql -u root -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE) \
	  < $(RUNTIME_DIR)/mysql/backups/dump.sql
	@echo "¡Importación finalizada!"

bash-php:
	docker exec -it wp-php bash
