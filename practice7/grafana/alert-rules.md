# Правила оповещения Grafana

Все три правила лежат в папке `office`, группа `office-alerts`, интервал проверки 10 с, pending period 0 с. Тип правил – Grafana-managed, источник данных `Prometheus` (uid `prometheus-office`).

Структура каждого правила: запрос A (Prometheus, режим Code, Instant) → B (Reduce, функция Last) → C (Threshold, условие тревоги).

## 1. TEMP-01 нет новых показаний

Запрос A:

```
office_sensor_age_seconds{job="office-controller",sensor_id="TEMP-01"} and on(job,instance) (up{job="office-controller"} == 1)
```

C: IS ABOVE 20. No data → OK (Normal). Summary: «TEMP-01 нет показаний больше 20 с».

## 2. HUM-01 нет новых показаний

Запрос A:

```
office_sensor_age_seconds{job="office-controller",sensor_id="HUM-01"} and on(job,instance) (up{job="office-controller"} == 1)
```

C: IS ABOVE 20. No data → OK (Normal). Summary: «HUM-01 нет показаний больше 20 с».

Условие `and on(job,instance) (up == 1)` оставляет значение только пока CTRL доступен. Если CTRL остановлен, запрос не возвращает данных и правила датчиков не срабатывают: остановка приложения не считается потерей датчика.

## 3. CTRL недоступен

Запрос A:

```
up{job="office-controller"}
```

C: IS BELOW 1. No data → Alerting. Summary: «Приложение CTRL недоступно».

## Уведомления

Contact point `email-admin` (тип Email) назначен контактом по умолчанию в Notification policies. Отправка идёт через SMTP, настроенный в `/etc/grafana/grafana.ini` (секция `[smtp]`, smtp.gmail.com:587). Файл `grafana.ini` в репозиторий не входит, так как содержит пароль приложения.
