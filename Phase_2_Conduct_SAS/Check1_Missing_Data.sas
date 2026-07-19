/* =========================================================
   PROJECT = CDISCPILOT01 - CDM Portfolio Project
   AUTHOR  = Rutuj Argade
   DATE    = June 2026
   EDIT CHECKS :
   CHECK 1 = Missing Data Checker
   PURPOSE = Flagging missing values in expected field 
             across AE, DM and VS domains
   INPUT   = mydata.ae, mydata.dm, mydata.vs
   OUTPUT  = output.master_missing_queries
============================================================ */
  
/* -------------------------------------------------
   CHECK 1A : ADVERSE EVENTS
------------------------------------------------- */
  
LIBNAME output "/home/u64530706/CDISC_Pilot_Project/OUTPUT";
  
PROC SQL;
    CREATE TABLE output.ae_miss AS
    SELECT 
       d.USUBJID AS Subject_ID,
       d.ARM     AS Treatment_Arm, 
       d.SITEID  AS Site_ID, 
       a.AETERM  AS Adverse_Event,
       a.AESTDTC AS AE_Start_Date , 
       a.AESER   AS Serious_Flag, 
       a.AESEV   AS Severity,
       'AE'      AS Domain,
       'Missing Essential AE Data' AS Issue,
       'OPEN'    AS Query_Status
   FROM mydata.ae AS a INNER JOIN mydata.dm AS d 
        ON a.USUBJID=d.USUBJID
   WHERE a.AESTDTC IS MISSING OR
         a.AESER IS MISSING OR
         a.AESEV IS MISSING OR
         a.AETERM IS MISSING ;
QUIT;
  
/* -------------------------------------------------
   CHECK 1B : DEMOGRAPHICS
-------------------------------------------------- */
PROC SQL;
    CREATE TABLE output.dm_miss AS 
    SELECT 
       d.USUBJID AS Subject_ID,
       d.ARM     AS Treatment_Arm, 
       d.SITEID  AS Site_ID,
       d.AGE     AS Age,
       d.RFSTDTC AS Trial_Start_Date,
       d.SEX     AS Sex,
       d.RACE    AS Race,
       'DM'      AS Domain,
       'Missing Essential DM Data' AS Issue,
       'OPEN'    AS Query_Status
   FROM mydata.dm AS d
   WHERE d.RFSTDTC IS MISSING OR
         d.AGE IS MISSING OR
         d.Sex IS MISSING OR
         d.Race IS MISSING ;
QUIT;
  
/* -------------------------------------------------
   CHECK 1C : VITAL SIGNS
------------------------------------------------- */
PROC SQL;
    CREATE TABLE output.vs_miss AS
    SELECT
       d.USUBJID  AS Subject_ID,
       d.ARM      AS Treatment_Arm, 
       d.SITEID   AS Site_ID,
       v.VSDTC    AS Visit_Date,
       v.VSORRES  AS Result,
       v.VSTESTCD AS Vital_Test,
       'VS'       AS Domain,
       'Missing Essential VS Data' AS Issue,
       'OPEN'     AS Query_Status
   FROM mydata.vs AS v INNER JOIN mydata.dm AS d 
   ON v.USUBJID= d.USUBJID
   WHERE v.VSDTC IS MISSING OR
         v.VSORRES IS MISSING OR
         v.VSTESTCD IS MISSING ;
QUIT;

  
/*-------------------------------------------------------------  
  Combining these to form master report
-------------------------------------------------------------*/
PROC SQL;
    CREATE TABLE output.master_missing_queries AS 
    SELECT Subject_ID, Site_ID, Treatment_Arm, Domain, Issue, Query_Status
    FROM output.ae_miss
UNION ALL
    SELECT Subject_ID, Site_ID, Treatment_Arm, Domain, Issue, Query_Status
    FROM output.dm_miss
UNION ALL
    SELECT Subject_ID, Site_ID, Treatment_Arm, Domain, Issue, Query_Status
    FROM output.vs_miss;
QUIT;


/*---------------------------------------------------------
Printing Missing Data Query Report
----------------------------------------------------------*/
PROC PRINT DATA=output.master_missing_queries NOOBS;
    TITLE "Edit Check-1 : Missing Data Query Report";
    TITLE2 "Domains : AE, DM, VS | Query Status: OPEN";
RUN;
TITLE;
