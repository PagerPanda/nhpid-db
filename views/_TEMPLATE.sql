-- ============================================================================
-- File:        <filename>.sql
-- Ticket:      <JIRA ticket>
-- Author:      <name>
-- Date:        <YYYY-MM-DD>
-- Environment: DEV / TEST / PROD
-- Engine:      Oracle
-- Schema:      NHPID_VAL_OWNER / NHPDWEB_OWNER
-- Description: <brief description>
-- ============================================================================

CREATE OR REPLACE VIEW <schema>.v_<name> AS
SELECT
    -- Use bilingual pattern:
    -- DECODE(NVL(#{lang}, 'en'), 'en', col_eng, 'fr', col_fr) AS col_name
    -- columns here
FROM <schema>.<table>
-- JOIN ...
-- WHERE ...
;
