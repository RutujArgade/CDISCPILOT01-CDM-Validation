/* =================================================================
  PROJECT  : CDISCPILOT01 - CDM Portfolio Project
  AUTHOR   : Rutuj Argade
  DATE     : June 2026
  CHECK 4  : Master Query Log Generator
  PURPOSE  : Consolidate all validation findings from Checks 1 to 3
             into a single master query log with summary
  INPUT    : output.master_missing_queries
             output.chron_ae_queries
             output.master_range_queries
  OUTPUT   : output.master_query_log
             output.query_summary
=============================================================== */
/* ---------------------------------
  Master Query Log
----------------------------------- */

PROC SQL;
	CREATE TABLE output.master_query_log AS 
/*---Check 1 : Missing Data---*/
	SELECT Subject_ID, Site_ID, Treatment_Arm, Domain, 
	       'Check 1' as Check_Number, 
	       'Missing_Data' as Check_Type, Issue, Query_Status 
    FROM output.master_missing_queries 
    
UNION ALL
    
/*---Check 2 : Chronology Errors---*/
    SELECT Subject_ID, Site_ID, Treatment_Arm, Domain, 
           'Check 2' AS Check_Number
           'Chronology Error' AS Check_Type, Issue, Query_Status
    FROM output.chron_ae_queries
    
UNION ALL
    
/*---Check 3 : Range and Unit Checks---*/
    SELECT Subject_ID, Site_ID, Treatment_Arm, Domain,
           'Check 3' AS Check_Number,
           'Range or Unit' AS Check_Type, Issue, Query_Status
    FROM output.master_range_queries;
Quit;

    
/* -----------------------------------------------
   Summary by check and domain
   ----------------------------------------------- */
PROC FREQ DATA=output.master_query_log;
    TABLES Check_Number*Domain*Check_Type / NOROW NOCOL NOPERCENT;
    TITLE  "Master Query Log Summary";
    TITLE2 "CDISCPILOT01 CDM Portfolio | All Checks";
RUN;

PROC PRINT DATA=output.master_query_log NOOBS;
    TITLE "Master Query Log Report";
    TITLE2 "All Validation Findings";
RUN;
TITLE;
  
  
           