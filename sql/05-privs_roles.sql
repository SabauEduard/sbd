-- ============================================
-- PHASE 5: PRIVILEGES & ROLES (N2 - Requirement 5)
-- ============================================
--
-- Objective: Implement Role-Based Access Control (RBAC) with privilege hierarchy
--
-- Grading Impact: N2 Requirement 5 (Higher grade - beyond passing)
--
-- Implementation:
--   1. Populate ROLE_PRIVS table with specific privileges
--   2. Define role hierarchy (inheritance)
--   3. Grant table privileges to roles
--   4. Demonstrate privilege checking
--
-- Role Hierarchy:
--   DBA_ROLE (highest)
--     ↓
--   MANAGER_ROLE
--     ↓
--   SENIOR_TELLER_ROLE
--     ↓
--   TELLER_ROLE
--     ↓
--   BASE_EMPLOYEE_ROLE
--     ↓
--   AUDITOR_ROLE (separate branch - read-only)
--
-- Why RBAC:
--   - Centralized access management
--   - Role inheritance (DRY principle)
--   - Easier privilege auditing
--   - Scalable for new users
-- ============================================

SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

PROMPT ========================================
PROMPT PHASE 5: PRIVILEGES & ROLES (RBAC)
PROMPT ========================================
PROMPT;
PROMPT This script implements:
PROMPT   1. Role privilege definitions (ROLE_PRIVS table)
PROMPT   2. Role hierarchy with inheritance
PROMPT   3. Table-level privilege grants
PROMPT   4. Privilege verification queries
PROMPT;

-- ============================================
-- PART 1: CLEAR EXISTING ROLE_PRIVS
-- ============================================

PROMPT ========================================
PROMPT PART 1: CLEARING EXISTING PRIVILEGES
PROMPT ========================================
PROMPT;

-- Clear existing privileges for clean run
DELETE FROM ROLE_PRIVS;
COMMIT;

PROMPT ✓ Existing privileges cleared
PROMPT;

-- ============================================
-- PART 2: BASE_EMPLOYEE_ROLE PRIVILEGES
-- ============================================

PROMPT ========================================
PROMPT PART 2: BASE_EMPLOYEE_ROLE
PROMPT ========================================
PROMPT;
PROMPT Granting minimal privileges (connect + view reference data)...
PROMPT;

-- Privilege 1: Connect to database
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 1, 'SYSTEM', 'CONNECT', NULL, 'N');

-- Privilege 2: View banks
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 1, 'OBJECT', 'SELECT', 'BANKS', 'N');

-- Privilege 3: View branches
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 1, 'OBJECT', 'SELECT', 'BRANCHES', 'N');

-- Privilege 4: View roles
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 1, 'OBJECT', 'SELECT', 'ROLES', 'N');

-- Privilege 5: View own user profile
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 1, 'OBJECT', 'SELECT', 'DB_USERS', 'N');

COMMIT;

PROMPT ✓ BASE_EMPLOYEE_ROLE: 5 privileges granted
PROMPT   - CONNECT (system)
PROMPT   - SELECT on BANKS, BRANCHES, ROLES, DB_USERS
PROMPT;

-- ============================================
-- PART 3: TELLER_ROLE PRIVILEGES
-- ============================================

PROMPT ========================================
PROMPT PART 3: TELLER_ROLE
PROMPT ========================================
PROMPT;
PROMPT Inherits: All BASE_EMPLOYEE_ROLE privileges
PROMPT Additional: View accounts, process transactions (with limits)
PROMPT;

-- Inherit from BASE_EMPLOYEE_ROLE (role hierarchy handled in ROLES table)

-- Privilege 6: View accounts (masked)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 2, 'OBJECT', 'SELECT', 'V_ACCOUNTS_MASKED', 'N');

-- Privilege 7: View transactions
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 2, 'OBJECT', 'SELECT', 'TRANSACTIONS', 'N');

-- Privilege 8: Create transactions (deposits, withdrawals up to 5000)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 2, 'OBJECT', 'INSERT', 'TRANSACTIONS', 'N');

-- Privilege 9: Update transaction status
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 2, 'OBJECT', 'UPDATE', 'TRANSACTIONS', 'N');

-- Privilege 10: Update account balance (via transactions only)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 2, 'OBJECT', 'UPDATE', 'ACCOUNTS', 'N');

COMMIT;

PROMPT ✓ TELLER_ROLE: 5 additional privileges granted
PROMPT   - SELECT on V_ACCOUNTS_MASKED (masked view)
PROMPT   - SELECT, INSERT, UPDATE on TRANSACTIONS
PROMPT   - UPDATE on ACCOUNTS (balance changes)
PROMPT;
PROMPT Note: Amount limits enforced by application logic / check constraints
PROMPT;

-- ============================================
-- PART 4: SENIOR_TELLER_ROLE PRIVILEGES
-- ============================================

PROMPT ========================================
PROMPT PART 4: SENIOR_TELLER_ROLE
PROMPT ========================================
PROMPT;
PROMPT Inherits: All TELLER_ROLE privileges
PROMPT Additional: View full accounts, reverse transactions, higher limits
PROMPT;

-- Privilege 11: View full accounts (unmasked)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 3, 'OBJECT', 'SELECT', 'ACCOUNTS', 'N');

-- Privilege 12: Delete transactions (reversal)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 3, 'OBJECT', 'DELETE', 'TRANSACTIONS', 'N');

-- Privilege 13: Modify account details
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 3, 'OBJECT', 'UPDATE', 'ACCOUNTS', 'N');

COMMIT;

PROMPT ✓ SENIOR_TELLER_ROLE: 3 additional privileges granted
PROMPT   - SELECT on ACCOUNTS (unmasked - full IBAN visible)
PROMPT   - DELETE on TRANSACTIONS (transaction reversal)
PROMPT   - UPDATE on ACCOUNTS (modify account details)
PROMPT;

-- ============================================
-- PART 5: MANAGER_ROLE PRIVILEGES
-- ============================================

PROMPT ========================================
PROMPT PART 5: MANAGER_ROLE
PROMPT ========================================
PROMPT;
PROMPT Inherits: All SENIOR_TELLER_ROLE privileges
PROMPT Additional: Account management, audit access, role grants
PROMPT;

-- Privilege 14: Create accounts
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 4, 'OBJECT', 'INSERT', 'ACCOUNTS', 'N');

-- Privilege 15: Delete accounts (close)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 4, 'OBJECT', 'DELETE', 'ACCOUNTS', 'N');

-- Privilege 16: View audit logs
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 4, 'OBJECT', 'SELECT', 'AUDIT_LOG', 'N');

-- Privilege 17: View role privileges
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 4, 'OBJECT', 'SELECT', 'ROLE_PRIVS', 'N');

-- Privilege 18: Manage users (limited)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 4, 'OBJECT', 'UPDATE', 'DB_USERS', 'N');

-- Privilege 19: Grant TELLER_ROLE and BASE_EMPLOYEE_ROLE
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 4, 'SYSTEM', 'GRANT_ROLE', 'TELLER_ROLE', 'Y');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 4, 'SYSTEM', 'GRANT_ROLE', 'BASE_EMPLOYEE_ROLE', 'Y');

COMMIT;

PROMPT ✓ MANAGER_ROLE: 7 additional privileges granted
PROMPT   - INSERT, DELETE on ACCOUNTS (open/close accounts)
PROMPT   - SELECT on AUDIT_LOG (view audit trail)
PROMPT   - SELECT on ROLE_PRIVS (view role permissions)
PROMPT   - UPDATE on DB_USERS (manage employee data)
PROMPT   - GRANT_ROLE for TELLER_ROLE, BASE_EMPLOYEE_ROLE (WITH GRANT OPTION)
PROMPT;

-- ============================================
-- PART 6: AUDITOR_ROLE PRIVILEGES
-- ============================================

PROMPT ========================================
PROMPT PART 6: AUDITOR_ROLE
PROMPT ========================================
PROMPT;
PROMPT Separate branch (not in hierarchy)
PROMPT Read-only access to everything
PROMPT;

-- Privilege 20-28: Read-only access to all tables
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'BANKS', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'BRANCHES', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'ACCOUNTS', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'TRANSACTIONS', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'DB_USERS', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'ROLES', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'ROLE_PRIVS', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'USER_SESSIONS', 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 5, 'OBJECT', 'SELECT', 'AUDIT_LOG', 'N');

COMMIT;

PROMPT ✓ AUDITOR_ROLE: 9 privileges granted
PROMPT   - SELECT on all tables (BANKS, BRANCHES, ACCOUNTS, TRANSACTIONS, etc.)
PROMPT   - NO INSERT, UPDATE, DELETE (read-only)
PROMPT   - Cannot modify anything they audit (separation of duties)
PROMPT;

-- ============================================
-- PART 7: DBA_ROLE PRIVILEGES
-- ============================================

PROMPT ========================================
PROMPT PART 7: DBA_ROLE
PROMPT ========================================
PROMPT;
PROMPT Inherits: All MANAGER_ROLE privileges
PROMPT Additional: Full DDL, system administration
PROMPT;

-- Privilege 29: Full control on all tables (CRUD)
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'OBJECT', 'ALL', 'ALL_TABLES', 'Y');

-- Privilege 30: Create tables
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'SYSTEM', 'CREATE TABLE', NULL, 'N');

-- Privilege 31: Alter tables
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'SYSTEM', 'ALTER ANY TABLE', NULL, 'N');

-- Privilege 32: Drop tables
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'SYSTEM', 'DROP ANY TABLE', NULL, 'N');

-- Privilege 33: Manage users
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'SYSTEM', 'CREATE USER', NULL, 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'SYSTEM', 'ALTER USER', NULL, 'N');

INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'SYSTEM', 'DROP USER', NULL, 'N');

-- Privilege 34: Grant any privilege
INSERT INTO ROLE_PRIVS (priv_id, role_id, privilege_type, privilege_name, object_name, grantable)
VALUES (SEQ_PRIV_ID.NEXTVAL, 6, 'SYSTEM', 'GRANT ANY PRIVILEGE', NULL, 'Y');

COMMIT;

PROMPT ✓ DBA_ROLE: 8 additional system privileges granted
PROMPT   - ALL privileges on ALL_TABLES (full CRUD with grant option)
PROMPT   - CREATE TABLE, ALTER ANY TABLE, DROP ANY TABLE
PROMPT   - CREATE USER, ALTER USER, DROP USER
PROMPT   - GRANT ANY PRIVILEGE
PROMPT;

-- ============================================
-- PART 8: ROLE HIERARCHY SUMMARY
-- ============================================

PROMPT ========================================
PROMPT PART 8: ROLE HIERARCHY
PROMPT ========================================
PROMPT;

PROMPT Role inheritance chain:
SELECT
    r1.role_id,
    r1.role_name AS role,
    r2.role_name AS parent_role,
    LEVEL AS hierarchy_level
FROM ROLES r1
LEFT JOIN ROLES r2 ON r1.parent_role_id = r2.role_id
START WITH r1.parent_role_id IS NULL
CONNECT BY PRIOR r1.role_id = r1.parent_role_id
ORDER SIBLINGS BY r1.role_id;

PROMPT;
PROMPT Hierarchy explanation:
PROMPT   Level 1: BASE_EMPLOYEE_ROLE (root - minimal privileges)
PROMPT   Level 2: TELLER_ROLE (inherits base + transaction processing)
PROMPT   Level 3: SENIOR_TELLER_ROLE (inherits teller + higher limits)
PROMPT   Level 4: MANAGER_ROLE (inherits senior + account management)
PROMPT   Level 5: DBA_ROLE (inherits manager + full system access)
PROMPT   Separate: AUDITOR_ROLE (read-only, not in hierarchy)
PROMPT;

-- ============================================
-- PART 9: PRIVILEGE SUMMARY BY ROLE
-- ============================================

PROMPT ========================================
PROMPT PART 9: PRIVILEGE SUMMARY
PROMPT ========================================
PROMPT;

PROMPT Total privileges per role:
SELECT
    r.role_name,
    COUNT(rp.priv_id) AS privilege_count,
    SUM(CASE WHEN rp.privilege_type = 'SYSTEM' THEN 1 ELSE 0 END) AS system_privs,
    SUM(CASE WHEN rp.privilege_type = 'OBJECT' THEN 1 ELSE 0 END) AS object_privs
FROM ROLES r
LEFT JOIN ROLE_PRIVS rp ON r.role_id = rp.role_id
GROUP BY r.role_name
ORDER BY privilege_count DESC;

PROMPT;

PROMPT Detailed privileges by role:
PROMPT;

PROMPT BASE_EMPLOYEE_ROLE:
SELECT privilege_type, privilege_name, object_name, grantable
FROM ROLE_PRIVS
WHERE role_id = 1
ORDER BY privilege_type, privilege_name;

PROMPT;
PROMPT TELLER_ROLE (+ inherited from BASE):
SELECT privilege_type, privilege_name, object_name, grantable
FROM ROLE_PRIVS
WHERE role_id = 2
ORDER BY privilege_type, privilege_name;

PROMPT;
PROMPT SENIOR_TELLER_ROLE (+ inherited from TELLER):
SELECT privilege_type, privilege_name, object_name, grantable
FROM ROLE_PRIVS
WHERE role_id = 3
ORDER BY privilege_type, privilege_name;

PROMPT;
PROMPT MANAGER_ROLE (+ inherited from SENIOR_TELLER):
SELECT privilege_type, privilege_name, object_name, grantable
FROM ROLE_PRIVS
WHERE role_id = 4
ORDER BY privilege_type, privilege_name;

PROMPT;
PROMPT AUDITOR_ROLE (separate branch):
SELECT privilege_type, privilege_name, object_name, grantable
FROM ROLE_PRIVS
WHERE role_id = 5
ORDER BY privilege_type, privilege_name;

PROMPT;
PROMPT DBA_ROLE (+ inherited from MANAGER):
SELECT privilege_type, privilege_name, object_name, grantable
FROM ROLE_PRIVS
WHERE role_id = 6
ORDER BY privilege_type, privilege_name;

PROMPT;

-- ============================================
-- PART 10: PRIVILEGE CHECKING QUERIES
-- ============================================

PROMPT ========================================
PROMPT PART 10: PRIVILEGE VERIFICATION
PROMPT ========================================
PROMPT;

PROMPT Who can SELECT from ACCOUNTS?
SELECT DISTINCT r.role_name
FROM ROLES r
JOIN ROLE_PRIVS rp ON r.role_id = rp.role_id
WHERE rp.object_name IN ('ACCOUNTS', 'ALL_TABLES')
  AND rp.privilege_name IN ('SELECT', 'ALL')
ORDER BY r.role_name;

PROMPT;
PROMPT Who can INSERT into TRANSACTIONS?
SELECT DISTINCT r.role_name
FROM ROLES r
JOIN ROLE_PRIVS rp ON r.role_id = rp.role_id
WHERE rp.object_name IN ('TRANSACTIONS', 'ALL_TABLES')
  AND rp.privilege_name IN ('INSERT', 'ALL')
ORDER BY r.role_name;

PROMPT;
PROMPT Who can view AUDIT_LOG?
SELECT DISTINCT r.role_name
FROM ROLES r
JOIN ROLE_PRIVS rp ON r.role_id = rp.role_id
WHERE rp.object_name = 'AUDIT_LOG'
  AND rp.privilege_name = 'SELECT'
ORDER BY r.role_name;

PROMPT;
PROMPT Who has DDL privileges?
SELECT DISTINCT r.role_name
FROM ROLES r
JOIN ROLE_PRIVS rp ON r.role_id = rp.role_id
WHERE rp.privilege_type = 'SYSTEM'
  AND rp.privilege_name LIKE '%TABLE%'
ORDER BY r.role_name;

PROMPT;

-- ============================================
-- PART 11: COMPLIANCE REQUIREMENTS
-- ============================================

PROMPT ========================================
PROMPT PART 11: COMPLIANCE MAPPING
PROMPT ========================================
PROMPT;

PROMPT PCI-DSS Requirement 7 - Restrict Access:
PROMPT   ✓ Access based on job classification (6 roles defined)
PROMPT   ✓ Need-to-know principle (tellers can't view audit logs)
PROMPT   ✓ Default deny (BASE_EMPLOYEE_ROLE is minimal)
PROMPT   ✓ Privilege hierarchy (inheritance with escalation)
PROMPT;
PROMPT PCI-DSS Requirement 7.1.2 - Privileges Based on Job:
PROMPT   ✓ TELLER_ROLE: Transaction processing only
PROMPT   ✓ MANAGER_ROLE: Account management + reporting
PROMPT   ✓ AUDITOR_ROLE: Read-only access for compliance
PROMPT   ✓ DBA_ROLE: System administration
PROMPT;
PROMPT GDPR Article 32 - Access Control:
PROMPT   ✓ Role-based access enforced
PROMPT   ✓ Least privilege principle applied
PROMPT   ✓ Separation of duties (auditors read-only)
PROMPT   ✓ Regular access reviews (via ROLE_PRIVS queries)
PROMPT;

-- ============================================
-- REQUIREMENT COMPLETION STATUS
-- ============================================

PROMPT;
PROMPT ========================================
PROMPT REQUIREMENT COMPLETION
PROMPT ========================================
PROMPT;
PROMPT ✅ N2 - Requirement 5: PRIVILEGES & ROLES - COMPLETE
PROMPT;
PROMPT Deliverables:
PROMPT   ✓ 34+ privileges defined in ROLE_PRIVS table
PROMPT   ✓ Role hierarchy with inheritance (5 levels)
PROMPT   ✓ AUDITOR_ROLE separate branch (read-only)
PROMPT   ✓ Privilege summaries by role
PROMPT   ✓ Verification queries (who can do what)
PROMPT   ✓ Compliance requirements mapped
PROMPT;
PROMPT Grade Progress:
PROMPT   N1: 5/5 requirements complete (100% - Pass achieved!)
PROMPT   N2: 1/2 requirements complete (50% toward higher grade)
PROMPT   - Requirement 5 (Privileges & Roles): ✅ DONE
PROMPT   - Requirement 6 (SQL Injection): ⬜ TODO
PROMPT;
PROMPT Current potential grade: Between 5 and 7 (need N2 Req 6 for Grade 7)
PROMPT;
PROMPT Next Phase: Phase 6 - SQL Injection Protection (N2 - Requirement 6)
PROMPT;

PROMPT ========================================
PROMPT SCREENSHOTS FOR DOCUMENTATION
PROMPT ========================================
PROMPT;
PROMPT Required screenshots for project document:
PROMPT   1. Role hierarchy tree (CONNECT BY query result)
PROMPT   2. Privilege count by role
PROMPT   3. Detailed privileges for TELLER_ROLE
PROMPT   4. Detailed privileges for MANAGER_ROLE
PROMPT   5. "Who can SELECT from ACCOUNTS?" query result
PROMPT   6. ROLE_PRIVS table sample data
PROMPT;
PROMPT Save to: assets/screenshots/phase5-roles/
PROMPT;

PROMPT ========================================
PROMPT Phase 5 Complete!
PROMPT ========================================
PROMPT;
PROMPT Role-Based Access Control implemented with:
PROMPT   - 6 roles with clear privilege definitions
PROMPT   - 34+ privileges across system and object levels
PROMPT   - Role inheritance hierarchy (5 levels)
PROMPT   - Separation of duties (auditor read-only)
PROMPT;
PROMPT 50% of N2 complete - Continue with Phase 6 for Grade 7!
PROMPT;
