#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script debe ejecutarse como root. Usá: sudo ./scripts/bootstrap.sh"
  exit 1
fi

set -e

echo "🚀 Iniciando bootstrap del servidor..."

# =========================
# Variables de entorno
# =========================
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# =========================
# Actualización del sistema
# =========================
echo "🔄 Actualizando sistema..."
apt update -y
apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# =========================
# Instalación de Docker
# =========================
if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Instalando Docker..."
  apt install -y docker.io
  systemctl enable docker
  systemctl start docker
else
  echo "✅ Docker ya está instalado"
fi

# =========================
# Instalación de Docker Compose
# =========================
if ! command -v docker-compose >/dev/null 2>&1; then
  echo "🧩 Instalando Docker Compose..."
  apt install -y docker-compose
else
  echo "✅ Docker Compose ya está instalado"
fi

# =========================
# Permisos de Docker
# =========================
if ! getent group docker >/dev/null; then
  groupadd docker
fi

usermod -aG docker "${SUDO_USER:-$USER}"

echo "🎉 Bootstrap completado. Cerrá sesión y volvé a entrar para aplicar permisos Docker."

