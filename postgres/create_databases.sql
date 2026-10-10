-- meltano: Meltano system DB (run history and incremental state)
SELECT 'CREATE DATABASE meltano'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'meltano')\gexec

-- metabase: Metabase application DB (users, questions, dashboards)
SELECT 'CREATE DATABASE metabase'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'metabase')\gexec

-- airflow: Airflow metadata DB (DAG runs, task instances, users, pools)
SELECT 'CREATE DATABASE airflow'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'airflow')\gexec

-- metabase_reader: read-only login used by Metabase to query the mart (and nothing else).
\getenv metabase_reader_password METABASE_READER_PASSWORD
SELECT format('CREATE ROLE metabase_reader LOGIN PASSWORD %L', :'metabase_reader_password')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metabase_reader')\gexec
ALTER ROLE metabase_reader PASSWORD :'metabase_reader_password';

CREATE SCHEMA IF NOT EXISTS mart AUTHORIZATION dwh;

GRANT CONNECT ON DATABASE dwh TO metabase_reader;
GRANT USAGE ON SCHEMA mart TO metabase_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA mart TO metabase_reader;
ALTER DEFAULT PRIVILEGES FOR ROLE dwh IN SCHEMA mart GRANT SELECT ON TABLES TO metabase_reader;
