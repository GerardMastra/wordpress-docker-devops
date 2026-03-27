# 🐳 WordPress Docker CI/CD en AWS – Arquitectura Desacoplada

## 🚀 Versión v1.3.2 – Pipeline CI/CD con Runtime Dinámico

Proyecto **DevOps Junior** que implementa un flujo completo de **Integración Continua y Despliegue Continuo (CI/CD)** para una aplicación real de **WordPress**, desplegada en **AWS Lightsail**.

El proyecto demuestra prácticas modernas de DevOps:

* Separación entre **imagen, datos y configuración**
* Uso de **Docker como runtime inmutable**
* Persistencia externa mediante **volúmenes y S3**
* Pipeline automatizado con **GitHub Actions**
* Despliegue remoto mediante **SSH**
* Infraestructura reproducible

---

## 🎯 Objetivo

Implementar un pipeline **end-to-end** donde:

1. El código se sube a GitHub
2. Se construye una imagen Docker
3. Se publica en Docker Hub
4. Se despliega automáticamente en producción
5. Los datos se restauran dinámicamente desde S3

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

---

## 🧠 Principio clave

> La imagen Docker NO contiene datos.

### Separación de responsabilidades

| Componente   | Responsabilidad         |
| ------------ | ----------------------- |
| Docker Image | Lógica de aplicación    |
| S3           | Datos (wp-content + DB) |
| Volumen      | Persistencia            |
| Entrypoint   | Configuración dinámica  |

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

1. Checkout del repo
2. Login a Docker Hub
3. Build de imagen
4. Tag:

   * `latest`
   * `commit SHA`
5. Push al registry

```bash
docker build -t user/wordpress-devops:latest -f php/Dockerfile .
docker push user/wordpress-devops:latest
```

---

## 🚀 CD – Deploy automático

1. Conexión SSH al servidor
2. Sync del repo
3. Pull de imagen
4. Restauración desde S3
5. Levantamiento del stack

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

Mediante el script:

```sh
php/docker-entrypoint-custom.sh
```

Uso de:

```bash
envsubst
```

---

## 🗂 Runtime

Ubicación en servidor:

```text
/opt/wordpress-runtime/
├── wordpress/
│   └── wp-content/
├── mysql/
└── certbot/
```

---

## ☁️ Restauración desde S3

Los datos no están en el repo.

Se descargan en runtime:

```bash
make restore-s3 ENV=prod
```

Incluye:

* `wp-content`
* dump de MySQL

---

## 🧪 Entorno local

```bash
cp .env.example .env.local
make up-local ENV=local
```

---

## 🌍 Deploy automático

```bash
git push origin main
```

Dispara:

* CI → build + push
* CD → deploy en EC2

---

## 🧰 Comandos útiles

```bash
make up-prod ENV=prod
make down ENV=prod
make logs ENV=prod
make ps ENV=prod
```

---

## 🔥 Cambios clave en v1.3.2

* Eliminación de `wp-content` del build
* Uso exclusivo de S3 para datos
* Volúmenes como fuente de verdad
* Entrypoint dinámico
* Pipeline completamente desacoplado
* Corrección de naming en Docker Hub
* Flujo idempotente

---

## 🧠 Decisiones técnicas

* CI/CD separado correctamente
* Imagen inmutable
* Datos externos (S3)
* Infra reproducible
* Seguridad mediante variables de entorno

---

## 📌 Estado del proyecto

* ✔ CI/CD completo
* ✔ Deploy automático funcional
* ✔ Arquitectura desacoplada
* ✔ Persistencia externa
* ✔ Producción estable

---

## 👤 Autor

Gerardo Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
