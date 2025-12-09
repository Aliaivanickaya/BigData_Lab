# Инструкция по запуску лабораторной работы №3

## Шаг 1: Подготовка проекта

1. Клонируйте репозиторий или убедитесь, что все файлы на месте:
   - `docker-compose.yml` - конфигурация Docker
   - `init.sql` - схема базы данных
   - `исходные данные/` - директория с CSV файлами (10 файлов MOCK_DATA*.csv)
   - `kafka/producer.py` - приложение для отправки данных в Kafka
   - `flink-job/` - Flink приложение

2. Проверьте наличие исходных данных:
   ```bash
   ls -la "исходные данные" | grep MOCK_DATA
   ```
   Должно быть 10 файлов: `MOCK_DATA.csv` и `MOCK_DATA (1).csv` до `MOCK_DATA (9).csv`

## Шаг 2: Сборка Flink Job

### Проверка существующего JAR файла

Сначала проверьте, есть ли уже собранный JAR файл:

```bash
ls -lh flink-job/target/flink-job-1.0-SNAPSHOT.jar
```

Если файл существует и имеет размер около 70MB, **можно пропустить сборку** и перейти к следующему шагу.

### Сборка JAR файла (если нужно)

Если JAR файла нет или нужно пересобрать после изменений в коде:

```bash
cd flink-job
mvn clean package
cd ..
```

После успешной сборки файл `flink-job/target/flink-job-1.0-SNAPSHOT.jar` будет создан и автоматически смонтирован в контейнер Flink.

**Примечание**: Если Maven не установлен, но JAR файл уже существует, можно использовать существующий файл.

## Шаг 3: Запуск всех сервисов

Запустите все сервисы с помощью Docker Compose:

```bash
docker compose up -d --build
```

Эта команда запустит:
- PostgreSQL (порт 5432)
- Zookeeper (порт 2181)
- Kafka (порт 9092)
- Kafka UI (порт 8080) - веб-интерфейс для мониторинга Kafka
- Flink JobManager (порт 8081) - веб-интерфейс Flink
- Flink TaskManager
- Kafka Producer - автоматически начнет отправлять данные из CSV файлов в Kafka

## Шаг 4: Проверка запуска сервисов

Проверьте статус всех контейнеров:

```bash
docker ps
```

Все контейнеры должны быть в статусе "Up".

## Шаг 5: Запуск Flink Job

После того как все сервисы запущены, запустите Flink job:

```bash
docker exec jobmanager flink run -d /opt/flink/usrlib/flink-job-1.0-SNAPSHOT.jar
```

Вы должны увидеть сообщение:
```
Job has been submitted with JobID <job-id>
```

## Шаг 6: Мониторинг работы

### Проверка статуса Flink Job

```bash
docker exec jobmanager flink list
```

Job должен быть в статусе `RUNNING`.

### Проверка Kafka топика

Проверьте, что данные поступают в Kafka:

```bash
docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic petstore-transactions --from-beginning --max-messages 5
```

### Веб-интерфейсы

- **Flink Web UI**: http://localhost:8081
  - Просмотр запущенных jobs
  - Мониторинг производительности
  - Просмотр логов

- **Kafka UI**: http://localhost:8080
  - Просмотр топиков
  - Мониторинг сообщений
  - Управление consumer groups

## Шаг 7: Проверка данных в PostgreSQL

Подключитесь к PostgreSQL и проверьте данные:

```bash
docker exec -it postgres-lab3 psql -U admin -d petstore
```

Или выполните запросы напрямую:

```bash
# Проверка количества записей в dimension таблицах
docker exec postgres-lab3 psql -U admin -d petstore -c "
SELECT 'dim_customer' as table_name, COUNT(*) as count FROM dim_customer 
UNION ALL 
SELECT 'dim_seller', COUNT(*) FROM dim_seller 
UNION ALL 
SELECT 'dim_product', COUNT(*) FROM dim_product 
UNION ALL 
SELECT 'dim_store', COUNT(*) FROM dim_store 
UNION ALL 
SELECT 'dim_time', COUNT(*) FROM dim_time 
UNION ALL 
SELECT 'fact_sales', COUNT(*) FROM fact_sales 
ORDER BY table_name;"

# Просмотр примеров данных
docker exec postgres-lab3 psql -U admin -d petstore -c "SELECT * FROM dim_customer LIMIT 5;"
```

### Подключение через DBeaver или другой SQL клиент

- **Host**: localhost
- **Port**: 5432
- **Database**: petstore
- **Username**: admin
- **Password**: password

## Шаг 8: Просмотр логов

### Логи Kafka Producer

```bash
docker logs kafka-producer -f
```

### Логи Flink JobManager

```bash
docker logs jobmanager -f
```

### Логи Flink TaskManager

```bash
docker logs taskmanager -f
```

### Логи Kafka

```bash
docker logs kafka -f
```

## Остановка и перезапуск
### Остановка всех сервисов

```bash
docker compose down
```

### Остановка с удалением данных (Это удалит все данные из PostgreSQL!)

```bash
docker compose down -v
```

### Перезапуск Flink Job

Если нужно перезапустить Flink job:

```bash
# Отменить текущий job
docker exec jobmanager flink cancel <job-id>

# Запустить новый
docker exec jobmanager flink run -d /opt/flink/usrlib/flink-job-1.0-SNAPSHOT.jar
```

### Перезапуск Kafka Producer

Если нужно перезапустить producer (например, для повторной отправки данных):

```bash
docker restart kafka-producer
```

## Устранение проблем

### Maven не установлен

Если Maven не установлен, но JAR файл уже существует, можно использовать существующий файл без пересборки. Проверьте наличие файла:

```bash
ls -lh flink-job/target/flink-job-1.0-SNAPSHOT.jar
```

Если файл существует (размер ~70MB), можно пропустить сборку.

Для установки Maven на macOS:
```bash
brew install maven
```

### Flink job не запускается

1. Проверьте, что JAR файл собран:
   ```bash
   ls -lh flink-job/target/flink-job-1.0-SNAPSHOT.jar
   ```

2. Проверьте логи:
   ```bash
   docker logs jobmanager
   docker logs taskmanager
   ```

### Kafka Producer не отправляет данные

1. Проверьте, что CSV файлы доступны:
   ```bash
   docker exec kafka-producer ls -la /app/data/
   ```

2. Проверьте логи:
   ```bash
   docker logs kafka-producer
   ```

3. Убедитесь, что Kafka доступен:
   ```bash
   docker exec kafka-producer ping -c 2 kafka
   ```

### Ошибки подключения к PostgreSQL

1. Проверьте, что PostgreSQL запущен:
   ```bash
   docker ps | grep postgres
   ```

2. Проверьте healthcheck:
   ```bash
   docker inspect postgres-lab3 | grep -A 10 Health
   ```

### Ошибки "ON CONFLICT" в PostgreSQL

Если видите ошибки о недостающих уникальных ограничениях, выполните:

```bash
docker exec postgres-lab3 psql -U admin -d petstore -c "
ALTER TABLE dim_customer ADD CONSTRAINT dim_customer_email_unique UNIQUE (customer_email);
ALTER TABLE dim_seller ADD CONSTRAINT dim_seller_email_unique UNIQUE (seller_email);
ALTER TABLE dim_product ADD CONSTRAINT dim_product_name_brand_unique UNIQUE (product_name, product_brand);
ALTER TABLE dim_store ADD CONSTRAINT dim_store_name_location_unique UNIQUE (store_name, store_location);
ALTER TABLE dim_time ADD CONSTRAINT dim_time_sale_date_unique UNIQUE (sale_date);
"
```