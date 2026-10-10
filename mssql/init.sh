#!/bin/bash

set -euo pipefail

SCRIPTS=/scripts

sqlcmd() {
  /opt/mssql-tools/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -b "$@" < /dev/null
}

sqlcmd -Q "IF DB_ID('BikeStores') IS NULL CREATE DATABASE BikeStores;"

loaded_rows=$(sqlcmd -d BikeStores -h -1 -W -Q "
  SET NOCOUNT ON;
  IF OBJECT_ID('sales.order_items') IS NOT NULL
    EXEC('SELECT COUNT(*) FROM sales.order_items');
  ELSE
    SELECT 0;" | tr -d '[:space:]')

if [ "${loaded_rows:-0}" -gt 0 ]; then
  echo "BikeStores already loaded (${loaded_rows} order_items rows). Skipping create/load."
else
  echo "BikeStores not loaded. Dropping partial objects (if any), creating and loading..."
  sqlcmd -d BikeStores -i "$SCRIPTS/BikeStores Sample Database - drop all objects.sql"
  sqlcmd -d BikeStores -i "$SCRIPTS/BikeStores Sample Database - create objects.sql"
  sqlcmd -i "$SCRIPTS/BikeStores Sample Database - load data.sql"
  echo "Sample data loaded."
fi

echo "Ensuring read-only login meltano_reader..."
export MELTANO_READER_PASSWORD
sqlcmd -t 60 -i /init/create_reader.sql

echo "Done."
