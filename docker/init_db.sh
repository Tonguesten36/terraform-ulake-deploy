#!/bin/bash

max_retries=30
retry_count=0

while [ $retry_count -lt $max_retries ]; do
  if docker exec ulake-mysql mariadb -u root -p'root' -e 'SELECT 1;' > /dev/null 2>&1; then
    break
  else
    sleep 2
    ((retry_count++))
  fi
done

if [ $retry_count -eq $max_retries ]; then
  echo "MariaDB did not become ready in time." >&2
  exit 1
else
  docker exec -i ulake-mysql mariadb -u root -p'root' < "../../deployment/init.sql"
  echo "Successfully initiated database"
fi
