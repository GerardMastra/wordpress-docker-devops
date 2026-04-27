# 🐳 WordPress DevOps Project — Terraform, AWS, CI/CD & Observability

## 🚀 Versión v2.0.0 — Infraestructura como código + Pipeline completo end-to-end

Proyecto **DevOps avanzado** que implementa una plataforma completa de:

- Provisionamiento de infraestructura (IaC)
- Build y distribución de aplicación
- Despliegue automatizado
- Backup y restauración
- Monitoreo y alertas

Todo integrado en un pipeline CI/CD real.

---

## 🎯 Objetivo de la versión v2.0.0

> Construir un sistema end-to-end donde:

1. La infraestructura se define como código (Terraform)
2. Se valida automáticamente en CI
3. Se provisiona en AWS (EC2, red, etc.)
4. La app se construye como imagen Docker
5. Se almacenan assets en S3
6. Se despliega automáticamente vía SSH
7. Se ejecuta en contenedores (Docker Compose)
8. Se monitorea en tiempo real
9. Se generan backups automáticos

---

## 🌐 Entorno demo

URL pública:  
http://gerardo-devops-wp.duckdns.org

---

## 🛠 Stack tecnológico

### ☁️ Cloud & IaC

- AWS (EC2, S3, VPC)
- Terraform

### 🐳 Contenedores

- Docker
- Docker Compose

### 🌐 Aplicación

- WordPress (PHP-FPM 8.1)
- Nginx
- MySQL 5.7

### ⚙️ Automatización

- GitHub Actions
- Makefile
- SSH Deployment

### 💾 Storage

- Amazon S3 (assets + backups)

### 📡 Networking

- DuckDNS (DNS dinámico)

### 🔐 Seguridad

- SSH con key
- Variables sensibles en GitHub Secrets

---

## 📊 Observabilidad

- Prometheus → métricas
- Node Exporter → sistema
- MySQL Exporter → base de datos
- Grafana → dashboards + alertas

---

## 🔄 CI/CD Pipeline

```bash
.github/workflows/deploy-pipeline.yml
```
---

### 🧠 Terraform CI

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
```

✔ Valida sintaxis
✔ Detecta errores antes de aplicar
✔ Evita romper infraestructura

---

### 🚀 Terraform CD (solo main)

```bash
terraform apply -auto-approve
```

✔ Provisiona infraestructura automáticamente
✔ Exporta IP pública de EC2 dinámicamente

---

### 🐳 App CI

```bash
aws s3 cp s3://$S3_BUCKET/$S3_PATH ./php/wp-content.tar.gz

docker build -t $DOCKERHUB_USERNAME/wordpress-devops:latest -f ./php/Dockerfile .
docker push $DOCKERHUB_USERNAME/wordpress-devops:latest
```

✔ Descarga assets desde S3
✔ Build de imagen Docker
✔ Push a Docker Hub

---

### 🚀 App CD

```bash
git fetch origin
git reset --hard origin/main

docker pull $DOCKERHUB_USERNAME/wordpress-devops:latest

make down ENV=prod
make up-prod ENV=prod
```

✔ Deploy automático vía SSH
✔ Uso de IP dinámica desde Terraform
✔ Restart limpio de servicios

---

## 💾 Backups automáticos

### 🧪 Testing local

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

### 🚀 Producción

```bash
make up-prod ENV=prod
```

Acceso:

```bash
docker exec -it backup-service sh
```
---
### ⏱ Automatización

- Contenedor dedicado
- Cron jobs
- Subida automática a S3

---

## 📊 Observabilidad (Prometheus + Grafana)

### 📈 Dashboards

- Node Exporter → ID 1860
- MySQL → ID 14057

---

### 🔎 Queries de ejemplo

```bash
node_memory_MemAvailable_bytes
```

```bash
mysql_up
```

---

## 🚨 Alertas

### CPU alta

```bash
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
```

### RAM baja

```bash
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```

### MySQL caído

```bash
mysql_up
```

---

## ⚙️ Entornos

```bash
.env.local
.env.prod

docker-compose.yml
docker-compose.local.yml
docker-compose.prod.yml
```

---

## 🧠 Lo que demuestra este proyecto

- Infraestructura como código (Terraform)
- Pipeline CI/CD real multi-stage
- Deploy automático con dependencia entre jobs
- Integración AWS (EC2 + S3)
- Build y distribución de contenedores
- Manejo de secretos (GitHub Secrets)
- Persistencia desacoplada
- Backups automatizados
- Observabilidad completa
- Alertas proactivas
- Debugging real en producción

---

## 🔥 Cambios clave en v2.0.0

- Integración completa de Terraform en CI/CD
- Pipeline multi-stage (infra + app)
- Deploy automático dependiente de infraestructura
- Uso de IP dinámica exportada desde Terraform
- Integración con S3 en pipeline (assets)
- Separación clara: infra vs aplicación
- Mejora del flujo end-to-end real

---

## 📌 Estado del proyecto

✔ Infraestructura como código
✔ Pipeline CI/CD completo
✔ Provisionamiento automático
✔ Deploy automático
✔ Backups automáticos
✔ Observabilidad completa
✔ Alertas configuradas

**Tag sugerido**: v1.3.0

---

## 👤 Autor

**Gerardo Angel Mastramico**
DevOps Junior

GitHub:
<https://github.com/GerardMastra>
