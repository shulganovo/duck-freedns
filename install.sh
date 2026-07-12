#!/bin/sh

PATH=/opt/bin:/opt/sbin:/usr/bin:/bin:/sbin
export PATH

APP="duck-freedns"
SCRIPT="/opt/bin/duck_freedns.sh"
CONFIG="/opt/etc/duck-freedns.conf"
CRON="*/5 * * * * /opt/bin/duck_freedns.sh >> /opt/var/log/duck-freedns.log 2>&1"

echo "================================"
echo " DuckDNS + FreeDNS installer"
echo " for Entware / Keenetic"
echo "================================"
echo


# Проверка Entware

if [ ! -x /opt/bin/opkg ]; then
    echo "ERROR: Entware not found"
    exit 1
fi


echo "[1/5] Updating package list..."

opkg update


echo "[2/5] Installing dependencies..."

opkg install curl bind-dig


# Установка скрипта

echo "[3/5] Installing script..."

mkdir -p /opt/bin
mkdir -p /opt/etc
mkdir -p /opt/var/log
mkdir -p /opt/var/run


echo
echo "Copying duck_freedns.sh..."

cat > "$SCRIPT" <<'EOF'
PLACEHOLDER
EOF

chmod +x "$SCRIPT"


# Настройка

if [ ! -f "$CONFIG" ]; then

echo
echo "Creating configuration..."

echo
printf "DuckDNS domain: "
read DUCK_DOMAIN

printf "DuckDNS token: "
read DUCK_TOKEN

printf "FreeDNS domain: "
read FREE_DOMAIN

printf "FreeDNS update URL: "
read FREE_URL


cat > "$CONFIG" <<EOF
DUCK_DOMAIN="$DUCK_DOMAIN"
DUCK_TOKEN="$DUCK_TOKEN"

FREE_DOMAIN="$FREE_DOMAIN"
FREE_URL="$FREE_URL"
EOF


chmod 600 "$CONFIG"

fi


# Cron

echo "[4/5] Configuring cron..."

CRONFILE="/opt/etc/crontab"

touch "$CRONFILE"

grep -qxF "$CRON" "$CRONFILE" || echo "$CRON" >> "$CRONFILE"


# Запуск

echo "[5/5] Test update..."

"$SCRIPT"


echo
echo "================================"
echo " Installation complete"
echo " Config:"
echo " $CONFIG"
echo " Script:"
echo " $SCRIPT"
echo "================================"
