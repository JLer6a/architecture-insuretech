# Task6 — Rate Limiting через Nginx

## 🧠 Цель
Ограничить количество запросов от партнёров к API до 10 запросов в минуту, чтобы защитить сервис от перегрузки.

---

## ⚙️ Архитектура

- **Flask-бэкенд**: простой сервис, отдающий `Backend OK`
- **Nginx**: проксирует запросы на 3 backend-инстанса и применяет `limit_req`
- **Docker Compose**: поднимает всё в изоляции

---

## 🐳 Состав `docker-compose.yml`

```yaml
services:
  backend1:
    build: ./app
    expose:
      - "5000"

  backend2:
    build: ./app
    expose:
      - "5000"

  backend3:
    build: ./app
    expose:
      - "5000"

  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - backend1
      - backend2
      - backend3
```

---

## 🌐 Конфигурация `nginx.conf`

```nginx
events {}

http {
    upstream backend_servers {
        server backend1:5000;
        server backend2:5000;
        server backend3:5000;
    }

    limit_req_zone $binary_remote_addr zone=partner_limit:10m rate=10r/m;

    server {
        listen 80;

        location / {
            limit_req zone=partner_limit burst=5 nodelay;
            limit_req_status 429;

            proxy_pass http://backend_servers;
        }
    }
}
```

---

## 🌐 Конфигурация `app.py`

```app.py
# -*- coding: utf-8 -*-
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return "Backend OK", 200

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
```

---

## ✅ Проверка

Скрипт `test.sh` отправляет 12 запросов подряд:

```bash
#!/bin/bash
echo "Тестирование Rate Limit:"
for i in {1..12}; do
  echo -n "[$i] "
  curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8080/
done
```

Ожидаемый результат:

```
[1] Status: 200
...
[10] Status: 200
[11] Status: 429
[12] Status: 429
```

---

## 🚀 Запуск

```bash
cd Task6/test
docker-compose up --build
```

Проверка:

```bash
bash test.sh

либо

выполните прямо в PowerShell:

for ($i = 1; $i -le 12; $i++) {
  Write-Host "[$i]"
  Invoke-WebRequest http://localhost:8080/ -UseBasicParsing | Select-Object StatusCode
}
```

---

## 🏁 Готово!
Сервис успешно ограничивает частоту запросов на уровне Nginx, отвечая `429 Too Many Requests` при превышении лимита.