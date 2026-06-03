# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v3.0 – Automated Cloud Backup Engine & Disaster Recovery (Hito Único)

Esta versión corona el **Proyecto 3** de la evolución de nuestra infraestructura, enfocándose de manera estricta en la **excelencia operativa, la resiliencia y la continuidad de negocio (Disaster Recovery)** según las buenas prácticas del AWS Well-Architected Framework.

Tras consolidar un pipeline inmutable de CI/CD (v2.1), este hito introduce una capa crítica de protección de datos: un **motor de respaldos cíclicos, automatizados y completamente desacoplados** hacia almacenamiento de objetos en **Amazon S3**. El sistema erradica la dependencia de ejecuciones manuales o scripts acoplados al sistema operativo del host, aislando las tareas de backup dentro de un microservicio dedicado que opera de manera desatendida y segura.

🌐 **URL pública (entorno demo):**
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ *Nota:* Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias operativas propias del proveedor externo.

---

## 🎯 Objetivo de la versión v3.0

> **Garantizar la supervivencia del negocio ante fallos catastróficos mediante la automatización de backups síncronos de la Base de Datos (MySQL) y archivos de aplicación (wp-content), orquestados por tareas cron internas en un contenedor independiente con persistencia directa en AWS S3.**

El diseño se rige bajo el principio de aislamiento de fallos: si la capa web colapsa, el motor de backups permanece intacto, permitiendo un tiempo de recuperación (RTO) y un punto de recuperación (RPO) optimizados para entornos de producción reales.

---

## 🛠️ Stack tecnológico

* **Cloud Infrastructure:** AWS Lightsail (Ubuntu Server)
* **Almacenamiento Seguro (Destino de Backups):** Amazon S3 (Buckets con versionado y políticas de acceso restringido)
* **Orquestación del Ecosistema:** Docker + Docker Compose
* **Servicio de Respaldos:** Contenedor dedicado Alpine Linux (`crond` nativo + AWS CLI)
* **Scripting Core:** Shell Scripting defensivo (Bash avanzado con control de estados)
* **Runtime Stack:** WordPress (PHP-FPM 8.2 Alpine) + Nginx + MySQL 5.7
* **Pipeline Base:** GitHub Actions (Integración y Despliegue Continuo)

---

## 🏗️ Arquitectura de Resiliencia y Desacoplamiento

Para evitar la penalización de recursos y la fatiga de CPU sobre los contenedores que sirven tráfico a los usuarios, el sistema introduce el componente `backup-service`.

```text
  [ wp-mysql ] ──( Red Interna Docker )──> [ backup-service ] ──> [ AWS S3 Bucket ]
  (Base de Datos)                           (Cron + Scripts)         (Almacenamiento Objeto)
```

Tabla de Separación de Responsabilidades en Producción

| Componente | Responsabilidad | Origen / Ubicación |
| :--- | :--- | :--- |
| **Docker Image** | Lógica de la aplicación, binarios del core y dependencias runtime. | Docker Hub (Compilado en CI) |
| **Amazon S3** | Persistencia a largo plazo de Dumps SQL y paquetes binarios `.tar.gz`. | Cloud S3 (Persistencia externa) |
| **backup-service** | Ejecución de tareas programadas y empaquetado de estados en caliente. | Microservicio aislado (Docker Stack) |
| **Volumen Host** | Fuente de verdad local acoplada al tiempo de ejecución de los contenedores. | `/opt/wordpress-runtime/` |

---

## ⚙️ El Motor de Backup: Scripts y Automatización

El corazón del sistema de resiliencia reside en dos scripts optimizados inyectados dentro del volumen del contenedor de backups:

1. `backup-db.sh`: Ejecuta de forma segura un comando `mysqldump` interceptando el motor MySQL a través de la red interna de Docker. Comprime el flujo de datos al vuelo usando `gzip` y le asigna un timestamp único para evitar colisiones.
2. `backup-files.sh`: Realiza un empaquetado comprimido recursivo de la ruta del volumen local (`wp-content`), preservando la integridad de las imágenes, temas y plugins subidos por los usuarios.

### 🛡️ Programación Desatendida (Cron Daemon)

El contenedor de backups mantiene activo el demonio `crond`. De forma declarativa, se le inyecta una tabla de planificación (crontab) que ejecuta los scripts de forma automatizada bajo intervalos definidos en las variables de entorno productivas, realizando el transporte inmediato hacia AWS S3 con la directiva `aws s3 cp`.

---

### 🚀 Guía de Operación y Pruebas de Recuperación

### 🧪 1. Testing de Backups en Entorno Local

El sistema permite simular una ventana de mantenimiento y validar los scripts de respaldo de forma segura en tu máquina de desarrollo antes de subir los cambios:

```bash
cp .env.example .env.local
# Configurar llaves de AWS de testing local
make up-local ENV=local

# Entrar al contenedor de backups y forzar una ejecución manual de validación
docker exec -it backup-service sh
/scripts/backup-db.sh
/scripts/backup-files.sh
```

### 🚨 2. Ejecución Manual de Emergencia en Producción

Si antes de realizar un cambio crítico en caliente o una actualización de plugins necesitás forzar un backup manual directamente en la nube mediante SSH:

```bash
# Invoca de forma directa las tareas del Makefile orientadas al entorno de producción
make backup-prod ENV=prod
```

### 🕒 3. Monitoreo de Tareas Automáticas

Para auditar que el cron está despertando el contenedor de backups correctamente y que las transferencias a S3 no están devolviendo códigos de error:

```bash
make logs ENV=prod | grep backup-service
```

---

## 🧠 Decisiones Técnicas Clave

* **Scripting Defensivo** (`set -e`): Todos los scripts de automatización inician con la directiva `set -e`. Esto asegura que si el comando `mysqldump` falla por falta de conectividad o el comando `aws s3` falla por red, el proceso aborte inmediatamente, evitando la subida de archivos vacíos o corruptos que rompan la estrategia de Disaster Recovery.
* **Principio de Mínimo Privilegio (Hardening de Accesos)**: El contenedor de backups no comparte permisos de root con el host y accede a MySQL utilizando el nombre de servicio interno de Docker (`mysql`), restringiendo la exposición de credenciales lógicas fuera del ecosistema.
* **Región de AWS Estricta**: Se eliminó el uso de zonas de disponibilidad específicas (como `us-east-1a`) en los scripts de configuración del CLI de AWS, estandarizando sobre identificadores de región puros (`us-east-1`) para garantizar la compatibilidad universal del cliente S3.

---

## 📌 Estado Actual de la Infraestructura Global

✔ Pipeline CI/CD robusto con empaquetado inmutable en Docker Hub
✔ Arquitectura desacoplada de código, secretos y almacenamiento
✔ Contenedor independiente de Backups integrado de forma nativa en el Compose
✔ Automatización desatendida mediante Cron funcional en producción
✔ Estrategia defensiva de Disaster Recovery validada hacia Amazon S3
✔ Ecosistema de infraestructura maduro y profesional listo para Portfolio DevOps

**Tag de Git definitivo**: `v3.0`

---

## 👤 Autor

Gerardo Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
