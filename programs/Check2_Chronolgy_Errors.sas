/* =========================================================
   PROJECT = CDISCPILOT01 - CDM Portfolio Project
   AUTHOR  = Rutuj Argade
   DATE    = June 2026
   EDIT CHECKS :
   CHECK 2 = Chronology Errors Detection
   PURPOSE = Flagging AE records when Adverse Event
             started before patient enrolled
   INPUT   = mydata.ae, mydata.dm
   OUTPUT  = output.chron_ae_queries
============================================================ */
  
/* -------------------------------------------------
   CHECK 2A : AE Chronology validation
------------------------------------------------- */
PROC SQL;
    CREATE TABLE output.chron_ae_queries AS
    SELECT
       a.USUBJID AS Subject_ID,
       a.AESTDTC AS AE_Start_Date,
       a.AETERM  AS Adverse_Event,
       d.RFSTDTC AS Trial_Start_Date,
       d.SITEID  AS Site_ID,
       d.ARM     AS Treatment_Arm,
       'AE'      AS Domain,
       'AE started before enrollment' as Issue,
       'OPEN'    AS Query_Status
    FROM mydata.ae AS a INNER JOIN 
       mydata.dm AS d 
       ON a.USUBJID= d.USUBJID
    WHERE a.AESTDTC < d.RFSTDTC AND
       a.AESTDTC is not missing AND
       d.RFSTDTC is not missing;
QUIT;
  
/*---------------------------------------------------
    Printing Chronology Error Report
----------------------------------------------------*/
PROC PRINT DATA=output.chron_ae_queries NOOBS;
    TITLE "Edit Check-2 : Chronology Error Report";
    TITLE2 "AE_Start_Date before Trial Enrollment | Status: OPEN";
RUN;
  