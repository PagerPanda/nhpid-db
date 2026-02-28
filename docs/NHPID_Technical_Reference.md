# NHPID Technical Reference

> Context primer for coding, troubleshooting, and system reasoning on the NHPID system.
> Revised from prior extracted notes and corrected against established NHPID session context.
> **Important:** inventories below are **selective, not exhaustive**, unless explicitly stated otherwise.

---

## 1. SYSTEM OVERVIEW

### NHPID — Natural Health Products Ingredient Database

| Property                       | Value                                         |
| ------------------------------ | --------------------------------------------- |
| **DB Engine**                  | Oracle                                        |
| **Primary Schemas**            | `NHPDWEB_OWNER`, `NHPID_VAL_OWNER`            |
| **Validation Loader Package**  | `NHPID_VAL_OWNER.NHPID_X$LOADER`              |
| **Web Service Layer**          | Java / Spring + MyBatis                       |
| **Primary Mapper File**        | `QueryMapper.xml`                             |
| **Mapper Namespace**           | `ca.gc.hc.nhpd.webservice.mapper.QueryMapper` |
| **Primary SQL Client (local)** | Oracle SQL Developer                          |

### Core system model

* `NHPDWEB_OWNER` provides key web-facing views and supporting objects used by the service layer.
* `NHPID_VAL_OWNER` contains the validation-layer objects, including `X$*` validation tables and the loader package `NHPID_X$LOADER`.
* `QueryMapper.xml` is the authoritative mapper reference for PLA / population-service query behaviour.
* `NHPID_VAL_OWNER.NHPID_X$LOADER` is the authoritative reference for how validation-layer `X$*` tables are populated and refreshed.

---

## 2. SCHEMA / LAYER MODEL

```text
NHPDWEB_OWNER
  - web-service / population-service facing views and supporting objects

NHPID_VAL_OWNER
  - validation-layer schema
  - contains validation X$* tables
  - contains package NHPID_X$LOADER

NHPID_VAL_OWNER.NHPID_X$LOADER
  - PL/SQL validation-layer loader package
  - truncates / refreshes / repopulates X$* validation tables
  - loads from X_* buffers / views and related sources
  - refreshes dependent MV_* materialized views where applicable
```

### Layer distinction

| Layer / Pattern  | Purpose                                                                        |
| ---------------- | ------------------------------------------------------------------------------ |
| `X_*`            | Buffer / upstream staging inputs used by validation ETL                        |
| `X$*`            | Validation-layer loaded tables used by downstream validation and service logic |
| `MV_*`           | Materialized views refreshed as part of validation-layer maintenance           |
| `NHPID_X$LOADER` | Package bridging `X_*` inputs into `X$*` validation-layer objects              |

### Authoritative references

1. **`NHPID_VAL_OWNER.NHPID_X$LOADER` package body** — authoritative source for validation-layer table population / refresh behaviour
2. **`QueryMapper.xml`** — authoritative source for PLA / population-service query logic
3. **`NHPDWEB_OWNER` views** — primary query surface used by the web service layer

---

## 3. VALIDATION LOADER PACKAGE — `NHPID_VAL_OWNER.NHPID_X$LOADER`

### Purpose

`NHPID_VAL_OWNER.NHPID_X$LOADER` is the core validation-layer loader package for NHPID. It manages ETL / refresh logic from buffer `X_*` sources into validation `X$*` tables, handles dependency-sensitive refresh operations, logs errors, and refreshes related materialized views.

### Operational responsibilities

* Truncate and reload validation `X$*` tables
* Refresh validation-layer data from upstream buffers / views
* Manage dependency order between refresh steps
* Disable / re-enable FK constraints or related dependencies where needed
* Refresh related materialized views (`MV_*`)
* Log loader messages and errors to `X_X$LOAD_LOG`

### Shared helper routines

The package includes common helper / utility routines such as:

* `log_err`
* `log_msg`
* `truncate_table`
* `enable_fk`
* `refresh_mv`
* `refresh_table`
* `get_proc_list`

### Key loader procedures (selective inventory)

The package includes many per-table / per-domain refresh procedures, including but not limited to:

* `p_x$assessment_dose`
* `p_x$assessment_dose_xref`
* `p_x$dfu_xref`
* `p_x$dose_cat_xref`
* `p_x$dose_form_types`
* `p_x$duration_xref`
* `p_x$group_rules`
* `p_x$ingredient_group_groups`
* `p_x$ingredient_prep_code`
* `p_x$monograph_ingredients_xref`
* `p_x$monograph_ingred_name_xref`
* `p_x$monograph_roa`
* `p_x$monograph_sub_ingredient`
* `p_x$monograph_source_rules`
* `p_x$monograph_xref`
* `p_x$mono_form_types`
* `p_x$mono_source_ingredient`
* `p_x$mono_source_subingredient`
* `p_x$non_ingred_org_prep_code`
* `p_x$organism_ingredient`
* `p_x$orphan_source_org_types`
* `p_x$preparation_methods_xref`
* `p_x$risk_xref`
* `p_x$roa_dosage_form`
* `p_x$solvent_lists`
* `p_x$solvent_solutions`
* `p_x$source_id_source_org_types`
* `p_x$source_organism_types`
* `p_x$storage_conditions_xref`

### Key implications for troubleshooting

* Loader failures do **not** necessarily mean compilation problems; they may reflect environment mismatch, privilege issues, dependency failures, or upstream data problems.
* If a validation-layer object looks stale, check both:

  * whether the relevant `p_x$*` refresh ran successfully
  * whether dependent `MV_*` refreshes completed
* `X_X$LOAD_LOG` is a primary operational source for refresh/load diagnostics.

---

## 4. KEY VALIDATION-LAYER OBJECTS (`NHPID_VAL_OWNER`)

> This is a selective object inventory for orientation only.

### Key validation `X$*` tables

| Object              | Description                                       |
| ------------------- | ------------------------------------------------- |
| `X$ASSESSMENT_DOSE` | Validation-layer dose assessment data             |
| `X$GROUP_RULES`     | Validation-layer group rules                      |
| `X$MONOGRAPH_XREF`  | Monograph cross-reference data                    |
| `X$MONOGRAPH_*`     | Monograph-related validation tables               |
| `X$ROA_DOSAGE_FORM` | ROA ↔ dosage-form mapping in the validation layer |
| `X_X$LOAD_LOG`      | Loader log table for status / error tracking      |

### Notes

* These are **validation-layer** objects, not a separate "loader schema."
* The loader package populates / refreshes them; it is not their owner in the schema sense.
* `X$*` should be treated as controlled validation outputs, not ad hoc scratch objects.

---

## 5. KEY WEB-FACING VIEWS / LOOKUPS (`NHPDWEB_OWNER`)

> Selective inventory based on prior established usage. Column notes are preserved where they were already useful.

| View / Object                 | Description / Notes                                                                                                                                |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `V_MONOGRAPHS`                | All monographs; key columns noted previously include `MONO_CODE`, `MONO_NAME_ENG`, `MONO_NAME_FR`, `PCI`, `VALIDATION_READY_DATE`                  |
| `V_MONOGRAPH_ROA`             | Monograph ↔ route of administration                                                                                                                |
| `V_ASSESSMENT_DOSE_SUB_POP`   | Dose sub-population data                                                                                                                           |
| `V_ASSESSMENT_DOSES`          | Assessment doses; prior notes reference `ASSESSMENT_DOSE_ID`, `MONO_CODE`, `INGREDIENT_ID`                                                         |
| `V_SUB_POPULATION_GROUPS`     | Sub-population groups (e.g., age grouping)                                                                                                         |
| `V_SUB_POPULATION_SEXES`      | Sex groups                                                                                                                                         |
| `V_SUB_POPULATION_CONDITIONS` | Female conditions / sub-population conditions                                                                                                      |
| `V_UNITS_OF_MEASURE`          | Units lookup; prior notes reference `UNIT_CODE`, `UNIT_TYPE_CODE`, `PREFERRED`, `RATIO_TO_BASE`, `UNIT_NAME_ENG`, `UNIT_NAME_FR`                   |
| `V_DOSAGE_FORMS`              | Dosage forms; prior notes reference `DOSAGE_FORM_CODE`, `DOSEFRM_ID`, `ALLOW_INGREDIENT_UNITS`, `NMI_REQUIRED`, `DISCRETE`, `VALID_FOR_COMPENDIAL` |
| `V_DOSAGE_FORM_UNITS`         | Dosage form ↔ units                                                                                                                                |
| `V_ROA_DOSAGE_FORMS`          | ROA ↔ dosage-form combinations and related population fields, including DFU / min-age fields where applicable                                      |
| `V_MONO_ROA_DOSAGE_FORM`      | Monograph-specific ROA + dosage forms; prior note referenced `HAS_NULL`                                                                            |
| `V_MONO_FORM_TYPES`           | Monograph form types                                                                                                                               |
| `V_STANDARD_GRADE_REFERENCES` | Standard-grade references; prior note referenced `STAND_GRADE_REF_IS_HOMEOPATHIC`                                                                  |
| `V_UOM_BY_INGRED_CLASS_TYPE`  | Units filtered by ingredient class / type                                                                                                          |
| `COMMON_TERMS`                | Common terms lookup; prior notes reference `COMMONTERMTYPE_ID`, `COMMONTERM_CODE`                                                                  |
| `COUNTRIES`                   | Country lookup                                                                                                                                     |
| `PROVINCES_STATES`            | Province / state lookup                                                                                                                            |
| `DOSAGE_UNITS`                | Dosage-unit lookup; prior notes reference `ADD_DOSEUNIT_INFO`, `DOSAGEUNIT_CODE`                                                                   |
| `ADMINISTRATION_ROUTES`       | Administration-route lookup; prior notes reference `ADMINRT_CODE`, `ADMINRT_ID`, `ADMINRT_STERILEREQUIRED`                                         |
| `APPLICATION_PROPERTIES_VAL`  | Application / property configuration; prior notes reference `KEY`, `DATA`, `FLAG`                                                                  |

### Caution

* These column notes should be treated as **working reference notes**, not a substitute for direct DESCRIBE / source inspection.
* When exact column naming matters for implementation, confirm against the environment.

---

## 6. QUERYMAPPER.XML REFERENCE

**File:** `QueryMapper.xml`
**Namespace:** `ca.gc.hc.nhpd.webservice.mapper.QueryMapper`
**Framework:** MyBatis 3.x

### Role

`QueryMapper.xml` is the authoritative mapper reference for PLA / population-service behaviour. It defines named SQL statements used by the service layer to resolve monographs, dosage forms, routes, units, age groups, ingredient-related lookups, and application properties.

### Named SQL statements — established / previously captured inventory

> This is a **partial inventory**, not a complete mapper index.

| SQL ID                           | Source                                                              | Key Parameters / Notes                                                                                     |
| -------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `ApplicationPropertyByKey`       | `APPLICATION_PROPERTIES_VAL`                                        | `#{propertyKey}`                                                                                           |
| `ValidatedMonographs`            | `V_MONOGRAPHS`                                                      | `#{lang}` — validated only (`VALIDATION_READY_DATE IS NOT NULL`)                                           |
| `AllMonographs`                  | `V_MONOGRAPHS`                                                      | `#{lang}` — PCI-oriented / all available monographs per prior notes                                        |
| `CommonAndTerms`                 | `COMMON_TERMS`                                                      | `#{lang}`, `#{CommonTermType}`                                                                             |
| `AgeGroups`                      | `V_SUB_POPULATION_GROUPS`                                           | `#{lang}`                                                                                                  |
| `FrenquencyUnits`                | `V_UNITS_OF_MEASURE`                                                | `#{lang}` — prior note: `UNIT_TYPE_CODE='TIME'`, `PREFERRED='y'`                                           |
| `FemaleConditions`               | `V_SUB_POPULATION_CONDITIONS`                                       | `#{lang}`                                                                                                  |
| `SexGroups`                      | `V_SUB_POPULATION_SEXES`                                            | `#{lang}`                                                                                                  |
| `SubPopulationsByMonoIngIds`     | `V_ASSESSMENT_DOSE_SUB_POP`                                         | `#{monoCode}`, `#{ingredientId}`, `#{lang}`                                                                |
| `MinimalAgeByMonoIngId`          | `V_ASSESSMENT_DOSE_SUB_POP` + related dose logic                    | `#{monoCode}`, `#{ingredientId}`, `#{lang}` — prior note: `ROWNUM = 1` style                               |
| `MinAgeByROAAndDFU`              | `V_ROA_DOSAGE_FORMS`                                                | `#{roaCode}`, `#{dosageFormCode}`, `#{lang}`                                                               |
| `UnitsByUnitTypeCodes`           | `V_UNITS_OF_MEASURE`                                                | `#{lang}`, `#{unitTypeCodes}` via `<foreach>`                                                              |
| `UnitsByIngClassCode`            | `V_UOM_BY_INGRED_CLASS_TYPE`                                        | `#{lang}`, `#{ingTypeCode}`, `#{ingClassCode}` — prior note: `ADDITIONAL_UNIT='n'`                         |
| `UnitByCode`                     | `V_UNITS_OF_MEASURE`                                                | `#{code}` → returns unit type / ratio information                                                          |
| `CountriesWithProvinces`         | `COUNTRIES` + `PROVINCES_STATES`                                    | `#{lang}`                                                                                                  |
| `StandardDosageUnits`            | `V_DOSAGE_FORM_UNITS`                                               | `#{dosageFormCode}`, `#{lang}`                                                                             |
| `StandardGradeRefs`              | `V_STANDARD_GRADE_REFERENCES`                                       | `#{lang}` — prior note: `STAND_GRADE_REF_IS_HOMEOPATHIC='n'`                                               |
| `DosageDiscrete`                 | `V_DOSAGE_FORMS`                                                    | `#{DosageFormCode}`                                                                                        |
| `DosageUnitAdditionalInfo`       | `DOSAGE_UNITS`                                                      | `#{dosageUnitCode}`                                                                                        |
| `DosageFormByCode`               | `V_DOSAGE_FORMS` + `V_DOSAGE_FORM_UNITS`                            | `#{dosageFormCode}`, `#{lang}`                                                                             |
| `DosageFormsByMonoROACode`       | `V_MONO_ROA_DOSAGE_FORM`                                            | `#{monoCode}`, `#{roaCode}`, `#{lang}`                                                                     |
| `HasNullDosageFormByMonoROACode` | `V_MONO_ROA_DOSAGE_FORM`                                            | `#{monoCode}`, `#{roaCode}`                                                                                |
| `CompendialDosageFormsByROACode` | `X$ROA_DOSAGE_FORM` + `V_DOSAGE_FORMS`                              | `#{roaCode}`, `#{lang}` — **predicate should be verified directly in mapper before relying on prior note** |
| `DosageFormsByROACode`           | `X$ROA_DOSAGE_FORM` + `ADMINISTRATION_ROUTES` / dosage-form sources | `#{roaCode}`, `#{lang}`                                                                                    |
| `AllROAs`                        | `X$ROA_DOSAGE_FORM` + `ADMINISTRATION_ROUTES`                       | `#{lang}`                                                                                                  |
| `SterileByROACode`               | `ADMINISTRATION_ROUTES`                                             | `#{roaCode}`                                                                                               |
| `PCIs`                           | `V_MONOGRAPHS`                                                      | `#{lang}` — validated PCIs only                                                                            |
| `AllPCIs`                        | `V_MONOGRAPHS`                                                      | `#{lang}` — all PCIs                                                                                       |
| `PCIsByROACodeAndUseType`        | `V_MONOGRAPH_ROA` + `V_MONO_FORM_TYPES`                             | `#{lang}`, `#{roaCode}`                                                                                    |

### Additional established mapper coverage

Prior session context also identified the updated QueryMapper as including authoritative mappings for items such as:

* `IngredientGeneral`
* `WholePartsByIngClassCode`
* `ConstituentsByPartCode`
* `SourceMaterials`
* `NCSourceMaterials`
* `IngredientById`
* `UnitsByIngClassCode`
* `AdditionalUnitsByMIClass`

These should be treated as part of the authoritative QueryMapper reference set, even where the exact SQL bodies are not reproduced here.

### Common Oracle / MyBatis patterns used

* `DECODE(NVL(#{lang}, 'en'), 'en', col_eng, 'fr', col_fr)` for bilingual column selection
* `ROWNUM = 1` for first-row selection
* `TO_CHAR(date_col, 'YYYY-MM-DD')` for date formatting
* `<foreach>` for collection iteration in MyBatis

### Important caution

This section is a **working inventory**, not a substitute for the live mapper file. When exact predicates, joins, aliases, or returned fields matter, verify directly in `QueryMapper.xml`.

---

## 7. TROUBLESHOOTING NOTES

### Package resolution / execute troubleshooting for `NHPID_VAL_OWNER.NHPID_X$LOADER`

#### Example error

```sql
ORA-06550: PLS-00201: identifier 'NHPID_VAL_OWNER.NHPID_X$LOADER' must be declared
```

#### Likely causes

This is not necessarily a compilation error. Common causes include:

1. Wrong database / service / PDB / environment
2. Package absent in that environment
3. Missing `EXECUTE` privilege
4. Missing synonym, when the package is being referenced without owner qualification
5. User connected under an unexpected schema / account

#### Diagnostic queries

```sql
-- Check package exists
SELECT owner, object_name, object_type, status
FROM all_objects
WHERE object_name = 'NHPID_X$LOADER'
  AND object_type IN ('PACKAGE', 'PACKAGE BODY')
ORDER BY owner, object_type;

-- Confirm environment / current user
SELECT sys_context('USERENV','DB_NAME')      AS db_name,
       sys_context('USERENV','SERVICE_NAME') AS service_name,
       sys_context('USERENV','CON_NAME')     AS con_name,
       user                                  AS current_user
FROM dual;
```

#### Privilege / synonym examples

```sql
-- Run as owner or DBA as appropriate
GRANT EXECUTE ON NHPID_VAL_OWNER.NHPID_X$LOADER TO <your_user>;

-- Optional synonym if you want unqualified invocation
CREATE SYNONYM NHPID_X$LOADER FOR NHPID_VAL_OWNER.NHPID_X$LOADER;
```

#### Practical interpretation

If Oracle says the identifier "must be declared," first verify:

* correct environment
* object exists
* privilege granted
* invocation syntax matches how the environment is set up

Do **not** assume the package body itself is invalid unless object status confirms that.

---

## 8. WORKING ASSUMPTIONS / IMPLEMENTATION NOTES

### Safe assumptions from prior context

* Oracle remains the authoritative storage / query engine for NHPID technical work discussed here.
* `NHPID_VAL_OWNER.NHPID_X$LOADER` is the authoritative validation-loader package.
* `QueryMapper.xml` is the authoritative population / PLA service query reference.
* `NHPDWEB_OWNER` views are central to service-layer lookups and bilingual query patterns.
* Loader / mapper inventories in this document are **selective** and should be expanded from source when deeper implementation work begins.

### Things to verify directly when coding

* exact object ownership in the current environment
* exact column names / case / aliases
* exact mapper predicates and joins
* existence and signature of any specific package entry point you plan to call
* dependencies between refresh procedures and materialized views

---

## 9. WHAT WAS INTENTIONALLY REMOVED FROM V1

The following content was intentionally removed from the technical reference because it belongs in a separate archive / ingestion note, not the system reference itself:

* conversation inventories
* `conversations-006.json` splitting / filtering instructions
* vector DB integration plan
* extraction workflow notes
* personal role / operator-context notes

Those can live in a separate document such as:

* `NHPID_Conversation_Extraction_Notes.md`
* `NHPID_Knowledge_Base_Ingestion.md`

---

## 10. SUMMARY

### What this document is

A corrected **technical context primer** for NHPID architecture, validation-loader reasoning, web-service query reasoning, and common troubleshooting.

### What it is not

* not a full data dictionary
* not a complete object inventory
* not a complete QueryMapper dump
* not an environment-specific deployment guide

### Primary mental model

If you need to reason about NHPID quickly:

1. **Use `QueryMapper.xml`** for population / service query behaviour
2. **Use `NHPID_VAL_OWNER.NHPID_X$LOADER`** for validation-layer population / refresh behaviour
3. **Use `NHPDWEB_OWNER` views** as the primary service-facing query surface
4. **Treat `X_*` and `X$*` as distinct layers** — upstream buffer inputs vs validation-layer outputs

---

*Updated: 2026-02-28 | Corrected v2 from prior extracted NHPID reference*
