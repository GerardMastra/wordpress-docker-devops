# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v2.1 – Enterprise CI/CD Pipeline & Immutable Core (Hito Mayor)

Esta versión representa el **salto definitivo hacia los estándares corporativos** de alta disponibilidad e ingeniería de lanzamientos dentro del **Proyecto 2**. Tras establecer la línea base de transporte por SSH (v2.0), este hito remaqueta por completo el ciclo de vida del software bajo dos dogmas fundamentales de la cultura DevOps: **la inmutabilidad del artefacto y el desacoplamiento absoluto del estado de la aplicación**.

Se elimina por completo el proceso de compilación (`build`) dentro del host de producción, protegiendo los recursos limitados del servidor cloud (**AWS Lightsail**). En su lugar, se implementa un pipeline robusto de **Integración Continua (CI)** que empaqueta una imagen agnóstica, liviana y ultra-optimizada, delegando el aprovisionamiento de datos dinámicos a un flujo desatendida en *runtime* en caliente mediante **Amazon S3**.

🌐 **URL pública (entorno demo):**
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ *Nota:* Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias operativas propias del proveedor externo.

---

## 🎯 Objetivo de la versión v2.1

> **Separar de forma estricta la etapa de compilación (CI) de la etapa de despliegue (CD), empaquetar imágenes inmutables en un Registry externo (Docker Hub) y orquestar un arranque dinámico donde el contenedor nace vacío y los datos se inyectan en caliente desde AWS S3.**

Esta arquitectura garantiza flujos de despliegue inmediatos, idempotentes y con tolerancia a fallos, simulando las dinámicas de escalabilidad horizontal de entornos corporativos de gran escala.

---

## 🛠️ Stack tecnológico

* **Cloud Infrastructure:** AWS Lightsail (Ubuntu Server)
* **Almacenamiento Objeto:** Amazon S3 (Bootstrap dinámico en caliente)
* **Pipeline CI/CD:** GitHub Actions (Automated Runner)
* **Image Registry:** Docker Hub (Versionado criptográfico)
* **Web Server & Reverse Proxy:** Nginx (Configuraciones en modo Read-Only)
* **Runtime Stack:** WordPress (Custom Image PHP-FPM 8.2 Alpine) + MySQL 5.7
* **Orquestación y Automatización:** Docker Compose + Makefile Avanzado + `envsubst`

---

## 🧠 Principio Arquitectónico: El Artefacto Inmutable

El cambio paradigmático en esta versión responde a una regla estricta: **La imagen Docker NO contiene datos dinámicos (`wp-content` o Bases de Datos).**

```text
  [ CÓDIGO ESTÁTICO ] ──> GitHub Actions (CI) ──> Docker Hub (Imagen Inmutable v2.1)
                                                                 │
                                                                 ▼
  [ DATOS DINÁMICOS ] ──> Amazon S3 ────────────> Instancia de AWS Lightsail (CD)
```

| Componente | Responsabilidad | Origen / Ubicación |
| :--- | :--- | :--- |
| **Docker Image** | Lógica de la aplicación, binarios del core y dependencias runtime. | Docker Hub (Compilado en CI) |
| **Amazon S3** | Datos mutables del negocio (uploads, themes, plugins y dumps SQL). | Cloud S3 (Persistencia persistente) |
| **Volumen Host** | Fuente de verdad de datos persistidos acoplados al contenedor. | `/opt/wordpress-runtime/` |

---

## ⚙️ Pipeline CI/CD Avanzado (GitHub Actions)

El ciclo de vida está gobernado de forma declarativa desde `.github/workflows/deploy.yml`, segmentando con precisión matemática las responsabilidades de compilación y lanzamiento.

### 🧪 1. Etapa de Integración Continua (CI) - Build & Push

Cada `push` en las ramas principales (`main` o `dev`) activa un runner aislado de GitHub que ejecuta de forma segura:

* **Checkout de Código:** Descarga la versión exacta del repositorio de infraestructura.
* **Docker Registry Login:** Autenticación en Docker Hub consumiendo credenciales protegidas desde *GitHub Secrets*.
* **Build Inmutable:** Compila la imagen personalizada basada en **PHP-FPM 8.2 Alpine** (minimizando la superficie de ataque y el peso de la imagen). El directorio mutable `wp-content` queda estrictamente excluido del build.
* **Etiquetado y Push:** Publica la imagen en Docker Hub bajo la etiqueta `latest` combinada de forma concurrente con el **Commit SHA** de Git para garantizar trazabilidad absoluta en auditorías.

### 🚀 2. Etapa de Despliegue Continuo (CD) - Pull & Run

Garantizado el artefacto en el registro, la etapa de despliegue se conecta al servidor remoto vía SSH para ejecutar un flujo inmediato:

* **Sincronización de Entorno:** Descarga las configuraciones del repositorio en la instancia cloud.
* **Pull de la Imagen:** El servidor de producción realiza un `docker pull` de la imagen pre-compilada desde Docker Hub, evitando fatiga de CPU y caídas de servicio por falta de memoria RAM.
* **Idempotencia:** Reinicia los servicios aplicando los contenedores de forma transparente.

---

## 🏗️ Arranque Dinámico y Entrypoint Personalizado

Al nacer el contenedor de WordPress completamente agnóstico y vacío, se diseñó un ciclo de inicialización inteligente para la inyección de entorno:

1. `docker-entrypoint-custom.sh`: Script interno inyectado en el contenedor que intercepta el arranque. Utiliza la utilidad `envsubst` para leer las variables de entorno de producción (`.env.prod`) y parsearlas sobre la plantilla `wp-config.php.template`, generando el archivo final seguro sin exponer secretos en texto plano.
2. **Bootstrap dinámico en caliente** (`make restore-s3`): Durante la inicialización del deployment remoto, la automatización del Makefile invoca al CLI de AWS de forma desatendida, descarga los paquetes desde S3, los extrae sobre la ruta limpia del volumen (`/opt/wordpress-runtime/wordpress/`) y reasigna los permisos de sistema Unix (`33:33` para www-data de PHP y `999:999` para el motor de base de datos MySQL).

---

## 🚀 Guía de Operación e Invocación

### 🧪 Despliegue en Entorno de Desarrollo Local

Para iterar de forma ágil localmente utilizando el compose con overrides nativos:

```bash
cp .env.example .env.local

# Configurar secretos de entorno de desarrollo local
make up-local ENV=local
```

### 🌍 Flujo Productivo Automatizado (Uso Diario)

Toda modificación sobre las reglas de infraestructura o el código base se despliega sin tocar el servidor de producción:

```bash
git add .
git commit -m "feat: optimizar configuraciones del entrypoint dinámico"
git push origin main
```

A partir de este comando, podés monitorear la pestaña de Actions en GitHub. El pipeline empaquetará la imagen en Docker Hub, se conectará de forma segura a AWS Lightsail, actualizará el stack y restaurará los datos persistentes desde S3 de forma 100% desatendida.

---

## 🧰 Comandos del Makefile (Administración remota de emergencia)

Si necesitás interactuar con el stack de producción de forma manual ingresando por SSH, utilizá la interfaz estandarizada con el flag `ENV`:

```bash
make up-prod ENV=prod       # Fuerza el levantamiento consumiendo imágenes remotas del Hub
make down ENV=prod          # Apaga el ecosistema productivo removiendo redes lógicas
make logs ENV=prod          # Inspecciona la salida de logs unificados de los contenedores
make ps ENV=prod            # Verifica el estado de los Healthchecks y políticas de salud
make restore-s3 ENV=prod    # Invoca manualmente el bootstrap en caliente desde S3
```

---

## 🧠 Decisiones Técnicas Clave

* **Principio de Inmutabilidad:** Los contenedores se comportan como infraestructura desechable. Si el servidor de producción se destruye por completo, el pipeline v2.1 puede reconstruir el servicio idéntico en un proveedor cloud diferente en cuestión de minutos.
* **Uso exclusivo de S3 para Datos de Negocio:** La persistencia se desvincula por completo del código fuente, resolviendo de forma elegante el manejo de estados en aplicaciones que no nacieron nativas de la nube (Cloud-Native) como WordPress.
* **Optimización de Recursos (Alpine Linux):** La migración de imágenes base a variantes Alpine redujo drásticamente los tiempos de descarga del pipeline en el CD y mitigó el consumo latente de memoria dentro del host cloud.

---

## 📌 Estado Actual del Proyecto

✔ Flujo CI/CD robusto Enterprise (Separación real de Build y Deploy)
✔ Imágenes inmutables versionadas criptográficamente en Docker Hub
✔ Cero procesos de compilación pesados en el servidor de producción
✔ Entrypoint dinámico implementado con plantillas e inyección de variables
✔ Bootstrap desatendido desde almacenamiento de objetos (Amazon S3)
✔ Arquitectura avanzada consolidada para Portfolio DevOps de alto impacto

**Tag de Git definitivo:** `v2.1`

---

## 👤 Autor

Gerardo Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
