#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"
else
  echo "ℹ️  $ENV_FILE mevcut, güncellenecek"
fi

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
set_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "MAILCATCHER_SERVER_HOSTNAME (örn: mail.example.com): " MAILCATCHER_SERVER_HOSTNAME

# --------------------------------------------------
# Docker Network
# --------------------------------------------------
NETWORK_NAME="mail-network"
if docker network inspect "$NETWORK_NAME" > /dev/null 2>&1; then
  echo "ℹ️  Docker network '$NETWORK_NAME' zaten mevcut"
else
  docker network create "$NETWORK_NAME"
  echo "✅ Docker network '$NETWORK_NAME' oluşturuldu"
fi

# --------------------------------------------------
# .env Güncelle
# --------------------------------------------------
set_env MAILCATCHER_SERVER_HOSTNAME "$MAILCATCHER_SERVER_HOSTNAME"

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "✅ MailCatcher .env başarıyla hazırlandı!"
echo "-----------------------------------------------"
echo "🌐 Hostname   : https://$MAILCATCHER_SERVER_HOSTNAME"
echo "-----------------------------------------------"
echo "📧 SMTP ayarları (test edilecek servise gir):"
echo "   Host : mailcatcher"
echo "   Port : 1025"
echo "   TLS  : Kapalı"
echo "   Auth : Yok"
echo "-----------------------------------------------"
echo "🔗 Test edilecek servisi $NETWORK_NAME'e ekle:"
echo "   networks:"
echo "     - $NETWORK_NAME"
echo "==============================================="
