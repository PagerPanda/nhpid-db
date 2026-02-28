# NHPID Conversation Extraction Notes
> Archive-processing and extraction notes for NHPID-related conversation history.
> This file is intentionally separate from the core technical reference.
---
## 1. PURPOSE
This document tracks:
- conversation inventory notes
- large JSON handling guidance
- filtering / extraction patterns
- archive-processing assumptions for NHPID-related chats
It is **not** a system architecture reference and should not be used as the source of truth for NHPID runtime behaviour.
---
## 2. CONVERSATION INVENTORY SNAPSHOT
The following inventory was previously captured as part of extracted NHPID conversation material.
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
### Additional captured item
| Date | Title | System | Size | Notes |
|---|---|---|---|---|
| 2026-02-04 | Oracle Package Error Troubleshooting | NHPID | 3.3K | `NHPID_X$LOADER` package resolution / PLS-00201 issue |
### Notes
- Conversation `#19` was cross-system and may also appear in BTS extraction notes.
- Inventory metadata is useful for archive management, not as runtime technical truth.
---
## 3. LARGE FILE HANDLING — `conversations-006.json`
### Context
A prior extraction workflow encountered a large file (`conversations-006.json`) that exceeded chat upload limits.
### Recommended strategies
#### Option A — split locally
```python
import json
with open('conversations-006.json') as f:
    data = json.load(f)
mid = len(data) // 2
with open('conversations-006a.json', 'w') as f:
    json.dump(data[:mid], f)
with open('conversations-006b.json', 'w') as f:
    json.dump(data[mid:], f)
print(f"Total: {len(data)} convos -> {mid} + {len(data)-mid}")
```
#### Option B — pre-filter for NHPID-relevant content
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
        if not msg:
            continue
        parts = msg.get('content', {}).get('parts', []) if isinstance(msg.get('content'), dict) else []
        texts.extend(p for p in parts if isinstance(p, str))
    return ' '.join(texts)
hits = [c for c in data if any(k.lower() in full_text(c).lower() for k in KEYWORDS)]
with open('conversations-006-nhpid.json', 'w') as f:
    json.dump(hits, f)
print(f"Filtered: {len(hits)}/{len(data)} conversations")
```
### Practical note
Prefer filtering before upload whenever the archive contains multiple systems or general non-technical content.
---
## 4. KEYWORD STRATEGY FOR FUTURE FILTERING
Useful NHPID-specific filter terms include:
- `NHPID_VAL_OWNER`
- `NHPDWEB_OWNER`
- `QueryMapper`
- `X$MONOGRAPH`
- `NHPID_X$LOADER`
- `V_MONOGRAPHS`
- `APPLICATION_PROPERTIES_VAL`
- `V_ROA_DOSAGE_FORMS`
- `V_DOSAGE_FORMS`
- `V_UNITS_OF_MEASURE`
### Practical rule
Use a mix of:
- schema/package names
- view names
- mapper names
- domain-specific table prefixes
This usually yields much cleaner extraction results than broad terms like "NHPID" alone.
---
## 5. EXTRACTION BOUNDARY RULES
### Include
- Oracle SQL / PL-SQL troubleshooting
- QueryMapper / MyBatis mapping work
- validation-layer loader discussions
- schema/view/table reasoning
- environment / package-resolution troubleshooting
### Exclude or tag separately
- BTS-only content
- general coding/tooling conversations with no NHPID object references
- non-technical planning chatter
- pure archive-management discussions
### Cross-system handling
If a conversation clearly spans BTS and NHPID:
- tag it as cross-system
- preserve it in both inventories if useful
- avoid copying its technical claims into either core technical reference without system-specific validation
---
## 6. FILE ORGANIZATION SUGGESTION
Suggested separation:
- `NHPID_Technical_Reference_v2.md` — core technical primer
- `NHPID_Conversation_Extraction_Notes.md` — archive and extraction notes
- `NHPID_Knowledge_Base_Ingestion.md` — vector DB / chunking / embedding plan
This keeps runtime truth separate from archive-processing operations.
---
*Updated: 2026-02-28 | Companion archive-processing notes for NHPID*
