# RTR (РЕД ОС 8)

Интерфейсы:

| Интерфейс | Порт в GNS3 | Назначение | Настройка |
|---|---|---|---|
| enp2s0 | e0 | к Cloud1 (внешний канал) | «Проводное подключение 1», Автоматически (DHCP) |
| ens1 | e1 | к коммутатору Switch1 | «Проводное подключение 2», IPv4 Вручную, три адреса (шлюзы подсетей) |

Адреса на ens1 (nmtui, «Проводное подключение 2»):

- 192.168.10.1/26
- 192.168.20.1/26
- 192.168.30.1/26

Маршрутизация и выход в интернет (выполнено под root):

```
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o enp2s0 -j MASQUERADE
```

Пересылка сохранена в файле (проверено `sysctl --system`, `net.ipv4.ip_forward = 1`):

```
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-forward.conf
```

Правила iptables сохранены командой `iptables-save > /etc/sysconfig/iptables`. После перезагрузки RTR проверять `iptables -t nat -S POSTROUTING`: если MASQUERADE пропал, добавить правило заново.
