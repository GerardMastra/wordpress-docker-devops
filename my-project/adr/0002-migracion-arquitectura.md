# ADR 0002: Mitigación de Costos y Complejidad Técnica mediante Escalado Vertical Manual (FinOps)

## Estado

Aceptado

## Contexto

Al tratarse de un proyecto independiente que se autosolventa, el presupuesto financiero debe mantenerse al mínimo necesario para satisfacer las necesidades del negocio. Una infraestructura de alta disponibilidad corporativa típica (con múltiples nodos distribuidos, balanceadores de carga nativos y Auto Scaling dinámico en la nube) introduce una complejidad técnica extrema (sincronización de archivos multimedia en tiempo real, manejo de sesiones persistentes) y costos fijos por hora sumamente elevados, los cuales se encontrarían ociosos el 95% del tiempo.

## Decisión

Decidimos rechazar la configuración automática de Auto Scaling y Load Balancers, optando en su lugar por una arquitectura de **Instancia Única Optimizada (Derecho de Dimensionamiento / Right-sizing)**, mitigando la concurrencia de picos de tráfico en lanzamientos mediante **Escalado Vertical Manual**.

* Ante un lanzamiento de cursos coordinado o envíos masivos de correos, se aplica FinOps manual: se apaga temporalmente el servidor minutos antes del evento, se incrementan los recursos de CPU y RAM del plano de la instancia desde la consola de AWS en un par de clics, se ejecuta el evento de alta concurrencia de forma fluida y, al día siguiente, se devuelve la instancia a su tamaño económico base (t3.micro / t3.small).

## Consecuencias

* **Positivas:** Costos mensuales predecibles, eliminación de cobros variables imprevistos en la tarjeta de crédito y simplificación drástica del código de infraestructura sin añadir capas complejes de red.
* **Negativas / Desafíos:** Requiere una intervención manual programada de unos minutos antes y después de eventos críticos de negocio, generando un micro-corte controlado durante el cambio de tamaño de la instancia.
