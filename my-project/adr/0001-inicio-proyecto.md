# ADR 0001: Selección de Contenedores Docker y Nube AWS como Arquitectura Base

## Estado

Aceptado

## Contexto

La aplicación web inicial del negocio corría sobre un hosting tradicional compartido ("caja negra"), experimentando caídas continuas (downtime inevitables durante actualizaciones), falta de resiliencia real ("el problema del vecino") y una rigidez absoluta de infraestructura que impedía automatizar copias de seguridad avanzadas independientes o escalar recursos de manera predecible. Para mitigar los riesgos de reputación y garantizar la continuidad del negocio, se requería migrar el sistema hacia una solución soberana, portable y escalable.

## Decisión

Decidimos migrar el stack tecnológico hacia una arquitectura basada en **Contenedores Docker** y desplegarla en el proveedor de nube **AWS (Amazon Web Services)**.

* **Docker:** Nos aporta aislamiento absoluto de los componentes (WordPress, Nginx, Base de Datos), consistencia multi-entorno y portabilidad de la aplicación, eliminando el bloqueo del proveedor (*vendor lock-in*).
* **AWS:** Elegido sobre competidores como Azure, GCP u OCI por ser el líder indiscutido del mercado en cuanto a madurez, documentación y estabilidad de sus servicios base (EC2, S3), garantizando soporte y compatibilidad absoluta con el ecosistema DevOps estándar de la industria.

## Consecuencias

* **Positivas:** Control total sobre el sistema operativo profundo, capacidad de automatizar la infraestructura, aislamiento de recursos del servidor y portabilidad del código hacia cualquier entorno en minutos.
* **Negativas / Desafíos:** Introduce la responsabilidad del mantenimiento, hardening y actualización del sistema operativo del host por nuestra cuenta, además de requerir una curva de aprendizaje técnica superior en comparación con un panel de control tradicional de hosting.
