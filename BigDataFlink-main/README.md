Подробная инструкция по установке и запуску находится в файле [INSTALLATION.md](INSTALLATION.md).

### Краткая инструкция:

1. **Соберите Flink job:**
   ```bash
   cd flink-job
   mvn clean package
   cd ..
   ```

2. **Запустите все сервисы:**
   ```bash
   docker compose up -d --build
   ```

3. **Запустите Flink job:**
   ```bash
   docker exec jobmanager flink run -d /opt/flink/usrlib/flink-job-1.0-SNAPSHOT.jar
   ```

4. **Проверьте данные в PostgreSQL:**
   ```bash
   docker exec postgres-lab3 psql -U admin -d petstore -c "SELECT COUNT(*) FROM dim_customer;"
   ```

Подробности и решение проблем см. в [INSTALLATION.md](INSTALLATION.md).
