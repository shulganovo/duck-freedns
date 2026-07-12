# DuckDNS + FreeDNS updater for Entware

Automatic DuckDNS and FreeDNS dynamic DNS updater for Keenetic routers running Entware.

## Features

- Updates DuckDNS and FreeDNS records automatically
- Works with dynamic public IP addresses
- Detects IP changes before updating
- Verifies DNS update using `dig`
- Automatic retry if verification fails
- Runs from cron
- Keeps configuration separate from scripts
- Designed for Keenetic routers with Entware

---

## Requirements

- Keenetic router
- Entware installed
- Internet connection

Required packages:

```sh
opkg update
opkg install curl bind-dig

Check installed utilities:
which curl
which dig

Expected result:

/opt/bin/curl
/opt/bin/dig
Installation

Run the installer:

sh -c "$(curl -fsSL https://raw.githubusercontent.com/shulganovo/duck-freedns/main/install.sh)"

or:

wget -qO- https://raw.githubusercontent.com/shulganovo/duck-freedns/main/install.sh | sh

During installation you will be asked for:

DuckDNS domain
DuckDNS token
FreeDNS domain
FreeDNS update URL

Your personal data is stored only on your router:

/opt/etc/duck-freedns.conf

Your tokens and private settings are not stored in this GitHub repository.

Configuration

Configuration file:

/opt/etc/duck-freedns.conf

Example:

DUCK_DOMAIN="your-domain"
DUCK_TOKEN="your-duckdns-token"

FREE_DOMAIN="your-domain.example.com"
FREE_URL="https://freedns.afraid.org/dynamic/update.php?your-key"

File permissions:

chmod 600 /opt/etc/duck-freedns.conf
Manual run

Run the updater manually:

/opt/bin/duck_freedns.sh
Logs

Log file:

/opt/var/log/duck-freedns.log

View log:

cat /opt/var/log/duck-freedns.log

or:

tail -50 /opt/var/log/duck-freedns.log
Automatic updates

The installer creates a cron task:

*/5 * * * * /opt/bin/duck_freedns.sh >> /opt/var/log/duck-freedns.log 2>&1

The script runs every 5 minutes and updates DNS records only when the public IP address changes.

Uninstall

Remove the project:

sh -c "$(curl -fsSL https://raw.githubusercontent.com/shulganovo/duck-freedns/main/uninstall.sh)"

or run:

/opt/bin/uninstall.sh

The uninstall script removes:

updater script;
configuration file;
log file;
cron entry.

Entware packages are not removed because they may be used by other services.

Security

This repository does not contain:

DuckDNS tokens;
FreeDNS keys;
personal domains;
IP addresses;
log files.

All private configuration stays on the local router.

Project structure
duck-freedns
│
├── duck_freedns.sh
├── install.sh
├── uninstall.sh
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
License

MIT License
