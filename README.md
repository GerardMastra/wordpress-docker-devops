# Arquitectura Cloud Orientada a la Continuidad de Negocio: Implementación del AWS Well-Architected Framework

Diseño e implementación de una infraestructura resiliente, automatizada y de costo optimizado, transformando necesidades críticas de negocio en soluciones técnicas viables.

## Versión: v4.0 – Full Observability Stack & Proactive Alerting Engine (Hito Mayor)

Esta versión representa la **cúspide de la madurez operativa y la excelencia en ingeniería** dentro de nuestro stack de infraestructura. Tras consolidar la inmutabilidad de los contenedores (v2.1) y la resiliencia ante desastres mediante backups automatizados (v3.0), este hito transforma el entorno en un ecosistema completamente transparente, medible y **capaz de auto-detectar anomalías en tiempo real** antes de que impacten al usuario final.

Se introduce una arquitectura avanzada de observabilidad basada en el patrón de recolección por *pulling* (raspado de métricas). Centralizamos el motor de series temporales (**Prometheus**) y la capa de visualización avanzada (**Grafana**), conectándolos mediante redes lógicas internas hacia agentes de exportación especializados (**Node Exporter** y **MySQL Exporter**) e implementando un motor de alertas proactivas mediante consultas en **PromQL**.

🌐 **URL pública (entorno demo):**
<http://gerardo-devops-wp.duckdns.org>

> ⚠️ *Nota:* Al utilizar DNS dinámico (DuckDNS), pueden existir intermitencias operativas propias del proveedor externo.

---

## 🎯 Objetivo de la versión v4.0

> **Garantizar la visibilidad absoluta del stack de producción mediante la recolección centralizada de métricas de infraestructura (Host de AWS) y rendimiento de datos (MySQL), implementando dashboards profesionales y un sistema de alertas proactivas capaz de identificar cuellos de botella de hardware y caídas de servicio de forma inmediata.**

Esta implementación evita la administración "a ciegas" de servidores, simulando los flujos de monitoreo y la gestión de incidentes propios de arquitecturas corporativas distribuidas a gran escala.

---

## 🛠️ Stack tecnológico

* **Cloud Infrastructure:** AWS Lightsail (Ubuntu Server)
* **Motor de Series Temporales:** Prometheus (Estrategia de Service Discovery interna)
* **Visualización y Alertas:** Grafana (Dashboards dinámicos + Alerting Engine)
* **Agentes de Extracción (Data Exporters):** Node Exporter (Sistema de archivos del Host) + MySQL Server Exporter (Métricas de la BBDD)
* **Runtime Stack:** WordPress (PHP-FPM 8.2 Alpine) + Nginx (Proxy Reverso) + MySQL 5.7
* **Pipeline Base:** GitHub Actions (CI/CD Automatizado)
* **Resiliencia:** Contenedor de Backups independiente hacia Amazon S3
* **Orquestación:** Docker Compose + Makefile Avanzado + Redes Aisladas

---

## 🏗️ Arquitectura de Observabilidad y Redes Aisladas

El stack de monitoreo está diseñado para no contaminar ni exponer públicamente las métricas del negocio. Prometheus descubre y "raspa" los datos a través de una red interna dedicada de Docker, garantizando que solo el puerto seguro de Grafana (`:3000`) sea accesible si se requiere auditoría visual externa.

```text
  [ Host AWS / SO ] ──> [ Node Exporter ]  ──┐
                                             ├──> [ Prometheus ] ──> [ Grafana ] (Puerto :3000)
  [ Base de Datos ] ──> [ MySQL Exporter ] ──┘     (Métricas Core)        (Dashboards + Alertas)
```

### Tabla de Separación de Responsabilidades Global

| Componente | Responsabilidad | Origen / Ubicación |
| :--- | :--- | :--- |
| **Docker Image** | Lógica de la aplicación, binarios del core y dependencias runtime. | Docker Hub (Compilado en CI) |
| **Amazon S3** | Persistencia a largo plazo de Dumps SQL y paquetes binarios `.tar.gz`. | Cloud S3 (Persistencia externa) |
| **backup-service** | Ejecución de tareas programadas y empaquetado de estados en caliente. | Microservicio aislado (Docker Stack) |
| **Prometheus / Grafana** | Recolección, almacenamiento temporal, modelado de datos y disparo de alertas. | Central de Monitoreo (Ecosistema Docker) |
| **Exporters (Node & MySQL)** | Instrumentación del hardware del host de AWS y variables de hilos/queries. | Agentes livianos integrados en runtime |
| **Volumen Host** | Fuente de verdad local acoplada al tiempo de ejecución de los contenedores. | `/opt/wordpress-runtime/` |

---

## ⚙️ Instrumentación y Recolección: Los Exporters

1. **Node Exporter**: Se despliega montando el sistema de archivos del host en modo lectura (`ro`). Captura en tiempo real métricas nativas de Linux: saturación de CPU, uso de memoria RAM latente, operaciones de Entrada/Salida de disco (IOPS) y tráfico de interfaces de red.
2. **MySQL Server Exporter**: Se conecta al contenedor `wp-mysql` compartiendo una red lógica. Se configuró un usuario con privilegios mínimos de lectura dentro del motor de base de datos para extraer variables críticas de rendimiento sin comprometer la seguridad (Conexiones activas, hilos de ejecución abiertos, consultas por segundo y el estado de vida del motor `mysql_up`).

---

## 🚨 Ingeniería de Alertas y Consultas en PromQL

Para transformar las métricas pasivas en un sistema de reacción proactivo, se definieron consultas en Prometheus Query Language (PromQL) encargadas de evaluar la salud del ecosistema:

* **Saturación de CPU Alta**: Alerta disparada si la capacidad disponible cae por debajo de los umbrales de seguridad operativos durante más de 1 minuto:

```Fragmento de código
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
```

* **Agotamiento de RAM Crítico**: Monitorea de manera porcentual la memoria real disponible en la máquina virtual de AWS Lightsail:

```Fragmento de código
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```

* **Caída del Servicio de Datos (Liveness Alert)**: Evalúa la métrica booleana provista por el agente de base de datos. Si el valor es cero, significa que la base de datos colapsó, disparando una notificación inmediata:

```Fragmento de código
mysql_up == 0
```

---

## 📊 Visualización Avanzada (Dashboards de Grafana)

Conectamos Prometheus de forma estricta como Data Source nativo en Grafana. Para evitar ruido visual y sobrecarga de datos, implementamos y personalizamos tableros basados en estándares de la industria:

* **Estado de Infraestructura (Linux Node)**: Basado en el estándar **ID 1860**, adaptado para reflejar de forma exacta los límites físicos del servidor cloud.
* **Estado del Motor de Datos (MySQL)**: Basado en el estándar **ID 14057**, visualizando el comportamiento de las consultas y la estabilidad transaccional de WordPress.

---

## 🚀 Guía de Operación y Validación

El proyecto mantiene la consistencia multi-entorno utilizando la capa de abstracción del Makefile.

### 🧪 1. Validación en Entorno Local de Desarrollo

Podés simular todo el ecosistema de monitoreo localmente para validar que Prometheus descubra los agentes de métricas correctamente:

```bash
cp .env.example .env.local
# Configurar llaves y secretos locales
make up-local ENV=local

# Validaciones internas:
# - Panel de Prometheus accesible en http://localhost:9090 (Verificar "Targets" en estado UP)
# - Interfaz de Grafana accesible en http://localhost:3000
```

### 🌍 2. Operación y Auditoría en Producción (AWS)

Toda la configuración se despliega de forma transparente a través de los flujos automatizados de Git. Si estás conectado al servidor y necesitás auditar el comportamiento de los contenedores de observabilidad:

```bash
make ps ENV=prod         # Verifica que Prometheus, Grafana y los Exporters estén estables
make logs ENV=prod       # Inspecciona la salida unificada ante problemas de red interna
```

---

## 🧠 Decisiones Técnicas Clave

* **Mínimo Privilegio en Capa de Datos**: El agente de MySQL no se conecta como `root`. Utiliza un usuario exclusivo con permisos limitados de lectura de tablas de estado, mitigando el riesgo de inyección de código sobre el motor de persistencia.
* **Service Discovery por DNS Interno**: En lugar de mapear IPs estáticas en el archivo `prometheus.yml`, se utilizó la resolución de nombres nativa de las redes de Docker (ej. `targets: ['node-exporter:9100', 'mysql-exporter:9104']`), logrando un entorno elástico y fácilmente escalable.
* **Optimización de Recursos**: Tanto Prometheus como Grafana fueron configurados para controlar los tiempos de retención de datos en disco, evitando que las series temporales saturen el almacenamiento limitado de la instancia de AWS.

---

## 📌 Estado Actual de la Infraestructura Global

✔ **Pipeline CI/CD robusto con empaquetado inmutable en Docker Hub (v2.1)**
✔ **Estrategia defensiva de Disaster Recovery validada hacia Amazon S3 (v3.0)**
✔ **Stack de Observabilidad completo e integrado nativamente al Compose (v4.0)**
✔ **Extracción activa de métricas del Sistema Operativo y Base de Datos (Node & MySQL)**
✔ **Reglas lógicas de alerta escritas en PromQL listas para producción (v4.0)**
✔ **Ecosistema de infraestructura maduro, seguro, medible y validado para Portfolio DevOps****

**Tag de Git definitivo**: `v4.0`

---

## 👤 Autor

Gerardo Mastramico
DevOps Junior
GitHub: <https://github.com/GerardMastra>
