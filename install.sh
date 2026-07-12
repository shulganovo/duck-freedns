#!/bin/sh

PATH=/opt/bin:/opt/sbin:/usr/bin:/usr/sbin:/bin:/sbin
export PATH

SCRIPT_URL="https://raw.githubusercontent.com/shulganovo/duck-freedns/main/duck_freedns.sh"

SCRIPT="/opt/bin/duck_freedns.sh"
CONFIG="/opt/etc/duck-freedns.conf"
LOG="/opt/var/log/duck-freedns.log"
CRONFILE="/opt/etc/crontab"

echo "========================================="
echo " DuckDNS + FreeDNS installer"
echo "========================================="
echo

# Проверка Entware

if [ ! -x /opt/bin/opkg ]; then
    echo "ERROR: Entware is not installed."
    exit 1
fi

echo "[1/6] Updating package list..."
opkg update

echo
echo "[2/6] Installing required packages..."
opkg install curl bind-dig

echo
echo "[3/6] Downloading script..."

mkdir -p /opt/bin
mkdir -p /opt/etc
mkdir -p /opt/var/log
mkdir -p /opt/var/run

if ! curl -fsSL "$SCRIPT_URL" -o "$SCRIPT"; then
    echo "ERROR: Cannot download duck_freedns.sh"
    exit 1
fi

chmod +x "$SCRIPT"

echo
echo "[4/6] Creating configuration..."

if [ ! -f "$CONFIG" ]; then

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

else
    echo "Configuration already exists."
fi

echo
echo "[5/6] Installing cron task..."

CRON='*/5 * * * * /opt/bin/duck_freedns.sh >> /opt/var/log/duck-freedns.log 2>&1'

touch "$CRONFILE"

grep -F "$CRON" "$CRONFILE" >/dev/null 2>&1 || echo "$CRON" >> "$CRONFILE"

echo
echo "[6/6] Test run..."

"$SCRIPT"

echo
echo "========================================="
echo "Installation completed successfully."
echo
echo "Script : $SCRIPT"
echo "Config : $CONFIG"
echo "Log    : $LOG"
echo "========================================="
