# Hướng dẫn chuyển đổi Database sang PostgreSQL (Secure Mode)

Hệ thống đã được cấu hình để sử dụng **Biến môi trường (Environment Variables)**. Bạn không cần sửa code để đổi database nữa.

## 1. Cập nhật `backend/pom.xml`

Thêm driver PostgreSQL (nếu chưa có):

```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

## 2. Cách chạy với PostgreSQL

Thay vì sửa file `application.properties`, bạn chỉ cần thiết lập các biến môi trường sau khi chạy ứng dụng.

### Cách 1: Chạy bằng dòng lệnh (Terminal/Bash)

```bash
# 1. Export các biến môi trường
export DB_URL=jdbc:postgresql://localhost:5432/learnchinesedb
export DB_USERNAME=postgres
export DB_PASSWORD=your_secure_password
export DB_DRIVER=org.postgresql.Driver
export DB_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
export GEMINI_API_KEY=your_gemini_key

# 2. Chạy ứng dụng
cd backend
mvn spring-boot:run
```

### Cách 2: Chạy bằng IntelliJ IDEA / Eclipse

1.  Mở cấu hình **Run/Debug Configurations**.
2.  Tìm mục **Environment variables**.
3.  Thêm chuỗi sau vào:
    ```text
    DB_URL=jdbc:postgresql://localhost:5432/learnchinesedb;DB_USERNAME=postgres;DB_PASSWORD=123456;DB_DRIVER=org.postgresql.Driver;DB_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
    ```

### Cách 3: Chạy bằng Docker (Production)

```bash
docker run -d \
  -e DB_URL=jdbc:postgresql://db-host:5432/learnchinesedb \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=secret \
  -e DB_DRIVER=org.postgresql.Driver \
  -e GEMINI_API_KEY=xyz \
  -p 8080:8080 \
  my-learn-chinese-app
```

## 3. Giá trị mặc định (Fallback)

Nếu bạn **KHÔNG** thiết lập các biến trên, ứng dụng sẽ tự động quay về sử dụng **H2 Database (File)** như cũ để phục vụ việc phát triển local:

*   **URL**: `jdbc:h2:file:./data/learnchinesedb`
*   **User**: `sa`
*   **Pass**: (rỗng)