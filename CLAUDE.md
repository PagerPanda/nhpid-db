# NHPID Database Development

## Who I Am
Lead backend developer on the Government of Canada Health Canada NHPID (Natural Health Products Ingredient Database) — Oracle, schemas `NHPID_VAL_OWNER` / `NHPDWEB_OWNER`.

## Technical Reference (auto-loaded)
@docs/NHPID_Quick_Reference.md

Schema hierarchy, key object names, layer model, and working assumptions.
For full inventories and troubleshooting, read `docs/NHPID_Deep_Reference.md`.

### Companion Documentation
- `docs/NHPID_Deep_Reference.md` — full inventories: QueryMapper SQL IDs, loader procedures, view column notes, troubleshooting
- `docs/NHPID_Conversation_Extraction_Notes.md` — archive-processing notes, conversation inventory, filtering scripts
- `docs/NHPID_Knowledge_Base_Ingestion.md` — vector DB ingestion plan, chunking strategy, metadata tagging

---

## CRITICAL RULES — MANDATORY BEFORE WRITING ANY SQL

### Syntax
- NHPID = **Oracle** syntax only
- Use Oracle-specific constructs: NVL, DECODE, TO_CHAR, rownum, etc.
- Never use MySQL syntax (IFNULL, LIMIT, backtick quoting, etc.)

### Oracle Patterns
- Bilingual columns: `DECODE(NVL(#{lang}, 'en'), 'en', col_eng, 'fr', col_fr)`
- First-row-only: `WHERE rownum = 1` (use subquery for correct ordering)
- Date formatting: `TO_CHAR(date_col, 'YYYY-MM-DD')`
- MyBatis collection iteration: `<foreach>` for IN-clause parameters

### DML Safety
- Always preview with SELECT before any UPDATE or DELETE
- Never write directly to production tables — always script with proper guards
- Test in `NHPID_VAL_OWNER` before touching `NHPDWEB_OWNER`
- DDL in Oracle causes implicit COMMIT — be careful with transaction boundaries

---

## Tooling
- Oracle SQL Developer
- MyBatis 3.0 (QueryMapper.xml — namespace `ca.gc.hc.nhpd.webservice.mapper.QueryMapper`)

---

## Repo Layout
```
/schema      → DDL: CREATE TABLE, ALTER TABLE scripts
/views       → CREATE OR REPLACE VIEW scripts
/procedures  → Stored procedures and packages
/migrations  → One-time data migration and backfill scripts
/queries     → Debug, reporting, and investigation queries
/docs        → Technical reference, extraction notes, ingestion plan
```

## File Naming Convention
```
schema/     nhpid_<table_name>.sql
views/      v_<view_name>.sql
procedures/ nhpid_<proc_name>.sql
migrations/ <ticket>_<description>.sql
queries/    debug_<description>.sql
```

---

## Working Instructions
- Always verify column/object names against `docs/NHPID_Deep_Reference.md` before writing SQL
- Schema changes: DDL first → views second → procedures third
- Never refactor existing working queries unless explicitly asked
- When in doubt about a table or column, say so — do not invent names
- IMPORTANT: Views in `NHPDWEB_OWNER` follow the `v_` or `V_` prefix convention
- IMPORTANT: X$ staging tables use the `X$` prefix convention
- IMPORTANT: Loader package objects use the `NHPID_X$LOADER` prefix
