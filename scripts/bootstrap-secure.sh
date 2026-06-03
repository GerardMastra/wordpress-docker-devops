#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script debe ejecutarse como root. Usá: sudo ./scripts/bootstrap-secure.sh"
  exit 1
fi

# 1. Seguridad de ejecución: Detener el script si hay errores
set -e

echo "🚀 Iniciando bootstrap del servidor..."

# =========================
# 2. Configurar variables de entorno para automatización
# =========================
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# =========================
# 3. Bootstrap seguro + hardening básico: Actualización profunda
# =========================
echo "🔄 Actualizando sistema..."
apt update -y
apt full-upgrade -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold"

# =========================
# 4. Instalación de Docker desde Repositorios Oficiales (Hardening de Suministro)
# =========================
# En lugar de usar docker.io (que puede ser antiguo), usamos el repo de Docker
# para garantizar que recibimos parches de seguridad rápidos.
echo "--- Instalando dependencias y certificados oficiales ---"
apt install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

if ! command -v docker >/dev/null 2>&1; then
 echo "🐳 Instalando Docker y Docker Compose..."
 apt update -y
 apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
 systemctl enable docker
 systemctl start docker

else
  echo "✅ Docker ya está instalado"
fi

# =========================
# 5. Configuración de acceso a Docker
# =========================
if ! getent group docker >/dev/null; then
  groupadd docker
fi
# NOTA: pertenecer al grupo docker implica privilegios equivalentes a root.
usermod -aG docker "${SUDO_USER:-$USER}"

# =========================
# 6. Hardening de Red local: Firewall (UFW)
# =========================
# Cerramos todo excepto lo estrictamente necesario
echo "--- Configurando Firewall (UFW) ---"
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp
ufw allow http
ufw allow https
ufw --force enable

echo "🎉 Bootstrap completado. Cerrá sesión y volvé a entrar para aplicar permisos Docker."

