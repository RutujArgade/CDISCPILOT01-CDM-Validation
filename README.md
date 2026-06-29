# CDISCPILOT01 — Clinical Data Management Portfolio Project

## Overview
End-to-end Clinical Data Management validation project using the publicly available CDISC Pilot Study dataset 
(CDISCPILOT01) — a real Alzheimer's disease efficacy trial submitted to the FDA. Built entirely in SAS Studio on 
SAS OnDemand for Academics.

---

## Study Background
- **Study:** CDISCPILOT01 — Xanomeline vs Placebo Alzheimer's Disease Trial
- **Standard:** CDISC SDTM v1.2
- **Subjects:** 254 enrolled across 3 treatment arms
- **Arms:** Xanomeline High Dose | Low Dose | Placebo
- **Domains used:** AE, DM, VS, LB, CM, EX, DS, MH, SV, SC

---

## Project Structure
```text
programs/
├── Import.sas : Raw XPT Data Import                   
├── Check1_Missing_Data.sas : Missing Values
├── Check2_Chronology_Errors.sas : Date Validation
├── Check3_Range_Checks.sas : Physiological and Unit Range Checks
├── Check4_Master_Query_Log.sas : Query Log
└── AE_Safety_Summary.sas : Safety Data Review (SDR) Summary
```
---

## Tools and Standards
- **Language:** SAS (PROC SQL, PROC FREQ, 
  PROC MEANS, PROC PRINT, SAS Macros)
- **Standards:** CDISC SDTM, ICH E6(R3) GCP, 21 CFR Part 11
- **Platform:** SAS Studio — SAS OnDemand for Academics
- **Dataset:** CDISC Pilot SDTM — available at github.com/phuse-org/phuse-scripts

---

## Data Import
Imported 10 SDTM domains from raw XPT transport files into a permanent SAS library using a reusable 
import macro with PROC COPY.

**Domains imported:** AE, CM, DM, DS, EX, LB, MH, SC, SV, VS

---

## Data Validation and Query Management

### Check 1 — Missing Data Validation
Executed PROC SQL inner joins against the Demographics (DM) domain to identify missing mandatory
SDTM fields across multiple datasets.

**Findings:**
- AE domain — 0 records flagged — passed ✅
- DM domain — 52 subjects with missing RFSTDTC
- VS domain — 8 records with missing VSORRES
- **Total: 60 open queries raised**

**Clinical Impact:**
RFSTDTC is the anchor for all study day calculations. Missing values here break
timing analyses and derived variables across all other domains.

---

### Check 2 — Chronology Error Detection
Identified AE records where adverse events occouring before enrollment date, indicating 
potential data entry errors or pre-existing conditions miscoded as study AEs.

**Validation Rule:** AESTDTC must be >= RFSTDTC

**Findings:**
- **65 AE records flagged** across multiple sites
- All flagged as OPEN queries for site investigation

---

### Check 3 — Out of Range Value Detection
Applied protocol-defined reference ranges for VS domain and SDTM standard ranges (LBSTNRLO/LBSTNRHI) 
for LB domain. 

**Key discovery:** TEMP and WEIGHT fields contained mixed units (Celsius/Fahrenheit, kg/lbs) across 
sites — flagged as systematic unit-value mismatches consistent with EDC configuration errors at site level.

**Findings:**
- VS range violations — 989 records
- Unit-value mismatches — 4,762 records
- LB range violations — 4,561 records
- **Total: 10,312 open queries raised**

---

### Check 4 — Master Query Log
Consolidated all validation findings into a single master query log with standardized columns for 
CDM tracking and site follow-up.

| Check | Type | Domain | Queries |
|---|---|---|---|
| Check 1 | Missing Data | DM, VS | 60 |
| Check 2 | Chronology Error | AE | 65 |
| Check 3 | Range or Unit | VS, LB | 10,312 |
| **Total** | | | **10,437** |

---

## Adverse Event Safety Summary
Clinical safety analysis of the AE domain structured for Data Review Meeting meeting.

**Overall:**
- Total AE records: 1,191
- Subjects with at least one AE: 225 of 254 (89%)

**Serious AEs:**
- Placebo: 0 | High Dose: 2 | Low Dose: 1
- Total SAEs: 3 — all in Xanomeline arms

**Severity Distribution:**
- MILD: 770 (65%) | MODERATE: 378 (32%) | 
  SEVERE: 43 (3%)

**Top 3 Most Frequent AEs:**
1. PRURITUS — 84 occurrences
2. APPLICATION SITE PRURITUS — 78 occurrences
3. ERYTHEMA — 59 occurrences

**Pharmacological Insight:**
 Skin and application site reactions dominated the safety profile— consistent with Xanomeline's 
 transdermal patch delivery system. SINUS BRADYCARDIA (24 occurrences) aligns with Xanomeline's
 known muscarinic agonist mechanism causing heart rate reduction validating the protocol-adjusted
 pulse lower threshold of 50 bpm used in Check 3.

---

## Key CDM Skills Demonstrated
- SDTM domain structure and variable classification
- Missing value detection across multiple domains
- Chronology validation using date comparison logic
- Range checks with unit-aware clinical thresholds
- Systematic unit-value mismatch detection
- Master query log generation and management
- AE safety summarization for Data Review Meeting
- SAS macro programming for reusable validation
- PROC SQL, PROC FREQ, PROC MEANS, PROC PRINT

---

## Author
**Rutuj Argade**
B. Pharm | Head Pharmacist transitioning to CDM  

Certifications: Vanderbilt CDM | SAS Programming 1 | 
ICH-GCP E6(R3) | CDISC TIG v1.0 | NIDA CTN | SQL | Excel

LinkedIn Profile: linkedin.com/in/rutuj-argade-cdm
