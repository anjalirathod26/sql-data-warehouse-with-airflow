-- check for the Nulls or duplicates in primary key
-- Expection no result

--First Table crm_cust_info

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;




-- Transformation on crm_cust_info table
// Transformation

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

SELECT
    cst_id,
    cst_key,

    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'Unknown'
    END AS cst_marital_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        ELSE 'Unknown'
    END AS cst_gndr,

    cst_create_date

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
) t
WHERE flag_last = 1;



-- Remove Unwanted spaces to ensure data consistency and uniformity across all records. 
-- Expection no result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);


--Check the consistency of values in low cardinality columns
-- Data standardization & consitency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;



-- To check the data after transformation
SELECT * FROM silver.crm_cust_info;



--Second Table 


--Data normalization and standaerzation
-- Maps Coded values to meaningful, user-friendly descriptions


-- Handling missing Data 
-- Fills in the blanks by adding a deafult value 


-- Rmove duplicates
-- Ensure only one record per entity by identifying and retaining the most relevant row


-- Replce null values with zero

--Transformation on crm_prd_info table
// Transformation

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)

SELECT
    prd_id,

    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,

    prd_nm,

    COALESCE(prd_cost, 0) AS prd_cost,

    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'other Sales'
        ELSE 'Unknown'
    END AS prd_line,

    CAST(prd_start_dt AS DATE) AS prd_start_dt,

    CAST(
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key
            ORDER BY prd_start_dt
        ) - INTERVAL '1 month'
        AS DATE
    ) AS prd_end_dt

FROM bronze.crm_prd_info;




-- Chcek for unwanted Spaces 
-- Expection no result
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


--Check for nulls or negative numbers 
-- Expection no result
SELECT prd_cost
FROM bronze.crm_prd_info    
WHERE prd_cost IS NULL
    OR prd_cost < 0;

--Data Standarization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- Check the invalid date order
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


SELECT
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER(PARTITION BY prd_id ORDER BY prd_start_dt)-1 AS prd_end_dt_test
FROM bronze.crm_prd_info





--Derived Columns
-- Create new columns based on calculations or transformations of existing data.


--Transformation on crm_sales_details table
-- Clean and Load
// Transformation

INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt = 0
             OR LENGTH(sls_order_dt::TEXT) != 8
        THEN NULL
        ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt = 0
             OR LENGTH(sls_ship_dt::TEXT) != 8
        THEN NULL
        ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt = 0
             OR LENGTH(sls_due_dt::TEXT) != 8
        THEN NULL
        ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
    END AS sls_due_dt,

    CASE
        WHEN sls_sales IS NULL
             OR sls_sales <= 0
             OR sls_sales <> sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    CASE
        WHEN sls_price IS NULL
             OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price

FROM bronze.crm_sales_details;





-- Check for invalid Dates
-- Check for outliers by validating the boundries of date range.
SELECT 
NULLIF(sls_order_dt, 0) AS sls_order_dt,
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101 
OR sls_order_dt < 20000101;


-- Check invalid dates order
SELECT 
* 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


-- Check data consistency: Between Sales , Quantity and Price
-- Sales  = quantity * price
--Values must me not be null, Zero or negative

SELECT 
sls_sales,
sls_quantity,
sls_price
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales    
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price    
END AS sls_price,

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price

OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_price <= 0;
ORDER BY sls_sales, sls_quantity, sls_price;





-- BUILS SILVER LAYER   
-- clan and Load
-- erp_cust_az12 table
-- Transformation on erp_cust_az12 table
// Transformation

INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)   

SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
        ELSE cid
    END AS cid,

    CASE
        WHEN bdate > CURRENT_DATE THEN NULL
        ELSE bdate
    END AS bdate,

    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'Unknown'
    END AS gen

FROM bronze.erp_cust_az12;


-- Identity out-of-range Dates
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE();



-- BUILD SILVER LAYER
-- Clean and Load
-- erp_loc_a101 table
// Transformation
INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)

SELECT 
REPLACE(cid,'-','') AS cid,

CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) = ('US', 'USA') THEN 'United States'
     WHEN TRIM(cntry) = '' OR cntry IS NULL  THEN 'Unknown'
ELSE TRIM(cntry)
END AS cntry

FROM bronze.erp_loc_a101


-- BUILD SILVER LAYER
-- Clean and Load
-- erp_px_cat_g1v2 table
// Transformation

INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
   id,
   cat,
   subcat,
   maintenance
FROM silver.erp_px_cat_g1v2;