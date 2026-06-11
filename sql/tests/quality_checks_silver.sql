/*
===============================================================================
Quality Checks - Silver Layer
===============================================================================
Purpose:
    Validate data quality after Silver Layer transformations.

Expected Result:
    Most validation queries should return 0 rows.
===============================================================================
*/


-- ============================================================================
-- CHECKING silver.crm_cust_info
-- ============================================================================

-- Check for NULLs or duplicate customer IDs
-- Expected: No rows
SELECT
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- Check for leading/trailing spaces in customer key
-- Expected: No rows
SELECT
    cst_key
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key);


-- Check customer marital status standardization
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;



-- ============================================================================
-- CHECKING silver.crm_prd_info
-- ============================================================================

-- Check for NULLs or duplicate product IDs
-- Expected: No rows
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- Check for unwanted spaces in product names
-- Expected: No rows
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


-- Check for NULL or negative costs
-- Expected: No rows
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL
   OR prd_cost < 0;


-- Check product line standardization
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;


-- Check invalid date ranges
-- End date should never be before start date
-- Expected: No rows
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



-- ============================================================================
-- CHECKING silver.crm_sales_details
-- ============================================================================

-- Validate source due dates
-- Expected: No rows
SELECT
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LENGTH(sls_due_dt::TEXT) <> 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;


-- Check order date occurs before shipping and due dates
-- Expected: No rows
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- Check sales calculation consistency
-- Sales = Quantity × Price
-- Expected: No rows
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY
    sls_sales,
    sls_quantity,
    sls_price;



-- ============================================================================
-- CHECKING silver.erp_cust_az12
-- ============================================================================

-- Check birth dates are within a reasonable range
-- Expected: No rows
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < DATE '1924-01-01'
   OR bdate > CURRENT_DATE;


-- Check gender standardization
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;



-- ============================================================================
-- CHECKING silver.erp_loc_a101
-- ============================================================================

-- Review country values for consistency
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;



-- ============================================================================
-- CHECKING silver.erp_px_cat_g1v2
-- ============================================================================

-- Check for unwanted spaces
-- Expected: No rows
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);


-- Check maintenance values standardization
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;