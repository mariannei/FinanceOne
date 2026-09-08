# FinanceOne

**Microsoft Fabric Financial Analytics Platform**

FinanceOne is a self-directed financial data engineering and analytics project built with simulated ERP-style financial data. The project demonstrates an end-to-end Microsoft Fabric implementation spanning data ingestion, Medallion architecture, financial data transformation and validation, Direct Lake semantic modeling, DAX, and executive Power BI reporting.

## Project Overview

FinanceOne was designed to simulate a financial analytics environment where General Ledger, Budget, Forecast, and reference data are processed through a structured Microsoft Fabric architecture.

The solution processes:

- 60,000 GL journals
- 166,888 GL journal lines
- 269,406 budget records
- Five fiscal years of budget data (FY2022–FY2026)
- General Ledger, Budget, and Forecast fact data
- Account, Department, Entity, Fiscal Period, and Location dimensions

## Architecture

The solution follows a Medallion architecture:

**ERP-Style Source Data → Bronze → Silver → Gold → Direct Lake Semantic Model → Power BI**

- **Bronze:** Raw source ingestion and preservation
- **Silver:** Data transformation, standardization, dimensional-key validation, and financial data-quality controls
- **Gold:** Conformed dimensions and financial fact tables optimized for analytics
- **Direct Lake:** Semantic modeling over Fabric data without traditional import-mode duplication
- **Power BI:** CFO-level financial reporting and General Ledger analysis

## Technology Stack

- Microsoft Fabric
- OneLake
- Fabric Lakehouse
- Data Factory Pipelines
- Dataflow Gen2
- Power Query
- Direct Lake
- Semantic Models
- DAX
- Power BI
## Data Model

FinanceOne uses a dimensional model designed for financial reporting and analysis.

### Fact Tables

- `fact_gl` — General Ledger journal-line activity
- `fact_budget` — Budget data by fiscal period, entity, department, location, and account
- `fact_forecast` — Forecast data by fiscal period, entity, department, and account

### Dimension Tables

- `dim_account`
- `dim_department`
- `dim_entity`
- `dim_fiscal_period`
- `dim_location`

The semantic model uses many-to-one relationships between the financial fact tables and conformed dimensions.

## Data Engineering Pipeline

FinanceOne implements an end-to-end Fabric data pipeline across Bronze, Silver, and Gold layers.

### Bronze

Raw ERP-style source files are ingested into the Bronze Lakehouse using Fabric Data Factory pipelines.

Data domains include:

- Reference data
- General Ledger
- Budget
- Forecast

### Silver

Dataflow Gen2 is used to transform and standardize Bronze data.

Transformation work includes:

- Data type standardization
- Dimensional key validation
- Account and department matching
- Entity and location matching
- Fiscal period validation
- General Ledger data-quality checks
- Budget and Forecast preparation

### Gold

The Gold Lakehouse contains conformed dimensions and financial fact tables used by the Direct Lake semantic model.

The Gold layer supports:

- General Ledger analysis
- Budget analysis
- Forecast analysis
- Financial statement reporting
- Entity and location reporting
- Executive dashboard analytics

## Financial Validation & Data Quality

Financial controls were incorporated into the transformation process rather than treating reporting as a visualization-only exercise.

Validation included:

- Journal debit and credit reconciliation
- Detection of unbalanced journal entries
- Missing account validation
- Missing department validation
- Missing location validation
- Missing fiscal period validation
- Dimensional key status checks

The expanded General Ledger dataset contains:

- 60,000 journals
- 166,888 journal lines

Twelve intentionally unbalanced journals were identified and corrected during validation, resulting in zero journals remaining with an imbalance greater than $0.05.

## Power BI Reporting

FinanceOne includes an executive financial dashboard and General Ledger detail reporting.

### CFO Executive Dashboard

The dashboard provides:

- Revenue
- Expenses
- Net Income
- Actual vs Budget vs Forecast
- Revenue by Location
- Expenses by Location
- Full-year Net Income trend
- General Ledger activity
- Total Debit and Total Credit reconciliation

Interactive filters include:

- Fiscal Year
- Period
- Entity
- Location

Custom DAX logic supports reciprocal Entity and Location filtering while preserving the dimensional model and avoiding ambiguous physical relationship paths.

### General Ledger Detail

The GL Detail page provides transaction-level visibility into journal activity with:

- Journal detail
- Account information
- Entity and location filtering
- Debit and credit values
- Total Debit
- Total Credit
- Net Amount reconciliation

## Key Engineering Challenges

Several implementation issues were resolved during development:

- Stale destination schemas after source expansion
- Direct Lake relationship failures caused by inconsistent key data types
- Ambiguous relationship paths between Entity, Location, and financial fact tables
- Dependent Entity and Location slicer behavior
- Fiscal period sorting and visual interaction behavior
- General Ledger financial validation
- Maintaining consistent dimensional keys across Silver, Gold, and the semantic model

These issues were resolved without compromising the intended star-schema design.

## Portfolio Case Study

A detailed case study with architecture, Fabric implementation screenshots, semantic modeling, reporting, and engineering challenges is available here:

[View the FinanceOne Portfolio Case Study](FinanceOne_Portfolio_Case_Study.pdf)

## Project Context

FinanceOne is a self-directed portfolio project developed using simulated ERP-style financial data. It was created to demonstrate practical Microsoft Fabric data engineering, financial systems analysis, semantic modeling, and Power BI reporting capabilities.
