# Troubleshooting

For each problem: the commands to check and debug it. Run them from the project root.

---

## A container does not start

```bash
docker compose ps -a                         
docker compose logs --tail 50 <service>      # e.g. mssql, mssql-init, postgres-init
docker compose up -d                         # re-run the init steps (safe to repeat)
```

## SQL Server (source) does not work

```bash
docker compose logs --tail 30 mssql          
docker compose logs mssql-init              
```

## Meltano does not work

```bash
# 1. Can Meltano connect to SQL Server?         
docker compose exec airflow-scheduler meltano config test tap-mssql

# 2. Does it see all tables?                
docker compose exec airflow-scheduler meltano select tap-mssql --list

# 3. Run the load and read the errors
docker compose exec airflow-scheduler meltano run el-incremental

# 4. Where did the last incremental load stop?    
docker compose exec airflow-scheduler meltano state get dev:tap-mssql-to-target-postgres
```


## dbt does not work

```bash
# 1. Profile, project and database connection    
docker compose exec airflow-scheduler dbt debug

# 2. Build and test each layer, read the first error
docker compose exec airflow-scheduler dbt run  --select staging
docker compose exec airflow-scheduler dbt test --select staging
docker compose exec airflow-scheduler dbt run  --select mart
docker compose exec airflow-scheduler dbt test --select mart
```


## Airflow does not run the pipeline

```bash
# 1. Are the DAGs loaded without errors?          
docker compose exec airflow-scheduler airflow dags list | grep bike_store
docker compose exec airflow-scheduler airflow dags list-import-errors

# 2. Is the DAG paused?                         
docker compose exec airflow-scheduler airflow dags unpause bike_store_daily

# 3. What happened in a run?
docker compose exec airflow-scheduler airflow dags list-runs bike_store_daily
docker compose exec airflow-scheduler airflow tasks states-for-dag-run bike_store_daily "<run_id>"
```


## The dashboard shows no data or wrong numbers

```bash
# Is the mart filled and readable by Metabase?    -> 4722+ lines
docker compose exec postgres psql -U metabase_reader -d dwh -c \
  "SELECT count(*), sum(booked_revenue) FROM mart.fct_order_items;"
```

More: [`metabase/README.md`](metabase/README.md#9-troubleshooting).

## After changing files

| Changed | Run |
|---|---|
| DAG file, dbt models/tests, `meltano.yml` settings | Nothing (mounted) |
| Meltano plugin, tool versions (`airflow/Dockerfile`) | `docker compose build airflow-init && docker compose up -d` |
| `docker-compose.yaml`, `postgres/create_databases.sql` | `docker compose up -d` |
