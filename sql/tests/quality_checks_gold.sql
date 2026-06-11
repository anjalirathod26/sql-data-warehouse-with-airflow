/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Purpose:
    Validate the quality and integrity of data in the Gold Layer.

Checks Performed:
    1. Verify surrogate keys are unique in dimension tables.
    2. Verify fact table records have matching dimension records.
    3. Detect orphan records that could break reporting and analytics.

Expected Result:
    All queries should return 0 rows.
===============================================================================
*/


-- ============================================================================
-- CHECK 1: Verify Customer Key Uniqueness
-- ============================================================================
-- Purpose:
-- Each customer in dim_customers should have exactly one unique surrogate key.
--
-- Expected Result:
-- No rows returned.
--
-- If rows are returned:
-- Duplicate customer_key values exist and must be investigated.
-- ============================================================================

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;



-- ============================================================================
-- CHECK 2: Verify Product Key Uniqueness
-- ============================================================================
-- Purpose:
-- Each product in dim_products should have exactly one unique surrogate key.
--
-- Expected Result:
-- No rows returned.
--
-- If rows are returned:
-- Duplicate product_key values exist and must be investigated.
-- ============================================================================

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;



-- ============================================================================
-- CHECK 3: Verify Fact-to-Dimension Relationships
-- ============================================================================
-- Purpose:
-- Ensure every sales record in fact_sales has:
--   - A valid customer in dim_customers
--   - A valid product in dim_products
--
-- Expected Result:
-- No rows returned.
--
-- If rows are returned:
-- Fact records exist without matching dimension records.
-- These are called orphan records and can cause incorrect reports.
-- ============================================================================

SELECT *
FROM gold.fact_sales f

LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key

LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key

WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;