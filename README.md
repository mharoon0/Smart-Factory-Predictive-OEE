# Smart Factory: Predictive OEE & Manufacturing Analytics Pipeline
## Enterprise Business Intelligence Case Study

[![Power BI](https://images.seeklogo.com/logo-png/40/1/power-bi-microsoft-logo-png_seeklogo-400711.png)](https://powerbi.microsoft.com/)

### 🔗 Portfolio Assets
* **Dashboard:** View Static Captures in `/assets`
* **Production Dataset Source:** `data/SmartFactory_OEE_Data.xlsx`
* **Relational Database Blueprint:** `model/SmartFactory_OEE_Model.pbix`

---

## 🏗️ 1. Business Scenario & Project Objective
In high-volume automated manufacturing environments, unplanned asset downtime and quality bottlenecks immediately jeopardize corporate profit margins. This project engineers an enterprise-grade Business Intelligence (BI) pipeline within Power BI to dynamically calculate, track, and monitor **Overall Equipment Effectiveness (OEE)** across 4 concurrent production assets:
1. **Robotic Welding Station A** (Fuel Tank Line)
2. **Automated Stamping Press** (Main Frame Assembly)
3. **Sustainable Curing Oven** (Paint Shop)
4. **Final Component Assembly** (Logistics Hub)

**The Core Goal:** Build a robust relational data ecosystem that acts as an interactive root-cause diagnostics terminal rather than a static reporting chart. The framework ingests multi-tab production transactions, processes them via a semantic DAX engine, and cross-filters shift schedules to flag predictive maintenance thresholds before system bottlenecks result in line failure.

---

## ⚙️ 2. Relational Architecture & Data Modeling
To bypass the performance and aggregation limitations of single-table flat spreadsheets, this project implements a professional **Star Schema** data model inside Power BI. This architecture optimizes DAX query evaluation speeds and isolates transactional logs from dimensional data.

```text
       [Dim_Machines]                     [Dim_Shifts]
     (Asset Capacities)                (Shift Windows)
             \                               /
              \                             /
             [Fact_OEE_Production] <--- [Dim_Date]
             (Shift Yield Logs)     (Independent Calendar)
                      ^
                      |
            [Fact_Machine_Failures]
             (Telemetry Error Logs)
```
### Data Pipeline Mechanics & Relationship Management

* **Dim_Machines ➔ Fact_OEE_Production / Fact_Machine_Failures:** One-to-Many ($1:*$) single-direction relationships mapped on `Machine_ID`.
* **Dim_Shifts ➔ Fact_OEE_Production:** One-to-Many ($1:*$) single-direction relationship mapped on `Shift_ID`.
* **Bi-Directional Filtering Integration:** > The relationship between `Dim_Machines` and `Fact_Machine_Failures` is explicitly configured to **Cross filter direction: Both**. This allows users to select an individual telemetry error code in the diagnostics rail and propagate that filter signal up to the dimension table and straight down into the production fact table, dynamically recalculating OEE metrics for only the affected periods.
* **Independent Time Intelligence:** A programmatic calendar dimension (`Dim_Date`) is generated via DAX to map continuous timelines, completely eliminating reliance on auto-generated column fields and ensuring error-free time-series tracking.

---

## 🧪 3. Advanced Analytics & Formula Engineering (DAX Layer)

Calculations completely reject default implicit sums and instead model the compounding mathematical physics of manufacturing effectiveness:

$$\text{OEE} = \text{Availability} \times \text{Performance} \times \text{Quality}$$

The following custom, context-aware DAX expressions were authored to preserve absolute mathematical integrity across all visual drill-down granularities (**Line ➔ Machine ➔ Date ➔ Shift**):

#### A. Plant Operating Time (Isolating Planned Capacity)
Enforces a row-by-row iteration across shift configurations using a nested `SUMX` pattern to handle baseline production capacities without filter conflict traps:

```dax
Planned_Operating_Time_Min = 
SUMX(
    Fact_OEE_Production,
    RELATED(Dim_Shifts[Scheduled_Time_Min]) - RELATED(Dim_Shifts[Planned_Downtime_Min])
)
```
#### B. Machine Availability ($A$)
Evaluates net active uptime fractions relative to planned runtime caps following unplanned machine stoppages:

```dax
Machine_Availability = 
VAR TotalRunTime = [Planned_Operating_Time_Min] - SUM(Fact_OEE_Production[Unplanned_Downtime_Min])
RETURN
    DIVIDE(TotalRunTime, [Planned_Operating_Time_Min], 0)
```
#### C. Machine Performance ($P$)
Compares physical throughput speeds against optimal cycle time metrics to highlight mechanical deceleration losses:

```dax
Machine_Performance = 
VAR IdealTimeSpentSec = SUMX(Fact_OEE_Production, Fact_OEE_Production[Total_Units_Produced] * RELATED(Dim_Machines[Ideal_Cycle_Time_Sec]))
VAR ActualRunTimeSec = ([Planned_Operating_Time_Min] - SUM(Fact_OEE_Production[Unplanned_Downtime_Min])) * 60
RETURN
    DIVIDE(IdealTimeSpentSec, ActualRunTimeSec, 0)
```
#### D. Machine Quality ($Q$)
Isolates the ratio of pristine component yields against overall manufactured volumetric output:
```dax
Machine_Quality = 
VAR GoodUnits = SUM(Fact_OEE_Production[Total_Units_Produced]) - SUM(Fact_OEE_Production[Defective_Units])
RETURN
    DIVIDE(GoodUnits, SUM(Fact_OEE_Production[Total_Units_Produced]), 0)
```
#### E. Composite OEE Index & Fleet-Level Averaging

```dax
Calculated_OEE = [Machine_Availability] * [Machine_Performance] * [Machine_Quality]
```
#### F. Programmatic Predictive Alert Logic

```dax
Predictive_Maintenance_Alert = 
VAR CurrentOEE = [Calculated_OEE]
VAR BaselineTarget = AVERAGE(Dim_Machines[Target_OEE])
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(CurrentOEE), "No Operations Logged",
        CurrentOEE < (BaselineTarget - 0.15), "⚠️ CRITICAL DEGRADATION: Schedule Overhaul",
        CurrentOEE < BaselineTarget, "💡 PERFORMANCE LOSS: Investigate Tooling",
        "✅ Optimal Operations"
    )
```

---

## 📊 4. Front-End Visual Analytics & Interface Architecture

### Executive Healthstrip (KPI Cards)
The upper dashboard canvas clusters high-visibility cards grouping three decoupled operational monitoring parameters alongside live system telemetry:

* **Aggregate Floor OEE Target:** Uses `AVERAGEX` to compute the truest factory conditions, preventing raw percentage summing errors.
* **Unplanned Stoppages:** Sums up raw minutes lost exclusively due to equipment downtime events.
* **Total Component Yield:** Tracks live component execution volume velocities across lines.

---

### Line Anomaly Grid Matrix & Exception Heat-Mapping
Operational drill-downs enforce a clean parent-child relationship hierarchy (`Production_Line` ➔ `Machine_Name` ➔ `Date` ➔ `Shift_ID`) inside an interactive Matrix. The layout eliminates abstract flat values by embedding color exception formatting based on operational thresholds:

* 🛑 **Critical Degradation (<78% OEE):** Soft Red color rules immediately target localized shift bottlenecks.
* ⚠️ **Performance Deviation (78% - 85% OEE):** Soft Amber highlights active speed-loss parameters.
* ✅ **Nominal Parameters (>85% OEE):** Soft Green confirms stable operation matching line targets.

---

### Diagnostic Slicer Panel
A dedicated right-hand control rail integrates interactive selection objects tied directly to the `Fact_Machine_Failures` log:

* **Subsystem Component Slicer:** Filters data down to specific physical asset components (e.g., *Welding Pneumatic Arm*, *Main Hydraulic Actuator*).
* **Error Code Tile Slicer:** Isolates precise machine telemetry codes (e.g., `ERR_THERMO_102`, `ERR_PNEUMATIC_40`), allowing managers to analyze the exact downtime and OEE impact of structural errors on the fly.

---

### 📈 5. Root-Cause Operational Insights Discovered

Deploying this BI framework successfully exposed hidden plant performance anomalies that were previously obscured by rolled-up global averages:

* **The Paint Shop Thermal Deficit (May 5th - Early Shift):** Machine `M_003` dropped to a critical **50% OEE**. The right-hand diagnostic panel filtered this directly to relay fault `ERR_THERMO_102` in the Heating Element, identifying clear component wear.
* **The Stamping Press Hydraulic Bottleneck (May 4th - Early Shift):** Machine `M_002` triggered a severe speed loss alert due to an actuator fluid drop (`ERR_HYDRAULIC_P`), cutting line availability while driving up component defects to **190 units**.
* **The Welding Station Pneumatic Deviation (May 3rd - Early Shift):** Machine `M_001` dropped below its **85% operational target**, flagging micro-stoppages related to the pneumatic arm timing.
