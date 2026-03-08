# 🐳 WordPress en Docker desplegado en AWS Lightsail

## Versión v1.3.0 – CI/CD Automation Pipeline

Proyecto **DevOps Junior** que demuestra el despliegue de una aplicación **WordPress real** utilizando **Docker Compose**, ejecutada en **AWS Lightsail**, con:

- Separación estricta entre **código (repo)** y **datos (runtime)**
- Persistencia fuera del repositorio
- Restauración desde **Amazon S3**
- Generación segura de configuración sensible
- Automatización operativa mediante **Makefile**
- Arranque ordenado entre servicios (**healthchecks**)
- Separación de entornos (`local` y `prod`)
- ***Pipeline CI/CD automatizado para despliegue remoto**

El objetivo no es sobre-automatizar, sino **demostrar criterio, reproducibilidad y buenas prácticas reales de infraestructura y automatización DevOps.**

---

## 🎯 Objetivo de la versión v1.3.0

> Incorporar automatización CI/CD para desplegar el stack automáticamente tras cambios en el repositorio.

Esta versión introduce:

- Pipeline **CI/CD con GitHub Actions**
- Deploy remoto automático vía **SSH**
- Sincronización automática entre repositorio y servidor
- Rebuild del stack Docker tras cambios en el código
- Imagen personalizada de WordPress basada en **PHP-FPM 8.1**

El despliegue ahora puede realizarse automáticamente tras un `push` a las ramas `main` o `dev`.

---

## ⚙️ Pipeline CI/CD

Se implementó un pipeline usando **GitHub Actions.**

Archivo:

`.github/workflows/deploy.yml`

El pipeline se ejecuta cuando hay `push` en:

`main`
`dev`

### Flujo del pipeline

**1.** GitHub detecta un push en el repositorio
**2.** Se ejecuta el workflow CI/CD
**3.** El pipeline abre una conexión SSH al servidor
**4.** El servidor sincroniza el repositorio
**5.** Se recrea el stack Docker

---

### 🔁 Proceso de despliegue automático

El workflow realiza:

```bash
git fetch origin
git reset --hard
git clean -fd
git checkout <branch>
git reset --hard origin/<branch>
```

Luego ejecuta:

```bash
make up-prod ENV=prod
```

Esto:

- reconstruye contenedores
- aplica cambios de configuración
- reinicia el stack

El despliegue es **idempotente y reproducible**.

---

### 🔐 Seguridad del pipeline

El acceso al servidor se realiza mediante:

- clave SSH privada
- puerto SSH personalizado
- secretos almacenados en GitHub

Secrets utilizados:

`EC2_HOST`
`EC2_USER`
`EC2_SSH_KEY`

Estos secretos **no se almacenan en el repositorio.**

---

## 🌐 Entorno demo

**URL pública:**  
<http://gerardo-devops-wp.duckdns.org>

El proyecto está preparado para funcionar con cualquier dominio válido.

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
- **DNS Dinámico:** DuckDNS
- **SO:** Ubuntu Server
- **Automatización:** Makefile
- **CI/CD:** GitHub Actions
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

---

### Configurar entorno productivo

```bash
cp .env.example .env.prod
```

Editar .env.prod con:

- Dominio real
- Bucket S3 real
- Credenciales reales
- Rutas de runtime productivas

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
- **PHP-FPM** dependiente de MySQL healthy
- **Nginx** en modo read-only
- **wp-cli** bajo profile tools
- **Certbot** para emisión y renovación SSL

---

## 🧠 Decisiones técnicas clave

- Infraestructura desacoplada del código
- Eliminación de hardcoding sensible
- Separación clara de entornos
- Runtime fuera del repositorio
- Automatización progresiva y controlada
- Integración de pipeline CI/CD

---

## 📌 Estado del proyecto

- ✔ Funcional
- ✔ Portable
- ✔ CI/CD automatizado
- ✔ Seguro a nivel configuración
- ✔ Sin datos reales en el repositorio
- ✔ Reproducible
- ✔ Apto para portfolio DevOps Junior

**Tag sugerido**: v1.3.0

---

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
