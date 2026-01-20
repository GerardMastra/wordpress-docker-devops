# 🐳 WordPress en Docker desplegado en AWS Lightsail

Proyecto DevOps Junior que demuestra el despliegue de una aplicación **WordPress real** utilizando **Docker Compose**, con **persistencia de datos**, **restauración desde S3** y ejecución en **AWS Lightsail**.

El foco del proyecto está en:

- reproducibilidad
- separación de responsabilidades
- operación manual consciente (bootstrap)
- documentación clara

🌐 **URL pública (entorno demo):**  
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias propias del proveedor.

---

## 🛠 Stack tecnológico

- **Cloud:** AWS Lightsail
- **Almacenamiento:** Amazon S3
- **Contenedores:** Docker & Docker Compose
- **Web Server:** Nginx
- **Aplicación:** WordPress (PHP-FPM)
- **Base de Datos:** MySQL
- **CLI:** wp-cli
- **DNS Dinámico:** DuckDNS
- **SO:** Ubuntu Server
- **Automatización ligera:** Makefile

---

## 🏗 Arquitectura

El proyecto se ejecuta completamente en contenedores Docker:

- `wp-nginx` → servidor web
- `wp-php` → PHP-FPM (WordPress)
- `wp-mysql` → base de datos MySQL (persistente)
- `wp-cli` → gestión WordPress vía CLI
- `phpMyAdmin` → administración de base de datos

Persistencia mediante volúmenes Docker para:

- base de datos MySQL
- archivos WordPress (`wp-content`)

Los artefactos de bootstrap (WordPress y dump SQL) se almacenan en **Amazon S3**.

---

## 🚀 Despliegue paso a paso

### 1️⃣ Acceso a la instancia Lightsail

```bash
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1-pd.pem ubuntu@44.220.98.235
```

### 2️⃣ Clonar el repositorio

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

### 3️⃣ Bootstrap del servidor

El proyecto incluye un script de bootstrap para preparar una instancia Ubuntu desde cero.

Este script:

- actualiza el sistema
- instala Docker
- instala Docker Compose
- habilita el servicio Docker

```bash
chmod +x scripts/bootstrap.sh
sudo ./scripts/bootstrap.sh
```

### 4️⃣ Configuración inicial

Copiar archivos base de configuración:

```bash
cp .env.example .env
cp wordpress/wp-config-sample.php wordpress/wp-config.php
```

Agregar el usuario ubuntu al grupo Docker y reconectar:

```bash
sudo usermod -aG docker ubuntu
exit
```

Volver a ingresar por SSH.

### 5️⃣ Instalación de dependencias auxiliares

```bash
sudo apt install make
```

### 6️⃣ Inicialización SSL y despliegue

```bash
make ssl-init
make ssl-https
make up
```

### 🔁 Restauración desde S3 (Bootstrap manual)
#### 📦 Restaurar archivos WordPress

```bash
aws s3 cp \
s3://gerardo-devops-wp-bootstrap/bootstrap/wordpress/wordpress-bootstrap.tar.gz \
/home/ubuntu/wordpress-docker-devops/wordpress/

cd ~/wordpress-docker-devops/wordpress
tar -xzf wordpress-bootstrap.tar.gz
```

Ajustar permisos:

```bash
sudo chown -R ubuntu:ubuntu ~/wordpress-docker-devops/wordpress
sudo find ~/wordpress-docker-devops/wordpress -type d -exec chmod 755 {} \;
sudo find ~/wordpress-docker-devops/wordpress -type f -exec chmod 644 {} \;
```

#### 🗄 Restaurar base de datos MySQL

```bash
mkdir -p ~/wordpress-docker-devops/mysql/backups
aws s3 cp \
s3://gerardo-devops-wp-bootstrap/bootstrap/mysql/dump.sql \
~/wordpress-docker-devops/mysql/backups/dump.sql
```

Reiniciar stack:

```bash
make down
make up
```

Importar base de datos:

```bash
docker exec -i wp-mysql mysql -u root -pchangeme_root wordpress ~/wordpress-docker-devops/mysql/backups/dump.sql
```

Ajustar permisos del volumen MySQL:

```bash
sudo chown -R 999:999 mysql/data
docker restart wp-mysql
```

### 🧩 Gestión de WordPress vía wp-cli

Desactivar plugins:

```bash
docker-compose run --rm wp-cli wp plugin deactivate --all
```

Instalar plugins:

```bash
docker-compose run --rm wp-cli wp plugin install meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin activate elementor zilom-themer meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin update --all

sudo chown -R 33:33 ~/wordpress-docker-devops/wordpress
```

> Nota: se utiliza `docker-compose` explícito para wp-cli por claridad operativa.

### 🧰 Makefile

El proyecto incluye un Makefile para estandarizar operaciones comunes:

```bash
make up        # Levanta el stack
make down      # Detiene los contenedores
make restart   # Reinicia servicios
make logs      # Muestra logs
make ps        # Estado de contenedores
```

### 🧠 Decisiones técnicas

El bootstrap es manual a propósito.

Se evita sobre-automatizar en esta etapa para:

- mantener claridad
- facilitar debugging
- separar bootstrap de runtime
- abordar automatización completa en proyectos posteriores (CI/CD).

### 📌 Estado del proyecto

- ✔ Funcional
- ✔ Documentado
- ✔ Reproducible
- ✔ Apto para portfolio DevOps Junior

### 🔜 Próximas mejoras (fase 2)

- Hardening del host (SSH, firewall)
- Backups automáticos a S3
- CI/CD con GitHub Actions
- Monitoreo con Prometheus & Grafana

## 👤 Autor

**Gerard Mastra**
DevOps Junior
GitHub: <https://github.com/GerardMastra>

