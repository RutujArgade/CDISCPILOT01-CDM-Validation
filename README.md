# CDISCPILOT01 — End-to-End Clinical Data Management Lifecycle

A two-phase Clinical Data Management portfolio project built on the CDISC Pilot Study (CDISCPILOT01) — a real Alzheimer's disease efficacy trial submitted to the FDA.

📄 **[Project_Evidence_Summary.pdf](./Phase_1_Startup_OpenClinica/Project_Evidence_Summary.pdf)** — full evidence walkthrough containing every eCRF, XML edit check, UAT execution screenshot, and query lifecycle.

Phase 1 covers the front-end Study Start-Up & EDC Build in OpenClinica, executed using simulated mock subjects. Phase 2 covers the back-end Data Standardization & Validation in SAS Studio, using the trial's full 254-subject dataset.

## Why This Project Has Two Phases
Phase 1 covers the EDC build and governance side — configuring, validating, and formally launching the data collection system itself, before a single statistical query is raised. Phase 2 covers the retrospective side — cleaning and validating the data after it's been collected. The two phases use different query mechanisms on purpose: Phase 1's fire in real time as data is entered; Phase 2's run in batch across the full locked dataset.

## Why OpenClinica
Most entry-level CDM postings ask for hands-on experience with a commercial EDC platform like Rave, Veeva Vault, or Oracle Clinical. Those are licensed exclusively to sponsors and CROs, leaving a gap for independent hands-on experience. OpenClinica Community Edition is an open-source, GCP-aligned EDC. While it lacks a commercial vendor's name, the underlying competency is identical: eCRF design, edit check logic, UAT methodology, and discrepancy management.

## Study Background
* **Study:** CDISCPILOT01 — Xanomeline vs Placebo Alzheimer's Disease Trial
* **Standard:** CDISC SDTM v1.2
* **Phase 1 (Start-Up):** 3 CRFs (DM, AE, VS) built and tested via mock subjects
* **Phase 2 (Conduct):** 254 real subjects across 3 arms (Xanomeline High Dose, Low Dose, Placebo)
* **Domains used:** AE, DM, VS, LB, CM, EX, DS, MH, SV, SC

## Repository Structure

```text
CDISCPILOT01-CDM-Lifecycle/
├── Phase_1_Startup_OpenClinica/
│   ├── Project_Evidence_Summary.pdf
│   ├── CRF_Specifications/
│   │   ├── DM_CRF_v1.3.xls
│   │   ├── AE_CRF_v1.1.xls
│   │   ├── VS_CRF_v1.0.xls
│   │   └── Annotated_CRF_AE.pdf
│   ├── Edit_Checks_XML/
│   │   ├── EC01_AE_Chronology_Check.xml
│   │   └── EC02_EC03_Temp_Age_Checks.xml
│   └── UAT_and_Discrepancy_Management/
│       └── UAT_Defect_Log_CDISCPILOT01.xlsx
└── Phase_2_Conduct_SAS/
    ├── Import.sas
    ├── Check1_Missing_Data.sas
    ├── Check2_Chronology_Errors.sas
    ├── Check3_Range_Checks.sas
    ├── Check4_Master_Query_Log.sas
    └── AE_Safety_Summary.sas
```
Phase 1: Study Start-Up & EDC Build (OpenClinica)

Built in OpenClinica Community Edition 3.12.2.

Database Build
| CRF | Version | Domain | Mapped SDTM Fields |
|---|---|---|---|
| Demographics_DM | v1.3 | DM | Date of Birth, Sex, Race, Ethnicity, Enrollment Date (ENRDAT) |
| Adverse_Events_AE | v1.1 | AE | AE Term, Start/End Date, Seriousness, Severity, Relation to Drug, Outcome |
| Vital_Signs_VS | v1.0 | VS | Temperature (+ unit), Weight (+ unit), Pulse |

Edit Checks (XML)

Three validation rules configured in OpenClinica Rule XML:

| ID | Logic | Scope |
|---|---|---|
| EC-01 | `I_ADVER_AESTDAT < I_DEMOG_ENRDAT` — AE date cannot precede enrollment date | Baseline through End of Study — every visit where an AE can be logged |
| EC-02 | `I_VITAL_VSTEMP` outside plausible range for selected unit (34–42°C / 93.2–107.6°F) | All 6 visits, Screening through End of Study |
| EC-03 | Subject Date of Birth falls below protocol age eligibility cutoff | Screening only |

EC-02 was specifically programmed to catch systemic data entry errors at the point of entry. The retrospective SAS validation in Phase 2 identified 4,762 historical records with mismatched temperature units — this rule exists to stop that exact failure mode before it happens.

User Acceptance Testing (UAT)
| Test Case | Rule | Condition Tested | Result |
|---|---|---|---|
| TC-01 | EC-01 | AE date before enrollment | Pass — error fired, save blocked |
| TC-02 | EC-01 | AE date after enrollment | Pass — saved cleanly |
| TC-03 | EC-01 | AE date equal to enrollment (boundary) | Pass — saved cleanly (confirms strict < logic) |
| TC-04 | EC-02 | Celsius, in range (37.0°C) | Pass — saved cleanly |
| TC-05 | EC-02 | Celsius, out of range (43.0°C) | Pass — error fired, save blocked |
| TC-06 | EC-02 | Fahrenheit, in range (98.6°F) | Pass — saved cleanly |
| TC-07 | EC-02 | Fahrenheit, out of range (108.0°F) | Pass — error fired, save blocked |
| TC-08 | EC-03 | Below age eligibility (DOB 1992) | Pass — error fired, save blocked |
| TC-09 | EC-03 | Meets age eligibility (DOB 1963) | Pass — saved cleanly |

Result: 9/9 test cases passed. Full visual execution log is in Project_Evidence_Summary.pdf.
Query Lifecycle (Production)

Two manual Discrepancy Notes were processed through a full 21 CFR Part 11 compliant audit trail (Raised → Resolution Proposed → Closed):

Q-01 (Data Consistency): A pulse rate entered as 7 bpm — a physiological data entry typo, corrected to 73 bpm after source verification.
Q-02 (Cross-field Logic): An adverse event marked Serious but coded with Mild severity — a clinical-logic inconsistency, corrected to Severe after review.

With both queries closed, the study was Frozen — blocking new data entry while still allowing discrepancy notes to be worked — then Locked, a hard stop with no further data entry, edits, or query activity.

Phase 2: Data Standardization & Validation (SAS Studio)

Built entirely in SAS Studio on SAS OnDemand for Academics.

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
- LB range violations — 4,555 records
- **Total: 10,306 open queries raised**

---

### Check 4 — Master Query Log
Consolidated all validation findings into a single master query log with standardized columns for 
CDM tracking and site follow-up.

| Check | Type | Domain | Queries |
|---|---|---|---|
| Check 1 | Missing Data | DM, VS | 60 |
| Check 2 | Chronology Error | AE | 65 |
| Check 3 | Range or Unit | VS, LB | 10,306 |
| **Total** | | | **10,431** |

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

Key CDM Skills Demonstrated
EDC database build, eCRF design, and XML edit check programming (OpenClinica)

UAT execution and boundary testing under ICH-GCP E6(R3)

SDTM domain structure and variable classification

Missing value, chronology, and unit-aware range validation

Master query log generation and management

AE safety summarization for a Data Review Meeting

SAS macro programming for reusable validation (PROC SQL, PROC FREQ, PROC MEANS, PROC PRINT)

Author
Rutuj Argade — B. Pharm | Head Pharmacist transitioning to CDM

Certifications: Vanderbilt CDM | SAS Programming 1 | ICH-GCP E6(R3) | CDISC TIG v1.0 | NIDA CTN | SQL | Excel

LinkedIn: linkedin.com/in/rutuj-argade-cdm
