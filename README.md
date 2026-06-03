# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v1.1 – Security, Hardening & Integration Stability

Esta versión representa una evolución directa, madura y estructurada sobre la línea base funcional (v1.0). El foco del proyecto cambia de "hacer que el sistema funcione" a **proteger los activos del sistema, reducir la superficie de ataque (Hardening) y garantizar la estabilidad de la integración** en un entorno cloud productivo con recursos restringidos (AWS Lightsail de 512MB–1GB RAM).

El proyecto demuestra la aplicación de prácticas esenciales de **DevSecOps** distribuidas en tres capas críticas: el Sistema Operativo del Host, la orquestación de contenedores en Docker y la configuración interna de la aplicación (WordPress).

🌐 **URL pública (entorno demo):**
http://gerardo-devops-wp.duckdns.org

⚠️ *Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias propias del proveedor externo.*

---

## 🎯 Objetivo de la versión v1.1

> **Garantizar el blindaje perimetral del entorno, aplicar el principio de mínimo privilegio y resolver la consistencia en la inyección de variables de entorno entre servicios interdependientes.**

Esta versión introduce la filosofía de **Shift-Left Security**, aplicando auditoría y sanitización antes de la ejecución del runtime. Además, actúa como un hito de estabilización (*Hotfix*) que corrige la pérdida de contexto de las variables de entorno dentro de las utilidades de CLI de la infraestructura.

---

## 🛠 Stack tecnológico

- **Cloud:** AWS Lightsail  
- **Almacenamiento (Persistencia delegada):** Amazon S3  
- **Contenedores:** Docker & Docker Compose (plugin nativo)  
- **Web Server:** Nginx (configurado como Reverse Proxy)  
- **Aplicación:** WordPress (PHP-FPM)  
- **Base de Datos:** MySQL 5.7  
- **CLI:** wp-cli  
- **DNS Dinámico:** DuckDNS  
- **SO:** Ubuntu Server  
- **Automatización ligera:** Makefile  
- **Seguridad Host:** UFW (Firewall), Fail2Ban, SSH Hardening  

---

## 🔐 Implementación de Seguridad y Hardening

### 1️⃣ Hardening del Host (Sistema Operativo)

- **Reconfiguración SSH:** Se modificó el daemon SSH del host mudando el servicio del puerto estándar 22 al puerto seguro **2222**. Se deshabilitó por completo el login del usuario `root` y se eliminó la autenticación por contraseña, permitiendo el acceso única y estrictamente mediante intercambio de **claves públicas (SSH Keys)**.
- **Firewall perimetral nativo (UFW):** Implementación de una política restrictiva *Default Deny Incoming*. Solo se abrieron los puertos estrictamente necesarios para el negocio: `80` (HTTP), `443` (HTTPS) y `2222` (SSH Hardened).
- **Mitigación de Fuerza Bruta (Fail2Ban):** Instalación y configuración de Fail2Ban mediante la declaración de una jaula (*jail*) activa para el puerto 2222. El sistema banea automáticamente por IP a cualquier origen que registre más de 3 intentos fallidos de conexión.

### 2️⃣ Hardening de la Infraestructura (Docker)

- **Principio de Mínimo Privilegio:** Inyección de directivas de seguridad en los servicios de Docker Compose (`no-new-privileges:true`) para prevenir la escalada de privilegios en caso de compromiso de un contenedor.
- **Control y Mitigación DoS:** Asignación de límites estrictos de consumo de memoria RAM y CPU por contenedor, evitando que el compromiso de un servicio degrade el host completo. Uso de montajes `read_only` y sistemas de archivos temporales en memoria (`tmpfs`) donde fue posible.
- **Aislamiento de phpMyAdmin:** Se restringió el acceso a la consola de base de datos eliminando su exposición hacia la red pública. El servicio quedó configurado para ser accesible **única y exclusivamente vía localhost**, requiriendo un túnel SSH seguro (*Port Forwarding*) para su administración activa.

### 3️⃣ Hardening de la Aplicación (WordPress)

- **Inyección Nativa de Secretos:** Se modificó el archivo `wp-config.php` para que consuma de forma directa y nativa las variables del entorno extraídas del `.env`, erradicando cualquier rastro de credenciales *hardcodeadas*.
- **Protección del Core:** Deshabilitación absoluta del editor de archivos integrado en el panel de administración de WordPress mediante la constante `DISALLOW_FILE_EDIT`, anulando la capacidad de inyectar código PHP malicioso desde la interfaz web.

---

## 🔧 Correcciones de Integración y Estabilidad (Hotfixes)

Durante las pruebas de integración en ambientes endurecidos, se aplicaron dos mejoras críticas de consistencia técnica:

- **Contexto en `wp-cli`:** Se detectó que el contenedor de tareas administrativas (`wp-cli`) perdía el contexto de conexión al no acceder dinámicamente a las variables de entorno del archivo principal. Se corrigió inyectando explícitamente el bloque `environment` dentro del servicio en el archivo `docker-compose.yml`.
- **Saneamiento de Permisos Unix:** Se estandarizó la asignación automatizada de IDs de usuario del sistema de archivos del host mapeado a los contenedores, forzando la compatibilidad estricta de UID `33` para los procesos web de WordPress (`www-data`) y UID `999` para el motor de MySQL.

---

## 🚀 Operación y Restauración Controlada (Manual Bootstrap)

Manteniendo un enfoque operativo consciente para dominar el flujo real de datos antes de delegarlo a pipelines automatizados, el proceso de restauración de la landing page se ejecuta de la siguiente manera:

### 1️⃣ Preparación y Descarga desde Amazon S3
Sanera los directorios del host y traé las estructuras estáticas y multimedia protegidas en tus buckets de AWS:
```bash
# Saneamiento de permisos iniciales
sudo chown -R ubuntu:ubuntu ~/wordpress-docker-devops/wordpress

# Descarga e ingesta de contenido multimedia (wp-content)
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/wordpress/wp-content.tar.gz /tmp/
tar -xzf /tmp/wp-content.tar.gz -C /home/ubuntu/wordpress-docker-devops/wordpress/

# Ajuste de permisos bajo estándar seguro de ejecución web
sudo chown -R 33:33 ~/wordpress-docker-devops/wordpress
```

### 2️⃣ Recuperación del Motor de Base de Datos

Descargar la estructura histórica de la base de datos y asignale el identificador nativo de MySQL antes de levantar el servicio:

```bash
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/mysql/mysql-bootstrap.tar.gz /tmp/
tar -xzf /tmp/mysql-bootstrap.tar.gz -C /home/ubuntu/wordpress-docker-devops/mysql/
sudo chown -R 999:999 mysql/data
```

### 3️⃣ Levantamiento del Stack e Inyección SQL

Reiniciar los servicios a través del Makefile para asegurar la lectura limpia de volúmenes e inyectá el dump SQL correspondiente:

```bash
make down
make up
docker exec -i wp-mysql mysql -u root -pchangeme_root wordpress < mysql/backups/dump.sql
```

---

## 🧩 Orquestación de WordPress vía wp-cli

Para tareas operativas y de mantenimiento sin ingresar a la interfaz web, se utiliza el perfil interactivo del contenedor auxiliar de wp-cli:

```bash
# Desactivación masiva de plugins para tareas de debugging
docker-compose run --rm wp-cli wp plugin deactivate --all

# Instalación y activación controlada del stack productivo de la Landing
docker-compose run --rm wp-cli wp plugin install meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin activate elementor zilom-themer meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin update --all
```

*Nota: Se invoca intencionalmente la sintaxis explícita de docker-compose para preservar la visibilidad completa del ciclo de vida del contenedor efímero.*

---

## 🧰 Interfaz Unificada Operativa (Makefile)

El control del ciclo de vida diario de la infraestructura se gestiona centralizadamente mediante comandos simplificados:

```bash
make up        # Inicializa y levanta el stack de contenedores en segundo plano
make down      # Detiene los contenedores y remueve las redes lógicas activas
make restart   # Aplica un ciclo de reinicio seguro a los servicios
make logs      # Muestra el flujo de logs unificado del stack en tiempo real
make ps        # Muestra el estado operativo, puertos y salud actual de los servicios
```

---

## 🧠 Decisiones de Diseño y Arquitectura

- **Seguridad desde el Diseño (Shift-Left):** Todo el proceso de hardening perimetral y del sistema operativo se ejecuta de forma previa al despliegue del runtime. Esto garantiza que la infraestructura web nunca quede expuesta en un estado vulnerable.
- **Aislamiento por Capas:** Separar las responsabilidades de red y restringir las herramientas analíticas (phpMyAdmin) a tráfico de la interfaz de loopback local minimiza de manera drástica los vectores de ataque explotables desde el exterior.

---

## 📌 Estado del proyecto

- 🟩 **Infraestructura Cloud Hardened (Segura)**
- 🟩 **Hotfix de integración y contexto de variables aplicado**
- 🟩 **Procesos operacionales y de Disaster Recovery auditables**
- 🟩 **Validado para Portfolio DevOps / DevSecOps Junior**

**Tag de Git sugerido:** `v1.1`

---

## 🔜 Próxima Evolución (Fase de Automatización Avanzada - v1.2)

- **Full Automation:** Automatización total del despliegue y restauración de datos en un solo comando unificado (make full-deploy).
- **Healthchecks avanzados:** Implementación de políticas de disponibilidad nativas en Docker Compose para resolver condiciones de carrera (evitar que PHP inicie antes de que la DB acepte conexiones).
- **Desacoplamiento absoluto:** Migración del almacenamiento de datos dinámicos fuera de la estructura de carpetas del repositorio de código hacia una ruta neutra en el sistema (/opt/wordpress-runtime).
- **Multi-entorno:** Separación limpia de la lógica para soportar configuraciones locales (local) y productivas (prod).

---

## 👤 Autor

**Gerardo Angel Mastramico**
DevOps Junior
GitHub: <https://github.com/GerardMastra>
