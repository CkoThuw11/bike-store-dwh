FROM apache/airflow:3.3.2-python3.12

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unixodbc \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/meltano-venv /opt/dbt-venv /opt/airflow/meltano \
    && chown -R airflow:0 /opt/meltano-venv /opt/dbt-venv /opt/airflow/meltano \
    && ln -s /opt/dbt-venv/bin/dbt /usr/local/bin/dbt \
    && ln -s /opt/meltano-venv/bin/meltano /usr/local/bin/meltano

USER airflow
ENV PIP_USER=false

# Meltano
RUN python -m venv /opt/meltano-venv \
    && /opt/meltano-venv/bin/pip install --no-cache-dir "meltano==4.4.0" "psycopg2-binary~=2.9"

# dbt
RUN python -m venv /opt/dbt-venv \
    && /opt/dbt-venv/bin/pip install --no-cache-dir "dbt-core~=1.12.0" "dbt-postgres~=1.11.0"


WORKDIR /opt/airflow/meltano
COPY --chown=airflow:0 meltano/meltano.yml ./
RUN /opt/meltano-venv/bin/meltano lock --update \
    && /opt/meltano-venv/bin/meltano install \
    && chmod -R g+rwX /opt/airflow/meltano


ENV MELTANO_PROJECT_ROOT=/opt/airflow/meltano \
    DBT_PROJECT_DIR=/opt/airflow/dbt/analytics \
    DBT_PROFILES_DIR=/opt/airflow/dbt/analytics \
    DBT_TARGET_PATH=/tmp/dbt/target \
    DBT_LOG_PATH=/tmp/dbt/logs

WORKDIR /opt/airflow
