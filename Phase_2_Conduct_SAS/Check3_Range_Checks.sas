/* =====================================================
   PROJECT  = CDISCPILOT01 - CDM Portfolio Project
   AUTHOR   = Rutuj Argade
   DATE     = June 2026
   EDIT CHECKS :
   CHECK 3  = Out of Range Value Detection
   PURPOSE  = Flagged VS and LB values outside their
              normal reference ranges.
              Also flagged unit-value mismatches in VS domain
   INPUT    = mydata.vs, mydata.lb, mydata.dm
   OUTPUT   = output.vs_range_queries
              output.lb_range_queries
              output.master_range_queries
======================================================== */
  
  
/*------------------------------------------------------- 
   To Check Value Distribution by Test and Unit
---------------------------------------------------------*/
PROC MEANS DATA=mydata.vs N MIN MAX MEAN NONOBS;
    WHERE VSTESTCD in ('SYSBP', 'DIABP', 'PULSE', 'TEMP', 'WEIGHT') and VSSTRESN is not missing ;
    VAR VSSTRESN;
    CLASS VSTESTCD VSORRESU;
    TITLE "Value Distribution by Test and Unit";
RUN;
TITLE;
  
/* ----------------------------------------------------------
   CHECK 3A : VITAL SIGNS RANGE CHECK
----------------------------------------------------------- */
PROC SQL;
    CREATE TABLE output.vs_range_queries AS
    SELECT
       d.USUBJID  AS Subject_ID,
       d.SITEID   AS Site_ID,
       d.ARM      AS Treatment_Arm,
       v.VSTESTCD AS Test_Code,
       v.VSTEST   AS Test_Name,
       v.VSORRES  AS Recorded_Result,
       v.VSORRESU AS Unit,
       'VS'       AS Domain,
    CASE
       WHEN v.VSTESTCD = 'SYSBP' AND v.VSSTRESN < 90 THEN 'Systolic BP below 90 mmHg'
       WHEN v.VSTESTCD = 'SYSBP' AND v.VSSTRESN > 160 THEN 'Systolic BP above 160 mmHg'
       WHEN v.VSTESTCD = 'DIABP' AND v.VSSTRESN < 55 THEN 'Dystolic BP below 55 mmHg'
       WHEN v.VSTESTCD = 'DIABP' AND v.VSSTRESN > 95 THEN 'Dystolic BP above 95 mmHg'
       WHEN v.VSTESTCD = 'PULSE' AND v.VSSTRESN < 50 THEN 'Heart rate below 50 bpm'
       WHEN v.VSTESTCD = 'PULSE' AND v.VSSTRESN > 100 THEN 'Heart rate above 100 bpm'
    END AS Issue,
      'OPEN' AS Query_Status
    FROM mydata.vs AS v INNER JOIN
       mydata.dm AS d 
    ON v.USUBJID = d.USUBJID
    WHERE (v.VSTESTCD = 'SYSBP' AND (v.VSSTRESN < 90 OR v.VSSTRESN > 160) AND (v.VSSTRESN IS NOT MISSING)) OR
          (v.VSTESTCD = 'DIABP' AND (v.VSSTRESN < 55 OR v.VSSTRESN > 95) AND (v.VSSTRESN IS NOT MISSING)) OR
          (v.VSTESTCD = 'PULSE' AND (v.VSSTRESN < 50 OR v.VSSTRESN > 100) AND (v.VSSTRESN IS NOT MISSING)) AND
          v.VSSTRESN IS NOT MISSING;
QUIT;
 
/* ----------------------------------------------------------------------------
   CHECK 3B : UNIT-VALUE MISMATCH DETECTION
------------------------------------------------------------------------------- */
PROC SQL;
    CREATE TABLE output.unit_mismatch_queries as
    SELECT
       d.USUBJID  AS Subject_ID,
       d.SITEID   AS Site_ID,
       d.ARM      AS Treatment_Arm,
       v.VSTESTCD AS Test_Code,
       v.VSTEST   AS Test_Name,
       v.VSORRES  AS Recorded_Result,
       v.VSORRESU AS Unit,
       'VS'       AS Domain,
   CASE
       WHEN v.VSTESTCD = 'TEMP' AND v.VSORRESU = 'F' AND v.VSSTRESN BETWEEN 34 AND 42 
       THEN 'Unit labeled as F but value is in Celcius range'
       WHEN v.VSTESTCD = 'WEIGHT' AND v.VSORRESU = 'LB' AND v.VSSTRESN BETWEEN 30 AND 150
       THEN 'Unit labeled as LB but value is in kg range'
   END AS Issue,
       'OPEN' AS Query_Status
   FROM mydata.vs AS v INNER JOIN mydata.dm AS d 
   ON v.USUBJID = d.USUBJID
   WHERE (v.VSTESTCD = 'TEMP' AND v.VSORRESU = 'F' AND (v.VSSTRESN BETWEEN 34 AND 42) AND (v.VSSTRESN IS NOT MISSING)) OR
       (v.VSTESTCD = 'WEIGHT' AND v.VSORRESU = 'LB' AND (v.VSSTRESN BETWEEN 30 AND 150) AND (v.VSSTRESN IS NOT MISSING)) AND
       v.VSSTRESN IS NOT MISSING;
Quit;
 
 
/* ---------------------------------------------------
   CHECK 3C : LAB RESULTS RANGE CHECK
--------------------------------------------------- */
PROC SQL;
    CREATE TABLE output.lb_range_queries AS
    select
       d.USUBJID  AS Subject_ID,
       d.SITEID   AS Site_ID,
       d.ARM      AS Treatment_Arm,
       l.LBTESTCD AS Test_Code,
       l.LBTEST   AS Test_Name,
       l.LBORRES  AS Recorded_Result,
       l.LBORRESU AS Unit,
       'LB'       AS Domain,
   CASE
       WHEN l.LBSTRESN < l.LBSTNRLO THEN 'Below Normal Range'
       WHEN l.LBSTRESN > l.LBSTNRHI THEN 'Above Normal Range'
   END AS Issue,
       'OPEN'   AS Query_Status
   FROM mydata.lb AS l INNER JOIN 
        mydata.dm AS d ON
        l.USUBJID = d.USUBJID
   WHERE (l.LBSTRESN < l.LBSTNRLO OR l.LBSTRESN > l.LBSTNRHI)
        AND l.LBSTRESN IS NOT MISSING;
QUIT;

 
/* ----------------------------------------------------------------------------
   MASTER RANGE QUERY REPORT 
   Combines Physiological range flags + unit mismatches + lab abnormalities 
------------------------------------------------------------------------------ */
PROC SQL;
    CREATE TABLE output.master_range_queries AS
    SELECT Subject_ID, Site_ID, Treatment_Arm, Test_Code, Test_Name, Recorded_Result,
        Unit, Domain, Issue, Query_Status FROM output.vs_range_queries 
        
UNION ALL
 
    SELECT  Subject_ID, Site_ID, Treatment_Arm, Test_Code, Test_Name, Recorded_Result,
        Unit, Domain, Issue, Query_Status FROM output.unit_mismatch_queries 
        
UNION ALL
 
    SELECT Subject_ID, Site_ID, Treatment_Arm, Test_Code, Test_Name, Recorded_Result,
        Unit, Domain, Issue, Query_Status FROM output.lb_range_queries;
QUIT;

 
 /*---Printing Reports---*/
PROC PRINT DATA=output.vs_range_queries NOOBS;
TITLE "Vital Signs Range Report";
TITLE2 "SYSBP DIABP PULSE | Status : Open";
RUN;

PROC PRINT DATA=output.unit_mismatch_queries NOOBS;
TITLE "Unit Value Mismatch Report";
TITLE2 "TEMP and WEIGHT Unit Inconsistencies | Status: OPEN";
RUN;

PROC PRINT DATA=output.lb_range_queries NOOBS;
TITLE "Lab Results Range Report | Status: OPEN";
RUN;

PROC PRINT DATA=output.master_range_queries NOOBS;
TITLE "Combined Range and Unit Query Report";
TITLE2 "VS and LB Domains | Status: OPEN";
RUN;
TITLE;
 
 
 
 
 
 
  
