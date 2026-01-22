# 🐳 WordPress en Docker desplegado en AWS Lightsail — **Versión 2 (Hardening)**

Proyecto **DevOps Junior** que demuestra el despliegue de una aplicación **WordPress real** utilizando **Docker Compose**, ejecutada en **AWS Lightsail**, con **persistencia de datos**, **restauración desde S3** y **hardening de seguridad aplicado** tanto en **host**, **Docker** como en **WordPress**.

Esta **V2** consolida el proyecto como una **plantilla segura y reproducible**, pensada para entornos pequeños (512MB–1GB) pero alineada con **buenas prácticas profesionales**.

---

## 🎯 Objetivos del proyecto

* Reproducibilidad del entorno
* Separación clara de responsabilidades
* Bootstrap **manual y consciente** (no magia oculta)
* Seguridad integrada desde el código (Security by Design)
* Documentación clara y auditable

🌐 **URL pública (entorno demo):**
[http://gerardo-devops-wp.duckdns.org](http://gerardo-devops-wp.duckdns.org)

> ⚠️ Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias propias del proveedor.

---

## 🛠 Stack tecnológico

* **Cloud:** AWS Lightsail
* **Almacenamiento:** Amazon S3
* **Contenedores:** Docker & Docker Compose (plugin)
* **Web Server:** Nginx
* **Aplicación:** WordPress (PHP-FPM)
* **Base de Datos:** MySQL 5.7
* **CLI:** wp-cli
* **DNS Dinámico:** DuckDNS
* **SO:** Ubuntu Server
* **Automatización ligera:** Makefile
* **Seguridad Host:** UFW, Fail2Ban, SSH Hardening

---

## 🏗 Arquitectura

El proyecto se ejecuta completamente en contenedores Docker:

* `wp-nginx` → servidor web (reverse proxy)
* `wp-php` → PHP-FPM (WordPress)
* `wp-mysql` → base de datos MySQL (persistente)
* `wp-cli` → gestión WordPress vía CLI (perfil tools)
* `phpMyAdmin` → administración DB (solo acceso local)
* `certbot` → emisión y renovación de certificados SSL

### Persistencia

* Volumen MySQL (`./mysql/data`)
* Archivos WordPress (`./wordpress`, incluyendo `wp-content`)

### Bootstrap externo

Los artefactos iniciales se almacenan en **Amazon S3**:

* `wp-content.tar.gz`
* `mysql-bootstrap.tar.gz`

---

## 🔐 Hardening aplicado (Resumen)

### Host / Sistema Operativo

* Actualización completa del sistema (`apt full-upgrade`)
* Docker instalado desde **repositorios oficiales** (no `docker.io`)
* Verificación de firmas GPG
* Firewall UFW por defecto **deny incoming**
* SSH:

  * Puerto no estándar (2222)
  * Login por clave pública
  * Root deshabilitado
* Fail2Ban activo sobre SSH
* Mensaje MOTD de advertencia

### Docker / Infraestructura

* Variables sensibles externalizadas (`.env` + `.gitignore`)
* Límites de memoria por contenedor
* `no-new-privileges:true`
* Contenedores `read_only` cuando aplica
* `tmpfs` para paths temporales
* phpMyAdmin accesible **solo desde localhost**
* Servicios auxiliares bajo `profiles: tools`

### WordPress

* Edición de archivos deshabilitada desde el panel
* Permisos restrictivos en archivos críticos
* Gestión de plugins vía `wp-cli`

---

## 🔐 Hardening Host — Pasos detallados y comandos

> Esta sección **documenta explícitamente** los cambios manuales aplicados en el servidor.
> No se automatizan a propósito para reforzar control, comprensión y trazabilidad.

---

### 🔑 Hardening de SSH

#### 0️⃣ Capa Cloud — AWS Lightsail (obligatorio)

> Este paso se realiza **fuera del servidor**, en la consola de AWS Lightsail.

En **Networking → Firewall**:

* Add rule
* Application: `Custom`
* Protocol: `TCP`
* Port: `2222`

📌 Este paso es **imprescindible**: aunque el servidor esté bien configurado, si el puerto no está abierto en la capa cloud, el acceso SSH fallará.

---

#### 1️⃣ Editar configuración del daemon SSH

```bash
sudo nano /etc/ssh/sshd_config
```

Configuración aplicada (mínimo seguro):

```conf
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
UsePAM yes
```

> ⚠️ Verificar que **no exista otro `Port 22` más abajo** en el archivo.

---

#### 🔒 Hardening adicional de SSH (opcional, recomendado)

Estas directivas **no son estrictamente necesarias para un entorno demo**, pero se documentan como **siguiente escalón de seguridad**:

```conf
MaxAuthTries 3
LoginGraceTime 30
AllowUsers ubuntu
```

🔎 Motivo de su carácter opcional:

* Pueden bloquear accesos legítimos si no se entienden
* `AllowUsers` debe mantenerse sincronizado con usuarios reales
* Se priorizó claridad y accesibilidad en la V2

---

#### 2️⃣ Validar configuración SSH antes de reiniciar

```bash
sudo sshd -t
```

✔️ Sin salida = configuración válida
❌ Con errores = **NO reiniciar SSH**

---

#### 3️⃣ Abrir puerto SSH en UFW (Host)

```bash
sudo ufw allow 2222/tcp
```

---

#### 4️⃣ Reiniciar servicio SSH (sshd)

```bash
sudo systemctl restart ssh
```

---

#### 5️⃣ Probar conexión SSH desde cliente

Desde otra terminal local:

```bash
ssh -i ~/.ssh/LightsailDefaultKey.pem ubuntu@IP_PUBLICA -p 2222
```

> Solo después de confirmar acceso exitoso se puede cerrar el puerto 22.

---

**Checklist de verificación final (post-configuración):**

* 6️⃣ **Validar configuración antes de reiniciar** (`sshd -t`)
* 7️⃣ **Abrir puerto SSH en UFW** (permitir 2222/tcp)
* 8️⃣ **Reiniciar servicio SSH** (`systemctl restart ssh`)
* 9️⃣ **Probar conexión desde otra terminal**

```bash
ssh -i ~/.ssh/LightsailDefaultKey.pem ubuntu@IP_PUBLICA -p 2222
```

> Solo después de confirmar acceso exitoso se puede cerrar el puerto 22.

---

### 🚨 Fail2Ban — Protección contra fuerza bruta

#### 1️⃣ Instalación

```bash
sudo apt update
sudo apt install fail2ban -y
```

---

#### 2️⃣ Crear configuración mínima (`jail.local`)

```bash
sudo nano /etc/fail2ban/jail.local
```

Contenido aplicado:

```ini
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 3
backend  = systemd

[sshd]
enabled  = true
port     = 2222
logpath  = %(sshd_log)s
```

---

#### 3️⃣ Validar sintaxis (paso crítico)

```bash
sudo fail2ban-client -d
```

✔️ Sin errores → continuar
❌ Con errores → corregir antes de seguir

---

#### 4️⃣ Habilitar y arrancar Fail2Ban

```bash
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
```

---

#### 5️⃣ Verificar estado

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

Salida esperada:

```text
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 0
|- Actions
|  |- Currently banned: 0
|  |- Total banned: 0
```

---

#### 6️⃣ Test opcional

* Intentar login SSH erróneo 3 veces
* Ver IP baneada:

```bash
sudo fail2ban-client status sshd
```

---

### 🖥️ Mensaje de bienvenida (MOTD)

```bash
sudo nano /etc/motd
```

Contenido:

```text
###############################################################
#  SISTEMA WP-DOCKER HARDENED — ACCESO RESTRINGIDO             #
#  Todo acceso es monitoreado (Fail2Ban + UFW)                #
#  Puerto SSH: 2222                                           #
###############################################################
```

---

## 🚀 Despliegue paso a paso

### 1️⃣ Acceso a la instancia

```bash
ssh -i ~/.ssh/LightsailDefaultKey.pem ubuntu@IP_PUBLICA -p 2222
```

---

=======
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

>>>>>>> 7fc08ddcf9a914c4d23a142ee86cb5b0831ef492
### 2️⃣ Clonar el repositorio

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

<<<<<<< HEAD
---

### 3️⃣ Bootstrap seguro del servidor
=======
### 3️⃣ Bootstrap del servidor

El proyecto incluye un script de bootstrap para preparar una instancia Ubuntu desde cero.
>>>>>>> 7fc08ddcf9a914c4d23a142ee86cb5b0831ef492

Script `bootstrap-secure.sh`:

<<<<<<< HEAD
* actualiza el sistema
* instala Docker desde repos oficiales
* habilita Docker
* configura UFW
* agrega el usuario al grupo docker

```bash
chmod +x scripts/bootstrap-secure.sh
sudo ./scripts/bootstrap-secure.sh
```

🔁 Cerrar sesión y volver a ingresar.
=======
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
cd ~/wordpress-docker-devops/
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

Ajustar permisos:

```bash
sudo chown -R ubuntu:ubuntu ~/wordpress-docker-devops/wordpress
sudo find ~/wordpress-docker-devops/wordpress -type d -exec chmod 755 {} \;
sudo find ~/wordpress-docker-devops/wordpress -type f -exec chmod 644 {} \;
```

```bash
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/wordpress/wp-content.tar.gz /tmp/
tar -xzf /tmp/wp-content.tar.gz -C /home/ubuntu/wordpress-docker-devops/wordpress/
sudo chown -R 33:33 ~/wordpress-docker-devops/wordpress
```

#### 🗄 Restaurar base de datos MySQL

```bash
sudo chown -R ubuntu:ubuntu mysql
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/mysql/mysql-bootstrap.tar.gz /tmp/
tar -xzf /tmp/mysql-bootstrap.tar.gz -C /home/ubuntu/wordpress-docker-devops/mysql/
sudo chown -R 999:999 mysql/data
```

Reiniciar stack:

```bash
make down
make up
```

Importar base de datos:

```bash
docker exec -i wp-mysql mysql -u root -pchangeme_root wordpress < ~/wordpress-docker-devops/mysql/backups/dump.sql
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
>>>>>>> 7fc08ddcf9a914c4d23a142ee86cb5b0831ef492

Se evita sobre-automatizar en esta etapa para:

<<<<<<< HEAD
### 4️⃣ Configuración inicial

```bash
cp .env.example .env
cp wordpress/wp-config-sample.php wordpress/wp-config.php
```

Editar `.env` con credenciales reales (no se sube al repo).

---

### 5️⃣ Instalación de utilidades

```bash
sudo apt install make -y
```

---

### 6️⃣ SSL y despliegue

```bash
make ssl-init
make ssl-https
make up
```

---

## 🔁 Restauración desde S3 (Bootstrap manual)

### 📦 Restaurar archivos WordPress

```bash
sudo chown -R ubuntu:ubuntu wordpress
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/wordpress/wp-content.tar.gz /tmp/
tar -xzf /tmp/wp-content.tar.gz -C wordpress/
sudo chown -R 33:33 wordpress
```

---

### 🗄 Restaurar base de datos

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

---

## 🧠 Decisiones técnicas

* El **hardening se aplica antes del git push**, no después.
* Se evita sobre-automatizar para facilitar debugging.
* Seguridad integrada desde el diseño.
* Separación clara entre bootstrap, runtime y tooling.

---

## 📌 Estado del proyecto

* ✔ Funcional
* ✔ Documentado
* ✔ Reproducible
* ✔ Hardened
* ✔ Apto para portfolio DevOps Junior

---

## 🔜 Próximas mejoras (Fase 3)

* Backups automáticos y rotación en S3
* CI/CD con GitHub Actions
* Escaneo de imágenes (Trivy)
* Monitoreo con Prometheus & Grafana
* Migración a Terraform

---

## 👤 Autor

**Gerardo Angel Mastramico**
DevOps Junior

GitHub: [https://github.com/GerardMastra](https://github.com/GerardMastra)
=======
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

**Gerardo Angel Mastramico**
DevOps Junior
GitHub: <https://github.com/GerardMastra>

>>>>>>> 7fc08ddcf9a914c4d23a142ee86cb5b0831ef492
