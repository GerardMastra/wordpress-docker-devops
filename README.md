# 🐳 WordPress en Docker desplegado en AWS Lightsail

## Versión v1.2.1 – Minor Fixes & Documentation Update

Proyecto **DevOps Junior** que demuestra el despliegue de una aplicación **WordPress real** utilizando **Docker Compose**, ejecutada en **AWS Lightsail**, con:

- Separación estricta entre **código (repo)** y **datos (runtime)**
- Persistencia de datos fuera del repositorio
- Restauración desde **Amazon S3**
- Generación segura de configuración sensible
- Automatización operativa mediante **Makefile**
- Arranque ordenado entre servicios (healthchecks)

El objetivo no es “sobre-automatizar”, sino **mostrar criterio, estabilidad y mentalidad DevOps realista**.

---

## 🎯 Objetivo de la versión v1.2.1

> **Lograr un despliegue completo, estable y reproducible, minimizando errores humanos y evitando versionar secretos.**

Esta versión introduce:

- `make full-deploy` como interfaz única de operación
- Generación dinámica de `wp-config.php` desde plantilla
- Datos persistentes fuera del repositorio
- Dependencias y healthchecks reales entre servicios
- Restauración automática de WordPress y MySQL desde S3

📝 Nota v1.2.1  
Esta versión no introduce cambios funcionales respecto a v1.2.0.
Incluye correcciones menores de documentación y precisión en los pasos de acceso (SSH hardening).

---

## 🌐 Entorno demo

**URL pública:**  
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ El dominio utiliza DNS dinámico (DuckDNS). Pueden existir intermitencias propias del proveedor.

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

## 🏗️ Estructura del proyecto

### 📦 Repositorio (versionado)

```text
repo/
├── docker-compose.yml
├── Makefile
├── README.md
├── .env.example
├── .gitignore
│
├── wordpress/
│   └── wp-config.php.template
│
├── nginx/
├── mysql/
└── scripts/
```

👉 El repositorio no contiene datos persistentes ni secretos.
Solo código, plantillas y definición de infraestructura.

---

## 🧠 Runtime (fuera del repo)

```text
/opt/wordpress-runtime/
├── wordpress/
│   ├── wp-config.php      # generado automáticamente
│   ├── wp-content/
│   └── ...
├── mysql/
└── certbot/
```

👉 Todo lo que vive y cambia en runtime queda fuera del control de versiones.

---

## 🔐 Gestión segura de configuración

- wp-config.php no se versiona
- Se genera dinámicamente desde:
  - wordpress/wp-config.php.template
  - variables definidas en .env

La generación se realiza con:

```bash
make generate-wp-config
```

Esto evita:

- subir credenciales al repo
- errores humanos
- configuraciones inconsistentes entre entornos

---

## 🚀 Despliegue

### 1️⃣ Acceso a la instancia

```bash
ssh -i ~/.ssh/LightsailDefaultKey.pem ubuntu@44.220.98.235 -p 2222
```

---

### 2️⃣ Clonar repositorio

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

---

### 3️⃣ Configuración inicial

```bash
cp .env.example .env
```

Editar .env con valores reales (credenciales, dominio, S3).

---

## ⚙️ Despliegue automatizado (recomendado)

### 🚀 Ejecución completa

```bash
make full-deploy
```

Este comando:

1. Prepara permisos de runtime
2. Genera wp-config.php
3. Levanta el stack Docker
4. Inicializa SSL (HTTP → HTTPS)
5. Restaura WordPress y MySQL desde S3
6. Importa la base de datos
7. Configura WordPress vía wp-cli
8. Valida estado final de los servicios

---

🧰 Comandos principales

```bash
make deploy        # Despliegue base
make full-deploy   # Deploy completo + restauración
make up            # Levanta contenedores
make down          # Detiene el stack
make ps            # Estado y healthchecks
make logs          # Logs en tiempo real
```

---

## 🏗 Arquitectura de servicios

- **MySQL**
  - Persistencia externa
  - Healthcheck activo
- **PHP-FPM**
  - Depende de MySQL healthy
- **Nginx**
  - Read-only
  - Proxy SSL
- **wp-cli**
  - Perfil tools
  - No se levanta por defecto
- **Certbot**
  - Gestión de certificados SSL
  - Renovación automática

---

## 🧠 Decisiones técnicas clave

- Separación repo / runtime
- Automatización progresiva, no mágica
- Makefile como interfaz única
- Configuración sensible fuera del versionado
- Healthchecks para evitar race conditions
- Servicios auxiliares bajo profiles

---

## 📌 Estado del proyecto

- ✔ Funcional
- ✔ Automatizado
- ✔ Seguro a nivel configuración
- ✔ Reproducible
- ✔ Estable en reinicios
- ✔ Apto para portfolio DevOps Junior

**Tag sugerido**: v1.2.1

---

## 🔜 Próximas evoluciones

- Backups automáticos y rotación en S3
- CI/CD con GitHub Actions
- Escaneo de imágenes (Trivy)
- Monitoreo con Prometheus & Grafana
- Infraestructura como código (Terraform)

---

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
