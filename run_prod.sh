#!/bin/bash
echo "--- Checking Database Configuration ---"
echo "DB_URL: $DB_URL"
echo "DB_USERNAME: $DB_USERNAME"
echo "DB_DRIVER: $DB_DRIVER"
echo "DB_PLATFORM: $DB_PLATFORM"
echo "-------------------------------------"

if [ -z "$DB_URL" ]; then
  echo "⚠️  WARNING: DB_URL is not set. Spring Boot will use default H2 Database."
else
  echo "✅  DB_URL is set. Attempting to run backend..."
fi

cd backend
mvn spring-boot:run
