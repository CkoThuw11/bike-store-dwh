"""Bike Store DWH pipeline: Meltano extract-load, then dbt run -> test per layer.

Each DAG: extract_load >> run_staging >> test_staging >> run_mart >> test_mart
If a test fails, the next steps don't run, so the dashboard keeps the last good data.
"""
from datetime import datetime, timedelta

from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG

# `meltano` and `dbt` are installed in the Airflow image (airflow/Dockerfile).

default_args = {"retries": 2, "retry_delay": timedelta(minutes=5)} 


# Daily 01:00 UTC: new orders (incremental) + small tables (full reload)
with DAG(
    dag_id="bike_store_daily",
    schedule="0 1 * * *",
    start_date=datetime(2026, 10, 1),
    catchup=False,
    max_active_runs=1,  
    default_args=default_args,
):
    extract_load = BashOperator(task_id="extract_load", bash_command="meltano run el-incremental")
    run_staging = BashOperator(task_id="run_staging", bash_command="dbt run --select staging")
    test_staging = BashOperator(task_id="test_staging", bash_command="dbt test --select staging")
    run_mart = BashOperator(task_id="run_mart", bash_command="dbt run --select mart")
    test_mart = BashOperator(task_id="test_mart", bash_command="dbt test --select mart")

    extract_load >> run_staging >> test_staging >> run_mart >> test_mart


# Weekly Sunday 03:00 UTC: full reload of orders / order_items (picks up status changes)
with DAG(
    dag_id="bike_store_weekly_full_reload",
    schedule="0 3 * * 0",
    start_date=datetime(2026, 10, 1),
    catchup=False,
    max_active_runs=1,  
    default_args=default_args,
):
    extract_load = BashOperator(task_id="extract_load", bash_command="meltano run el-orders-full")
    run_staging = BashOperator(task_id="run_staging", bash_command="dbt run --select staging")
    test_staging = BashOperator(task_id="test_staging", bash_command="dbt test --select staging")
    run_mart = BashOperator(task_id="run_mart", bash_command="dbt run --select mart")
    test_mart = BashOperator(task_id="test_mart", bash_command="dbt test --select mart")

    extract_load >> run_staging >> test_staging >> run_mart >> test_mart


# Manual only: reload every table, ignoring saved state (first load / recovery)
with DAG(
    dag_id="bike_store_full_refresh",
    schedule=None,
    start_date=datetime(2026, 10, 1),
    catchup=False,
    max_active_runs=1,  
    default_args=default_args,
):
    extract_load = BashOperator(task_id="extract_load", bash_command="meltano run --full-refresh el-incremental")
    run_staging = BashOperator(task_id="run_staging", bash_command="dbt run --select staging")
    test_staging = BashOperator(task_id="test_staging", bash_command="dbt test --select staging")
    run_mart = BashOperator(task_id="run_mart", bash_command="dbt run --select mart")
    test_mart = BashOperator(task_id="test_mart", bash_command="dbt test --select mart")

    extract_load >> run_staging >> test_staging >> run_mart >> test_mart
