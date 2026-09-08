/*
FinanceOne Power Query / Dataflow Gen2 Transformation Reference

Purpose
-------
Documents the principal transformation patterns used in the FinanceOne
Bronze-to-Silver processing layer. The queries standardize financial keys,
enrich fact data from reference tables, validate dimensional integrity,
and prepare GL, Budget, and Forecast data for the Gold dimensional model.

The examples are organized as reusable Power Query (M) patterns representing
the FinanceOne transformation design.
*/


// ============================================================================
// 1. GENERAL LEDGER — STANDARDIZE KEY DATA TYPES
// ============================================================================

let
    Source = silver_fact_gl_source,
    StandardizedTypes = Table.TransformColumnTypes(
        Source,
        {
            {"account_number", type text},
            {"department_code", type text},
            {"location_code", type text},
            {"fiscal_year", Int64.Type},
            {"fiscal_period", Int64.Type},
            {"debit_amount", Currency.Type},
            {"credit_amount", Currency.Type}
        }
    )
in
    StandardizedTypes


// ============================================================================
// 2. GENERAL LEDGER — ACCOUNT DIMENSION MATCH
// ============================================================================

let
    Source = StandardizedGL,
    MergeAccount = Table.NestedJoin(
        Source,
        {"account_number"},
        silver_account,
        {"account_number"},
        "AccountMatch",
        JoinKind.LeftOuter
    ),
    ExpandAccount = Table.ExpandTableColumn(
        MergeAccount,
        "AccountMatch",
        {"account_id"},
        {"account_id"}
    )
in
    ExpandAccount


// ============================================================================
// 3. GENERAL LEDGER — DEPARTMENT DIMENSION MATCH
// ============================================================================

let
    Source = GLWithAccount,
    MergeDepartment = Table.NestedJoin(
        Source,
        {"department_code"},
        silver_department,
        {"department_code"},
        "DepartmentMatch",
        JoinKind.LeftOuter
    ),
    ExpandDepartment = Table.ExpandTableColumn(
        MergeDepartment,
        "DepartmentMatch",
        {"department_id"},
        {"department_id"}
    )
in
    ExpandDepartment


// ============================================================================
// 4. GENERAL LEDGER — LOCATION DIMENSION MATCH
// ============================================================================

let
    Source = GLWithDepartment,
    MergeLocation = Table.NestedJoin(
        Source,
        {"location_code"},
        silver_location,
        {"location_code"},
        "LocationMatch",
        JoinKind.LeftOuter
    ),
    ExpandLocation = Table.ExpandTableColumn(
        MergeLocation,
        "LocationMatch",
        {"location_id"},
        {"location_id"}
    )
in
    ExpandLocation


// ============================================================================
// 5. GENERAL LEDGER — FISCAL PERIOD MATCH
// ============================================================================

let
    Source = GLWithLocation,
    MergeFiscalPeriod = Table.NestedJoin(
        Source,
        {"fiscal_year", "fiscal_period"},
        silver_fiscal_calendar,
        {"fiscal_year", "fiscal_period"},
        "FiscalPeriodMatch",
        JoinKind.LeftOuter
    ),
    ExpandFiscalPeriod = Table.ExpandTableColumn(
        MergeFiscalPeriod,
        "FiscalPeriodMatch",
        {"fiscal_period_id"},
        {"fiscal_period_id"}
    )
in
    ExpandFiscalPeriod


// ============================================================================
// 6. GENERAL LEDGER — DIMENSIONAL KEY VALIDATION
// ============================================================================

let
    Source = GLWithFiscalPeriod,
    AddFactKeyStatus = Table.AddColumn(
        Source,
        "fact_key_status",
        each
            if [entity_id] = null then "MISSING_ENTITY"
            else if [account_id] = null then "MISSING_ACCOUNT"
            else if [department_id] = null then "MISSING_DEPARTMENT"
            else if [location_id] = null then "MISSING_LOCATION"
            else if [fiscal_period_id] = null then "MISSING_FISCAL_PERIOD"
            else "VALID",
        type text
    )
in
    AddFactKeyStatus


// ============================================================================
// 7. GENERAL LEDGER — SIGNED AMOUNT
// ============================================================================
// FinanceOne uses signed_amount as the core GL value consumed by the
// semantic-model Net Amount measure.

let
    Source = ValidatedGL,
    AddSignedAmount = Table.AddColumn(
        Source,
        "signed_amount",
        each [debit_amount] - [credit_amount],
        Currency.Type
    )
in
    AddSignedAmount


// ============================================================================
// 8. BUDGET — STANDARDIZE TYPES AND MATCH FISCAL PERIOD
// ============================================================================

let
    Source = silver_budget_source,
    StandardizedTypes = Table.TransformColumnTypes(
        Source,
        {
            {"account_number", type text},
            {"entity_code", type text},
            {"department_code", type text},
            {"location_code", type text},
            {"fiscal_year", Int64.Type},
            {"fiscal_period", Int64.Type},
            {"budget_amount", Currency.Type},
            {"budget_validation_status", type text}
        }
    ),
    MergeFiscalPeriod = Table.NestedJoin(
        StandardizedTypes,
        {"fiscal_year", "fiscal_period"},
        silver_fiscal_calendar,
        {"fiscal_year", "fiscal_period"},
        "FiscalPeriodMatch",
        JoinKind.LeftOuter
    ),
    ExpandFiscalPeriod = Table.ExpandTableColumn(
        MergeFiscalPeriod,
        "FiscalPeriodMatch",
        {"fiscal_period_id"},
        {"matched_fiscal_period_id"}
    )
in
    ExpandFiscalPeriod


// ============================================================================
// 9. BUDGET — KEY VALIDATION STATUS
// ============================================================================

let
    Source = BudgetWithKeys,
    AddFactBudgetKeyStatus = Table.AddColumn(
        Source,
        "fact_budget_key_status",
        each
            if [entity_id] = null then "MISSING_ENTITY"
            else if [account_id] = null then "MISSING_ACCOUNT"
            else if [department_id] = null then "MISSING_DEPARTMENT"
            else if [location_id] = null then "MISSING_LOCATION"
            else if [matched_fiscal_period_id] = null then "MISSING_FISCAL_PERIOD"
            else "VALID",
        type text
    )
in
    AddFactBudgetKeyStatus


// ============================================================================
// 10. FORECAST — STANDARDIZE FINANCIAL KEYS
// ============================================================================
// FinanceOne keeps Forecast as a separate fact domain. Forecast does not use
// location_code; its grain includes fiscal period, entity, department,
// account, and forecast amount.

let
    Source = silver_forecast_source,
    StandardizedTypes = Table.TransformColumnTypes(
        Source,
        {
            {"account_number", type text},
            {"entity_code", type text},
            {"department_code", type text},
            {"fiscal_year", Int64.Type},
            {"fiscal_period", Int64.Type},
            {"forecast_amount", Currency.Type}
        }
    )
in
    StandardizedTypes


// ============================================================================
// 11. GOLD MODEL — CONSISTENT RELATIONSHIP KEY TYPES
// ============================================================================
// Relationship keys are standardized before loading the Gold model.
// This prevents Direct Lake relationship failures caused by mismatched
// numeric/text key types.

let
    Source = SilverFinanceData,
    RelationshipKeyTypes = Table.TransformColumnTypes(
        Source,
        {
            {"account_number", type text},
            {"department_id", type text},
            {"entity_id", type text}
        }
    )
in
    RelationshipKeyTypes
