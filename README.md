# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v1.2 – Environment Decoupling & Full Automation

Esta versión representa la **fase de madurez absoluta** del Proyecto 1. Tras consolidar la estabilidad (v1.0) y el blindaje perimetral de seguridad (v1.2), el foco de esta evolución se centra en la **abstracción total de la infraestructura, el desacoplamiento de datos dinámicos respecto al código base, el soporte nativo multi-entorno y la automatización completa de la experiencia operativa (DX)**.

El repositorio ha sido completamente sanitizado, eliminando cualquier dependencia hardcodeada de infraestructura real (IPs públicas, dominios o credenciales personales), transformándose en una solución de despliegue 100% portable, segura e ideal para portafolios profesionales de ingeniería DevOps.

🌐 **URL pública (entorno demo):**
<http://gerardo-devops-wp.duckdns.org>

⚠️ *Nota: Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias operativas propias del proveedor externo.*

---

## 🎯 Objetivo de la versión v1.2

> **Separar de forma estricta el código (definición de infraestructura) de los datos (runtime), proveer una interfaz operativa de un solo comando y segmentar la ejecución entre entornos locales y remotos.**

Esta versión erradica los errores humanos en despliegues y las condiciones de carrera entre servicios interdependientes, garantizando un aprovisionamiento limpio, reproducible y modular mediante automatización inteligente con `Makefile` y plantillas de configuración dinámicas.

---

## 🛠️ Stack tecnológico

- **Cloud Infrastructure:** AWS Lightsail (Ubuntu Server)
- **Almacenamiento Objeto:** Amazon S3 (Disaster Recovery & Bootstrap automatizado)]
- **Contenedores y Orquestación:** Docker + Docker Compose (Multi-file overrides)
- **Web Server & Reverse Proxy:** Nginx (Configuraciones en modo Read-Only)
- **Runtime Stack:** WordPress (PHP-FPM 8.1) + MySQL 5.7
- **Administración y Automatización:** wp-cli + Makefile avanzado
- **Seguridad & SSL:** Let’s Encrypt (Certbot) + Healthchecks nativos

---

## 🏗️ Arquitectura de Abstracción: Repo vs. Runtime

El cambio de paradigma fundamental en esta versión es el **aylamiento completo del estado de la aplicación**:

### 📦 1. Repositorio (Código y Definición de Infraestructura)

El repositorio de Git es estrictamente agnóstico a los datos dinámicos. No contiene secretos, certificados, backups ni credenciales reales.

```text
.
├── docker-compose.local.yml     # Definición específica para desarrollo local
├── docker-compose.prod.yml      # Definición específica para entorno productivo
├── Makefile                     # Interfaz de automatización y orquestación macro
├── README.md
├── .env.example                 # Placeholders genéricos y seguros de versionar
├── .env.local                   # Variables locales de desarrollo (Ignorado en Git)
├── .env.prod                    # Variables de infraestructura real (Ignorado en Git)
├── .gitignore
├── mysql/
│   └── .gitkeep                 
├── nginx/
│   ├── default.conf             # Configuración base del Reverse Proxy
│   ├── default.http.conf        # Configuración para validación de Certbot (Puerto 80)
│   └── default.https.conf       # Configuración con terminación SSL activa (Puerto 443)
├── scripts/
│   └── bootstrap-secure.sh      # Script de Hardening y preparación inicial del Host
└── wordpress/
    ├── wp-config.php.template   # Plantilla dinámica de inyección de configuración
    └── mkt/default.example.php  
```

### 🗂️ 2. Runtime (Fuera del Repositorio)

Todo lo que vive, muta o persiste durante el tiempo de ejecución se almacena en una ruta neutra y aislada del host (`/opt/wordpress-runtime/`). Esto previene fugas de información accidental hacia el sistema de control de versiones y simplifica la replicabilidad del entorno.

```Plaintext
/opt/wordpress-runtime/
├── wordpress/
│   ├── wp-config.php            # Generado dinámicamente desde la plantilla del repo
│   ├── wp-content/              # Volumen dinámico inyectado (Temas, plugins, uploads)
│   └── ...
├── mysql/                       # Persistencia de datos reales de la BD
└── certbot/                     # Certificados y llaves criptográficas de Let's Encrypt
```

---

## 🧠 Gestión Segura de Configuración y Multi-entorno

### 🔓 Eliminación de Hardcoding Sensible

El archivo original wp-config.php ya no se versiona. En su lugar, el comando make generate-wp-config utiliza la utilidad del sistema para leer las variables de entorno declaradas en el archivo actual (.env.local o .env.prod) y parsearlas sobre wordpress/wp-config.php.template. Esto garantiza entornos idénticos pero configuraciones parametrizadas.

### 🚥 Orquestación y Healthchecks (Anti Race-Conditions)

Se implementaron políticas de salud nativas para evitar fallos de inicialización en cascada:

- **MySQL** cuenta con un healthcheck activo que valida que el motor esté listo para recibir consultas, no solo que el contenedor esté corriendo.
- **PHP-FPM** posee una política de dependencia estricta vinculada al estado saludable de la base de datos, bloqueando su inicio hasta que el motor esté plenamente operativo, eliminando errores de conexión iniciales.
- **wp-cli y Certbot** se ejecutan bajo perfiles aislados (profiles: tools), invocándose únicamente cuando el ciclo de vida de la automatización lo requiere.

---

## 🚀 Interfaz de Despliegue de un Solo Comando (DX)

La complejidad operativa de descargar artefactos, asignar permisos a nivel de kernel de Linux, inyectar configuraciones e importar bases de datos se ha encapsulado por completo.

### 💻 Despliegue en Entorno Local (Desarrollo)

1. Cloná el repositorio:

```bash
git clone [https://github.com/GerardMastra/wordpress-docker-devops.git](https://github.com/GerardMastra/wordpress-docker-devops.git)
cd wordpress-docker-devops
```

2. Inicializar tu entorno de desarrollo local:

```bash
cp .env.example .env.local
```

(Editar .env.local con tus credenciales de desarrollo.

3. Levantar todo el ecosistema con un comando:

```bash
make up-local ENV=local
```

### 🌍 Despliegue en Entorno Remoto (Producción - AWS Lightsail)

1. Conectate a tu instancia mediante acceso seguro SSH Hardened:

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@your-server-ip -p 2222
```

2. Clonar el repositorio en el servidor y configurá tus variables de producción:

```bash
git clone [https://github.com/GerardMastra/wordpress-docker-devops.git]
cd wordpress-docker-devops
cp .env.example .env.prod
```

(Editar `.env.prod` con el dominio real, bucket de S3 productivo y secretos cifrados).

3. Ejecutar el Despliegue Automatizado Absoluto:

```bash
make up-prod ENV=prod
```

### ¿Qué ejecuta internamente la automatización avanzada (make full-deploy)?

Este macro de automatización ejecuta de forma secuencial y controlada las siguientes tareas:

1. `prepare-runtime-paths`: Prepara de forma segura las estructuras de directorios en `/opt/wordpress-runtime/` asignando permisos de sistema.
2. `generate-wp-config`: Parsea la plantilla inyectando las variables de `.env` correspondientes.
3. `docker-compose up`: Inicializa la infraestructura de red aislada y levanta el stack Docker.
4. `ssl-init / ssl-https`: Automatiza la validación de Certbot ante Let's Encrypt para activar tráfico HTTPS.
5. `restore-s3-bootstrap`: Invoca el CLI de AWS de forma desatendida, descarga los paquetes desde S3, los descomprime sobre la ruta de runtime y reasigna los UIDs Unix correctos (`33:33` para web, `999:999` para MySQL).
6. `db-import`: Espera al healthcheck exitoso de MySQL e inyecta de forma limpia el dump de SQL.
7. `wp-cli-verify`: Ejecuta diagnósticos post-deploy sobre el core de WordPress para certificar que la landing está online y operativa.

---

## 🧰 Caja de Herramientas del Makefile (Uso diario)

La administración diaria de ambos entornos se unifica bajo la misma interfaz semántica utilizando el flag `ENV`:

  ```bash
   make up-local ENV=local     # Inicializa el entorno ágil de desarrollo local
   make up-prod ENV=prod       # Levanta el entorno productivo desacoplado en la nube
   make down ENV=prod          # Detiene los servicios y remueve redes lógicas en el entorno
   make logs ENV=prod          # Inspecciona logs unificados en tiempo real
   make ps ENV=prod            # Muestra los servicios activos, puertos mapeados y estado de healthchecks
  ```

---

## 🧠 Decisiones Técnicas Clave

- **Código Inmutable (Infrastructure as Code Mindset):** El repositorio se comporta como una receta estricta. Cambiar de servidor o recrear la landing page desde cero es una tarea trivial que toma minutos gracias a la separación total del runtime.
- **Automatización Progresiva:** No se recurrió a herramientas ciegas; se utilizó un Makefile modular para mantener el control de granularidad fina sobre cada etapa del flujo, permitiendo realizar debugging de infraestructura de manera limpia y veloz.

---

## 📌 Estado Actual del Proyecto

- ✔ **Infraestructura Portable e agnóstica al entorno.**
- ✔ **Cero secretos o datos sensibles expuestos en el repositorio (Sanitizado**
- ✔ **Ciclo de vida gobernado mediante orquestación y Healthchecks robustos**
- ✔ **Despliegue automatizado funcional de punta a punta**
- ✔ **Apto para portfolio DevOps Junior**

**Tag de Git sugerido:** `v1.2`

---

## 🔜 Próximas Evoluciones (Hacia el Stack DevOps Enterprise)

Habiendo madurado la portabilidad de los contenedores a nivel de host single-instance, el roadmap evolutivo se prepara para dar el salto hacia infraestructuras distribuidas y automatización remota:

- **Infraestructura como Código (IaC):** Migración y aprovisionamiento de la capa cloud global utilizando **Terraform**.
- **CI/CD Pipelines:** Automatización del push de código y despliegue continuo desatendido mediante **GitHub Actions**.
- **Observabilidad Proactiva:** Implementación de recolección de métricas y dashboards de telemetría a través del stack **Prometheus & Grafana**.

---

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
