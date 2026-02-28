# NHPID Knowledge Base Ingestion
> Working plan for ingesting extracted NHPID markdown into a local searchable knowledge base.
> This file is intentionally separate from the core technical reference.
---
## 1. PURPOSE
This document captures the plan for:
- organizing extracted NHPID markdown files
- chunking them for retrieval
- embedding them into a local vector database
- tagging and merging future archive batches
It is **not** a source of truth for NHPID runtime behaviour.
---
## 2. INPUT SOURCES
### Primary inputs
- extracted NHPID `.md` files from prior conversation processing
- future filtered NHPID archive files such as `conversations-006-nhpid.json`
- companion reference files such as:
  - `NHPID_Technical_Reference_v2.md`
  - `NHPID_Conversation_Extraction_Notes.md`
### Recommended separation
Do not merge these categories blindly:
1. core technical references
2. archive extraction notes
3. raw conversation-derived markdown
4. implementation work notes
Use metadata to distinguish them at ingest time.
---
## 3. TARGET DIRECTORY MODEL
Suggested knowledge-base structure:
```text
knowledge-base/
  nhpid/
    technical/
    extraction/
    conversations/
    workstreams/
```
### Suggested placement
- `technical/` — curated technical references
- `extraction/` — archive-processing notes and inventories
- `conversations/` — normalized markdown derived from raw conversation exports
- `workstreams/` — topic-specific implementation notes if later added
---
## 4. CHUNKING STRATEGY
### Recommended chunk size
- approximately **500 tokens per chunk**
- include overlap between adjacent chunks
### Why
This is a good balance between:
- semantic coherence
- retrieval precision
- manageable embedding size
### Recommended chunk boundaries
Prefer chunking by:
1. section heading
2. subsection heading
3. procedure/table/view inventory blocks
4. troubleshooting recipe blocks
Avoid chunking mid-table or mid-code block if possible.
---
## 5. EMBEDDING STRATEGY
### Candidate embedding models previously discussed
- OpenAI `text-embedding-3-small`
- Anthropic embeddings
### Practical rule
Keep embedding choice configurable so the ingestion pipeline can switch providers without changing chunk metadata or directory conventions.
---
## 6. VECTOR DATABASE OPTIONS
Previously discussed options:
- **ChromaDB**
- **pgvector**
### Practical guidance
- use **ChromaDB** for fast local prototyping
- use **pgvector** if you want tighter integration with a relational environment and stronger SQL-centric workflows
---
## 7. METADATA TAGGING
Each chunk should carry at minimum:
- `system = NHPID`
- `source_file`
- `source_type` (technical / extraction / conversation / workstream)
- `date`
- `topic`
- `keywords_hit`
### Recommended additional metadata
- `object_names`
- `schema_names`
- `package_names`
- `view_names`
- `confidence` (curated vs raw extracted)
### Why
This helps separate:
- authoritative curated notes
- raw conversation-derived context
- archive-management material
---
## 8. INGESTION FLOW
### Suggested flow
1. Copy all NHPID markdown files into the knowledge-base input directory
2. Normalize filenames and folder placement
3. Chunk by section-aware rules
4. Generate embeddings for each chunk
5. Store chunks in the local vector database
6. Attach structured metadata
7. Merge newly processed archive batches such as filtered `conversations-006` output
8. Re-index if chunking rules or metadata schema changes
---
## 9. QUALITY RULES
### Keep separate
Do not allow these to collapse into one undifferentiated corpus without tags:
- technical reference content
- archive extraction notes
- draft workstream design notes
- raw troubleshooting chat fragments
### Curated-first retrieval
If retrieval returns multiple matches on the same topic, prefer in this order:
1. curated technical reference
2. curated workstream note
3. extraction notes
4. raw conversation chunk
### Verification rule
If a retrieved chunk conflicts with a curated reference, prefer the curated reference until the live source system proves otherwise.
---
## 10. FUTURE BATCH MERGE PLAN
When a new archive file is processed:
1. filter for NHPID-relevant content
2. convert to normalized markdown or structured chunks
3. tag with file/batch provenance
4. ingest into the existing NHPID vector collection
5. avoid overwriting curated documents unless explicitly revised
### Provenance suggestion
Use metadata such as:
- `batch_id`
- `conversation_id`
- `ingested_on`
- `derived_from_json = true/false`
---
## 11. MINIMAL IMPLEMENTATION CHECKLIST
- [ ] Create knowledge-base directory structure
- [ ] Place curated NHPID markdown files in the correct folders
- [ ] Add raw extracted conversation markdown separately
- [ ] Define chunking rules
- [ ] Define metadata schema
- [ ] Generate embeddings
- [ ] Load into ChromaDB or pgvector
- [ ] Test retrieval against known NHPID concepts
- [ ] Validate that curated files rank above raw chat fragments
---
## 12. SUMMARY
### What this document is
A working ingestion plan for turning extracted NHPID markdown into a searchable local knowledge base.
### What it is not
- not runtime NHPID architecture
- not a data dictionary
- not a guarantee that all retrieved chunks are equally authoritative
### Core principle
Keep curated technical truth, extraction notes, and raw conversation-derived content **separate but searchable together** through metadata.
---
*Updated: 2026-02-28 | Companion ingestion plan for NHPID knowledge-base work*
