# NHPID Quick Reference

> Lightweight context primer — auto-loaded by CLAUDE.md.
> For full inventories and troubleshooting: `docs/NHPID_Deep_Reference.md`
> **Important:** inventories below are **selective, not exhaustive**.

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

## 3. KEY OBJECTS — QUICK INVENTORY

> Name-only lists for orientation. Full descriptions and column notes: `docs/NHPID_Deep_Reference.md`

### Validation-layer objects (`NHPID_VAL_OWNER`)

`X$ASSESSMENT_DOSE` | `X$GROUP_RULES` | `X$MONOGRAPH_XREF` | `X$MONOGRAPH_*` | `X$ROA_DOSAGE_FORM` | `X_X$LOAD_LOG`

### Web-facing views / lookups (`NHPDWEB_OWNER`)

**Views:** `V_MONOGRAPHS` | `V_MONOGRAPH_ROA` | `V_ASSESSMENT_DOSE_SUB_POP` | `V_ASSESSMENT_DOSES` | `V_SUB_POPULATION_GROUPS` | `V_SUB_POPULATION_SEXES` | `V_SUB_POPULATION_CONDITIONS` | `V_UNITS_OF_MEASURE` | `V_DOSAGE_FORMS` | `V_DOSAGE_FORM_UNITS` | `V_ROA_DOSAGE_FORMS` | `V_MONO_ROA_DOSAGE_FORM` | `V_MONO_FORM_TYPES` | `V_STANDARD_GRADE_REFERENCES` | `V_UOM_BY_INGRED_CLASS_TYPE`

**Tables:** `COMMON_TERMS` | `COUNTRIES` | `PROVINCES_STATES` | `DOSAGE_UNITS` | `ADMINISTRATION_ROUTES` | `APPLICATION_PROPERTIES_VAL`

---

## 4. QUERYMAPPER.XML — SUMMARY

**File:** `QueryMapper.xml`
**Namespace:** `ca.gc.hc.nhpd.webservice.mapper.QueryMapper`
**Framework:** MyBatis 3.x

Defines named SQL statements for monographs, dosage forms, routes, units, age groups, ingredient lookups, and application properties.

Full SQL ID inventory with source tables and parameters: `docs/NHPID_Deep_Reference.md` section 3.

---

## 5. VALIDATION LOADER — SUMMARY

**Package:** `NHPID_VAL_OWNER.NHPID_X$LOADER`

ETL / refresh from `X_*` buffers into `X$*` validation tables. Logs to `X_X$LOAD_LOG`. Refreshes dependent `MV_*` views.

Full procedure inventory, helper routines, and troubleshooting: `docs/NHPID_Deep_Reference.md` sections 2 and 5.

---

## 6. WORKING ASSUMPTIONS

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

*Auto-loaded tier. Deep reference: `docs/NHPID_Deep_Reference.md`*
