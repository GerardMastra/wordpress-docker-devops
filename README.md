# 🐳 Proyecto DevOps 1 — WordPress + Docker Compose
## WordPress + Nginx + PHP-FPM + MySQL + Docker Compose

Este proyecto implementa un entorno completo y profesional de WordPress usando Docker Compose, con servicios independientes y persistencia asegurada.
El objetivo es demostrar habilidades DevOps usando contenedores, Nginx como reverse proxy, PHP-FPM optimizado, MySQL con backups automatizados y un Makefile al estilo empresa.

Incluye:
- WordPress completamente dockerizado
- Nginx configurado manualmente (`default.conf`)
- PHP-FPM (imagen oficial de WordPress)
- MySQL con volúmenes persistentes
- phpMyAdmin para inspeccionar la base
- Persistencia total del sitio (código + contenido + DB)
- Backups automáticos con fecha
- Restauración parcial del sitio original
- Infraestructura lista para migrar a AWS (Proyecto DevOps 2)

## 🚀 Arquitectura

             ┌────────────┐
             │   NGINX     │
             └─────┬──────┘
                   │
                   ▼
          ┌────────────────┐
          │  PHP-FPM + WP  │
          └───────┬────────┘
                  │
     ┌────────────┴────────────┐
     ▼                           ▼
┌───────────┐             ┌─────────────┐
│   MySQL   │             │ phpMyAdmin  │
└───────────┘             └─────────────┘

## 📦 Estructura del proyecto

```plaintext
proyecto-wordpress/
├── docker-compose.yml
├── docker-compose.override.yml
├── .gitignore
├── Makefile
├── nginx/
│   └── default.conf
├── mysql/
│   ├── data/           # volumen persistente - NO se versiona
│   └── backups/        # backups automáticos
└── wordpress/          # core + wp-content
```

## ⚙️ Comandos principales (Makefile)

Este proyecto incluye un **Makefile profesional** para agilizar tareas DevOps:

| Comando          | Acción                               |
| ---------------- | ------------------------------------ |
| `make up`        | Levanta todo el stack                |
| `make down`      | Apaga los contenedores               |
| `make restart`   | Reinicia todo                        |
| `make logs`      | Muestra logs en tiempo real          |
| `make ps`        | Lista contenedores del proyecto      |
| `make backup-db` | Genera un backup MySQL con timestamp |
| `make shell-wp`  | Entra al contenedor WordPress/PHP    |
| `make shell-db`  | Abre la CLI de MySQL                 |


Ejemplo de backup generado:

```plaintext
mysql/backups/backup_20241230_153045.sql
```

## 🗃️ Backups y Restauración

### Generar un backup MySQL

```bash
make backup-db
```

### Restaurar un backup

Copiar el archivo .sql dentro de mysql/backups/ y ejecutar:

```bash
docker exec -i wp-mysql mysql -u wpuser -pwppass wordpress < mysql/backups/archivo.sql
```

---

🖥️ Accesos

| Servicio   | URL                                                              |
| ---------- | ---------------------------------------------------------------- |
| WordPress  | [http://localhost:8080](http://localhost:8080)                   |
| wp-admin   | [http://localhost:8080/wp-admin](http://localhost:8080/wp-admin) |
| phpMyAdmin | [http://localhost:8081](http://localhost:8081)                   |

---

🔒 .gitignore profesional incluido

Este repositorio no sube nada sensible ni pesado, incluyendo:

```gitignore
/mysql/data
/wordpress/wp-content/uploads
/wordpress/wp-content/cache
/wordpress/wp-content/upgrade
.env
```

---

💾 Volúmenes de Persistencia

| Área                | Ubicación              |
| ------------------- | ---------------------- |
| Código WordPress    | `./wordpress`          |
| Configuración Nginx | `./nginx/default.conf` |
| Base de datos       | `./mysql/data`         |
| Backups             | `./mysql/backups`      |

---

🛠️ Instalación

1. Clonar el repositorio
```bash
git clone https://github.com/TU_USUARIO/wordpress-docker-devops.git
cd wordpress-docker-devops
```
2. Levantar el stack
```bash
make up
```

---

📦 Restauración parcial del sitio (característica destacada)

Este proyecto incluye la capacidad de restaurar solo páginas específicas, URLs y contenido mínimo, sin necesidad de traer todo el sitio completo de producción.

Esto demuestra:
- Manejo experto de base de datos
- Conocimiento de tablas de WordPress
- Restauración quirúrgica de contenido

☁️ Preparado para migración a AWS
Este proyecto sirve como base para el Proyecto DevOps 2, que incluirá:

- S3 (archivos estáticos)
- RDS (MySQL administrado)
- EC2 o ECS (WordPress)
- Load Balancer
- CloudFront
- Terraform como IaC

---

👨‍💻 Autor

Gerardo Mastramico
DevOps Junior — WordPress + Docker + AWS + CI/CD

---
