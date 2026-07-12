#!/bin/sh

PATH=/opt/bin:/opt/sbin:/usr/bin:/bin:/sbin
export PATH

SCRIPT="/opt/bin/duck_freedns.sh"
CONFIG="/opt/etc/duck-freedns.conf"
LOG="/opt/var/log/duck-freedns.log"
CRON="/opt/etc/crontab"

echo "================================"
echo " DuckDNS + FreeDNS uninstall"
echo "================================"
echo


echo "Removing cron entry..."

if [ -f "$CRON" ]; then
    sed -i '\|/opt/bin/duck_freedns.sh|d' "$CRON"
fi


echo "Removing files..."

rm -f "$SCRIPT"
rm -f "$CONFIG"
rm -f "$LOG"


echo
echo "Uninstall complete."
echo
echo "Note:"
echo "Packages curl and bind-dig were not removed."
echo "They may be used by other Entware services."
