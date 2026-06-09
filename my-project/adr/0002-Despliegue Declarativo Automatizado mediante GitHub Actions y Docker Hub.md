# ADR 0002: Despliegue Declarativo Automatizado mediante GitHub Actions y Docker Hub

## Estado

Aceptado

## Contexto

Las actualizaciones e intervenciones manuales imperativas por SSH o arrastres FTP provocan errores humanos, pérdida de tiempo operativo y caídas prolongadas de la plataforma (downtime), afectando de forma directa la reputación de la marca y la experiencia de los alumnos. Adicionalmente, compilar el código fuente en el servidor de producción (`docker compose build`) consume picos críticos de CPU y memoria RAM, arriesgando fallas por falta de memoria (*Out Of Memory*) e inestabilidad del sitio en runtime mientras los usuarios navegan.

## Decisión

Se decide implementar un pipeline automatizado de Integración Continua y Despliegue Continuo (CI/CD) end-to-end utilizando **GitHub Actions** como motor de automatización y **Docker Hub** como registro centralizado de imágenes bajo un enfoque de **Núcleo Inmutable**.

* **Integración Continua (CI)**: Al hacer push a las ramas principales (`main` o `dev`), el pipeline de GitHub empaqueta y compila el código estático agnóstico en una imagen optimizada basada en PHP-FPM Alpine, abstrayendo el contenido dinámico. La imagen se etiqueta usando el tag `latest` en combinación con el Commit SHA único de Git para garantizar trazabilidad criptográfica.
* **Despliegue Continuo (CD)**: El pipeline interactúa de forma segura con AWS a través de llaves SSH almacenadas en GitHub Secrets. Se elimina la compilación local en producción, sustituyéndola por un comando inmediato de descarga (`docker compose pull`) de la imagen precompilada.
* **Runtime Dinámico**: Se implementa un entrypoint personalizado (`docker-entrypoint-custom.sh`) que utiliza `envsubst` para inyectar variables de entorno (.env) en las plantillas de configuración en caliente durante el arranque.

## Consecuencias

* **Positivas:** Despliegues automatizados libres de errores humanos. Eliminación total del consumo de hardware ocioso por compilación en el servidor de producción. Reducción del tiempo de inactividad de la web durante actualizaciones a un micro-corte casi imperceptible de 2 a 5 segundos.
* **Negativas / Desafíos:** Introduce una dependencia operativa absoluta de la disponibilidad global de plataformas de terceros como GitHub Actions y Docker Hub para empaquetar y propagar nuevos cambios.
