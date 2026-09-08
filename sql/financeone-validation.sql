/*
FinanceOne Financial Validation
Microsoft Fabric / SQL

Purpose
-------
Validation queries supporting the FinanceOne General Ledger data-quality workflow.
The checks focus on journal balancing and dimensional-key integrity before financial
data is consumed by the semantic model and Power BI reporting layer.

FinanceOne GL scale:
- 60,000 journals
- 166,888 journal lines
*/


-- ============================================================================
-- 1. JOURNAL DEBIT / CREDIT RECONCILIATION
-- ============================================================================
-- Summarizes each journal and calculates the difference between total debits
-- and total credits.

SELECT
    journal_id,
    SUM(COALESCE(debit_amount, 0))  AS total_debit,
    SUM(COALESCE(credit_amount, 0)) AS total_credit,
    SUM(COALESCE(debit_amount, 0))
        - SUM(COALESCE(credit_amount, 0)) AS journal_imbalance
FROM fact_gl
GROUP BY journal_id
ORDER BY journal_id;


-- ============================================================================
-- 2. IDENTIFY UNBALANCED JOURNALS
-- ============================================================================
-- Uses a $0.05 tolerance to isolate journals requiring investigation.

SELECT
    journal_id,
    SUM(COALESCE(debit_amount, 0))  AS total_debit,
    SUM(COALESCE(credit_amount, 0)) AS total_credit,
    SUM(COALESCE(debit_amount, 0))
        - SUM(COALESCE(credit_amount, 0)) AS journal_imbalance
FROM fact_gl
GROUP BY journal_id
HAVING ABS(
    SUM(COALESCE(debit_amount, 0))
        - SUM(COALESCE(credit_amount, 0))
) > 0.05
ORDER BY ABS(
    SUM(COALESCE(debit_amount, 0))
        - SUM(COALESCE(credit_amount, 0))
) DESC;


-- ============================================================================
-- 3. COUNT UNBALANCED JOURNALS
-- ============================================================================
-- Provides a compact control total for the journal-balance validation.

SELECT
    COUNT(*) AS unbalanced_journal_count
FROM (
    SELECT
        journal_id
    FROM fact_gl
    GROUP BY journal_id
    HAVING ABS(
        SUM(COALESCE(debit_amount, 0))
            - SUM(COALESCE(credit_amount, 0))
    ) > 0.05
) AS unbalanced_journals;


-- ============================================================================
-- 4. GENERAL LEDGER CONTROL TOTALS
-- ============================================================================
-- Confirms total journal-line volume and organization-wide debit/credit totals.

SELECT
    COUNT(*) AS journal_line_count,
    COUNT(DISTINCT journal_id) AS journal_count,
    SUM(COALESCE(debit_amount, 0)) AS total_debit,
    SUM(COALESCE(credit_amount, 0)) AS total_credit,
    SUM(COALESCE(debit_amount, 0))
        - SUM(COALESCE(credit_amount, 0)) AS net_difference
FROM fact_gl;


-- ============================================================================
-- 5. MISSING ACCOUNT VALIDATION
-- ============================================================================
-- Identifies GL rows whose account number does not resolve to dim_account.

SELECT
    gl.journal_id,
    gl.journal_line_number,
    gl.account_number
FROM fact_gl AS gl
LEFT JOIN dim_account AS a
    ON gl.account_number = a.account_number
WHERE a.account_number IS NULL
ORDER BY gl.journal_id, gl.journal_line_number;


-- ============================================================================
-- 6. MISSING DEPARTMENT VALIDATION
-- ============================================================================
-- Identifies GL rows whose department key does not resolve to dim_department.

SELECT
    gl.journal_id,
    gl.journal_line_number,
    gl.department_id
FROM fact_gl AS gl
LEFT JOIN dim_department AS d
    ON gl.department_id = d.department_id
WHERE d.department_id IS NULL
ORDER BY gl.journal_id, gl.journal_line_number;


-- ============================================================================
-- 7. MISSING LOCATION VALIDATION
-- ============================================================================
-- Identifies GL rows whose location key does not resolve to dim_location.

SELECT
    gl.journal_id,
    gl.journal_line_number,
    gl.location_id
FROM fact_gl AS gl
LEFT JOIN dim_location AS l
    ON gl.location_id = l.location_id
WHERE l.location_id IS NULL
ORDER BY gl.journal_id, gl.journal_line_number;


-- ============================================================================
-- 8. MISSING FISCAL PERIOD VALIDATION
-- ============================================================================
-- Identifies GL rows whose fiscal-period key does not resolve to
-- dim_fiscal_period.

SELECT
    gl.journal_id,
    gl.journal_line_number,
    gl.fiscal_period_id
FROM fact_gl AS gl
LEFT JOIN dim_fiscal_period AS fp
    ON gl.fiscal_period_id = fp.fiscal_period_id
WHERE fp.fiscal_period_id IS NULL
ORDER BY gl.journal_id, gl.journal_line_number;


-- ============================================================================
-- 9. FACT KEY STATUS SUMMARY
-- ============================================================================
-- Summarizes the dimensional-key validation status generated during the
-- FinanceOne Silver transformation process.

SELECT
    fact_key_status,
    COUNT(*) AS journal_line_count
FROM fact_gl
GROUP BY fact_key_status
ORDER BY fact_key_status;


-- ============================================================================
-- 10. VALID VS EXCEPTION GL ROWS
-- ============================================================================
-- Provides a final high-level data-quality control before semantic-model use.

SELECT
    CASE
        WHEN fact_key_status = 'VALID' THEN 'VALID'
        ELSE 'EXCEPTION'
    END AS validation_result,
    COUNT(*) AS journal_line_count
FROM fact_gl
GROUP BY
    CASE
        WHEN fact_key_status = 'VALID' THEN 'VALID'
        ELSE 'EXCEPTION'
    END
ORDER BY validation_result;
