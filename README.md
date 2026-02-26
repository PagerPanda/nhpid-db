# NHPID Database Scripts

SQL scripts for backend development on the Natural Health Products Ingredient Database (NHPID).

- **DB Engine:** Oracle
- **Primary Schemas:** `NHPID_VAL_OWNER`, `NHPDWEB_OWNER`
- **Loader Schema:** `NHPID_X$LOADER`
- **Web Service Layer:** Java/Spring + MyBatis (`QueryMapper.xml`)

## Structure

| Folder | Contents |
|---|---|
| `/schema` | DDL — CREATE TABLE, ALTER TABLE |
| `/views` | CREATE OR REPLACE VIEW scripts |
| `/procedures` | Stored procedures and packages |
| `/migrations` | One-time data backfill / migration scripts |
| `/queries` | Debug, reporting, investigation queries |
| `/docs` | Technical reference documentation |

## Reference

See `docs/NHPID_Technical_Reference.md` for full schema documentation, QueryMapper.xml inventory, and known issues.

## Claude Code

This repo is configured for Claude Code via `CLAUDE.md`. Run `claude` from the repo root to start a context-aware session.
