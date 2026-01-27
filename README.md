# 🐳 WordPress en Docker desplegado en AWS Lightsail

## Versión: v1.1.2 – Fix & Integration Stability

Proyecto **DevOps Junior** que demuestra el despliegue de una aplicación **WordPress real** utilizando **Docker Compose**, ejecutada en **AWS Lightsail**, con **persistencia de datos**, **restauración desde S3** y **mejoras de seguridad aplicadas** en el **host**, la **infraestructura Docker** y **WordPress**.

Esta versión es una **evolución directa de la v1.0.1**, orientada a demostrar **conciencia de seguridad en un entorno tipo producción**, sin perder claridad ni simplicidad operativa.

---

## 🎯 Objetivo de la versión v1.1.2

> **Corregir la integración entre servicios y asegurar la consistencia de la configuración inicial.**

Esta versión resuelve errores de la v1.1.1 relacionados con la falta de variables de entorno en el servicio `wp-cli` y la correcta vinculación de constantes en el archivo de configuración de WordPress.

🧠 **Importante:**  
Esta versión **no es obligatoria para presentar el proyecto**, sino una **mejora incremental natural** sobre la v1.0.1

---

## 🌐 Entorno demo

**URL pública:**  
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias propias del proveedor.

---

## 🛠 Stack tecnológico

- **Cloud:** AWS Lightsail  
- **Almacenamiento:** Amazon S3  
- **Contenedores:** Docker & Docker Compose (plugin)  
- **Web Server:** Nginx  
- **Aplicación:** WordPress (PHP-FPM)  
- **Base de Datos:** MySQL 5.7  
- **CLI:** wp-cli  
- **DNS Dinámico:** DuckDNS  
- **SO:** Ubuntu Server  
- **Automatización ligera:** Makefile  
- **Seguridad Host:** UFW, Fail2Ban, SSH Hardening  

---

## 🏗 Arquitectura

El proyecto se ejecuta completamente en contenedores Docker:

- `wp-nginx` → servidor web (reverse proxy)  
- `wp-php` → PHP-FPM (WordPress)  
- `wp-mysql` → base de datos MySQL (persistente)  
- `wp-cli` → gestión WordPress vía CLI  
- `phpMyAdmin` → administración de base de datos (**solo acceso local**)  

### Persistencia

- Datos MySQL: `./mysql/data`  
- Archivos WordPress: `./wordpress` (incluye `wp-content`)  

### Bootstrap externo (S3)

- `wp-content.tar.gz`  
- `mysql-bootstrap.tar.gz`  

---

## 🔐 Hardening aplicado (resumen)

### 🔑 SSH Hardening

- Puerto no estándar: **2222**
- Autenticación **solo por clave pública**
- Login de root deshabilitado

### 🔥 Firewall (UFW)

- Política por defecto: **deny incoming**
- Puertos expuestos:
  - 80 / 443 (HTTP / HTTPS)
  - 2222 (SSH)

### 🚨 Fail2Ban

- Protección activa contra fuerza bruta en SSH
- Baneo automático por intentos fallidos

### 🐳 Docker / Infraestructura

- Variables sensibles externalizadas (`.env`)
- Principio de mínimo privilegio
- phpMyAdmin accesible **solo desde localhost**
- Servicios auxiliares bajo `profiles: tools`
- **Integración WP-CLI:** Se añadió el bloque `environment` al servicio para permitir la gestión de la base de datos desde el contenedor.
- **Configuración Dinámica:** Sincronización de constantes de DB entre Docker y `wp-config.php`.

### 🧩 WordPress

- Edición de archivos deshabilitada (`DISALLOW_FILE_EDIT`)
- Gestión de plugins vía `wp-cli`
- Configuración preparada para proxy reverso
- Limpieza de headers SSL

---

## 🚀 Despliegue (resumen)

### 1️⃣ Acceso a la instancia

```bash
ssh -i ~/.ssh/LightsailDefaultKey.pem ubuntu@IP_PUBLICA -p 2222
```

### 2️⃣ Clonar repositorio

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

### 3️⃣ Bootstrap del servidor (seguro)

```bash
chmod +x scripts/bootstrap-secure.sh
sudo ./scripts/bootstrap-secure.sh
```

### 🔁 Cerrar sesión y volver a ingresar

### 4️⃣ Configuración inicial

```bash
cp .env.example .env
# El archivo ya incluye las constantes vinculadas a las variables de entorno
cp wordpress/wp-config-sample.php wordpress/wp-config.php
```

Editar .env con credenciales reales (no se sube al repo).

### 5️⃣ SSL y despliegue

```bash
make ssl-init
make ssl-https
make up
```

### 🔁 Restauración desde S3 (manual)

### 📦 Archivos WordPress

```bash
sudo chown -R ubuntu:ubuntu wordpress
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/wordpress/wp-content.tar.gz /tmp/
tar -xzf /tmp/wp-content.tar.gz -C wordpress/
sudo chown -R 33:33 wordpress
```

---

## 🗄 Restaurar Base de datos

```bash
sudo chown -R ubuntu:ubuntu mysql
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/mysql/mysql-bootstrap.tar.gz /tmp/
tar -xzf /tmp/mysql-bootstrap.tar.gz -C mysql/
sudo chown -R 999:999 mysql/data
```

```bash
make down
make up
```

```bash
docker exec -i wp-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD wordpress < mysql/backups/dump.sql
```

---

## 🧩 Gestión de WordPress vía wp-cli

```bash
docker-compose run --rm wp-cli wp plugin deactivate --all
```

```bash
docker-compose run --rm wp-cli wp plugin install meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin activate elementor zilom-themer meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin update --all
```

> Se utiliza `docker-compose` explícito para wp-cli por claridad operativa.

---

## 🧰 Makefile

```bash
make up        # Levanta el stack
make down      # Detiene contenedores
make restart   # Reinicia servicios
make logs      # Logs
make ps        # Estado
```

## 🧠 Decisiones técnicas (v1.1.2)

- El hardening se aplica antes del runtime
- Seguridad integrada desde el diseño
- Bootstrap manual para mayor control y trazabilidad
- Automatización completa reservada para fases posteriores
- **Contexto en wp-cli:** Se detectó que el contenedor de CLI fallaba al no tener acceso a las variables de entorno del `docker-compose.yml`. Se corrigió inyectando el bloque `environment`.
- **Consistencia de Configuración:** Se estandarizó el `wp-config-sample.php` para que utilice las variables definidas en el `.env` de forma nativa, evitando errores de conexión manuales.

### 📌 Estado del proyecto

- ✔ **Funcional y Corregido (Hotfix)**
- ✔ Documentado
- ✔ Reproducible
- ✔ Seguridad aplicada

### 🔜 Próxima evolución (v1.2.0)

- Deploy en un solo comando (Full Automation)
- Healthchecks para servicios dependientes (DB readiness)
- Validaciones post-deploy
- Mejor experiencia operativa (DX)
- CI/CD con GitHub Actions

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
