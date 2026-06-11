-- Placeholder Bronze load SQL
-- Replace the SQL below with your real bronze-layer load statements.

-- Simple no-op / sanity query for now:
SELECT 1;

TRUNCATE TABLE bronze.crm_cust_info;
TRUNCATE TABLE bronze.crm_prd_info;
TRUNCATE TABLE bronze.crm_sales_details;
TRUNCATE TABLE bronze.erp_loc_a101;
TRUNCATE TABLE bronze.erp_cust_az12;
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

COPY bronze.crm_cust_info
FROM '/data/source_crm/cust_info.csv'
WITH CSV HEADER;

COPY bronze.crm_prd_info
FROM '/data/source_crm/prd_info.csv'
WITH CSV HEADER;

COPY bronze.crm_sales_details
FROM '/data/source_crm/sales_details.csv'
WITH CSV HEADER;

COPY bronze.erp_loc_a101
FROM '/data/source_erp/loc_a101.csv'
WITH CSV HEADER;

COPY bronze.erp_cust_az12
FROM '/data/source_erp/cust_az12.csv'
WITH CSV HEADER;

COPY bronze.erp_px_cat_g1v2
FROM '/data/source_erp/px_cat_g1v2.csv'
WITH CSV HEADER;