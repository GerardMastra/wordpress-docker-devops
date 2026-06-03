# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v2.0 – Automated Remote Deployment (Línea Base de CD)

Esta versión marca el inicio del **Proyecto 2** en la evolución del ecosistema de infraestructura. Tras consolidar la portabilidad multi-entorno y el desacoplamiento de datos (v1.2), el foco estratégico de este hito se traslada hacia la **automatización del ciclo de vida del software mediante prácticas de Despliegue Continuo (CD)**.

Se introduce un pipeline de automatización que actúa como cordón umbilical entre el repositorio de código en GitHub y la instancia cloud en **AWS Lightsail**. Esto erradica los despliegues manuales imperativos por SSH, garantizando que el servidor de producción refleje el estado exacto de las ramas principales de forma automática, desatendida y segura.

🌐 **URL pública (entorno demo):**
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ *Nota:* Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias operativas propias del proveedor externo.

---

## 🎯 Objetivo de la versión v2.0

> **Incorporar automatización de CD mediante GitHub Actions para sincronizar el repositorio y rediseñar el ciclo de vida del stack con un esquema de despliegue remoto sin intervención manual.**

Cada vez que se realiza un `git push` hacia las ramas protegidas (`main` o `dev`), el pipeline toma el control, valida la conectividad, actualiza el código fuente en el host remoto y orquesta la reconstrucción de los servicios de manera transparente.

---

## 🛠️ Stack tecnológico

* **Cloud Infrastructure:** AWS Lightsail (Ubuntu Server)
* **Almacenamiento Objeto:** Amazon S3 (Persistencia delegada y Bootstrap)
* **Orquestación local:** Docker + Docker Compose
* **Pipeline de CD:** GitHub Actions (Runner gestionado)
* **Conectividad Segura:** SSH sobre llaves criptográficas robustas
* **Web Server & Reverse Proxy:** Nginx (Modo Read-Only)
* **Runtime Stack:** WordPress (Imagen personalizada PHP-FPM 8.1) + MySQL 5.7
* **Automatización Macro:** Makefile como interfaz operativa unificada

---

## ⚙️ El Pipeline de CD (GitHub Actions)

La automatización se gobierna de forma declarativa mediante el flujo configurado en `.github/workflows/deploy.yml`.

### 🔄 Flujo Completo del Workflow

1. **Disparador (Trigger):** Eventos de `push` dirigidos a las ramas `main` o `dev`.
2. **Autenticación SSH Segura:** El runner de GitHub inicializa un agente SSH consumiendo credenciales protegidas desde *GitHub Secrets*.
3. **Sincronización de Código:** Conexión segura con el servidor remoto para ejecutar un flujo de actualización limpia del repositorio de infraestructura.
4. **Rebuild e Inyección:** Orquestación remota para compilar cambios locales y refrescar los contenedores sin alterar los datos persistidos en el host.

---

## 🏗️ Arquitectura de Servicios y Abstracción

El sistema se mantiene fiel a la separación estricta entre **Código (Repo)** y **Datos (Runtime)** establecida previamente, permitiendo que el pipeline de CD destruya o recree los contenedores de manera segura.

* **MySQL:** Inicializado con un `healthcheck` activo que bloquea los servicios dependientes hasta que el motor esté listo.
* **PHP-FPM:** Consume la imagen personalizada (PHP 8.1) y arranca en cascada una vez que la base de datos está saludable.
* **Nginx:** Actúa como Reverse Proxy perimetral seguro con volúmenes montados en modo lectura.
* **Runtime Aislado:** Toda la persistencia real (base de datos y uploads) reside fuera de las rutas de Git, en `/opt/wordpress-runtime/`, lo que permite al pipeline de CD realizar actualizaciones de código con cero riesgo de pérdida de datos.

---

## 🚀 Guía de Despliegue y Operación

### 🧪 1. Preparación del Entorno Local (Desarrollo)

Para levantar el entorno ágil de desarrollo local:

```bash
cp .env.example .env.local
# Configurar las variables locales básicas en .env.local
make up-local ENV=local
```

### ☁️ 2. Configuración Inicial del Entorno Productivo

Antes de activar el pipeline automático, la primera vez en el servidor remoto de AWS Lightsail se deben preparar las variables reales:

```bash
cp .env.example .env.prod
# Configurar variables reales (Dominio, credenciales de S3, rutas de producción)
```

### 🎯 3. Activación del Despliegue Automático (Uso Diario)

A partir de la configuración inicial, todo el ciclo de despliegue queda delegado al control de versiones.

Para desplegar en el entorno deseado, simplemente ejecutá:

```bash
# Para actualizar la infraestructura de desarrollo/QA
git checkout dev
git push origin dev

# Para actualizar el entorno productivo principal
git checkout main
git push origin main
```

El pipeline de GitHub Actions se encargará de forma remota de conectarse, sincronizar los archivos y ejecutar los comandos del Makefile en destino para realizar el redeploy del sistema.

---

## 🧰 Interfaz de Comandos Útiles (Makefile)

Tanto el administrador de forma manual (vía SSH) como el runner de GitHub de forma automatizada utilizan la misma sintaxis unificada gracias al flag de entorno `ENV`:

```bash
make up-local ENV=local     # Inicializa el entorno local de desarrollo
make up-prod ENV=prod       # Fuerza el levantamiento del stack productivo en la nube
make down ENV=prod          # Detiene los servicios y remueve las redes lógicas
make logs ENV=prod          # Inspecciona la salida de logs unificados en producción
make ps ENV=prod            # Muestra el estado de salud actual de los contenedores
```

---

## 🧠 Decisiones Técnicas Clave

* **Despliegue basado en Git (GitOps Mindset):** Se elimina la necesidad de acceder manualmente al servidor para aplicar parches o configuraciones de infraestructura. Git se convierte en la única fuente de verdad para el estado de los contenedores.
* **Seguridad por Diseño (Secrets Hardening):** No existen llaves SSH, contraseñas de bases de datos ni tokens de AWS en el código. GitHub Actions consume estos valores en tiempo de ejecución de manera cifrada a través de variables de entorno protegidas.
* **Automatización Controlada:** El proceso de bootstrap inicial (descarga de paquetes desde S3 e importación de la base de datos SQL) se mantiene administrado mediante comandos del Makefile para asegurar el control granular antes de delegar el empaquetado inmutable en registros externos.

---

## 📌 Estado Actual del Proyecto

✔ **Pipeline CI/CD con GitHub Actions completamente automatizado**
✔ **Despliegue remoto desatendido vía SSH funcional**
✔ **Seguridad robusta mediante la eliminación de secretos expuestos**
✔ **Estructura multi-entorno (local vs prod) completamente integrada**
✔ **Arquitectura limpia validada para Portfolio DevOps Junior**

**Tag de Git definitivo:** `v2.0`

---

## 🔜 Siguiente Evolución Mayor (Hacia v2.1 – Enterprise CI/CD)

Establecido el flujo de transporte automático de código, la siguiente fase de madurez técnica abordará los estándares corporativos de alta disponibilidad:

* **Separación de CI y CD:** Eliminar el proceso de compilación (`build`) dentro de la instancia de AWS para optimizar el uso de CPU/RAM.
* **Inmutabilidad en Registry:** Implementar un flujo de empaquetado para construir imágenes Docker personalizadas (basadas en Alpine) y publicarlas versionadas en **Docker Hub**.
* **Runtime Dinámico:** Modificar el ciclo de arranque de los contenedores para que consuman variables de entorno al vuelo mediante un Entrypoint con `envsubst` y descarguen su bootstrap de S3 de forma 100% desatendida.

---

## 👤 Autor

Gerardo Angel Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
