/* =============================================================================
   PROJECT  : CDISCPILOT01 - CDM Portfolio Project
   AUTHOR   : Rutuj Argade
   DATE     : June 2026
   PURPOSE  : Adverse Event safety summary for Data Review Meeting
              Analyzes AE severity, seriousness and frequency by treatment arm
   INPUT    : mydata.ae, mydata.dm
   OUTPUT   : output.ae_safety_summary
   ============================================================================= */
  
/* ---------------------------------------------------
   Overall AE counts and unique subjects affected
----------------------------------------------------- */
PROC SQL;
    CREATE TABLE work.ae_analysis AS
    SELECT
       a.USUBJID AS Subject_ID,
       d.SITEID  AS Site_ID,
       d.ARM     AS Treatment_Arm,
       a.AEDECOD AS Code_Term,
       a.AESEV   AS Severity,
       a.AESER   AS Serious
    FROM mydata.ae AS a INNER JOIN mydata.dm AS d 
       ON a.USUBJID=d.USUBJID;
QUIT;
 
PROC SQL;
    SELECT count(*) AS Total_AE_Records,
           count(DISTINCT Subject_ID) AS Subjects_with_AE
    FROM work.ae_analysis;
QUIT;
  
/* -----------------------------------------------
    Serious AE by treatment arm
    AESER = Y triggers FDA 15-day reporting
-------------------------------------------------- */
PROC FREQ DATA=work.ae_analysis;
    TABLES Serious * Treatment_Arm / NOROW NOCOL NOPERCENT;
    TITLE "Serious Adverse Event Report by Treatment Arm";
    TITLE2 "AESER Y = FDA 15-day reporting obligation";
RUN;
  
/* -----------------------------------------------
    Severity by treatment arm
    MILD / MODERATE / SEVERE distribution
------------------------------------------------- */
PROC FREQ DATA=work.ae_analysis;
    TABLES Severity * Treatment_Arm / NOROW NOCOL NOPERCENT;
    TITLE "Adverse Event Severity Report by Treatment Arm";
    TITLE2 "Severity Distribution ";
RUN;

/* -----------------------------------------------
    Top 10 most frequent AEs
    Using AEDECOD — MedDRA standardized terms
------------------------------------------------- */
PROC SQL OUTOBS=10;
    CREATE TABLE output.ae_safety_summary AS
    SELECT Code_Term AS medDRA_Term,
       count(*) AS Frequency,
       sum(CASE WHEN Serious = 'Y' THEN 1 ELSE 0 END) AS Serious_Count,
       sum(CASE WHEN Severity = 'SEVERE' THEN 1 ELSE 0 END) AS Severity_Count
    FROM work.ae_analysis
    WHERE Code_Term IS NOT MISSING
    GROUP BY Code_Term
    ORDER BY Frequency DESC;
Quit;

PROC PRINT DATA=output.ae_safety_summary NOOBS;
    TITLE "Top 10 most frequent Adverse Events";
    TITLE2 "MedDRA coded terms | CDISCPILOT01 Alzheimer Trial";
RUN;
TITLE;
       





  
  
  
  
  