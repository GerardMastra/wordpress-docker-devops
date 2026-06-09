# ADR 0003: Desacoplamiento de Datos Dinámicos y Almacenamiento en Búnker Duradero (Amazon S3)

## Estado

Aceptado

## Contexto

Los datos de salud, historiales clínicos e interacciones de los pacientes son información altamente sensible que no puede ponerse en riesgo bajo ninguna circunstancia. Si el motor de persistencia de la base de datos o los activos del negocio (`wp-content`) se encuentran acoplados al ciclo de vida del contenedor o expuestos a fallos físicos catastróficos del hardware del servidor de AWS, se quebraría el pilar de fiabilidad, resultando en pérdida destructiva de información confidencial y afectando la continuidad del negocio.

## Decisión

Se decide aislar por completo la capa de datos dinámicos mediante un esquema de desacoplamiento absoluto, delegando la persistencia de largo plazo fuera de la zona de disponibilidad del host hacia almacenamiento de objetos en **Amazon S3**.

* **Desacoplamiento Local**: Se migra la persistencia de la base de datos MySQL y el directorio `/wp-content` fuera del código de la app, mapeándolos a una ruta neutra y absoluta en el host (`/opt/wordpress-runtime/`). Si el contenedor de WordPress se destruye o actualiza, los datos permanecen intactos.
* **Microservicio Sidecar de Backup**: Se configura un servicio independiente (`backup-service`) en la orquestación de Docker Compose que comparte la red lógica interna con el motor de base de datos MySQL pero aísla por completo sus procesos.
* **Scripting Defensivo y Automatización**: El contenedor sidecar ejecuta scripts en Bash robustecidos con directivas estrictas de manejo de errores (`set -e`) para detener el flujo ante fallas de red. Estos extraen los dumps de la base de datos (`mysqldump`) y empaquetan los archivos mutables de forma recursiva en caliente.
* **Planificación y Transporte**: Se utiliza el demonio `cron` interno para calendarizar ejecuciones cíclicas desatendidas en producción. Los archivos comprimidos (`.sql.gz` y `.tar.gz`) son enviados cifrados al bucket seguro de Amazon S3 en la región `us-east-1` utilizando AWS CLI. Las credenciales y S3 Keys se inyectan con el principio de mínimo privilegio vía secretos protegidos.

## Consecuencias

* **Positivas:** Inviolabilidad, persistencia y durabilidad extrema de los datos (99.999999999% en S3) ante cualquier destrucción o fallo físico de la instancia. Capacidad de reconstruir el negocio desde cero descargando los datos históricos mediante llamadas automatizadas (`make restore-s3`) con asignación precisa de permisos Unix (`33:33`).
* **Negativas / Desafíos:** Introduce un pequeño costo variable incremental en la facturación mensual de AWS debido al almacenamiento de objetos y las transferencias de datos salientes hacia S3.
