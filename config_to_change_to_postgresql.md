# PostgreSQLへのデータベース移行ガイド (セキュア設定)

システムは **環境変数 (Environment Variables)** を使用するように構成されています。データベースを切り替える際にコードを修正する必要はありません。

## 1. `backend/pom.xml` の更新

PostgreSQL ドライバを追加します（まだの場合）:

```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

## 2. PostgreSQL での実行方法

`application.properties` を直接修正する代わりに, アプリケーション起動時に環境変数を設定します。

### 方法 1: ターミナルから実行 (Bash/Zsh)

```bash
# 1. 環境変数をエクスポート
export DB_URL=jdbc:postgresql://localhost:5432/learnchinesedb
export DB_USERNAME=postgres
export DB_PASSWORD=your_secure_password
export DB_DRIVER=org.postgresql.Driver
export DB_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
export GEMINI_API_KEY=your_gemini_key
export APP_PROFILE=prod

# 2. 実行
cd backend
mvn spring-boot:run
```

### 方法 2: IntelliJ IDEA / Eclipse での実行

1.  **Run/Debug Configurations** を開きます。
2.  **Environment variables** 項目を探します。
3.  以下の文字列を追加します:
    ```text
    APP_PROFILE=prod;DB_URL=jdbc:postgresql://localhost:5432/learnchinesedb;DB_USERNAME=postgres;DB_PASSWORD=password;DB_DRIVER=org.postgresql.Driver;DB_PLATFORM=org.hibernate.dialect.PostgreSQLDialect
    ```

### 方法 3: Docker での実行 (本番環境)

```bash
docker run -d \
  -e APP_PROFILE=prod \
  -e DB_URL=jdbc:postgresql://db-host:5432/learnchinesedb \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=secret \
  -e DB_DRIVER=org.postgresql.Driver \
  -e GEMINI_API_KEY=xyz \
  -p 8080:8080 \
  my-learn-chinese-app
```

## 3. デフォルト値 (Fallback)

環境変数を設定 **しない** 場合, アプリケーションは自動的に **H2 データベース (ファイル)** を使用します（ローカル開発用）:

*   **URL**: `jdbc:h2:file:./data/learnchinesedb`
*   **User**: `sa`
*   **Pass**: (空)
*   **Profile**: `dev`
