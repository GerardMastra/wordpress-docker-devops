# ADR 0004: Monitoreo Proactivo Basado en el Modelo de Raspado (Prometheus + Grafana)

## Estado

Aceptado

## Contexto

En infraestructuras tradicionales, enterarse de las degradaciones de rendimiento, la saturación de memoria o la caída total de la plataforma a través de reclamos y mensajes de clientes frustrados daña gravemente la reputación de la marca, rompe la experiencia premium buscada y denota una administración reactiva e ineficiente. Se requiere visibilidad técnica en tiempo real y telemetría centralizada para anticiparse a los incidentes.

## Decisión

Se decide diseñar e integrar una solución transversal de observabilidad en tiempo real basada en el patrón de recolección por raspado (pulling) utilizando el stack compuesto por **Prometheus y Grafana** dentro de la misma orquestación del servidor.

* **Aislamiento y Service Discovery**: Se configuran redes lógicas internas en Docker para que Prometheus descubra y extraiga métricas dinámicamente mediante DNS interno. Se restringe por completo el perímetro exterior, exponiendo de forma pública única y exclusivamente el puerto `:3000` correspondiente a la interfaz de visualización de Grafana.
* **Instrumentación de Infraestructura (Host)**: Se despliega el agente `Node Exporter` montando volúmenes del sistema de archivos del host en modo estricto de lectura para capturar el rendimiento de hardware (consumo de CPU, saturación de RAM, operaciones de E/S de disco).
* **Instrumentación de Persistencia (DB)**: Se interconecta el contenedor `MySQL Server Exporter` aplicando el principio de mínimo privilegio, utilizando un usuario limitado que extrae variables críticas de rendimiento (queries por segundo, conexiones e hilos activos).
* **Ingeniería de Alertas en PromQL**: Se configura el archivo `prometheus.yml` fijando los intervalos de scraping. Se modelan consultas matemáticas lógicas en Prometheus Query Language (PromQL) para disparar alertas inmediatas ante anomalías críticas (como la regla booleana `mysql_up == 0` para detectar la caída de la base de datos o fórmulas de saturación de CPU y RAM).

## Consecuencias

* **Positivas:** Alerta temprana e inmediata de incidentes directo en tu panel de control centralizado antes de que impacte a la disponibilidad de los alumnos. Diagnóstico visual e histórico preciso de cuellos de botella mediante tableros profesionales consolidados de la industria (Dashboards ID 1860 e ID 14057).
* **Negativas / Desafíos:** Consumo mínimo pero constante de un porcentaje de la CPU y la memoria RAM de la instancia de AWS para sostener los procesos activos de los exportadores y el motor de series temporales de Prometheus.
