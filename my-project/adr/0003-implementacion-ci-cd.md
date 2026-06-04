# ADR 0003: Pipeline de Despliegue con Núcleo Inmutable basado en GitHub Actions y Docker Hub

## Estado

Aceptado

## Contexto

En las primeras versiones del despliegue (v2.0), el pipeline automatizado ejecutaba tareas imperativas de compilación (`docker compose build`) directamente en el servidor de producción de AWS. Esto generaba un consumo latente y crítico de CPU y memoria RAM dentro de la instancia de cómputo durante las actualizaciones, provocando micro-cortes indeseados, degradación de la experiencia del usuario (UX) o fallas de falta de memoria (*Out Of Memory*) en el servidor mientras los usuarios intentaban navegar por la web.

## Decisión

Decidimos implementar un rediseño de arquitectura bajo el enfoque de **Núcleo Inmutable** utilizando **GitHub Actions** como motor de Integración Continua (CI) y **Docker Hub** como registro de imágenes centralizado.

* El proceso de empaquetado y compilación se extrae por completo del servidor de producción y se delega a los runners de GitHub, quienes construyen una imagen optimizada basada en PHP-FPM Alpine.
* La imagen se etiqueta con el Commit SHA único de Git para asegurar trazabilidad criptográfica y se publica en Docker Hub.
* El pipeline de Despliegue Continuo (CD) en el servidor se limita a realizar un comando inmediato de descarga (`docker compose pull`), refrescando los contenedores en runtime de forma instantánea.

## Consecuencias

* **Positivas:** El tiempo de inactividad de la web durante una actualización se redujo a un micro-corte imperceptible de entre 2 y 5 segundos (lo que tarda el contenedor inmutable en reiniciarse). Se eliminó por completo el consumo de recursos de hardware ocioso por compilación en el servidor de AWS.
* **Negativas / Desafíos:** Introduce dependencia externa de servicios de terceros (el pipeline no se ejecutará si Docker Hub o GitHub Actions sufren una caída en sus plataformas globales).
