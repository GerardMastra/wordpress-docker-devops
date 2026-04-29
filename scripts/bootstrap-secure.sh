#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script debe ejecutarse como root."
  exit 1
fi

set -e

echo "🚀 Iniciando bootstrap del servidor..."

# =========================
# Variables de entorno
# =========================
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# ========================
# SWAP (idempotente)
# ========================
if [ ! -f /swapfile ]; then
  echo "🧠 Creando swap..."
  fallocate -l 1G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
else
  echo "✅ Swap ya existe"
fi

# =========================
# Update & Upgrade
# =========================
echo "🔄 Actualizando sistema..."
apt update -y
apt full-upgrade -y \
  -o Dpkg::Options::="--force-confdef" \
  -o Dpkg::Options::="--force-confold"

# =========================
# Tools básicas
# =========================
echo "🛠️ Instalando herramientas base..."
apt install -y make unzip ca-certificates curl gnupg lsb-release

# =========================
# AWS CLI v2
# =========================
if ! command -v aws >/dev/null 2>&1; then
  echo "☁️ Instalando AWS CLI v2..."
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  ./aws/install
  rm -rf awscliv2.zip aws/
else
  echo "✅ AWS CLI ya está instalado"
fi

# =========================
# Docker (repo oficial)
# =========================
echo "🐳 Instalando Docker..."

mkdir -p /etc/apt/keyrings

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt update -y

if ! command -v docker >/dev/null 2>&1; then
  apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable docker
  systemctl start docker
else
  echo "✅ Docker ya está instalado"
fi

# =========================
# Permisos Docker
# =========================
echo "👤 Configurando usuario para Docker..."

if ! getent group docker >/dev/null; then
  groupadd docker
fi

usermod -aG docker ubuntu

# =========================
# Automatizar DNS con Verificación
# =========================
echo "🌐 Configurando DuckDNS..."

DUCKDNS_DOMAIN="gerardo-devops-wp"
DUCKDNS_TOKEN="TU_TOKEN" # Asegúrate de usar tu token real o variable

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

# Intentar actualización hasta que sea exitosa
for i in {1..5}; do
    RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=$DUCKDNS_DOMAIN&token=$DUCKDNS_TOKEN&ip=$PUBLIC_IP")
    if [ "$RESPONSE" = "OK" ]; then
        echo "✅ API de DuckDNS respondió OK"
        break
    fi
    echo "⚠️ Intento $i: Fallo en API DuckDNS, reintentando..."
    sleep 5
done

# VERIFICACIÓN DE PROPAGACIÓN
echo "🔍 Verificando propagación DNS local..."
for i in {1..12}; do
    RESOLVED_IP=$(dig +short ${DUCKDNS_DOMAIN}.duckdns.org @8.8.8.8 | tail -n1)
    if [ "$RESOLVED_IP" = "$PUBLIC_IP" ]; then
        echo "✅ DNS propagado: $RESOLVED_IP"
        break
    fi
    echo "⏳ Esperando propagación (Actual: $RESOLVED_IP | Esperada: $PUBLIC_IP)..."
    sleep 10
done

# =========================
# Firewall (UFW)
# =========================
echo "🔥 Configurando firewall..."

ufw default deny incoming
ufw default allow outgoing

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable

# Crear señal de finalización
touch /var/log/bootstrap_finished

echo "🎉 Bootstrap completado correctamente."
