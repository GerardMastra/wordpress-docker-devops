# ADR 0001: Migración a AWS bajo el modelo Single-Instance Dockerizada

## Estado

Aceptado

## Contexto

La aplicación web del negocio corría sobre un hosting tradicional compartido ("caja negra"), experimentando caídas continuas debido a picos de tráfico de terceros ("el problema del vecino"), falta de control del sistema operativo profundo, actualizaciones manuales lentas vía FTP que generaban downtime prolongado y una rigidez absoluta para automatizar copias de seguridad avanzadas independientes. Para mitigar los riesgos de reputación y garantizar la continuidad del negocio con una experiencia de usuario premium, se requería migrar el sistema hacia una solución soberana, portable y eficiente en costos. Levantar una infraestructura multi-servicio nativa con bases de datos administradas (AWS RDS) y balanceadores de carga tradicionales resulta prohibitiva en presupuesto para esta etapa del negocio.

## Decisión

Se decide migrar el stack tecnológico hacia una arquitectura basada en **Contenedores Docker** (imágenes optimizadas basadas en Alpine) y desplegarla de forma centralizada en una única instancia dedicada **AWS EC2 (Familia Linux t3.micro/nano)**.

* **SO Linux**: Seleccionado por la natividad del stack LEMP/LAMP, su alta eficiencia en consumo de recursos en comparación con Windows Server (permitiendo instancias más pequeñas y económicas) y la nulidad de costos de licenciamiento (TCO).
* **AWS**: Elegido sobre Azure, GCP u OCI por ser el líder indiscutido del mercado en cuanto a madurez, documentación comunitaria y estabilidad de sus servicios base (EC2, S3), asegurando soporte absoluto con el ecosistema DevOps estándar.
* **Docker & Docker Compose**: Nos aporta aislamiento absoluto de los componentes (WordPress, Nginx, MySQL, phpMyAdmin), consistencia multi-entorno y portabilidad total del software.

## Consecuencias

* **Positivas:** Control absoluto del entorno profundo del servidor, reducción radical de costos al no pagar licencias de software, aprovechamiento máximo del hardware disponible por la ausencia de interfaces gráficas ociosas y portabilidad total del código.
* **Negativas / Desafíos:** Toda la responsabilidad de la administración del servidor, la aplicación de parches de seguridad del Host, el endurecimiento (hardening) de la red y el diseño de los esquemas de backups recae por completo sobre el código propio.
