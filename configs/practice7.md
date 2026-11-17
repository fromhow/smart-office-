# Prometheus и Grafana на MON

MON-01 (192.168.20.12) собирает метрики приложения на CTRL-01 (192.168.10.11:8080). Prometheus и Grafana установлены как системные службы, Docker для мониторинга не используется. Файлы лежат в `practice7/`.

## CTRL: приёмник версии 3

`receiver.js` версии 3 добавляет `/metrics` в формате Prometheus. Перед заменой сделана резервная копия прежнего файла, контейнер пересоздан.

```
curl -i http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/metrics
```

С MON-01 адрес `http://192.168.10.11:8080/metrics` тоже открывается. Отправка из Node-RED на CTRL и запись в SQLite на DB продолжают работать.

## MON: установка

```
dnf install -y golang-github-prometheus grafana
```

На MON-01 предварительно были заданы DNS-серверы (`nmcli connection modify ... ipv4.dns "10.0.0.41 10.0.0.42"`), без них репозиторий не открывался.

## Prometheus

Конфигурация `/etc/prometheus/prometheus.yml` (копия – `practice7/monitoring/prometheus.yml`): job `office-controller`, цель `192.168.10.11:8080`, путь `/metrics`, интервал 5 с, таймаут 4 с (меньше интервала). Проверка:

```
promtool check config /etc/prometheus/prometheus.yml
```

Служба `/etc/systemd/system/prometheus.service` (копия – `practice7/monitoring/prometheus.service`): бинарник `/usr/bin/prometheus`, пользователь `prometheus`, каталог данных `/var/lib/prometheus`.

```
systemctl daemon-reload
systemctl enable --now prometheus
systemctl is-active prometheus
```

Интерфейс: `http://192.168.20.12:9090`, цель `office-controller` в Status → Targets имеет состояние UP.

## Grafana

```
systemctl enable --now grafana-server
```

Интерфейс: `http://192.168.20.12:3000`. Источник данных создан файлом provisioning `/etc/grafana/provisioning/datasources/datasource.yml` (копия – `practice7/monitoring/datasource.yml`), uid `prometheus-office`. Панель импортирована из `practice7/grafana/dashboard_teacher.json`.

## Проверка показателей

Запросы в Prometheus: `office_temperature_celsius`, `office_humidity_percent`, `office_control_mode_auto`, `office_fan_on`, `office_sensor_last_reading_timestamp_seconds`, `office_sensor_age_seconds`. При температуре 25 вентилятор выключен, при 35 включён (значение `office_fan_on` меняется 0 → 1).

## Оповещения

Описание правил – в `practice7/grafana/alert-rules.md`. Почта: SMTP задан в секции `[smtp]` файла `/etc/grafana/grafana.ini` (в репозитории его нет), Contact point `email-admin`, тестовое письмо дошло до получателя.
