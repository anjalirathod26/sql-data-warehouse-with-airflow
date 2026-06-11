# Modern Data Warehouse with PostgreSQL & Apache Airflow

## Project Overview

This project demonstrates the design and implementation of a modern data warehouse using PostgreSQL and Apache Airflow.

The solution consolidates ERP and CRM datasets from CSV files into a centralized analytical repository using automated ETL pipelines orchestrated by Apache Airflow.

The warehouse follows the Medallion Architecture (Bronze, Silver, and Gold) to transform raw data into business-ready datasets for analytics and reporting.

---

## Data Architecture

### Bronze Layer

Stores raw data exactly as received from source CSV files.

Responsibilities:

* Load source CRM and ERP datasets
* Preserve raw data for auditing and traceability
* No business transformations applied

### Silver Layer

Stores cleaned and standardized data.

Responsibilities:

* Remove duplicates
* Handle missing values
* Standardize formats
* Validate business rules
* Apply data transformations

### Gold Layer

Stores business-ready analytical models.

Responsibilities:

* Create dimension tables
* Create fact tables
* Build Star Schema models
* Support reporting and analytics

---

## Technologies Used

* PostgreSQL
* Apache Airflow
* SQL
* Docker
* Git & GitHub

---

## Project Features

* Automated ETL Pipelines using Apache Airflow
* Data Loading from CSV Files
* Data Quality Validation
* Data Cleansing and Standardization
* Star Schema Data Modeling
* Workflow Monitoring and Scheduling
* Analytical Reporting Layer

---

## Skills Demonstrated

* Data Engineering
* Apache Airflow
* PostgreSQL
* ETL Development
* Data Warehousing
* Data Modeling
* Workflow Orchestration
* SQL Development
* Data Quality Validation

---

## Data Sources

### CRM Dataset

* Customer Information
* Product Information
* Sales Information

### ERP Dataset

* Customer Demographics
* Customer Location Information
* Product Categories


## ETL Workflow

### Bronze Pipeline

* Truncate Bronze tables
* Load CRM CSV files
* Load ERP CSV files
* Log load duration

### Silver Pipeline

* Read data from Bronze layer
* Apply transformations
* Perform data cleansing
* Standardize values
* Load Silver tables
* Execute data quality checks

### Gold Layer

* Create analytical views
* Build Star Schema
* Support reporting and dashboarding

---

## Airflow DAG Flow

```text
CRM & ERP CSV Files
          │
          ▼
   Bronze Pipeline
          │
          ▼
   Silver Pipeline
          │
          ▼
     Gold Views
          │
          ▼
 Analytics & Reporting
```

---

## Data Quality Checks

### Silver Layer

* Duplicate Record Detection
* Null Value Validation
* Date Validation
* Data Standardization Checks
* Business Rule Validation

### Gold Layer

* Surrogate Key Validation
* Referential Integrity Checks
* Fact-to-Dimension Relationship Validation

---

## Analytics Use Cases

The warehouse supports:

* Customer Behavior Analysis
* Product Performance Analysis
* Revenue Analysis
* Sales Trend Analysis
* Customer Segmentation

---

## Future Enhancements

* Incremental Data Loading
* Airflow Scheduling Automation
* Email Alerts for Failures
* Dashboard Integration (Power BI / Tableau)
* Data Lineage Tracking
* Cloud Deployment on AWS

---


**Anjali Subhash Rathod**

