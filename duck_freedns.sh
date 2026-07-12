#!/bin/sh

PATH=/opt/bin:/opt/sbin:/usr/bin:/bin:/sbin
export PATH

CONFIG="/opt/etc/duck-freedns.conf"
LOG="/opt/var/log/duck-freedns.log"
IP_FILE="/opt/var/run/duck-freedns.ip"

if [ ! -f "$CONFIG" ]; then
    echo "Config not found: $CONFIG"
    exit 1
fi

. "$CONFIG"

log()
{
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

CURRENT_IP=$(curl -4 -fsS https://api.ipify.org)

if [ -z "$CURRENT_IP" ]; then
    log "ERROR: Cannot get external IP"
    exit 1
fi

OLD_IP=""

[ -f "$IP_FILE" ] && OLD_IP=$(cat "$IP_FILE")

if [ "$CURRENT_IP" = "$OLD_IP" ]; then
    exit 0
fi


log "IP changed: $OLD_IP -> $CURRENT_IP"


# DuckDNS

if [ -n "$DUCK_DOMAIN" ] && [ -n "$DUCK_TOKEN" ]; then

    RESULT=$(curl -fsS \
    "https://www.duckdns.org/update?domains=${DUCK_DOMAIN}&token=${DUCK_TOKEN}&ip=${CURRENT_IP}")

    log "DuckDNS: $RESULT"

fi


# FreeDNS

if [ -n "$FREE_URL" ]; then

    RESULT=$(curl -fsS \
    "${FREE_URL}&address=${CURRENT_IP}")

    log "FreeDNS: $RESULT"

fi


sleep 15


# Проверка DNS

FAILED=0


if [ -n "$DUCK_DOMAIN" ]; then

    DUCK_IP=$(dig +short "${DUCK_DOMAIN}.duckdns.org" @1.1.1.1 | tail -1)

    if [ "$DUCK_IP" != "$CURRENT_IP" ]; then
        log "DuckDNS verification failed"
        FAILED=1
    fi

fi


if [ -n "$FREE_DOMAIN" ]; then

    FREE_IP=$(dig +short "$FREE_DOMAIN" @1.1.1.1 | tail -1)

    if [ "$FREE_IP" != "$CURRENT_IP" ]; then
        log "FreeDNS verification failed"
        FAILED=1
    fi

fi


if [ "$FAILED" = "1" ]; then

    log "Retry update"

    [ -n "$DUCK_TOKEN" ] && \
    curl -fsS \
    "https://www.duckdns.org/update?domains=${DUCK_DOMAIN}&token=${DUCK_TOKEN}&ip=${CURRENT_IP}" \
    >> "$LOG"

    [ -n "$FREE_URL" ] && \
    curl -fsS \
    "${FREE_URL}&address=${CURRENT_IP}" \
    >> "$LOG"

else

    echo "$CURRENT_IP" > "$IP_FILE"
    log "SUCCESS: $CURRENT_IP"

fi

exit 0
