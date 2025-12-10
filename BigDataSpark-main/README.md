### Запуск приложения

```bash
docker compose up --build -d
```

### Проверка статуса

```bash
docker compose ps
```

### Просмотр логов

```bash
docker compose logs

### Остановка

```bash
docker compose down
```

## Сервисы

### PostgreSQL (порт 5432)
- **Пользователь**: Alisa
- **Пароль**: password
- **База данных**: db
- Используется для хранения витрин данных и фактовых таблиц

### ClickHouse
- **HTTP порт**: 8123
- **Native порт**: 9000
- **Пользователь**: admin
- **Пароль**: password
- Используется для аналитических запросов

## Подключение к базам данных

### PostgreSQL
```bash
docker exec -it db psql -U Alisa -d db
```

### ClickHouse
```bash
docker exec -it clickhouse clickhouse-client --user admin --password password
```

### Cassandra
```bash
docker exec -it cassandra cqlsh
```

### Пересоздание контейнеров
Если возникли проблемы, попробуйте пересоздать контейнеры:
```bash
docker compose down -v
docker compose up --build -d
```