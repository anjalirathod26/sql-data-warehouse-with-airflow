from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime
from pathlib import Path
import logging
from airflow.exceptions import AirflowNotFoundException


# ----------------------------------------------------
# Start Timer
# ----------------------------------------------------
def start_timer(**context):

    context["ti"].xcom_push(
        key="start_time",
        value=datetime.now().isoformat()
    )

    logging.info("===================================")
    logging.info("Loading Bronze Layer Started")
    logging.info("===================================")


# ----------------------------------------------------
# End Timer
# ----------------------------------------------------
def end_timer(**context):

    start_time = datetime.fromisoformat(
        context["ti"].xcom_pull(
            task_ids="start_timer",
            key="start_time"
        )
    )

    end_time = datetime.now()

    duration = (end_time - start_time).total_seconds()

    logging.info("===================================")
    logging.info("Loading Bronze Layer Completed")
    logging.info(
        "Total Load Duration: %.2f seconds",
        duration
    )
    logging.info("===================================")


# ----------------------------------------------------
# Bronze DAG
# ----------------------------------------------------
with DAG(
    dag_id="bronze_pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["bronze", "datawarehouse"]
) as dag:

    # Start Timer Task
    start = PythonOperator(
        task_id="start_timer",
        python_callable=start_timer
    )

    # Runtime SQL runner (reads file at task runtime and executes on postgres_dw)
    def run_bronze_sql(**context):
        # Resolve path at runtime (worker/executor filesystem)
        sql_path = Path(__file__).resolve().parent / "sql" / "bronze" / "load_bronze.sql"

        try:
            sql_content = sql_path.read_text()
        except FileNotFoundError:
            logging.warning(
                "Bronze SQL file not found at %s; skipping execution. Create the file to run the real load.",
                sql_path
            )
            return

        hook = PostgresHook(postgres_conn_id="postgres_dw")
        try:
            hook.run(sql_content)
            logging.info("Executed bronze SQL from %s", sql_path)
        except AirflowNotFoundException:
            logging.error(
                "Airflow connection 'postgres_dw' not found. Define the connection in Airflow UI/ENV to run the bronze load."
            )
            return

    # Execute Bronze SQL Script (runs at task runtime)
    load_bronze = PythonOperator(
        task_id="load_bronze",
        python_callable=run_bronze_sql
    )

    # End Timer Task
    end = PythonOperator(
        task_id="end_timer",
        python_callable=end_timer
    )

    # Workflow
    start >> load_bronze >> end