# 🐳 WordPress en Docker desplegado en AWS Lightsail

## Versión v1.2.2 – Environment Decoupling & Security Cleanup

Proyecto **DevOps Junior** que demuestra el despliegue de una aplicación **WordPress real** utilizando **Docker Compose**, ejecutada en AWS Lightsail, con:

- Separación estricta entre **código (repo)** y **datos (runtime)**
- Persistencia fuera del repositorio
- Restauración desde Amazon S3
- Generación segura de configuración sensible
- Automatización operativa mediante Makefile
- Arranque ordenado entre servicios (healthchecks)
- Separación de entornos (`local` y `prod`)

El objetivo no es sobre-automatizar, sino **demostrar criterio, reproducibilidad y buenas prácticas reales de infraestructura**.

---

## 🎯 Objetivo de la versión v1.2.2

> Eliminar dependencias hardcodeadas de infraestructura real y asegurar que el repositorio sea 100% portable.

Esta versión:

- Elimina IP pública hardcodeada del README
- Remueve datos reales de dominio, bucket y email del `.env.example`
- Refuerza separación entre `.env.example`, `.env.local` y `.env.prod`
- Mejora la neutralidad del proyecto para uso público y portfolio

No introduce cambios funcionales respecto a v1.2.1.  
Es una mejora de seguridad documental y portabilidad.

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
- **SSL:** Let’s Encrypt (Certbot)

---

## 🏗️ Estructura actual del repositorio

```text
.
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

- `wp-config.php` no se versiona
- Se genera dinámicamente desde:

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

## 🌍 Despliegue en entorno remoto (prod)

Conectarse previamente al servidor vía SSH.

### 1️⃣ Clonar repositorio en entorno productivo

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

---

### 2️⃣ Configurar entorno productivo

```bash
cp .env.example .env.prod
```

Editar .env.prod con:

- Dominio real
- Bucket S3 real
- Credenciales reales
- Rutas de runtime productivas

---

### 3️⃣ Deploy productivo

```bash
make up-prod ENV=prod
```

- docker-compose.prod.yml
- Variables definidas en `.env.prod`
- Runtime persistente en `/opt/wordpress-runtime`

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

- MySQL con healthcheck activo
- PHP-FPM dependiente de MySQL healthy
- Nginx en modo read-only
- wp-cli bajo profile tools
- Certbot para emisión y renovación SSL

---

## 🧠 Decisiones técnicas clave

- Infraestructura desacoplada del código
- Eliminación de hardcoding sensible
- Separación clara de entornos
- Runtime fuera del repositorio
- Automatización progresiva y controlada

---

## 📌 Estado del proyecto

- ✔ Funcional
- ✔ Portable
- ✔ Seguro a nivel configuración
- ✔ Sin datos reales en el repositorio
- ✔ Reproducible
- ✔ Apto para portfolio DevOps Junior

**Tag sugerido**: v1.2.2

---

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
