# 🐳 WordPress DevOps Project — Docker, AWS, CI/CD & Observability

## 🚀 Versión v1.5.1 — Observabilidad completa + MySQL + Alertas

Proyecto **DevOps Junior avanzado** que implementa una plataforma completa de despliegue, backup y monitoreo para una aplicación real de **WordPress**, ejecutándose en **AWS Lightsail**.

---

## 🎯 Objetivo

Construir un sistema completo donde:

1. El código se versiona en GitHub
2. Se construye y publica una imagen Docker
3. Se despliega automáticamente en producción
4. Se restauran datos desde S3
5. Se generan backups automáticos
6. Se monitorea el sistema en tiempo real
7. Se detectan problemas mediante alertas

---

## 🧱 Arquitectura

### Componentes principales

* WordPress (PHP-FPM)
* Nginx
* MySQL
* Certbot (SSL)
* Docker Compose
* AWS Lightsail
* Amazon S3
* Contenedor de Backups (cron + scripts)

---

### 📊 Observabilidad

* Prometheus → métricas
* Node Exporter → sistema
* MySQL Exporter → base de datos
* Grafana → dashboards + alertas

---

## 🔄 CI/CD Pipeline

```bash
.github/workflows/deploy.yml
```

### CI

```bash
docker build -t user/wordpress-devops:latest -f php/Dockerfile .
docker push user/wordpress-devops:latest
```

### CD

```bash
docker compose pull
make restore-s3 ENV=prod
docker compose up -d
```

---

## 💾 Backups automáticos

### 🧪 Testing en entorno local

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

### 🚀 Ejecución en producción

```bash
docker compose \
  --env-file .env.prod \
  -f docker-compose.yml \
  -f docker-compose.prod.yml \
  up -d --build
```

Acceso al contenedor:

```bash
docker exec -it backup-service sh
```

Ejecución manual:

```bash
/scripts/backup-db.sh
/scripts/backup-files.sh
```

---

### ⏱ Automatización

* Contenedor dedicado
* Uso de `cron`
* Backups a Amazon S3

---

## 📊 Observabilidad (Prometheus + Grafana)

### 📈 Dashboards

* Node Exporter → **ID 1860**
* MySQL → **ID 14057**

---

### 🔎 Queries de ejemplo

```promql
node_memory_MemAvailable_bytes
```

```promql
mysql_up
```

---

## 🚨 Alertas

### CPU alta

```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
```

### RAM baja

```promql
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```

### MySQL caído

```promql
mysql_up
```

---

## ⚙️ Entornos

```bash
.env.local
.env.prod
```

```bash
docker-compose.yml
docker-compose.local.yml
docker-compose.prod.yml
```

---

## 🧠 Lo que demuestra este proyecto

* CI/CD real
* Deploy automático
* Manejo de entornos
* Persistencia desacoplada
* Backups automatizados + testing local
* Observabilidad completa
* Alertas proactivas
* Debugging real en producción

---

## 📸 Screenshots

👉 Grafana (Node + MySQL)
👉 Prometheus Targets (UP)
👉 Alertas

---

## 🔥 Cambios clave en v1.5.1

* MySQL Exporter integrado
* Dashboard MySQL funcional (14057)
* Alertas implementadas
* Testing local de backups documentado
* Ejecución manual en producción documentada

---

## 📌 Estado del proyecto

* ✔ CI/CD completo
* ✔ Deploy automático
* ✔ Backups automáticos
* ✔ Testing local
* ✔ Observabilidad completa
* ✔ Dashboards funcionales
* ✔ Alertas configuradas

---

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
Git Hub: <https://github.com/GerardMastra>
