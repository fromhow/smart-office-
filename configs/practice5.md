# Вентилятор FAN-01 в Node-RED

Файлы лежат в каталоге `practice5/`: приёмник версии 2 (`ctrl/receiver.js`, `ctrl/compose.yml`) и поток Node-RED (`node-red/fan-flow.json`).

## CTRL-01: приёмник v2

В `~/practice4/ctrl` заменён `receiver.js` (добавлен `POST /api/actuators`), `compose.yml` не менялся.

```
docker-compose -f compose.yml up -d --force-recreate
curl -i --connect-timeout 10 http://127.0.0.1:8080/health
docker-compose -f compose.yml logs -f --tail=20 receiver
```

Приёмник принимает `POST /api/actuators` в формате JSON: `actuator_id` (`FAN-01`), `zone` (`server_room`), `state` (`ON` или `OFF`), `mode` (`auto`), `timestamp`.

## IOT-01: поток Node-RED

Температура TEMP-01 формируется в диапазоне 20–40 °C каждые 5 секунд и уходит в приёмник на `/api/readings`. Тот же объект попадает в узел switch «TEMP-01 > 30 ?»:

- значение больше 30 идёт в узел change «FAN-01 ON»;
- значение 30 и меньше идёт в узел change «FAN-01 OFF».

В каждом из двух change правила Set заданы отдельно: `fan.state`, `fan.actuator_id` (`FAN-01`), `fan.zone` (`server_room`), `fan.mode` (`auto`), `fan.timestamp`, затем `payload` берётся из `fan`. Дальше узел http request отправляет сигнал на `http://192.168.10.11:8080/api/actuators`, ответ виден в debug.
