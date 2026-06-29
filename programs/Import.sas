/* =================================================================
   PROJECT = CDISCPILOT01 - CDM Portfolio Project
   AUTHOR  = Rutuj Argade
   DATE    = June 2026
   PURPOSE = Import all SDTM domains using PROC COPY
   INPUT   = 10 XPT files from the CDISC_Pilot_Project folder 
   OUTPUT  = mydata.ae, mydata.cm, mydata.dm, mydata.ds, mydata.ex,
             mydata.lb, mydata.mh, mydata.sc, mydata.sv, mydata.vs
 ===================================================================== */ 

/*-------------------------------------------------------------------
     Created a permanent library 
--------------------------------------------------------------------*/
LIBNAME mydata "/home/u64530706/CDISC_Pilot_Project";

/*-------------------------------------------------------------------
     Used Macro to import the raw xpt files 
--------------------------------------------------------------------*/
%MACRO import(domain);
	LIBNAME xptlib XPORT "/home/u64530706/CDISC_Pilot_Project/&domain..xpt";
	
/*---Copied dataset into permanent library---*/ 

	PROC COPY in=xptlib OUT=mydata;
		SELECT &domain;
	RUN;
	
	LIBNAME xptlib CLEAR;

	%PUT Note: &domain copied successfully to mydata;
	
%MEND import;

/*----------------------------------------
     Importing the Domains
 -----------------------------------------*/
%import(ae) 
%import(cm) 
%import(dm) 
%import(ds) 
%import(ex) 
%import(lb) 
%import(mh) 
%import(sc) 
%import(sv) 
%import(vs)




