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
