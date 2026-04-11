# 🐳 WordPress DevOps Project — Docker, AWS, CI/CD & Observability

## 🚀 Versión v1.5.0 — Observabilidad con Prometheus y Grafana

Proyecto **DevOps Junior avanzado** que implementa una plataforma completa de despliegue, backup y monitoreo para una aplicación real de **WordPress**, ejecutándose en **AWS Lightsail**.

Este proyecto demuestra un enfoque **end-to-end** de DevOps moderno:

* CI/CD automatizado
* Infraestructura reproducible con Docker
* Persistencia desacoplada (S3 + volúmenes)
* Backups automáticos
* **Observabilidad real con métricas y dashboards**

---

## 🎯 Objetivo

Construir un sistema completo donde:

1. El código se versiona en GitHub
2. Se construye y publica una imagen Docker
3. Se despliega automáticamente en producción
4. Se restauran datos desde S3
5. Se generan backups automáticos
6. **Se monitorea el sistema en tiempo real**

---

## 🧱 Arquitectura

### Componentes principales

* **WordPress (PHP-FPM 8.2 Alpine)**
* **Nginx**
* **MySQL 5.7**
* **Certbot (SSL)**
* **Docker Compose**
* **AWS Lightsail**
* **Amazon S3**
* **Contenedor de Backups (cron + scripts)**

### 🔥 Observabilidad (nuevo)

* **Prometheus (recolección de métricas)**
* **Node Exporter (CPU, RAM, sistema)**
* **Grafana (visualización y dashboards)**

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
| Prometheus       | Recolección de métricas |
| Grafana          | Visualización           |

---

## 🔄 CI/CD Pipeline

Archivo:

```bash
.github/workflows/deploy.yml
```

### 🧪 CI – Build & Push

```bash
docker build -t user/wordpress-devops:latest -f php/Dockerfile .
docker push user/wordpress-devops:latest
```

### 🚀 CD – Deploy automático

```bash
docker compose pull
make restore-s3 ENV=prod
docker compose up -d
```

---

## 💾 Backups automáticos

### 🗄 Base de datos

```bash
mysqldump → .sql
```

### 📁 Archivos

```bash
wp-content → .tar.gz
```

### ☁️ Destino

```bash
Amazon S3
```

### ⏱ Automatización

* Contenedor dedicado
* Uso de `cron`
* Scripts desacoplados

---

## 📊 Observabilidad (Prometheus + Grafana)

### 🧠 Métricas recolectadas

* Uso de CPU
* Memoria RAM
* Load average
* Red
* Estado del sistema

### 🔍 Ejemplo de query

```promql
node_memory_MemAvailable_bytes
```

### 📈 Dashboards

Se implementó dashboard oficial:

* **Node Exporter Full (ID: 1860)**

Incluye visualización en tiempo real de:

* CPU
* RAM
* Disco
* Red

---

## 🧪 Validación

* Prometheus accesible en `:9090`
* Grafana accesible en `:3000`
* Targets en estado `UP`
* Métricas disponibles en PromQL
* Dashboards cargando correctamente

---

## 🗂 Runtime

```tree
/opt/wordpress-runtime/
├── wordpress/
│   └── wp-content/
├── mysql/
└── certbot/
```

---

## ⚙️ Entornos

El proyecto soporta:

* **Local**
* **Producción**

Mediante:

```bash
.env.local
.env.prod
```

Y múltiples archivos:

```bash
docker-compose.yml
docker-compose.local.yml
docker-compose.prod.yml
```

---

## 🧠 Lo que demuestra este proyecto

* Manejo de entornos (local/prod)
* Deploy automatizado real
* Persistencia desacoplada
* Backup y recuperación de datos
* Observabilidad y monitoreo
* Debugging en producción (red, puertos, servicios)
* Uso de Docker networking (service discovery)

---

## 📸 Screenshots

👉 Agregar aquí:

* Dashboard de Grafana
* Prometheus targets en UP

---

## 🔥 Cambios clave en v1.5.0

* Implementación de Prometheus
* Integración de Node Exporter
* Implementación de Grafana
* Dashboards en tiempo real
* Observabilidad completa del sistema

---

## 📌 Estado del proyecto

* ✔ CI/CD completo
* ✔ Deploy automático
* ✔ Persistencia desacoplada
* ✔ Backups automáticos
* ✔ Integración con S3
* ✔ Observabilidad implementada
* ✔ Métricas en tiempo real
* ✔ Dashboards funcionales

---

## 👤 Autor

Gerardo Mastramico
DevOps Junior

GitHub: <https://github.com/GerardMastra>
