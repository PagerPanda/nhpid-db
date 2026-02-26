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

CREATE OR REPLACE PROCEDURE <schema>.nhpid_<name>(
    p_param1 IN NUMBER,
    p_user   IN VARCHAR2
)
AS
BEGIN
    -- Procedure logic here

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END nhpid_<name>;
/
