# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v1.0 – Functional Cloud Deployment (MVP)

Proyecto **DevOps Junior** que demuestra el despliegue **end-to-end** de una aplicación **WordPress real** utilizando **Docker Compose**, con **persistencia de datos**, **restauración manual desde S3** y ejecución en **AWS Lightsail**.

El foco del proyecto está en:

* **Reproducibilidad integral** del entorno cloud.
* **Separación clara de responsabilidades** en la capa de servicios independientes.
* **Operación manual consciente** mediante un proceso de bootstrap estructurado.
* **Documentación detallada**, auditable y trazable para portfolio.

🌐 **URL pública (entorno demo):**
<http://gerardo-devops-wp.duckdns.org>

⚠️ *Nota: Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias propias del proveedor externo.*

---

## 🎯 Objetivo de la versión v1.0

> **Demostrar arquitectura, criterio técnico básico y que el sistema funciona de punta a punta en la nube.**

Esta versión está diseñada estratégicamente para consolidar los **fundamentos sólidos de DevOps**, priorizando el entendimiento del flujo de datos y la estabilidad del stack, evitando complejidad innecesaria o una sobre-automatización prematura.

---

## 🛠 Stack tecnológico

* **Cloud:** AWS Lightsail  
* **Almacenamiento (Persistencia delegada):** Amazon S3  
* **Contenedores:** Docker & Docker Compose  
* **Web Server:** Nginx  
* **Aplicación:** WordPress (PHP-FPM)  
* **Base de Datos:** MySQL  
* **CLI:** wp-cli  
* **DNS Dinámico:** DuckDNS  
* **SO:** Ubuntu Server  
* **Automatización ligera:** Makefile  

---

## 🏗 Arquitectura y Componentes

El proyecto se ejecuta abstrayendo los servicios en contenedores independientes de Docker:

* `wp-nginx` → Servidor web encargado de la recepción de peticiones.
* `wp-php` → Procesamiento de la aplicación WordPress vía PHP-FPM.
* `wp-mysql` → Motor de base de datos MySQL (persistente).
* `wp-cli` → Utilidad de gestión y administración de WordPress mediante CLI.
* `phpMyAdmin` → Interfaz gráfica para la administración ágil de la base de datos.

### Persistencia de Datos (Volúmenes)

La persistencia de la información se garantiza mapeando directorios del host hacia los contenedores mediante volúmenes de Docker:

* **Datos de MySQL**: `./mysql/data`
* **Archivos de WordPress**: `./wordpress` (incluye la carpeta crítica `wp-content`).

### Bootstrap Externo (S3)

Los artefactos históricos necesarios para reconstruir el entorno de la landing page se resguardan en un bucket de **Amazon S3** y se recuperan manualmente en el despliegue inicial:

* `wp-content.tar.gz` (Código de temas, plugins y archivos multimedia).
* `mysql-bootstrap.tar.gz` (Estructura base y datos históricos del motor).

---

## 🚀 Despliegue paso a paso

### 1️⃣ Acceso a la instancia Lightsail

Conectate a tu servidor remoto por SSH utilizando tu clave privada:

```bash
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1-pd.pem ubuntu@44.220.98.235
```

### 2️⃣ Clonar el repositorio

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

### 3️⃣ Bootstrap del servidor

El proyecto incluye un script de automatización inicial (`bootstrap.sh`) para preparar la instancia de Ubuntu Server limpia. Este script se encarga de actualizar los paquetes del sistema, instalar Docker, Docker Compose y habilitar los servicios necesarios.

```bash
chmod +x scripts/bootstrap.sh
sudo ./scripts/bootstrap.sh
```

### 4️⃣ Configuración inicial de entornos

Copiar los archivos base para las variables de entorno y la estructura del Core de WordPress:

```bash
cp .env.example .env
cp wordpress/wp-config-sample.php wordpress/wp-config.php
```

*Nota: Asegurarse de editar el archivo `.env` para asignar contraseñas seguras y tus credenciales reales.*

Asignar el usuario actual al grupo de Docker para ejecutar comandos sin privilegios de `sudo` y reiniciar la sesión SSH:

```bash
sudo usermod -aG docker ubuntu
exit
```

*Volver a ingresar a la instancia por SSH antes de continuar.*

### 5️⃣ Instalación de herramientas de automatización

```bash
cd ~/wordpress-docker-devops/
sudo apt install make
```

### 6️⃣ Inicialización SSL y despliegue del stack

Ejecutár los comandos estructurados en el Makefile para emitir tus certificados Let's Encrypt y levantar los contenedores en segundo plano:

```bash
make ssl-init
make ssl-https
make up
```

---

## 🔁 Restauración desde S3 (Bootstrap Manual)

### 📦 Restaurar archivos y multimedia de WordPress

Ajustar los permisos del sistema de archivos del host, descargar el paquete multimedia desde S3 y descomprimilo en la ruta destino con los permisos de usuario web de Linux (`www-data: 33`):

```bash
sudo chown -R ubuntu:ubuntu ~/wordpress-docker-devops/wordpress
sudo find ~/wordpress-docker-devops/wordpress -type d -exec chmod 755 {} \;
sudo find ~/wordpress-docker-devops/wordpress -type f -exec chmod 644 {} \;

aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/wordpress/wp-content.tar.gz /tmp/
tar -xzf /tmp/wp-content.tar.gz -C /home/ubuntu/wordpress-docker-devops/wordpress/
sudo chown -R 33:33 ~/wordpress-docker-devops/wordpress
```

### 🗄 Restaurar base de datos MySQL

Descargar y descomprimí el backup estructural del motor de base de datos, asignándole el identificador de usuario nativo de MySQL (`999`):

```bash
sudo chown -R ubuntu:ubuntu mysql
aws s3 cp s3://gerardo-devops-wp-bootstrap/bootstrap/mysql/mysql-bootstrap.tar.gz /tmp/
tar -xzf /tmp/mysql-bootstrap.tar.gz -C /home/ubuntu/wordpress-docker-devops/mysql/
sudo chown -R 999:999 mysql/data
```

Reiniciar el stack de contenedores para forzar la lectura correcta de los volúmenes e importá el dump SQL correspondiente:

```bash
make down
make up
docker exec -i wp-mysql mysql -u root -pchangeme_root wordpress < ~/wordpress-docker-devops/mysql/backups/dump.sql
```

---

## 🧩 Gestión de WordPress vía wp-cli

Puedes realizar operaciones rápidas y tareas de mantenimiento sobre la aplicación utilizando el contenedor interactivo auxiliar de `wp-cli`:

* **Desactivar todos los plugins activos en lote:**

```bash
docker-compose run --rm wp-cli wp plugin deactivate --all
```

* **Instalar, activar y actualizar el stack de plugins requerido para producción:**

```bash
docker-compose run --rm wp-cli wp plugin install meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin activate elementor zilom-themer meta-box contact-form-7
docker-compose run --rm wp-cli wp plugin update --all
```

*Nota: Se invoca la sintaxis explícita de `docker-compose` para mantener la claridad del flujo operativo paso a paso.*

---

## 🧰 Automatización con Makefile

El proyecto expone una interfaz unificada mediante comandos simples para gobernar el ciclo de vida de la infraestructura:

```bash
make up        # Inicializa y levanta el stack de contenedores en segundo plano
make down      # Detiene los contenedores y remueve las redes lógicas activas
make restart   # Aplica un ciclo de reinicio seguro a los servicios de la aplicación
make logs      # Muestra la salida unificada de logs en tiempo real
make ps        # Muestra el estado operativo y de salud actual de los contenedores
```

---

## 🧠 Decisiones de diseño y arquitectura

El proceso de bootstrap y restauración se mantiene manual de forma premeditada en esta primera etapa. Se evitó la sobre-automatización prematura con los siguientes fines:

1. **Garantizar la máxima visibilidad** del flujo real de los datos y facilitar las tareas de debugging tempranas.
2. **Aislar el proceso único de aprovisionamiento** (bootstrap inicial) del comportamiento en runtime continuo de la plataforma.
3. **Construir los cimientos empíricos necesarios** para abordar la automatización avanzada de infraestructura en los siguientes proyectos del roadmap.

---

## 📌 Estado del proyecto

* 🟩 **Funcional en entorno Cloud**
* 🟩 **Entorno completamente reproducible**
* 🟩 **Documentado operativamente paso a paso**
* 🟩 **Apto y validado para Portfolio DevOps Junior**

**Tag sugerido:** `v1.0`

---

## 🔜 Roadmap Evolutivo (Próximas fases)

### v1.1 – Security & Hardening

* Hardening del Daemon SSH del Host (muda de puerto, llaves criptográficas).
* Firewall de red nativo (UFW).
* Mitigación de fuerza bruta con Fail2Ban.
* Ajustes internos de seguridad en las directivas de WordPress.

### v1.2 – Automation & DX (Developer Experience)

* Despliegue completo unificado en un solo comando (Full Automation).
* Healthchecks integrados para asegurar la comunicación interactiva entre servicios.
* Validaciones automatizadas post-deploy.

---

## 👤 Autor

**Gerardo Angel Mastramico**
DevOps Junior
GitHub: <https://github.com/GerardMastra>
