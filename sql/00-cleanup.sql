-- ============================================
-- DATABASE CLEANUP SCRIPT
-- ============================================
--
-- Purpose: Drop all objects for clean database run
-- Run before final screenshot execution
-- ============================================

SET SERVEROUTPUT ON

PROMPT ========================================
PROMPT DATABASE CLEANUP - DROPPING ALL OBJECTS
PROMPT ========================================
PROMPT;

-- Drop VPD policies first
BEGIN
    DBMS_RLS.DROP_POLICY('BANK_SCHEMA', 'ACCOUNTS', 'VPD_ACCOUNTS_BRANCH_POLICY');
    DBMS_OUTPUT.PUT_LINE('✓ Dropped VPD policy');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  VPD policy does not exist');
END;
/

-- Drop views
DECLARE
    v_count NUMBER;
BEGIN
    FOR v IN (SELECT view_name FROM user_views) LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
        v_count := SQL%ROWCOUNT;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ Dropped all views');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping views: ' || SQLERRM);
END;
/

-- Drop procedures
DECLARE
    v_count NUMBER;
BEGIN
    FOR v IN (SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE') LOOP
        EXECUTE IMMEDIATE 'DROP PROCEDURE ' || v.object_name;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ Dropped all procedures');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping procedures: ' || SQLERRM);
END;
/

-- Drop functions
DECLARE
    v_count NUMBER;
BEGIN
    FOR v IN (SELECT object_name FROM user_objects WHERE object_type = 'FUNCTION') LOOP
        EXECUTE IMMEDIATE 'DROP FUNCTION ' || v.object_name;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ Dropped all functions');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping functions: ' || SQLERRM);
END;
/

-- Drop packages
DECLARE
    v_count NUMBER;
BEGIN
    FOR v IN (SELECT object_name FROM user_objects WHERE object_type = 'PACKAGE') LOOP
        EXECUTE IMMEDIATE 'DROP PACKAGE ' || v.object_name;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ Dropped all packages');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping packages: ' || SQLERRM);
END;
/

-- Drop triggers
DECLARE
    v_count NUMBER;
BEGIN
    FOR v IN (SELECT trigger_name FROM user_triggers) LOOP
        EXECUTE IMMEDIATE 'DROP TRIGGER ' || v.trigger_name;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ Dropped all triggers');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping triggers: ' || SQLERRM);
END;
/

-- Drop tables (cascade constraints to handle FKs)
DECLARE
    v_count NUMBER;
BEGIN
    FOR v IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || v.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ Dropped all tables');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping tables: ' || SQLERRM);
END;
/

-- Drop sequences
DECLARE
    v_count NUMBER;
BEGIN
    FOR v IN (SELECT sequence_name FROM user_sequences) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || v.sequence_name;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ Dropped all sequences');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping sequences: ' || SQLERRM);
END;
/

PROMPT;
PROMPT ========================================
PROMPT CLEANUP COMPLETE
PROMPT ========================================
PROMPT;
PROMPT Database is now clean and ready for fresh run
PROMPT;

-- Verify cleanup
PROMPT Remaining objects:
SELECT object_type, COUNT(*) AS count
FROM user_objects
WHERE object_type IN ('TABLE', 'VIEW', 'SEQUENCE', 'TRIGGER', 'PROCEDURE', 'FUNCTION', 'PACKAGE')
GROUP BY object_type
ORDER BY object_type;

PROMPT;
PROMPT If no rows returned above, database is completely clean.
PROMPT;
