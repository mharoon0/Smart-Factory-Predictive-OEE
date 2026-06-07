# Use Case A: Isolating the Repeat Bottleneck (The Pareto Principle Analysis)

  SELECT 
      m.Production_Line,
      f.Subsystem_Component,
      f.Error_Code,
      COUNT(f.Failure_ID) AS Total_Failure_Incidents,
      SUM(f.Repair_Time_Min) AS Total_Downtime_Minutes,
      ROUND(AVG(f.Repair_Time_Min), 1) AS Average_Time_To_Repair_MTTR
  FROM Fact_Machine_Failures f
  JOIN Dim_Machines m ON f.Machine_ID = m.Machine_ID
  GROUP BY m.Production_Line, f.Subsystem_Component, f.Error_Code
  ORDER BY Total_Downtime_Minutes DESC;

# Use Case B: Chronological Failure Sequencing (Advanced Window Function)

  WITH RankedFailures AS (
      SELECT 
          f.Failure_ID,
          f.Date,
          m.Machine_Name,
          f.Subsystem_Component,
          f.Repair_Time_Min,
          ROW_NUMBER() OVER (
              PARTITION BY f.Machine_ID 
              ORDER BY f.Repair_Time_Min DESC, f.Date ASC
          ) AS Severity_Rank
      FROM Fact_Machine_Failures f
      JOIN Dim_Machines m ON f.Machine_ID = m.Machine_ID
  )
  SELECT 
      Failure_ID,
      Date,
      Machine_Name,
      Subsystem_Component,
      Repair_Time_Min AS Peak_Downtime_Minutes
  FROM RankedFailures
  WHERE Severity_Rank = 1;
