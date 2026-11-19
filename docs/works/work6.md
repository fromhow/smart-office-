# SQLite на DB

Хранилище работает на DB-01 (192.168.20.13, порт 8081). Файлы лежат в каталоге `db/`, поток Node-RED – в `iot/flows.json`.

## DB-01: подготовка

Docker и Docker Compose уже установлены (работа 3), дополнительно ставится `sqlite`:

```
dnf install -y sqlite
sqlite3 --version
```

Четыре файла (`compose.yml`, `server.py`, `index.html`, `inspect_db.py`) лежат в одной папке `~/practice6/db`, рядом с подпапкой `data`.

## База данных

Базу `data/telemetry.sqlite3` с двумя таблицами создаёт `init.sql`:

```
mkdir -p data
sqlite3 data/telemetry.sqlite3 < init.sql
sqlite3 data/telemetry.sqlite3 ".tables"
sqlite3 data/telemetry.sqlite3 ".schema"
```

Таблица `measurements` создана по заданию, `actuator_events` содержит столбцы `id, source, device_id, zone, timestamp, received_at, state, mode`. Сам `server.py` таблицы не создаёт, а только проверяет структуру при запуске.

## Запуск

```
docker-compose -f compose.yml up -d
docker-compose -f compose.yml ps
curl -i http://127.0.0.1:8081/health
```

Веб-интерфейс: `http://192.168.20.13:8081/`.

## Node-RED

Показания TEMP-01, HUM-01 и сигналы FAN-01 уходят параллельно на CTRL (порт 8080) и на DB (порт 8081, адреса `/api/readings` и `/api/actuators`).

## Проверка SQL-запросами

```
sqlite3 data/telemetry.sqlite3 "SELECT COUNT(*) FROM measurements;"
sqlite3 data/telemetry.sqlite3 "SELECT id, device_id, metric, value, unit FROM measurements ORDER BY id DESC LIMIT 5;"
sqlite3 data/telemetry.sqlite3 "SELECT id, device_id, state, mode FROM actuator_events ORDER BY id DESC LIMIT 5;"
```
