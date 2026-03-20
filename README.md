# 🐳 WordPress en Docker desplegado en AWS Lightsail

## Versión v1.3.1 – Full CI/CD Pipeline (Build + Push + Deploy)

Proyecto **DevOps Junior** que demuestra el despliegue de una aplicación **WordPress real** utilizando **Docker Compose**, ejecutada en **AWS Lightsail**, con:

- Separación estricta entre **código (repo)** y **datos (runtime)**
- Persistencia fuera del repositorio
- Restauración desde **Amazon S3**
- Generación segura de configuración sensible
- Automatización operativa mediante **Makefile**
- Arranque ordenado entre servicios (**healthchecks**)
- Separación de entornos (`local` y `prod`)
- ***Pipeline CI/CD completo con build, push y deploy automático**

El objetivo es demostrar, sino **flujo DevOps end-to-end**, desde el código hasta producción.

---

## 🎯 Objetivo de la versión v1.3.1

> Implementar un pipeline CI/CD completo que construya la imagen Docker, la publique en Docker Hub y despliegue automáticamente en el servidor.

Esta versión introduce:

- Etapa **CI**: build y push de imagen Docker
- Publicación en Docker Hub
- Versionado de imagen (`latest` + commit SHA)
- Etapa **CD**: deploy automático vía SSH
- Eliminación del build en servidor (principio de inmutabilidad)

---

## ⚙️ Pipeline CI/CD

Se implementó un pipeline con **GitHub Actions.**

Archivo:

`.github/workflows/deploy.yml`

El pipeline se ejecuta en cada `push` a:

- `main`
- `dev`

---

### 🔄 Flujo completo del pipeline

#### 🧪 CI - Build & Push

**1.** Checkout del repositorio
**2.** Login a Docker Hub
**3.** Build de imagen desde `./php`
**4.** Tag de imagen:
    - `latest`
    - `${commit_sha}`
**5.** Push a Docker Hub

Ejemplo:

```bash
docker build -t user/wordpress-devops:latest ./php
docker push user/wordpress-devops:latest
```

---

#### 🚀 CD - Deploy automático

**1.** Conexión SSH al servidor
**2.** Sincronización del repo
**3.** Descarga de la nueva imagen

```bash
docker pull user/wordpress-devops:latest
```

**4.** Recreación del stack:

```bash
make down ENV=prod
make up-prod ENV=prod
```

---

### 🐳 Cambio clave de arquitectura

Antes (v1.3.0):

```yaml
php:
  build: ./php
  image: user/wordpress-devops:latest
```

Ahora (v1.3.1):

```yaml
php:
  image: user/wordpress-devops:latest
```

#### 🧠 ¿Por qué es importante este cambio?

Se elimina el build en producción.

Esto permite:

- Entornos inmutables
- Deploys reproducibles
- Separación real entre CI y CD
- Mejor práctica DevOps

El servidor ahora **solo ejecuta imágenes**, no las construye.

---

### 🔐 Seguridad del pipeline

Se utilizan secretos de GitHub:

`DOCKERHUB_USERNAME`
`DOCKERHUB_TOKEN`
`EC2_HOST`
`EC2_USER`
`EC2_SSH_KEY`

Estos valores:

- no están en el repositorio
- se gestionan de forma segura en GitHub

---

## 🌐 Entorno demo

**URL pública:**  
<http://gerardo-devops-wp.duckdns.org>

Ejemplo de acceso SSH seguro:

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@your-server-ip -p 2222
```

---

## 🛠 Stack tecnológico

- **Cloud:** AWS Lightsail
- **Almacenamiento:** Amazon S3
- **Contenedores:** Docker + Docker Compose
- **Web Server:** Nginx
- **Aplicación:** WordPress (PHP-FPM 8.1)
- **Base de Datos:** MySQL 5.7
- **CLI:** wp-cli
- **CI/CD:** GitHub Actions
- **Registry:** Docker Hub
- **DNS Dinámico:** DuckDNS
- **SO:** Ubuntu Server
- **Automatización:** Makefile
- **SSL:** Let’s Encrypt (Certbot)

---

## 🏗️ Estructura actual del repositorio

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── docker-compose.local.yml
├── docker-compose.prod.yml
├── Makefile
├── README.md
├── .env.example
├── .env.local
├── .env.prod
├── .gitignore
│
├── mysql/
│   └── .gitkeep
│
├── nginx/
│   ├── default.conf
│   ├── default.http.conf
│   └── default.https.conf
│
├── php/
│   └── Dockerfile
│
├── scripts/
│   └── bootstrap-secure.sh
│
└── wordpress/
    ├── wp-config.php.template
    └── mkt/default.example.php
```

El repositorio contiene únicamente:

- Código
- Plantillas
- Definición de infraestructura
- Scripts de bootstrap
- Configuración CI/CD

No contiene:

- Datos persistentes
- Certificados
- Backups
- Credenciales reales

---

## 🧠 Separación de entornos

`.env.example`

Contiene únicamente placeholders genéricos:

```bash
MYSQL_ROOT_PASSWORD=change_me_root
DOMAIN_NAME=example.local
S3_BUCKET=your-bucket-name
```

Este archivo es seguro para versionar.

---

`.env.local` y `.env.prod`

Contienen valores reales específicos de infraestructura.

Estos archivos:

- No deben compartirse públicamente
- No deben contener secretos en repositorios públicos
- Son específicos de cada entorno

---

## 🗂 Runtime (fuera del repositorio)

El runtime vive fuera del repo:

```bash
/opt/wordpress-runtime/
├── wordpress/
│   ├── wp-config.php
│   ├── wp-content/
│   └── ...
├── mysql/
└── certbot/
```

Esto permite:

- Separar infraestructura de datos
- Evitar subir secretos
- Reproducir el entorno fácilmente

---

## 🔐 Gestión segura de configuración

`wp-config.php` no se versiona

Se genera dinámicamente desde:

```bash
wordpress/wp-config.php.template
```

usando variables del entorno (.env.local o .env.prod)

Generación:

```bash
make generate-wp-config
```

---

## 🚀 Despliegue en entorno local

### 1️⃣ Clonar repositorio en entorno local

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

---

### 2️⃣ Configurar entorno local

```bash
cp .env.example .env.local
```

Editar .env.local con valores reales.

---

### 3️⃣ Deploy local

```bash
make up-local ENV=local
```

Este comando:

- Prepara permisos
- Genera wp-config.php
- Levanta contenedores
- Configura SSL
- Restaura datos desde S3
- Importa base de datos
- Configura WordPress vía wp-cli

---

## 🌍 Despliegue automático (CI/CD)

Ya no es necesario ejecutar comandos manuales.

Ahora:

```bash
git push origin main
```

o

```bash
git push origin dev
```

➡️ dispara automáticamente:

- build de imagen
- push a Docker Hub
- deploy en servidor

---

### Despliegue

Cuando se realiza un `push` al repositorio:

   `git push origin main`

o

   `git push origin dev`

el pipeline ejecuta automáticamente:

- sincronización del repositorio
- reconstrucción del stack
- redeploy del sistema

---

## 🧰 Comandos útiles

```bash
make up-local ENV=local
make up-prod ENV=prod
make down ENV=local         # o ENV=prod
make ps ENV=local           # o ENV=prod
make logs ENV=local         # o ENV=prod
```

---

## 🏗 Arquitectura de servicios

- **MySQL** con healthcheck activo
- **PHP-FPM** desacoplado (imagen remota)
- **Nginx** en modo read-only
- **wp-cli** bajo profile tools
- **Certbot** para emisión y renovación SSL

---

## 🧠 Decisiones técnicas clave

- Separación CI / CD
- Eliminación de build en producción
- Uso de registry (Docker Hub)
- Versionado de imágenes
- Infraestructura desacoplada
- Automatización end-to-end

---

## 📌 Estado del proyecto

- ✔ Funcional
- ✔ Portable
- ✔ CI/CD completo
- ✔ Deploy automático
- ✔ Imagen versionada
- ✔ Seguro a nivel configuración
- ✔ Sin datos reales en el repositorio
- ✔ Reproducible

**Tag sugerido**: `v1.3.1`

---

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
