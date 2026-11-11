# РЕД ОС 8: Docker, Docker Compose, SSH, тестовый Nginx

Узлы: IOT-01 (192.168.30.14), CTRL-01 (192.168.10.11), DB-01 (192.168.20.13).

## Имена и DNS

```
hostnamectl set-hostname CTRL-01      # DB-01, IOT-01 на остальных
nmcli con mod "Проводное подключение 1" ipv4.dns 10.0.0.41
nmcli con mod "Проводное подключение 1" +ipv4.dns 10.0.0.42
nmcli con up "Проводное подключение 1"
```

DNS 10.0.0.41 и 10.0.0.42 взят с внешнего интерфейса RTR (`nmcli dev show enp2s0 | grep DNS`). Репозиторий пакетов: kkrepo.petrocollege.ru.

## Установка

```
dnf install -y docker-ce
systemctl enable --now docker
dnf install -y docker-compose
```

Проверка: `docker --version` (24.0.9), `systemctl is-active docker` (active), `docker-compose --version` (2.11.2).

## SSH и SCP

С IOT-01:

```
ssh student@192.168.10.11 hostname
ssh student@192.168.20.13 hostname
echo "test from IOT-01" > test.txt
scp test.txt student@192.168.10.11:~/
```

## Nginx

На CTRL-01 через `docker run`:

```
docker run -d --name nginx-test -p 8080:80 nginx
docker rm -f nginx-test
```

Через Docker Compose (`docker/compose.yml`):

```
docker-compose up -d
docker-compose down
```

Проверка с IOT-01: `curl -I http://192.168.10.11:8080` (HTTP 200). С WIN-01 страница открывается по адресу `http://192.168.10.11:8080`. После проверки `docker-compose down`, порт 8080 свободен.
