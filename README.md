# NHPID Database Scripts

SQL scripts for backend development on the Natural Health Products Ingredient Database (NHPID).

- **DB Engine:** Oracle
- **Primary Schemas:** `NHPID_VAL_OWNER`, `NHPDWEB_OWNER`
- **Validation Loader Package:** `NHPID_VAL_OWNER.NHPID_X$LOADER`
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

| Document | Description |
|----------|-------------|
| `docs/NHPID_Quick_Reference.md` | Quick reference (auto-loaded) — schema hierarchy, key object names, layer model, working assumptions |
| `docs/NHPID_Deep_Reference.md` | Deep reference (on-demand) — full QueryMapper inventory, loader procedures, view column notes, troubleshooting |
| `docs/NHPID_Conversation_Extraction_Notes.md` | Archive-processing notes — conversation inventory, filtering scripts, keyword strategy |
| `docs/NHPID_Knowledge_Base_Ingestion.md` | Knowledge-base ingestion plan — chunking, embedding, vector DB setup |

## Claude Code

This repo is configured for Claude Code via `CLAUDE.md`. Run `claude` from the repo root to start a context-aware session.
