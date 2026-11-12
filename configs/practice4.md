# Приёмник показаний и Node-RED

Приёмник работает на CTRL-01 (192.168.10.11, порт 8080), Node-RED на IOT-01 (192.168.30.14, порт 1880). Файлы лежат в каталоге `practice4/`.

## CTRL-01: приёмник

Каталог `~/practice4/ctrl`, файлы `compose.yml` и `receiver.js` (образ `node:22-alpine`).

```
docker-compose -f compose.yml up -d
docker-compose -f compose.yml ps
curl -i --connect-timeout 10 http://127.0.0.1:8080/health
docker-compose -f compose.yml logs -f --tail=20 receiver
```

Приёмник принимает `POST /api/readings` в формате JSON: `sensor_id` (`TEMP-01` или `HUM-01`), `zone`, `unit`, `value`, `timestamp`.

Журнал и список контейнеров:

```
docker-compose -f compose.yml logs --no-color --tail=100 receiver > ~/practice4/receiver-log.txt
docker-compose -f compose.yml ps > ~/practice4/ctrl-containers.txt
```

## IOT-01: Node-RED

Каталог `~/practice4/iot`, файл `compose.yml` (образ `nodered/node-red`, том `node_red_data`).

```
docker-compose -f compose.yml up -d
docker-compose -f compose.yml ps
```

С WIN-01 Node-RED открывается по адресу `http://192.168.30.14:1880`.

## Датчики

Поток `practice4/node-red/sensors-flow.json` содержит два датчика, каждый по цепочке `inject → change → http request → debug`. Запуск каждые 5 секунд.

| Датчик | Зона | Единица | Значение |
|---|---|---|---|
| TEMP-01 | server_room | C | случайное 20–30 |
| HUM-01 | work_area | % | случайное 40–70 |

Узел `change` формирует показание отдельными правилами `Set`:

| Правило | Значение |
|---|---|
| `msg.payload` | `{}` (JSON) |
| `msg.payload.sensor_id` | `TEMP-01` или `HUM-01` (строка) |
| `msg.payload.zone` | `server_room` или `work_area` (строка) |
| `msg.payload.unit` | `C` или `%` (строка) |
| `msg.payload.value` | `$round($random()*10+20,1)` или `$round($random()*30+40,1)` (выражение) |
| `msg.payload.timestamp` | время (тип timestamp) |

Показания отправляются на `http://192.168.10.11:8080/api/readings`.
