# DuckDNS + FreeDNS updater для Entware

Автоматическое обновление динамического DNS для роутеров Keenetic с установленным Entware.

Выбор пал на ddns сервисы https://www.duckdns.org/ и https://freedns.afraid.org/ из-за бесплатного обслуживания и необходимости переподтверждения аккаунта каждый месяц.

Создан для тех, кому нужен доступ к домашней сети, своим впн сервисам и тем, кто не может настроить режим моста (или bridge) на провайдерском роутере.

Скрипт обновляет записи **DuckDNS** и **FreeDNS (afraid.org)** при изменении внешнего IP-адреса.

## Возможности

- автоматическое обновление DuckDNS;
- автоматическое обновление FreeDNS;
- работа с динамическим внешним IP;
- проверка изменения IP перед обновлением;
- проверка успешного обновления DNS через `dig`;
- повторная попытка при ошибке обновления;
- запуск через cron;
- отдельный файл конфигурации;
- совместимость с Keenetic + Entware.

---

## Требования

Необходимо:

- роутер Keenetic;
- установленный Entware;
- доступ в интернет.

Необходимые пакеты:

```sh
opkg update
opkg install curl bind-dig
```

Проверка установленных утилит:

```sh
which curl
which dig
```

Ожидаемый результат:

```text
/opt/bin/curl
/opt/bin/dig
```

---

## Установка

Запустите установщик одной командой:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/shulganovo/duck-freedns/main/install.sh)"
```

или:

```sh
wget -qO- https://raw.githubusercontent.com/shulganovo/duck-freedns/main/install.sh | sh
```

Во время установки будут запрошены:

- домен DuckDNS;
- токен DuckDNS;
- домен FreeDNS;
- ссылка обновления FreeDNS.

Ваши личные данные сохраняются только на роутере:

```text
/opt/etc/duck-freedns.conf
```

Токены и персональные настройки не хранятся в GitHub.

---

## Конфигурация

Файл настроек:

```text
/opt/etc/duck-freedns.conf
```

Пример:

```sh
DUCK_DOMAIN="your-domain"
DUCK_TOKEN="your-duckdns-token"

FREE_DOMAIN="your-domain.example.com"
FREE_URL="https://freedns.afraid.org/dynamic/update.php?your-key"
```

Для защиты файла:

```sh
chmod 600 /opt/etc/duck-freedns.conf
```

---

## Ручной запуск

Запустить обновление вручную:

```sh
/opt/bin/duck_freedns.sh
```

---

## Логи

Файл журнала:

```text
/opt/var/log/duck-freedns.log
```

Просмотр лога:

```sh
cat /opt/var/log/duck-freedns.log
```

Последние записи:

```sh
tail -50 /opt/var/log/duck-freedns.log
```

---

## Автоматическое обновление

После установки создается задача cron:

```cron
*/5 * * * * /opt/bin/duck_freedns.sh >> /opt/var/log/duck-freedns.log 2>&1
```

Скрипт запускается каждые 5 минут и обновляет DNS только при изменении внешнего IP.

---

## Удаление

Для удаления проекта:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/shulganovo/duck-freedns/main/uninstall.sh)"
```

или:

```sh
/opt/bin/uninstall.sh
```

Удаляются:

- скрипт обновления;
- файл конфигурации;
- лог-файл;
- запись cron.

Пакеты Entware (`curl`, `bind-dig`) не удаляются, так как они могут использоваться другими сервисами.

---

## Безопасность

В репозитории отсутствуют:

- токены DuckDNS;
- ключи FreeDNS;
- персональные домены;
- IP-адреса;
- файлы логов.

Все персональные настройки хранятся только на локальном роутере.

---

## Структура проекта

```text
duck-freedns
|
├── duck_freedns.sh
├── install.sh
├── uninstall.sh
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

---

## Лицензия

MIT License
