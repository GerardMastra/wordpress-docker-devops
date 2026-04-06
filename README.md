# 🐳 WordPress Docker CI/CD en AWS – Arquitectura Desacoplada

## 🚀 Versión v1.4.0 – Automatización de Backups con S3

Proyecto **DevOps Junior** que implementa un flujo completo de **CI/CD + automatización de backups** para una aplicación real de **WordPress**, desplegada en **AWS Lightsail**.

El proyecto demuestra prácticas modernas de DevOps:

* Separación entre **imagen, datos y configuración**
* Uso de **Docker como runtime inmutable**
* Persistencia externa mediante **volúmenes y S3**
* Pipeline automatizado con **GitHub Actions**
* Despliegue remoto mediante **SSH**
* **Automatización de backups con contenedor dedicado**
* Infraestructura reproducible

---

## 🎯 Objetivo

Implementar un pipeline **end-to-end** donde:

1. El código se sube a GitHub
2. Se construye una imagen Docker
3. Se publica en Docker Hub
4. Se despliega automáticamente en producción
5. Los datos se restauran dinámicamente desde S3
6. **Se generan backups automáticos de la aplicación y base de datos hacia S3**

---

## ⚙️ Arquitectura

## 🧱 Componentes

* **WordPress (PHP-FPM 8.2 Alpine)**
* **Nginx**
* **MySQL 5.7**
* **Certbot (SSL)**
* **wp-cli**
* **Docker Compose**
* **AWS Lightsail**
* **Amazon S3**
* **Contenedor de Backups (cron + scripts)**

---

## 🧠 Principio clave

> La imagen Docker NO contiene datos.

### Separación de responsabilidades

| Componente       | Responsabilidad         |
| ---------------- | ----------------------- |
| Docker Image     | Lógica de aplicación    |
| S3               | Datos (wp-content + DB) |
| Volumen          | Persistencia            |
| Entrypoint       | Configuración dinámica  |
| Backup Container | Backups automáticos     |

---

## 🔄 Pipeline CI/CD

Archivo:

```yml
.github/workflows/deploy.yml
```

Se ejecuta en cada push a:

* `main`
* `dev`

---

## 🧪 CI – Build & Push

```bash
docker build -t user/wordpress-devops:latest -f php/Dockerfile .
docker push user/wordpress-devops:latest
```

---

## 🚀 CD – Deploy automático

```bash
docker compose pull
make restore-s3 ENV=prod
docker compose up -d
```

---

## 🔐 Configuración dinámica

El archivo `wp-config.php` no se versiona.

Se genera automáticamente desde:

```bash
wordpress/wp-config.php.template
```

Mediante:

```sh
php/docker-entrypoint-custom.sh
```

---

## 🗂 Runtime

```text
/opt/wordpress-runtime/
├── wordpress/
│   └── wp-content/
├── mysql/
└── certbot/
```

---

## ☁️ Restauración desde S3

```bash
make restore-s3 ENV=prod
```

Incluye:

* `wp-content`
* dump de MySQL

---

## 🔥 NUEVO — Sistema de Backups Automáticos

## 🧠 Enfoque

Se implementa un **contenedor independiente de backups**, desacoplado de la aplicación principal.

👉 Esto permite:

* Automatización mediante **cron**
* Independencia del ciclo de vida de WordPress
* Escalabilidad y mantenimiento simple

---

## 📦 Tipos de backup

### 🗄 Base de datos

```bash
mysqldump → .sql
```

---

### 📁 Archivos WordPress

```bash
wp-content → .tar.gz
```

---

## ☁️ Destino

Los backups se almacenan en:

```text
Amazon S3
```

Ejemplo:

```text
s3://<bucket>/backups/
```

---

## 🧪 Testing en entorno local

```bash
make backup-test
make backup-shell
```

Dentro del contenedor:

```bash
/scripts/backup-db.sh
/scripts/backup-files.sh
```

---

## 🚀 Ejecución en producción (manual)

```bash
docker compose \
  --env-file .env.prod \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  up -d --build
```

Acceso:

```bash
docker exec -it backup-service sh
```

Ejecución:

```bash
/scripts/backup-db.sh
/scripts/backup-files.sh
```

---

## ⏱ Automatización

El contenedor utiliza:

```bash
crond
```

Para ejecutar backups automáticamente según la configuración definida.

---

## ⚠️ Consideraciones

* El contenedor debe compartir red con MySQL
* Se debe usar el nombre de servicio (`mysql`) como host
* AWS requiere región válida (ej: `us-east-1`, no `us-east-1a`)
* Los scripts deben manejar errores (`set -e`)

---

## 🧰 Comandos útiles

```bash
make up-prod ENV=prod
make down ENV=prod
make logs ENV=prod
make ps ENV=prod
```

---

## 🔥 Cambios clave en v1.4.0

* Implementación de contenedor de backups independiente
* Automatización con cron
* Integración con Amazon S3
* Scripts de backup desacoplados
* Soporte para testing local de backups
* Mejora en manejo de errores en scripts
* Validación manual en producción sin CI/CD

---

## 🧠 Decisiones técnicas

* Arquitectura desacoplada
* Contenedor dedicado para backups
* Automatización mediante cron
* Persistencia externa en S3
* Testing aislado por entorno
* Estrategia de despliegue segura mediante feature branch

---

## 📌 Estado del proyecto

* ✔ CI/CD completo
* ✔ Deploy automático funcional
* ✔ Arquitectura desacoplada
* ✔ Persistencia externa
* ✔ Backups automáticos funcionando
* ✔ Integración con S3
* ✔ Testing local y validación en producción

---

## 👤 Autor

Gerardo Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
