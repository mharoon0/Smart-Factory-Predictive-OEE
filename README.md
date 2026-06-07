# Smart Factory Predictive OEE & Manufacturing Analytics Pipeline
## Industrial Business Intelligence Case Study

### Business Scenario & Objective
In high-volume manufacturing environments, unplanned asset downtime and quality drop-offs directly erode corporate profit margins. This project engineers an enterprise-grade Business Intelligence architecture to calculate and monitor **Overall Equipment Effectiveness (OEE)** across 4 concurrent production lines (Fuel Tank Line, Main Frame Assembly, Paint Shop, and Logistics Hub). 

By integrating multi-source factory floor transactions ( dbt/SQL principles) into a relational Star Schema, this pipeline extracts raw sensor telemetry and shift records to flag system-level degradation patterns before mechanical thresholds are breached.

### Data Architecture
The data infrastructure utilizes a clean relational Star Schema modeling cascading dimensions into structural transaction logs:
* **Fact_OEE_Production**: Continuous operational ledger tracking shift yields and unplanned stoppages (60+ rows of transactional entries).
* **Fact_Machine_Failures**: Diagnostics log tracking component-specific telemetry alert codes.
* **Dim_Machines / Dim_Shifts**: Structural reference data mapping physical cycle capacities and planned baseline constraints.
* **Dim_Date**: Programmatic analytical calendar table for independent time intelligence verification.

## Technical Implementation & DAX Architecture

### Relational Data Model (Star Schema)
To ensure optimal query performance, the database model rejects single-table structures and enforces a strict Star Schema design pattern:
1. One-to-Many (1:*) relationship mapping between asset dimension arrays (`Dim_Machines`) and operational logs (`Fact_OEE_Production` / `Fact_Machine_Failures`).
2. Programmatic time-series calculation utilizing an independent `Dim_Date` calendar table to prevent calendar loops and allow dynamic cross-fact data filtering.

### Mathematical Formulations (OEE Calculations)
Rather than summarizing raw metrics, Overall Equipment Effectiveness is computed dynamically via modular metrics dependencies:

$$\text{OEE} = \text{Availability} \times \text{Performance} \times \text{Quality}$$

* **Availability Measure**: Computes remaining active execution periods against planned runtime limits following unplanned machine stoppages:
  ```dax
  Machine_Availability = 
  VAR TotalRunTime = [Planned_Operating_Time_Min] - SUM(Fact_OEE_Production[Unplanned_Downtime_Min])
  RETURN DIVIDE(TotalRunTime, [Planned_Operating_Time_Min], 0)

* **Performance Measure**: Compares physical component throughput cycle limits against absolute actual operating seconds to isolate localized speed losses:
  ```dax
  Machine_Performance = 
  VAR IdealTimeSpentSec = SUMX(Fact_OEE_Production, Fact_OEE_Production[Total_Units_Produced] * RELATED(Dim_Machines[Ideal_Cycle_Time_Sec]))
  VAR ActualRunTimeSec = ([Planned_Operating_Time_Min] - SUM(Fact_OEE_Production[Unplanned_Downtime_Min])) * 60
  RETURN DIVIDE(IdealTimeSpentSec, ActualRunTimeSec, 0)

* **Quality Measure**: Rates the ratio of pristine component manufacturing output against aggregate product volume logs:
  ```dax
  Machine_Quality = 
  VAR GoodUnits = SUM(Fact_OEE_Production[Total_Units_Produced]) - SUM(Fact_OEE_Production[Defective_Units])
  RETURN DIVIDE(GoodUnits, SUM(Fact_OEE_Production[Total_Units_Produced]), 0)

## Enterprise Data Warehouse Analytics (SQL Audit Engine)

To complement the Power BI visual semantic layer, this framework incorporates production-grade SQL optimization scripts deployed directly into the simulated enterprise data layer (Snowflake / PostgreSQL standard). 

### Real-World Analytical Use Cases Implemented:
1. **The Plant Pareto Bottleneck Analysis**: Aggregates component-specific failure frequencies alongside total operational minutes lost. This highlights the exact subsystem components (e.g., *Welding Pneumatic Arms*) eating away at corporate profit margins.
2. **Chronological Failure Partitioning**: Deploys advanced SQL Window Functions (`ROW_NUMBER() OVER (PARTITION BY...)`) to isolate, rank, and extract the single most severe downtime incident for every machine asset across the time series to streamline Mean Time To Repair (MTTR) audits.
