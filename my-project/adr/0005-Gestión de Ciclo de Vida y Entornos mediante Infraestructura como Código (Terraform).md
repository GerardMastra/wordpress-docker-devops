# ADR 0005: Gestión de Ciclo de Vida y Entornos mediante Infraestructura como Código (Terraform)

## Estado

Aceptado

## Contexto

El aprovisionamiento manual e imperativo de recursos de hardware en la consola web de un Cloud Provider induce a errores de configuración, inconsistencias en las políticas de seguridad de red y falta de trazabilidad. Asimismo, mantener recursos encendidos de forma innecesaria durante etapas de pruebas o desarrollo genera cobros inesperados y variables en la tarjeta de crédito (riesgos FinOps). Se requiere un mecanismo agnóstico, reproducible y declarativo para clonar o destruir todo el negocio en minutos.

## Decisión

Se decide codificar, modularizar y automatizar la totalidad del ciclo de vida de los recursos de AWS utilizando el paradigma de **Infraestructura como Código (IaC)** con **Terraform**, unificándolo con un pipeline multi-etapa en GitHub Actions.

* **Modelado Declarativo**: Toda la topología cloud (instancias EC2, políticas, buckets de Amazon S3, redes) se declara en archivos de configuración estructurados (`main.tf`, `variables.tf`, `outputs.tf`). El estado de la nube se valida y mantiene mediante planes de ejecución previsibles (`terraform plan`).
* **Seguridad como Código (Security as Code)**: Se definen de forma explícita las reglas de firewall a través de AWS Security Groups, bloqueando todo el tráfico entrante por defecto y abriendo restrictivamente solo los accesos esenciales (`:80`, `:443`, `:3000` y el puerto SSH seguro `:2222`).
* **Orquestación de Pipelines Multi-Stage**: El workflow de GitHub Actions se divide en trabajos encadenados secuencialmente mediante la directiva lógica `needs`. El *Stage 1 (IaC)* ejecuta de forma desatendida los cambios de Terraform (`terraform apply`) consumiendo las llaves desde GitHub Secrets. El *Stage 2 (Aplicación)* se dispara de manera condicionada si el Stage 1 finaliza con éxito.
* **Inyección Dinámica**: Se implementan mecanismos para capturar en caliente los outputs de Terraform (como la IP pública dinámica de la instancia EC2 recién aprovisionada) y transferirlos como variables de entorno operativas al runner encargado de ejecutar el despliegue del software.
* **Docker & Docker Compose**: Aporta aislamiento absoluto de los componentes (WordPress, Nginx, MySQL, phpMyAdmin), consistencia multi-entorno y portabilidad total del software.

## Consecuencias

* **Positivas:** Mitigación absoluta de sorpresas financieras al permitir levantar entornos idénticos de pruebas y destruirlos por completo con un solo comando (`terraform destroy`) al finalizar. Aislamiento estricto de ciclos de vida: las actualizaciones del código de la aplicación web (como temas de WordPress) no fuerzan la recreación del hardware de AWS si Terraform detecta que el estado de la nube permanece intacto, acelerando los despliegues diarios.
* **Negativas / Desafíos:** Mayor complejidad en la gestión inicial del pipeline y la necesidad de resguardar rigurosamente el archivo de estado de Terraform (`terraform.tfstate`) para evitar la desincronización o corrupción de la infraestructura real.
