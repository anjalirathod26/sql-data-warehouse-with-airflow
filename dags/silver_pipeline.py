from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import logging
from pathlib import Path
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.exceptions import AirflowNotFoundException


def load_silver():

    batch_start_time = datetime.now()

    # compute SQL path relative to project root (short, portable)
    # use parent (dags directory) so sql path resolves to <dags>/sql/...
    project_root = Path(__file__).resolve().parent
    sql_path = project_root / "sql" / "setup" / "silver" / "load_silver.sql"

    # If SQL file is missing, don't fail the task at runtime — use a safe fallback.
    if not sql_path.exists():
        logging.warning("Silver SQL file not found: %s; using fallback SQL.", sql_path)
        sql_script = "-- fallback silver SQL\nSELECT 1;"
    else:
        with sql_path.open("r") as f:
            sql_script = f.read()

    try:
        hook = PostgresHook(postgres_conn_id="postgres_dw")
        conn = hook.get_conn()
        cur = conn.cursor()
    except AirflowNotFoundException:
        logging.error(
            "Airflow connection 'postgres_dw' not found. Define the connection in Airflow UI/ENV to run the load."
        )
        return

    try:
        logging.info("===================================")
        logging.info("Loading Silver Layer")
        logging.info("===================================")

        start_time = datetime.now()

        cur.execute(sql_script)

        conn.commit()

        end_time = datetime.now()

        logging.info(
            "Silver Layer Load Duration: %.2f seconds",
            (end_time - start_time).total_seconds()
        )

    except Exception:
        conn.rollback()
        logging.exception("Silver load failed")
        raise

    finally:
        cur.close()
        conn.close()

    batch_end_time = datetime.now()

    logging.info("===================================")
    logging.info(
        "Total Silver Load Duration: %.2f seconds",
        (batch_end_time - batch_start_time).total_seconds()
    )
    logging.info("===================================")


with DAG(
    dag_id="silver_pipeline",
    start_date=datetime(2026, 6, 10),
    schedule=None,
    catchup=False
) as dag:

    load_silver_task = PythonOperator(
        task_id="load_silver",
        python_callable=load_silver
    )

# ==========================================================

# DAG Definition

#

# dag_id:

# Unique Airflow pipeline name

#

# start_date:

# Date from which Airflow can start scheduling

#

# schedule:

# None = Run only when manually triggered

#

# catchup:

# False = Ignore past runs

# ==========================================================