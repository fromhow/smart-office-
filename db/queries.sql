-- Запросы проверки хранилища (sqlite3 data/telemetry.sqlite3 < queries.sql)

-- общее число измерений
SELECT COUNT(*) FROM measurements;

-- последние пять показаний
SELECT id, device_id, metric, value, unit FROM measurements ORDER BY id DESC LIMIT 5;

-- последние пять сигналов вентилятора
SELECT id, device_id, state, mode FROM actuator_events ORDER BY id DESC LIMIT 5;

-- число показаний по датчикам
SELECT device_id, COUNT(*) FROM measurements GROUP BY device_id;

-- число сигналов вентилятора по состояниям
SELECT state, COUNT(*) FROM actuator_events GROUP BY state;
