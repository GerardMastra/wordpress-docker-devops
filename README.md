# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v5.0 – Infrastructure as Code & Multi-Stage Orchestration (Cierre del Stack)

Esta versión representa la **cúspide evolutiva y la madurez absoluta de ingeniería** de todo nuestro ecosistema de infraestructura. Tras asegurar la inmutabilidad de la aplicación (v2.1), la resiliencia de datos (v3.0) y la observabilidad proactiva (v4.0), este hito rompe el último esquema manual: **el aprovisionamiento del propio hardware cloud**.

Se introduce la **Infraestructura como Código (IaC)** mediante **Terraform** para gobernar los recursos en **AWS** (Cómputo en **EC2**, almacenamiento de objetos en **S3** y configuraciones perimetrales de red). Todo el sistema se unifica bajo un pipeline **Multi-Stage en GitHub Actions** con dependencias lógicas estrictas: el código define el hardware, el pipeline lo aprovisiona de forma desatendida, extrae dinámicamente sus salidas lógicas (como la IP dinámica) e inyecta en caliente el despliegue de los contenedores mediante Docker Compose de extremo a extremo.

🌐 **URL pública (entorno demo):**
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ *Nota:* Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias operativas propias del proveedor externo.

---

## 🎯 Objetivo de la versión v5.0

> **Automatizar por completo el ciclo de vida de la infraestructura cloud mediante código declarativo (Terraform), integrando un pipeline multi-etapa que encadene secuencialmente la creación de hardware en AWS con la compilación y despliegue del stack contenerizado de forma 100% desatendida e idempotente.**

Con esta implementación, la infraestructura y la aplicación se funden en un único flujo de valor continuo, erradicando los clics en consolas web y garantizando que todo el entorno de negocio sea reproducible desde cero en cuestión de minutos.

---

## 🛠️ Stack tecnológico

* **Cloud Infrastructure & IaC:** AWS (EC2, S3, VPC, Security Groups) + Terraform Core
* **Pipeline Multi-Stage:** GitHub Actions (Encadenamiento de Jobs con dependencias lógicas)
* **Orquestación en Destino:** Docker + Docker Compose + Makefile Avanzado
* **Runtime Stack:** WordPress (PHP-FPM 8.1 Alpine) + Nginx (Proxy Reverso) + MySQL 5.7
* **Observabilidad Centralizada:** Prometheus + Grafana + Node Exporter + MySQL Exporter
* **Mapeo Dinámico y Redes:** DuckDNS + Redes Lógicas Aisladas en Docker
* **Resiliencia Operativa:** Contenedor de Backups automático e independiente hacia Amazon S3
* **Seguridad y Secretos:** GitHub Secrets (Consumo cifrado en tiempo de ejecución)

---

## 🏗️ Arquitectura Global Desacoplada: Infraestructura vs Aplicación

El repositorio adopta una separación estricta de responsabilidades. Terraform administra el ciclo de vida de los fierros (nube), mientras que Docker Compose gobierna el ciclo de vida del software (servicios). El puente de unión dinámico es el pipeline de CI/CD.

```text
  [ Código Git ] ──> GitHub Actions (Multi-Stage Job)
                           │
                           ├──> Stage 1: Terraform ──> Provisiona EC2 / S3 / Redes
                           │                                      │ (Exporta IP Dinámica)
                           ▼                                      ▼
                           └──> Stage 2: CD Deploy ──> Docker Compose Pull & Run
```

### Tabla de Responsabilidades del Ecosistema Consolidado

| Componente | Responsabilidad | Origen / Ubicación |
| :--- | :--- | :--- |
| **Capa de IaC (Terraform)** | Definición, creación y destrucción del hardware cloud de forma declarativa. | AWS Cloud (EC2, S3, Firewalls) |
| **Docker Image** | Lógica de la aplicación, binarios del core y dependencias runtime. | Docker Hub (Compilado en CI) |
| **Amazon S3** | Persistencia a largo plazo de Dumps SQL, paquetes binarios `.tar.gz` y assets. | Cloud S3 (Persistencia externa) |
| **backup-service** | Ejecución de tareas programadas y empaquetado de estados en caliente. | Microservicio aislado (Docker Stack) |
| **Prometheus / Grafana** | Recolección, almacenamiento temporal, modelado de datos y disparo de alertas. | Central de Monitoreo (Ecosistema Docker) |
| **Exporters (Node & MySQL)** | Instrumentación del hardware del host de AWS y variables de hilos/queries. | Agentes livianos integrados en runtime |
| **Volumen Host** | Fuente de verdad local acoplada al tiempo de ejecución de los contenedores. | `/opt/wordpress-runtime/` |

---

## ⚙️ Orquestación del Pipeline Multi-Stage (GitHub Actions)

El ciclo de vida del proyecto está gobernado de forma declarativa en `.github/workflows/deploy.yml`, segmentando el flujo en dos grandes trabajos (*Jobs*) interdependientes:

### 📡 Job 1: Infraestructura como Código (IaC Stage)

* **Validación**: Ejecuta `terraform validate` y `terraform fmt` de forma automática para asegurar la calidad del código de infraestructura.
* **Planificación y Aplicación**: Procesa el plan de ejecución y aplica los cambios en AWS consumiendo de forma cifrada las credenciales desde *GitHub Secrets*.
* **Outputs Dinámicos**: Al finalizar el aprovisionamiento, exporta las variables críticas resultantes (como la IP pública de la instancia EC2 recién creada) hacia el siguiente Job del flujo.

### 🚀 Job 2: Despliegue de Aplicación (CD Stage - Dependiente)

Utiliza la directiva `needs: [infra_job]`. Si la infraestructura es estable, este Job toma el control:

* **Conectividad Elástica**: Se conecta mediante SSH utilizando la IP dinámica recuperada del Stage anterior.
* **Pull e Idempotencia**: Sincroniza las configuraciones del repositorio en el host, realiza un `docker compose pull` de las imágenes inmutables de Docker Hub y refresca el stack sin alterar los datos dinámicos ni la telemetría.

---

## 🚨 Ingeniería de Alertas y Telemetría Integrada

La infraestructura aprovisionada por Terraform arranca de forma nativa el ecosistema de observabilidad (v4.0). Prometheus evalúa activamente reglas complejas escritas en **PromQL** para la detección proactiva de incidentes sobre el hardware creado:

* **Saturación de CPU Alta**: `100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)`
* **Agotamiento de RAM Crítico**: `(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100`
* **Caída del Servicio de Datos**: `mysql_up == 0`

---

## 🚀 Guía de Operación e Invocación Local

Toda la complejidad macro está abstraída detrás de comandos limpios del `Makefile`, permitiendo probar componentes de la aplicación localmente de forma ágil antes de empujarlos al flujo de Terraform en la nube:

```bash
cp .env.example .env.local
# Configurar llaves y secretos lógicos locales
make up-local ENV=local

# Validaciones locales rápidas:
# - WordPress funcional en http://localhost
# - Grafana accesible en http://localhost:3000
```

### 🌍 Flujo de Lanzamiento Productivo (Uso Diario)

Para modificar cualquier parámetro de la aplicación, el monitoreo, o añadir recursos en la nube, el flujo se reduce exclusivamente al control de versiones:

```bash
git add .
git commit -m "infra: ajustar reglas del security group para habilitar puerto de monitoreo"
git push origin main
```

A partir de este comando, podés monitorear la ejecución en tiempo real desde la pestaña de Actions en GitHub, observando cómo se encadenan secuencialmente las etapas de infraestructura y código de aplicación.

---

## 🧠 Decisiones Técnicas Clave

* **Inmutabilidad de Red y State Hardening**: Los archivos de estado de Terraform (`.tfstate`) se gestionan bajo estrictas políticas de aislamiento y no se versionan en Git, asegurando que las credenciales de AWS permanezcan protegidas en tiempo de ejecución.
* **Security Groups por Código**: Se bloquea por defecto todo el tráfico perimetral de la instancia EC2. Las reglas de firewall se declaran explícitamente en el código de Terraform, abriendo de forma restrictiva únicamente los puertos HTTP (`:80`), HTTPS (`:443`), Grafana (`:3000`) y SSH bajo llaves criptográficas robustas.
* **Separación de Ciclos de Vida**: Si una actualización solo altera el código fuente de la aplicación (por ejemplo, un cambio estético en WordPress), el Stage 1 de Terraform detecta de forma inteligente que no hay cambios en el hardware de AWS, agilizando el pipeline y ejecutando directamente el CD sobre el host existente sin recrear la instancia.

---

## 📌 Estado de Cierre de la Infraestructura Global

✔ **Infraestructura como Código (IaC) completamente automatizada con Terraform**
✔ **Pipeline CI/CD multi-stage de nivel enterprise integrado en GitHub Actions**
✔ **Provisión y despliegue dinámico basado en IPs dinámicas exportadas en caliente**
✔ **Imágenes inmutables versionadas criptográficamente en Docker Hub (v2.1)**
✔ **Motor de backups desatendido con persistencia delegada en Amazon S3 (v3.0)**
✔ **Stack de observabilidad y alertas proactivas en PromQL funcional (v4.0)**
✔ **Ecosistema DevOps maduro, robusto, reproducible y documentado para Portfolio Global**

**Tag de Git definitivo**: `v5.0`

---

## 👤 Autor

**Gerardo Angel Mastramico** DevOps Junior GitHub: <https://github.com/GerardMastra>
