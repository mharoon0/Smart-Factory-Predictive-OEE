# Smart Factory Predictive OEE & Manufacturing Analytics Pipeline
## Industrial Business Intelligence Case Study

### 🏗️ Business Scenario & Objective
In high-volume manufacturing environments, unplanned asset downtime and quality drop-offs directly erode corporate profit margins. This project engineers an enterprise-grade Business Intelligence architecture to calculate and monitor **Overall Equipment Effectiveness (OEE)** across 4 concurrent production lines (Fuel Tank Line, Main Frame Assembly, Paint Shop, and Logistics Hub). 

By integrating multi-source factory floor transactions ( dbt/SQL principles) into a relational Star Schema, this pipeline extracts raw sensor telemetry and shift records to flag system-level degradation patterns before mechanical thresholds are breached.

### 📊 Data Architecture
The data infrastructure utilizes a clean relational Star Schema modeling cascading dimensions into structural transaction logs:
* **Fact_OEE_Production**: Continuous operational ledger tracking shift yields and unplanned stoppages (60+ rows of transactional entries).
* **Fact_Machine_Failures**: Diagnostics log tracking component-specific telemetry alert codes.
* **Dim_Machines / Dim_Shifts**: Structural reference data mapping physical cycle capacities and planned baseline constraints.
* **Dim_Date**: Programmatic analytical calendar table for independent time intelligence verification.
