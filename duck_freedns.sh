#!/bin/sh

VERSION="1.0.0"

if [ "$1" = "--version" ]; then
    echo "duck_freedns.sh v$VERSION"
    exit 0
fi

PATH=/opt/bin:/opt/sbin:/usr/bin:/usr/sbin:/bin:/sbin
export PATH

CONFIG="/opt/etc/duck-freedns.conf"
LOG="/opt/var/log/duck-freedns.log"
IP_FILE="/opt/var/run/duck-freedns.ip"

# Проверка конфигурации
if [ ! -f "$CONFIG" ]; then
    echo "Configuration file not found: $CONFIG"
    exit 1
fi

. "$CONFIG"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S')  $*" >> "$LOG"
}

# Проверка обязательных параметров
if [ -z "$DUCK_DOMAIN" ] || [ -z "$DUCK_TOKEN" ] || \
   [ -z "$FREE_DOMAIN" ] || [ -z "$FREE_URL" ]; then
    log "ERROR: Configuration is incomplete."
    exit 1
fi

# Получение внешнего IP
get_ip() {

    for URL in \
        "https://api.ipify.org" \
        "https://ipv4.icanhazip.com" \
        "https://ifconfig.me/ip" \
        "https://checkip.amazonaws.com" \
        "https://ipinfo.io/ip"
    do
        IP=$(curl -4 -fsS --connect-timeout 5 --max-time 10 "$URL" 2>/dev/null | tr -d '\r\n')

        if echo "$IP" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
            log "IP detected via: $URL"
            echo "$IP"
            return 0
        fi
    done

    return 1
}

CURRENT_IP=$(get_ip)

if [ -z "$CURRENT_IP" ]; then
    log "ERROR: Unable to determine external IP."
    exit 1
fi

LAST_IP=""
[ -f "$IP_FILE" ] && LAST_IP=$(cat "$IP_FILE")

# IP не изменился
if [ "$CURRENT_IP" = "$LAST_IP" ]; then
    exit 0
fi

log "New IP: $CURRENT_IP"

########################################
# DuckDNS
########################################

DUCK_RESULT=$(curl -fsS \
"https://www.duckdns.org/update?domains=${DUCK_DOMAIN}&token=${DUCK_TOKEN}&ip=${CURRENT_IP}")

log "DuckDNS: $DUCK_RESULT"

########################################
# FreeDNS
########################################

FREE_RESULT=$(curl -fsS \
"${FREE_URL}&address=${CURRENT_IP}")

log "FreeDNS: $FREE_RESULT"

########################################

sleep 15

DUCK_IP=$(dig +short "${DUCK_DOMAIN}.duckdns.org" @1.1.1.1 | tail -1)
FREE_IP=$(dig +short "${FREE_DOMAIN}" @1.1.1.1 | tail -1)

FAILED=0

if [ "$DUCK_IP" != "$CURRENT_IP" ]; then
    log "DuckDNS verification failed ($DUCK_IP)"
    FAILED=1
fi

if [ "$FREE_IP" != "$CURRENT_IP" ]; then
    log "FreeDNS verification failed ($FREE_IP)"
    FAILED=1
fi

if [ "$FAILED" -eq 1 ]; then

    log "Retry update..."

    curl -fsS \
"https://www.duckdns.org/update?domains=${DUCK_DOMAIN}&token=${DUCK_TOKEN}&ip=${CURRENT_IP}" \
>/dev/null

    curl -fsS \
"${FREE_URL}&address=${CURRENT_IP}" \
>/dev/null

else

    echo "$CURRENT_IP" > "$IP_FILE"
    log "Update successful."

fi

exit 0
