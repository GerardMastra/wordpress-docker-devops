# 🚀 Enterprise WordPress Cloud Deployment  

## Security & DevOps Focus

Este proyecto demuestra un **despliegue profesional de WordPress en la nube**, utilizando contenedores Docker y prácticas DevOps reales, con un fuerte enfoque en **seguridad (hardening)**, **automatización** e **infraestructura reproducible**.

🌐 **URL Pública:**  
<https://gerardo-devops-wp.duckdns.org>

---

## 🛠 Stack Tecnológico

- **Cloud:** AWS Lightsail / EC2 y Oracle Cloud (Always Free Tier)
- **Contenedores:** Docker & Docker Compose
- **Reverse Proxy:** Nginx Proxy Manager
- **SSL/TLS:** Let’s Encrypt (certificados automáticos)
- **Base de Datos:** MySQL (persistencia mediante volúmenes)
- **DNS Dinámico:** DuckDNS
- **Sistema Operativo:** Ubuntu Server

---

## 🔒 Seguridad & Hardening Aplicado

Este proyecto va más allá de un despliegue estándar de WordPress e incorpora medidas de seguridad típicas de entornos productivos.

### 1️⃣ Bastionado del Host (SSH Hardening)

- **Cambio de Puerto SSH:** de 22 a **2222**, reduciendo ataques automatizados.
- **Autenticación por Llave:** acceso SSH exclusivo mediante claves RSA/PEM.
- **Fail2Ban:** sistema de prevención de intrusos que bloquea IPs tras múltiples intentos fallidos.

### 2️⃣ Seguridad de Red

- **Principio de Menor Privilegio:**  
  El firewall permite acceso SSH y phpMyAdmin únicamente desde mi IP pública.
- **Aislamiento de Servicios:**  
  MySQL no expone puertos al exterior; la comunicación se realiza exclusivamente dentro de la red interna de Docker.

### 3️⃣ Endurecimiento de WordPress

- **Protección de `wp-config.php`:**  
  Edición de archivos deshabilitada desde el panel (`DISALLOW_FILE_EDIT`).
- **Sanitización de Base de Datos:**  
  Dumps SQL sin información sensible y usuario administrativo genérico.

---

## 🏗 Arquitectura del Proyecto

La arquitectura está organizada en capas claramente separadas:

1. **Proxy Layer**  
   Nginx Proxy Manager gestiona el tráfico HTTP/HTTPS y certificados SSL.
2. **Application Layer**  
   WordPress ejecutándose sobre PHP-FPM dentro de contenedores.
3. **Data Layer**  
   MySQL con persistencia de datos mediante volúmenes Docker.

## 🚀 Despliegue del Proyecto

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/GerardMastra/wordpress-docker-devops.git
cd wordpress-docker-devops
```

### 2️⃣ Inicialización del servidor (Bootstrap)

El proyecto incluye un script de inicialización (bootstrap) para preparar una instancia Ubuntu desde cero.

Este script:

- **Actualiza el sistema**
- **Instala Docker**
- **Instala Docker Compose**
- **Habilita y levanta el servicio Docker**

Archivo:

``` bash
scripts/bootstrap.sh
```

Ejecución:

``` bash
chmod +x scripts/bootstrap.sh
sudo ./scripts/bootstrap.sh
```

El mismo script puede utilizarse como User Data al crear una instancia en AWS Lightsail u otra nube compatible.

### 3️⃣ Configuración de variables de entorno

Crear un archivo .env basado en .env.example con las credenciales necesarias.

### 4️⃣ Levantar la infraestructura

``` bash
docker-compose up -d
```

### 5️⃣ Restaurar Base de Datos (opcional)

Cargar el dump SQL sanitizado dentro del contenedor MySQL.

## 🧰 Automatización con Makefile

El proyecto incluye un `Makefile` para simplificar y estandarizar las tareas
más comunes del entorno.

Ejemplos de comandos disponibles:

```bash
make up        # Levanta la infraestructura
make down      # Detiene los contenedores
make logs      # Muestra logs de los servicios
make restart   # Reinicia el stack
```

Los comandos del Makefile encapsulan llamadas a docker-compose para
mejorar la experiencia operativa y reducir errores manuales.

✔️ Claro  
✔️ Corto  
✔️ Profesional  
✔️ No invasivo  

---

### 🔹 Opción mínima (si querés ultra simple)

```md
> El proyecto incluye un `Makefile` con atajos para las tareas más comunes de Docker Compose.
```

## 📄 Notas de Mantenimiento

El repositorio incluye un .gitignore optimizado para evitar la subida de:

- **variables sensibles (.env)**
- **datos persistentes de base de datos**
- **La infraestructura es 100% portable entre distintos proveedores cloud.**
- **El proyecto está pensado como base para entornos productivos, no solo de desarrollo.**

## 🎯 Objetivo del Proyecto

Este proyecto forma parte de mi portfolio DevOps, con foco en:

- **automatización**
- **seguridad**
- **buenas prácticas de despliegue**
- **operación de servicios en la nube**
