# NHPID Technical Reference
> Extracted from ChatGPT conversation history | Split from combined BTS/NHPID reference
> Use this as context primer for any new coding session on the NHPID system.

---

## 1. SYSTEM OVERVIEW

### NHPID — Natural Health Products Ingredient Database
| Property | Value |
|---|---|
| **DB Engine** | Oracle |
| **Primary Schemas** | `NHPID_VAL_OWNER`, `NHPDWEB_OWNER` |
| **Loader Schema** | `NHPID_X$LOADER` (staging/ETL prefix) |
| **Web Service Layer** | Java/Spring + MyBatis |
| **Mapper File** | `QueryMapper.xml` — namespace `ca.gc.hc.nhpd.webservice.mapper.QueryMapper` |
| **Your Role** | Lead backend — read/write access to existing tables, debug support |
| **Tooling** | Oracle SQL Developer |

---

## 2. NHPID SCHEMA — KEY OBJECTS

### Schema hierarchy
```
NHPDWEB_OWNER          — production web-facing views and tables
NHPID_VAL_OWNER        — validation layer tables
NHPID_X$LOADER         — ETL/staging loader prefix (X$ tables)
```

### Key X$ tables (staging/loader layer)
| Object | Description |
|---|---|
| `NHPID_X$LOADER` | Main loader interface |
| `X$ASSESSMENT_DOSE` | Dose assessment staging |
| `X$GROUP_RULES` | Group rules staging |
| `X$MONOGRAPH_XREF` | Monograph cross-reference |
| `X$MONOGRAPH_*` | All monograph-related staging tables |
| `X_X$LOAD_LOG` | ETL load log — check here for loader errors/status |
| `x$roa_dosage_form` | ROA ↔ dosage form mapping |

### Key views (NHPDWEB_OWNER layer)
| View | Description |
|---|---|
| `v_monographs` | All monographs; key cols: `mono_code`, `mono_name_eng`, `mono_name_fr`, `pci`, `validation_ready_date` |
| `v_monograph_roa` | Monograph ↔ route of administration |
| `V_ASSESSMENT_DOSE_SUB_POP` | Dose sub-population data |
| `V_ASSESSMENT_DOSES` | Assessment doses; key: `ASSESSMENT_DOSE_ID`, `mono_code`, `INGREDIENT_ID` |
| `V_SUB_POPULATION_GROUPS` | Sub-population groups (age, sex) |
| `V_SUB_POPULATION_SEXES` | Sex groups |
| `V_SUB_POPULATION_CONDITIONS` | Female conditions |
| `V_UNITS_OF_MEASURE` | Units; key cols: `UNIT_CODE`, `UNIT_TYPE_CODE`, `PREFERRED`, `RATIO_TO_BASE`, `UNIT_NAME_ENG`, `UNIT_NAME_FR` |
| `V_DOSAGE_FORMS` | Dosage forms; `DOSAGE_FORM_CODE`, `DOSEFRM_ID`, `ALLOW_INGREDIENT_UNITS`, `NMI_REQUIRED`, `discrete`, `VALID_FOR_COMPENDIAL` |
| `V_DOSAGE_FORM_UNITS` | Dosage form ↔ units |
| `V_ROA_DOSAGE_FORMS` | ROA + dosage form combinations |
| `V_MONO_ROA_DOSAGE_FORM` | Monograph-specific ROA + dosage forms; `has_null` flag |
| `V_MONO_FORM_TYPES` | Monograph form types |
| `V_STANDARD_GRADE_REFERENCES` | Standard grade refs; `STAND_GRADE_REF_IS_HOMEOPATHIC` flag |
| `V_UOM_BY_INGRED_CLASS_TYPE` | Units filtered by ingredient class |
| `V_ROA_DOSAGE_FORMS` | Min-age by ROA + dosage form; `DFU_GROUP_CODE`, `DFU_MIN_AGE` |
| `COMMON_TERMS` | Common terms lookup; `commontermtype_id`, `commonterm_code` |
| `COUNTRIES` / `PROVINCES_STATES` | Geography lookups |
| `DOSAGE_UNITS` | `add_doseunit_info`, `dosageunit_code` |
| `ADMINISTRATION_ROUTES` | `adminrt_code`, `adminrt_id`, `adminrt_sterilerequired` |
| `APPLICATION_PROPERTIES_VAL` | App config; `KEY`, `data`, `flag` |

---

## 3. NHPID — QUERYMAPPER.XML REFERENCE

**File:** `QueryMapper.xml`
**Namespace:** `ca.gc.hc.nhpd.webservice.mapper.QueryMapper`
**Framework:** MyBatis 3.0

### Named SQL snippets (epla population service)

| SQL ID | Source | Key Parameters |
|---|---|---|
| `ApplicationPropertyByKey` | `APPLICATION_PROPERTIES_VAL` | `#{propertyKey}` |
| `ValidatedMonographs` | `v_monographs` | `#{lang}` — validated only (`validation_ready_date IS NOT NULL`) |
| `AllMonographs` | `v_monographs` | `#{lang}` — PCI only |
| `CommonAndTerms` | `COMMON_TERMS` | `#{lang}`, `#{CommonTermType}` |
| `AgeGroups` | `V_SUB_POPULATION_GROUPS` | `#{lang}` |
| `FrenquencyUnits` | `V_UNITS_OF_MEASURE` | `#{lang}` — `UNIT_TYPE_CODE='TIME'`, `PREFERRED='y'` |
| `FemaleConditions` | `V_SUB_POPULATION_CONDITIONS` | `#{lang}` |
| `SexGroups` | `V_SUB_POPULATION_SEXES` | `#{lang}` |
| `SubPopulationsByMonoIngIds` | `V_ASSESSMENT_DOSE_SUB_POP` | `#{monoCode}`, `#{ingredientId}`, `#{lang}` |
| `MinimalAgeByMonoIngId` | `V_ASSESSMENT_DOSE_SUB_POP` + doses | `#{monoCode}`, `#{ingredientId}`, `#{lang}` — `rownum=1` |
| `MinAgeByROAAndDFU` | `V_ROA_DOSAGE_FORMS` | `#{roaCode}`, `#{dosageFormCode}`, `#{lang}` |
| `UnitsByUnitTypeCodes` | `V_UNITS_OF_MEASURE` | `#{lang}`, `#{unitTypeCodes}` (list, `<foreach>`) |
| `UnitsByIngClassCode` | `v_uom_by_ingred_class_type` | `#{lang}`, `#{ingTypeCode}`, `#{ingClassCode}` — `ADDITIONAL_UNIT='n'` |
| `UnitByCode` | `V_UNITS_OF_MEASURE` | `#{code}` → returns `UNIT_TYPE_CODE`, `RATIO_TO_BASE` |
| `CountriesWithProvinces` | `COUNTRIES` + `PROVINCES_STATES` | `#{lang}` |
| `StandardDosageUnits` | `V_DOSAGE_FORM_UNITS` | `#{dosageFormCode}`, `#{lang}` |
| `StandardGradeRefs` | `v_standard_grade_references` | `#{lang}` — `STAND_GRADE_REF_IS_HOMEOPATHIC='n'` |
| `DosageDiscrete` | `V_DOSAGE_FORMS` | `#{DosageFormCode}` |
| `DosageUnitAdditionalInfo` | `DOSAGE_UNITS` | `#{dosageUnitCode}` |
| `DosageFormByCode` | `V_DOSAGE_FORMS` + `V_DOSAGE_FORM_UNITS` | `#{dosageFormCode}`, `#{lang}` |
| `DosageFormsByMonoROACode` | `V_MONO_ROA_DOSAGE_FORM` | `#{monoCode}`, `#{roaCode}`, `#{lang}` |
| `HasNullDosageFormByMonoROACode` | `V_MONO_ROA_DOSAGE_FORM` | `#{monoCode}`, `#{roaCode}` |
| `CompendialDosageFormsByROACode` | `x$roa_dosage_form` + `V_DOSAGE_FORMS` | `#{roaCode}`, `#{lang}` — `VALID_FOR_COMPENDIAL='n'` |
| `DosageFormsByROACode` | `x$roa_dosage_form` + `ADMINISTRATION_ROUTES` | `#{roaCode}`, `#{lang}` |
| `AllROAs` | `x$roa_dosage_form` + `ADMINISTRATION_ROUTES` | `#{lang}` |
| `SterileByROACode` | `ADMINISTRATION_ROUTES` | `#{roaCode}` |
| `PCIs` | `v_monographs` | `#{lang}` — validated PCIs only |
| `AllPCIs` | `v_monographs` | `#{lang}` — all PCIs |
| `PCIsByROACodeAndUseType` | `v_monograph_roa` + `v_mono_form_types` | `#{lang}`, `#{roaCode}` |

**Oracle patterns used throughout:**
- `DECODE(NVL(#{lang}, 'en'), 'en', col_eng, 'fr', col_fr)` — bilingual column pattern
- `WHERE rownum = 1` — first row only (use subquery for correct ordering)
- `TO_CHAR(date_col, 'YYYY-MM-DD')` — date formatting
- `<foreach>` — MyBatis collection iteration

---

## 4. CONVERSATION INVENTORY (source files)

| # | Date | Title | System | Size |
|---|---|---|---|---|
| 1 | 2023-04-14 | SAS EG 7.1 Q&A | NHPID | 443K |
| 2 | 2023-11-07 | SQL Query Revision MVM vs ELSE | NHPID | 54K |
| 3 | 2023-11-29 | OpenAI GPT-3 Model Comparison | NHPID + QueryMapper | 60K |
| 4 | 2024-01-28 | Oracle SQL Character Match | NHPID | 630K |
| 5 | 2024-07-07 | Inserting Date into Database | NHPID | 1.5K |
| 6 | 2024-07-30 | Include Missing Ingred_IDs | NHPID | 5K |
| 7 | 2025-01-14 | APEX procedure abort troubleshooting | NHPID | 269K |
| 8 | 2025-05-14 | Duplicate Ingredients Query | NHPID | 85K |
| 9 | 2025-05-20 | SQL Column Cleanup | NHPID | 20K |
| 10 | 2025-05-22 | SQL Add Columns | NHPID | 5K |
| 11 | 2025-05-30 | Generate Insert Statements | NHPID | 16K |
| 12 | 2025-06-05 | Delete NonNHPRole SQL | NHPID | 3.9K |
| 13 | 2025-06-17 | Exclude Underscore in SQL | NHPID | 5.2K |
| 14 | 2025-06-20 | ORA-28231 Debugging Guide | NHPID | 47K |
| 15 | 2025-06-27 | Synchronizer Abort Fix | NHPID | 5.8K |
| 16 | 2025-06-27 | Nom chimique français silicate | NHPID | 11K |
| 17 | 2025-06-29 | SQL Query for Ingredients | NHPID | 6.9K |
| 18 | 2025-07-31 | Fix SQL query | NHPID | 6.3K |
| 19 | 2025-08-08 | Insert unique bioc data | BTS/NHPID | 45K |
| 20 | 2025-08-14 | SQL table creation script | NHPID | 4.1K |
| 24 | 2025-11-04 | Conditionally trim prefix | NHPID | 10K |
| 27 | 2025-11-20 | SQL text replacements | NHPID | 102K |
| 31 | 2025-12-02 | population web service | NHPID (QueryMapper) | 718K |
| 33 | 2025-12-03 | Referencing NHPID | NHPID | 484K |

> Conversation #19 is cross-system — also tracked in the BTS repo where relevant.

---

## 5. HANDLING `conversations-006.json` (59MB — TOO LARGE TO UPLOAD)

The 31MB chat limit blocked this file. Options to process it:

**Option A — Split it locally (recommended):**
```python
import json

with open('conversations-006.json') as f:
    data = json.load(f)

mid = len(data) // 2
with open('conversations-006a.json', 'w') as f:
    json.dump(data[:mid], f)
with open('conversations-006b.json', 'w') as f:
    json.dump(data[mid:], f)

print(f"Total: {len(data)} convos → {mid} + {len(data)-mid}")
```
Then upload `conversations-006a.json` and `conversations-006b.json` in a new session.

**Option B — Pre-filter to only technical conversations:**
```python
import json

KEYWORDS = [
    'NHPID_VAL_OWNER', 'NHPDWEB_OWNER',
    'QueryMapper', 'X$MONOGRAPH',
    'NHPID_X$LOADER', 'v_monographs'
]

with open('conversations-006.json') as f:
    data = json.load(f)

def full_text(convo):
    texts = []
    for node in convo.get('mapping', {}).values():
        msg = node.get('message')
        if not msg: continue
        parts = msg.get('content', {}).get('parts', []) if isinstance(msg.get('content'), dict) else []
        texts.extend(p for p in parts if isinstance(p, str))
    return ' '.join(texts)

hits = [c for c in data if any(k.lower() in full_text(c).lower() for k in KEYWORDS)]
with open('conversations-006-nhpid.json', 'w') as f:
    json.dump(hits, f)

print(f"Filtered: {len(hits)}/{len(data)} conversations")
```
Upload the filtered file — it'll be much smaller.

---

## 6. NEXT STEPS — VECTOR DB INTEGRATION

Once Mac mini M4 Pro is set up:
1. Copy all NHPID `.md` files from extraction to Mac mini knowledge base directory
2. Chunk by conversation section (≈500 token chunks with overlap)
3. Embed with OpenAI `text-embedding-3-small` or Anthropic embeddings
4. Store in local vector DB (ChromaDB or pgvector recommended)
5. Tag each chunk with metadata: `system` = NHPID, `date`, `topic`, `keywords_hit`
6. Process `conversations-006.json` and merge into the same DB

---

## 7. NHPID — LOADER PACKAGE: NHPID_X$LOADER.REFRESH_ALL (Feb 2026)

### Error Encountered
```
ORA-06550: PLS-00201: identifier 'NHPID_VAL_OWNER.NHPID_X$LOADER' must be declared
```

### Root Cause
Not a compilation error — Oracle can't resolve the package in the current session. Causes:
1. Wrong DB/PDB/schema instance (DEV vs TEST vs PROD)
2. Package doesn't exist in that environment
3. Package exists but user lacks `GRANT EXECUTE` and no synonym

### Diagnostic Queries
```sql
-- Check package exists
SELECT owner, object_name, object_type, status
FROM all_objects
WHERE object_name = 'NHPID_X$LOADER'
  AND object_type IN ('PACKAGE','PACKAGE BODY')
ORDER BY owner, object_type;

-- Confirm you're in the right environment
SELECT sys_context('USERENV','DB_NAME') AS db_name,
       sys_context('USERENV','SERVICE_NAME') AS service_name,
       sys_context('USERENV','CON_NAME') AS con_name,
       user AS current_user
FROM dual;

-- Fix: grant execute (run as NHPID_VAL_OWNER or DBA)
GRANT EXECUTE ON NHPID_VAL_OWNER.NHPID_X$LOADER TO <your_user>;

-- Optional: create synonym so you don't need full qualification
CREATE SYNONYM NHPID_X$LOADER FOR NHPID_VAL_OWNER.NHPID_X$LOADER;
```

---

## 8. UPDATED CONVERSATION INVENTORY (conversations-006)

| Date | Title | System | Size | Notes |
|---|---|---|---|---|
| 2026-02-04 | Oracle Package Error Troubleshooting | NHPID | 3.3K | NHPID_X$LOADER PLS-00201 error |

---
*Updated: 2026-02-26 | Split from combined BTS/NHPID reference | NHPID conversations only*
