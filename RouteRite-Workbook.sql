SELECT * FROM routerite_leads;
SELECT *  FROM routerite_sales;

-- =========================================
-- CLEANING: routerite_leads
-- =========================================

-- Step 1: Create backup before any changes
CREATE TABLE routerite_leads_backup AS
SELECT * FROM routerite_leads;


-- Step 2: Check for NULLs across key columns
-- Found a few in each — decided to leave optional fields as-is,
-- will COALESCE at report time rather than UPDATE the raw table
SELECT
    SUM(CASE WHEN company_name IS NULL THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS null_phone,
    SUM(CASE WHEN techs_trucks IS NULL THEN 1 ELSE 0 END) AS null_techs,
    SUM(CASE WHEN lead_id IS NULL THEN 1 ELSE 0 END) AS null_lead_id
FROM routerite_leads;

SELECT COUNT(*) FROM leads WHERE salesperson IS NULL;

-- Confirm the nulls in Lead ID since it is important, then exclude it going forward 
SELECT * FROM routerite_leads WHERE lead_id IS NULL;

-- Step 3: Check for dups in relevnt columns 
SELECT lead_id, COUNT(*) AS occurrences
FROM routerite_leads
GROUP BY lead_id
HAVING COUNT(*) > 1;

/* lead_id R0076 — two different companies, cannot be resolved without source data, 
left as-is since neither has an associated sale. */
SELECT * FROM routerite_leads WHERE lead_id  = 'R0076';

-- Step 4:  CHecking for different case, spaces etc and fixing 
SELECT DISTINCT source FROM routerite_leads;

SELECT DISTINCT UPPER(TRIM(source)) AS clean_source FROM routerite_leads;
UPDATE routerite_leads SET source = UPPER(TRIM(source));

SELECT source FROM routerite_leads;

UPDATE routerite_leads
SET source = 'FACEBOOK ADS'
WHERE source  = 'FB';

SELECT DISTINCT source FROM routerite_leads;


--  Checking other columns  - These look good 
SELECT DISTINCT routing_method FROM routerite_leads;
SELECT DISTINCT timeline FROM routerite_leads;

-- Step 5: Checking date formats and fixing 
SELECT submission_date FROM routerite_leads;

SELECT STR_TO_DATE(submission_date, '%m/%d/%Y') AS clean_date FROM routerite_leads;

UPDATE routerite_leads
SET submission_date = STR_TO_DATE(submission_date, '%m/%d/%Y');

ALTER TABLE routerite_leads MODIFY submission_date DATE;

-- =========================================
-- CLEANING: routerite_sales
-- =========================================

SELECT *  FROM routerite_sales;

-- Step 1: Create backup before any changes
CREATE TABLE routerite_sales_backup AS
SELECT * FROM routerite_sales;

-- Step 2: Check for NULLs across key columns
-- There aere no nulls from these columnns only from the closed
-- date and revenue which makle sense
SELECT
    SUM(CASE WHEN lead_id IS NULL THEN 1 ELSE 0 END) AS null_lead_id,
    SUM(CASE WHEN salesperson IS NULL THEN 1 ELSE 0 END) AS null_salesperson,
    SUM(CASE WHEN deal_stage IS NULL THEN 1 ELSE 0 END) AS null_deal_stage
FROM routerite_sales;

SELECT COUNT(*) FROM routerite_sales WHERE salesperson IS NULL;

-- Step 3: Check for dups in relevnt columns 
SELECT lead_id, COUNT(*) AS occurrences
FROM routerite_sales
GROUP BY lead_id
HAVING COUNT(*) > 1;


SELECT * FROM routerite_sales WHERE lead_id  = 'R0036';
-- delete actual dup
DELETE FROM routerite_sales WHERE sale_id = 81;

-- make sure it was deleted
SELECT * FROM routerite_sales WHERE lead_id  = 'R0036';


-- Step 4:  Checking for different case, spaces etc and fixing 
SELECT *  FROM routerite_sales;
SELECT DISTINCT salesperson FROM routerite_sales;
SELECT DISTINCT deal_stage FROM routerite_sales;


-- Step 5: Checking date formats and fixing 
-- this column is already a date column type
-- the nulls are for Not yet closed. might change later
SELECT close_date FROM routerite_sales;

SELECT * FROM routerite_sales;

-- 6. Check revenue for any issues
-- Excluding sale_id 86 (R0086) from revenue calcs — revenue of $2,540,325 is a clear
-- typo/outlier vs. the rest of the dataset (next highest is ~$33,700).
-- In a real scenario, would confirm the correct value with the salesperson before
-- either fixing or permanently excluding.
SELECT *
FROM routerite_sales
WHERE sale_id != 'R0086';


-- =========================================
-- GET READY TO EXPORT FOR TABLEAU
-- =========================================
SELECT 
    l.lead_id, l.company_name, l.techs_trucks, l.routing_method, l.timeline,
    l.source, l.submission_date,
    COALESCE(s.salesperson, 'Not Assigned') AS salesperson,
    COALESCE(s.deal_stage, 'No Opportunity') AS deal_stage,
    s.revenue,
    s.close_date
FROM routerite_leads l
LEFT JOIN routerite_sales s ON l.lead_id = s.lead_id
WHERE s.lead_id != 'R0086' OR s.sale_id IS NULL;





