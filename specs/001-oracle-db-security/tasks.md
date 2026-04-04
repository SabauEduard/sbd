# Task Breakdown: Oracle Database Security for Banking Transactions

**Feature ID**: 001-oracle-db-security  
**Generated**: 2026-04-04  
**Total Tasks**: 65  
**Estimated Total Effort**: 44 hours

---

## Task Summary

| Phase | Requirements | Tasks | Effort | Priority | Status |
|-------|--------------|-------|--------|----------|--------|
| Phase 1 | Setup | 5 | 1h | Setup | ⬜ Not Started |
| Phase 2 | N1-Req1 (Schema) | 10 | 5h | 🔴 CRITICAL | ⬜ Not Started |
| Phase 3 | N1-Req2 (Encryption) | 7 | 4h | 🟠 HIGH | ⬜ Blocked by Phase 2 |
| Phase 4 | N1-Req3 (Auditing) | 9 | 5h | 🟠 HIGH | ⬜ Blocked by Phase 2 |
| Phase 5 | N1-Req4 (Identity Mgmt) | 8 | 4h | 🟠 HIGH | ⬜ Blocked by Phase 2 |
| Phase 6 | N1-Req7 (Masking) | 6 | 3h | 🟠 HIGH | ⬜ Blocked by Phase 2 |
| Phase 7 | N2-Req5 (Privileges) | 7 | 4h | 🟡 MEDIUM | ⬜ Blocked by Phase 5 |
| Phase 8 | N2-Req6 (SQL Injection) | 6 | 4h | 🟡 MEDIUM | ⬜ Blocked by Phase 2 |
| Phase 9 | N3 (Complexity) | 6 | 8h | 🟢 BONUS | ⬜ Blocked by Phase 6 |
| Phase 10 | Documentation | 5 | 6h | 🔴 CRITICAL | ⬜ Blocked by Phase 6 |

**Total**: 10 phases, 69 tasks, ~44 hours

---

## Grading Impact Map

| Grade Target | Phases Required | Total Effort | Status |
|--------------|-----------------|--------------|--------|
| **Grade 5 (Pass)** | Phase 1-6 (N1) | ~22h | N1 requirements |
| **Grade 7** | Phase 1-8 (N1+N2) | ~30h | Add N2 requirements |
| **Grade 10 (Max)** | Phase 1-10 (All) | ~44h | Add N3 complexity |

---

## Implementation Strategy

### MVP Scope (Minimum Viable Project - Grade 5)
**Target**: Phases 1-6 (N1 requirements)  
**Deliverables**: Database schema + Encryption + Auditing + Identity + Masking  
**Effort**: ~22 hours  
**Risk**: LOW (all essential features, well-documented)

### Recommended Scope (Grade 7)
**Target**: Phases 1-8 (N1 + N2)  
**Deliverables**: MVP + Privileges/Roles + SQL Injection Protection  
**Effort**: ~30 hours  
**Risk**: LOW (standard security features)

### Maximum Scope (Grade 10)
**Target**: Phases 1-10 (Full implementation)  
**Deliverables**: All requirements + Advanced features + Technical report  
**Effort**: ~44 hours  
**Risk**: MEDIUM (optional advanced features may require deeper Oracle knowledge)

---

## Phase 1: Environment Setup

**Objective**: Prepare Oracle development environment and tools  
**Estimated Effort**: 1 hour  
**Blocking**: None  
**Deliverables**: Working Oracle instance, SQL scripts directory structure

### Tasks

- [ ] T001 Verify Oracle Database installation (19c or XE 21c) at development workstation
- [ ] T002 [P] Install Oracle SQL Developer or verify SQLcl is available
- [ ] T003 [P] Create project directory structure: `sql/`, `docs/`, `screenshots/`
- [ ] T004 Test database connection and verify SYSDBA access for security configuration
- [ ] T005 [P] Initialize git repository and create `.gitignore` for Oracle files (wallet, logs)

**Completion Criteria**:
- ✅ Oracle database accessible via SQL*Plus or SQL Developer
- ✅ SYSDBA access confirmed
- ✅ Project directories created
- ✅ Version control initialized

**Parallel Execution**:
Tasks T002, T003, T005 can run in parallel (different systems/configurations).

---

## Phase 2: Foundation - Database Schema (N1 - Requirement 1) 🎯 CRITICAL

**Objective**: Create complete normalized banking database schema  
**Estimated Effort**: 5 hours  
**Blocking**: All subsequent phases depend on this  
**Deliverables**: `<grupa>-<Nume>_<Prenume>-creare_inserare.sql`, ERD diagram, relational schemas

**⚠️ CRITICAL PATH**: This phase MUST be completed before any other security implementation.

### Tasks

- [ ] T006 [REQ1] Design conceptual ERD showing BANKS, BRANCHES, ACCOUNTS, TRANSACTIONS, DB_USERS, ROLES, AUDIT_LOG, USER_SESSIONS, ROLE_PRIVS entities with relationships in `docs/erd.png`
- [ ] T007 [REQ1] Document relational schemas with all attributes, primary keys, foreign keys in `docs/schemas.md`
- [ ] T008 [REQ1] Create sequence generation script for all primary keys in `sql/creare_inserare.sql`
- [ ] T009 [REQ1] Implement BANKS and BRANCHES tables with constraints in `sql/creare_inserare.sql`
- [ ] T010 [REQ1] Implement ACCOUNTS table (balance NOT encrypted yet) with constraints in `sql/creare_inserare.sql`
- [ ] T011 [REQ1] Implement TRANSACTIONS table with self-referencing FK and CHECK constraints in `sql/creare_inserare.sql`
- [ ] T012 [REQ1] Implement DB_USERS, ROLES, ROLE_PRIVS tables in `sql/creare_inserare.sql`
- [ ] T013 [REQ1] Implement AUDIT_LOG and USER_SESSIONS tables in `sql/creare_inserare.sql`
- [ ] T014 [REQ1] Create indexes for performance (ACCOUNTS.branch_id, TRANSACTIONS.from_account_id, etc.) in `sql/creare_inserare.sql`
- [ ] T015 [REQ1] Generate and insert sample data: 2 banks, 3 branches, 6 accounts, 10+ transactions, 6 users in `sql/creare_inserare.sql`

**Completion Criteria**:
- ✅ All 9 tables created without errors
- ✅ All foreign key constraints validated
- ✅ Minimum 20 sample records per major table
- ✅ All CHECK constraints tested (attempt to violate each one)
- ✅ ERD diagram exported and saved
- ✅ Can query all tables successfully

**Parallel Execution**:
Tasks T009-T013 can be developed in parallel (different tables), but must be executed sequentially due to foreign key dependencies. Final execution order: BANKS → BRANCHES → DB_USERS → ACCOUNTS → TRANSACTIONS → ROLES → ROLE_PRIVS → AUDIT_LOG → USER_SESSIONS.

**Testing Checklist**:
```sql
-- Verify all tables created
SELECT table_name FROM user_tables ORDER BY table_name;

-- Verify row counts
SELECT 'BANKS', COUNT(*) FROM BANKS UNION ALL
SELECT 'BRANCHES', COUNT(*) FROM BRANCHES UNION ALL
SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS;

-- Test constraint violations
INSERT INTO ACCOUNTS (balance) VALUES (-100);  -- Should fail (CHK_BALANCE_NON_NEGATIVE)
INSERT INTO TRANSACTIONS (from_account_id, to_account_id) VALUES (1001, 1001);  -- Should fail (CHK_NO_SELF_TRANSFER)
```

---

## Phase 3: Data Protection - Encryption (N1 - Requirement 2) 🎯 HIGH

**Objective**: Encrypt ACCOUNTS.BALANCE column using TDE or DBMS_CRYPTO  
**Estimated Effort**: 4 hours  
**Blocking**: Depends on Phase 2 (schema must exist)  
**Deliverables**: `<grupa>-<Nume>_<Prenume>-criptare.sql`, wallet backup, encryption verification screenshots

### Tasks

- [ ] T016 [REQ2] Configure Oracle Wallet for TDE: create wallet directory and initialize with `mkstore` command
- [ ] T017 [REQ2] Update `sqlnet.ora` with ENCRYPTION_WALLET_LOCATION parameter pointing to wallet directory
- [ ] T018 [REQ2] Open wallet and set TDE master encryption key in `sql/criptare.sql`
- [ ] T019 [REQ2] Apply column encryption to ACCOUNTS.BALANCE using `ALTER TABLE ... MODIFY (balance ENCRYPT USING 'AES256')` in `sql/criptare.sql`
- [ ] T020 [REQ2] Create fallback DBMS_CRYPTO implementation with encryption/decryption procedures in `sql/criptare_fallback.sql` (if TDE unavailable)
- [ ] T021 [REQ2] Test encrypted storage by querying raw data as SYSDBA and verify gibberish in `sql/criptare.sql`
- [ ] T022 [REQ2] Test decryption by querying as authorized user (BANK_SCHEMA) and verify plaintext balance in `sql/criptare.sql`

**Completion Criteria**:
- ✅ BALANCE column encrypted at rest (verify with DBA_ENCRYPTED_COLUMNS)
- ✅ Authorized users see decrypted plaintext values
- ✅ Unauthorized users cannot read plaintext (see encrypted bytes or error)
- ✅ Wallet backed up to safe location
- ✅ Screenshots: encrypted storage vs decrypted query results

**Parallel Execution**:
Tasks T016-T017 (wallet setup) can run parallel to T020 (fallback development).

**Testing Checklist**:
```sql
-- Verify encryption
SELECT table_name, column_name, encryption_alg 
FROM USER_ENCRYPTED_COLUMNS 
WHERE table_name = 'ACCOUNTS';

-- Test decryption
CONNECT BANK_SCHEMA/password
SELECT account_id, balance FROM ACCOUNTS;  -- Should see plaintext

-- View encrypted storage (SYSDBA only)
CONNECT sys AS SYSDBA
SELECT DUMP(balance, 16) FROM BANK_SCHEMA.ACCOUNTS WHERE account_id = 1001;  -- Should see hex gibberish
```

---

## Phase 4: Audit Trail - Database Auditing (N1 - Requirement 3) 🎯 HIGH

**Objective**: Implement three-layer auditing (Standard + FGA + Triggers)  
**Estimated Effort**: 5 hours  
**Blocking**: Depends on Phase 2 (tables must exist)  
**Deliverables**: `<grupa>-<Nume>_<Prenume>-audit.sql`, audit configuration, query scripts

### Tasks

- [ ] T023 [REQ3] Enable database-wide auditing: set AUDIT_TRAIL=DB,EXTENDED in init parameters in `sql/audit.sql`
- [ ] T024 [REQ3] Configure standard auditing for sessions, DDL, and DML on ACCOUNTS/TRANSACTIONS in `sql/audit.sql`
- [ ] T025 [REQ3] Create Fine-Grained Audit (FGA) policy for BALANCE column access using DBMS_FGA.ADD_POLICY in `sql/audit.sql`
- [ ] T026 [REQ3] Implement custom audit trigger TRG_AUDIT_TRANSACTIONS capturing INSERT/UPDATE/DELETE with old/new values in `sql/audit.sql`
- [ ] T027 [REQ3] Implement custom audit trigger TRG_AUDIT_ACCOUNTS for account modifications in `sql/audit.sql`
- [ ] T028 [REQ3] Create audit trail query scripts for DBA_AUDIT_TRAIL, DBA_FGA_AUDIT_TRAIL, AUDIT_LOG in `sql/audit_queries.sql`
- [ ] T029 [REQ3] Test all three audit layers: perform transactions and verify logs in `sql/audit.sql`
- [ ] T030 [REQ3] Create audit analysis queries: failed logins, suspicious patterns, high-value transactions in `sql/audit_queries.sql`
- [ ] T031 [REQ3] Protect AUDIT_LOG table: create trigger preventing UPDATE/DELETE on audit records in `sql/audit.sql`

**Completion Criteria**:
- ✅ All login attempts logged (DBA_AUDIT_TRAIL)
- ✅ All BALANCE column access logged (DBA_FGA_AUDIT_TRAIL)
- ✅ All TRANSACTIONS DML logged with old/new values (AUDIT_LOG)
- ✅ No gaps in audit trail (continuous timestamp sequence)
- ✅ Audit logs queryable by date, user, action type
- ✅ AUDIT_LOG table is immutable (trigger prevents modification)

**Parallel Execution**:
Tasks T024 (standard audit), T025 (FGA), T026-T027 (triggers) are independent and can be developed in parallel.

**Testing Checklist**:
```sql
-- Generate test activity
INSERT INTO TRANSACTIONS VALUES (...);
UPDATE ACCOUNTS SET balance = balance + 100 WHERE account_id = 1001;
SELECT balance FROM ACCOUNTS WHERE account_id = 1001;

-- Verify standard audit
SELECT username, timestamp, action_name, obj_name 
FROM DBA_AUDIT_TRAIL 
WHERE owner = 'BANK_SCHEMA' AND timestamp >= SYSDATE - 1;

-- Verify FGA
SELECT db_user, timestamp, sql_text 
FROM DBA_FGA_AUDIT_TRAIL 
WHERE object_schema = 'BANK_SCHEMA';

-- Verify custom audit
SELECT * FROM AUDIT_LOG ORDER BY audit_timestamp DESC;
```

---

## Phase 5: Identity Management - Users & Resources (N1 - Requirement 4) 🎯 HIGH

**Objective**: Implement identity management with resource quotas and access matrices  
**Estimated Effort**: 4 hours  
**Blocking**: Depends on Phase 2 (tables must exist)  
**Deliverables**: `<grupa>-<Nume>_<Prenume>-gestiune_identitati_resurse_comp.sql`, three matrices in project document

### Tasks

- [ ] T032 [REQ4] Document Process-User matrix showing which users perform which business processes in `docs/matrices.md`
- [ ] T033 [REQ4] Document Entity-Process matrix showing which processes access which entities in `docs/matrices.md`
- [ ] T034 [REQ4] Document Entity-User matrix showing which users access which entities in `docs/matrices.md`
- [ ] T035 [REQ4] Create TELLER_PROFILE with session limits, CPU quota, connect time, idle timeout in `sql/gestiune_identitati_resurse_comp.sql`
- [ ] T036 [REQ4] Create MANAGER_PROFILE with elevated limits in `sql/gestiune_identitati_resurse_comp.sql`
- [ ] T037 [REQ4] Create AUDITOR_PROFILE and DBA_PROFILE in `sql/gestiune_identitati_resurse_comp.sql`
- [ ] T038 [REQ4] Create Oracle users (TELLER_01, TELLER_02, MANAGER_01, AUDITOR_01) with appropriate profiles in `sql/gestiune_identitati_resurse_comp.sql`
- [ ] T039 [REQ4] Test resource quota enforcement: exceed session limit and capture error in `sql/gestiune_identitati_resurse_comp.sql`

**Completion Criteria**:
- ✅ All three matrices documented with clear formatting
- ✅ Minimum 4 profiles created (Teller, Manager, Auditor, DBA)
- ✅ Minimum 4 Oracle users created with assigned profiles
- ✅ Resource quotas enforced (demonstrate SESSIONS_PER_USER exceeded)
- ✅ Each matrix accurately reflects security design

**Parallel Execution**:
Tasks T032-T034 (documentation) can run parallel to T035-T037 (profile creation).

**Testing Checklist**:
```sql
-- Verify profiles
SELECT profile, resource_name, limit 
FROM DBA_PROFILES 
WHERE profile IN ('TELLER_PROFILE', 'MANAGER_PROFILE', 'AUDITOR_PROFILE')
ORDER BY profile, resource_name;

-- Verify users
SELECT username, profile, account_status 
FROM DBA_USERS 
WHERE username LIKE '%TELLER%' OR username LIKE '%MANAGER%' OR username LIKE '%AUDITOR%';

-- Test quota exceeded
-- Open 3 sessions as TELLER_01 (limit is 2)
-- Third session should fail with ORA-02391: exceeded simultaneous SESSIONS_PER_USER limit
```

---

## Phase 6: Data Privacy - Data Masking (N1 - Requirement 7) 🎯 HIGH

**Objective**: Mask account numbers for unauthorized users  
**Estimated Effort**: 3 hours  
**Blocking**: Depends on Phase 2 (ACCOUNTS table), Phase 5 (user roles)  
**Deliverables**: `<grupa>-<Nume>_<Prenume>-mascare_date.sql`, masking function, masked view

### Tasks

- [ ] T040 [REQ7] Create MASK_ACCOUNT_NUMBER function checking for UNMASK_ACCOUNT_ROLE in `sql/mascare_date.sql`
- [ ] T041 [REQ7] Implement masking logic: return 'XXXX-XXXX-XXXX-[last 4 digits]' for unauthorized users in `sql/mascare_date.sql`
- [ ] T042 [REQ7] Create V_ACCOUNTS_MASKED view applying masking function to account_number column in `sql/mascare_date.sql`
- [ ] T043 [REQ7] Create UNMASK_ACCOUNT_ROLE and grant to MANAGER_ROLE in `sql/mascare_date.sql`
- [ ] T044 [REQ7] Grant SELECT on V_ACCOUNTS_MASKED to TELLER_ROLE (will see masked) in `sql/mascare_date.sql`
- [ ] T045 [REQ7] Test masking: query as TELLER_01 (should see XXXX-1234) and as MANAGER_01 (should see full number) in `sql/mascare_date.sql`

**Completion Criteria**:
- ✅ Tellers see masked account numbers (XXXX-XXXX-XXXX-1234)
- ✅ Managers see full account numbers (granted UNMASK_ACCOUNT_ROLE)
- ✅ Masking applied consistently (all queries through view)
- ✅ No way to bypass masking without UNMASK_ACCOUNT_ROLE privilege
- ✅ Screenshots: side-by-side comparison (teller vs manager view)

**Parallel Execution**:
Tasks T040-T041 (function) must complete before T042 (view). Tasks T043-T044 (grants) can run parallel to T040-T042.

**Testing Checklist**:
```sql
-- As TELLER_01 (should see masked)
CONNECT TELLER_01/password
SELECT account_id, account_number FROM BANK_SCHEMA.V_ACCOUNTS_MASKED;
-- Expected: RO49AAAA1B31007593840001 → XXXXXXXXXXXXXXXXXXXXXX0001

-- As MANAGER_01 (should see full)
CONNECT MANAGER_01/password  
SELECT account_id, account_number FROM BANK_SCHEMA.ACCOUNTS;
-- Expected: RO49AAAA1B31007593840001 (full IBAN)

-- Verify role grants
SELECT granted_role FROM DBA_ROLE_PRIVS WHERE grantee = 'MANAGER_01';
```

---

## Phase 7: Access Control - Privileges & Roles (N2 - Requirement 5) 💎 MEDIUM

**Objective**: Implement comprehensive role-based access control with privilege hierarchies  
**Estimated Effort**: 4 hours  
**Blocking**: Depends on Phase 2 (tables), Phase 5 (users created)  
**Deliverables**: `<grupa>-<Nume>_<Prenume>-privs_roles.sql`, role hierarchy diagram

### Tasks

- [ ] T046 [REQ5] Create BASE_EMPLOYEE_ROLE with CREATE SESSION system privilege in `sql/privs_roles.sql`
- [ ] T047 [REQ5] Create TELLER_ROLE inheriting BASE_EMPLOYEE_ROLE, grant SELECT on ACCOUNTS, INSERT on TRANSACTIONS in `sql/privs_roles.sql`
- [ ] T048 [REQ5] Create SENIOR_TELLER_ROLE inheriting TELLER_ROLE with UPDATE on TRANSACTIONS in `sql/privs_roles.sql`
- [ ] T049 [REQ5] Create MANAGER_ROLE inheriting SENIOR_TELLER_ROLE with INSERT/UPDATE/DELETE on ACCOUNTS in `sql/privs_roles.sql`
- [ ] T050 [REQ5] Create AUDITOR_ROLE inheriting BASE_EMPLOYEE_ROLE with SELECT on ACCOUNTS, TRANSACTIONS, AUDIT_LOG in `sql/privs_roles.sql`
- [ ] T051 [REQ5] Create DBA_ROLE with ALL PRIVILEGES in `sql/privs_roles.sql`
- [ ] T052 [REQ5] Create dependent object (V_DAILY_TRANSACTIONS view) and demonstrate explicit grant required in `sql/privs_roles.sql`

**Completion Criteria**:
- ✅ Minimum 6 roles created (BASE_EMPLOYEE, TELLER, SENIOR_TELLER, MANAGER, AUDITOR, DBA)
- ✅ Hierarchy implemented (roles inherit from parent roles)
- ✅ System privileges granted (CREATE SESSION)
- ✅ Object privileges scoped correctly (SELECT, INSERT, UPDATE, DELETE)
- ✅ Dependent object privileges explicitly granted (view inherits nothing)
- ✅ Users cannot access objects without explicit grant
- ✅ Role hierarchy diagram created

**Parallel Execution**:
Tasks T046-T051 (role creation) are sequential due to inheritance. Task T052 (dependent object) is independent and can run parallel.

**Testing Checklist**:
```sql
-- Verify role hierarchy
SELECT granted_role, grantee 
FROM DBA_ROLE_PRIVS 
WHERE granted_role IN ('BASE_EMPLOYEE_ROLE', 'TELLER_ROLE', 'MANAGER_ROLE')
ORDER BY granted_role;

-- Verify object privileges
SELECT grantee, table_name, privilege 
FROM DBA_TAB_PRIVS 
WHERE grantee LIKE '%_ROLE'
ORDER BY grantee, table_name;

-- Test privilege inheritance
CONNECT TELLER_01/password
SELECT * FROM BANK_SCHEMA.ACCOUNTS;  -- Should succeed (has SELECT through TELLER_ROLE)
DELETE FROM BANK_SCHEMA.ACCOUNTS WHERE account_id = 1001;  -- Should fail (no DELETE privilege)
```

---

## Phase 8: Application Security - SQL Injection Protection (N2 - Requirement 6) 💎 MEDIUM

**Objective**: Demonstrate SQL injection vulnerability and protection techniques  
**Estimated Effort**: 4 hours  
**Blocking**: Depends on Phase 2 (tables), Phase 5 (application context users)  
**Deliverables**: `<grupa>-<Nume>_<Prenume>-securitate_aplicatii.sql`, vulnerable and secure procedures

### Tasks

- [ ] T053 [REQ6] Create BANK_CONTEXT application context namespace in `sql/securitate_aplicatii.sql`
- [ ] T054 [REQ6] Create SET_BANK_CONTEXT procedure to populate user session attributes in `sql/securitate_aplicatii.sql`
- [ ] T055 [REQ6] Create GET_ACCOUNT_INFO_VULN procedure with SQL injection vulnerability (concatenation) in `sql/securitate_aplicatii.sql`
- [ ] T056 [REQ6] Demonstrate SQL injection attack: inject malicious SQL through p_account_id parameter in `sql/securitate_aplicatii.sql`
- [ ] T057 [REQ6] Create GET_ACCOUNT_INFO_SECURE procedure using bind variables and strong typing in `sql/securitate_aplicatii.sql`
- [ ] T058 [REQ6] Create GET_ACCOUNT_INFO_VALIDATED procedure using application context for row-level access control in `sql/securitate_aplicatii.sql`

**Completion Criteria**:
- ✅ Application context configured (BANK_CONTEXT)
- ✅ Vulnerable procedure demonstrates successful SQL injection exploit
- ✅ Secure procedure prevents same exploit (bind variables)
- ✅ Context-validated procedure enforces row-level security
- ✅ Minimum 3 SQL injection patterns tested (UNION, comment injection, boolean-based)
- ✅ Screenshots: successful attack vs blocked attack

**Parallel Execution**:
Tasks T053-T054 (context setup) must complete before T058 (validated procedure). Tasks T055-T057 (procedure creation) are independent.

**Testing Checklist**:
```sql
-- Test SQL injection attack on vulnerable procedure
EXEC GET_ACCOUNT_INFO_VULN('1 UNION SELECT PASSWORD FROM DBA_USERS WHERE USERNAME=''SYS''');
-- Should expose sensitive data (attack succeeds)

-- Test same attack on secure procedure
EXEC GET_ACCOUNT_INFO_SECURE(1);  -- Normal use works
EXEC GET_ACCOUNT_INFO_SECURE('1 UNION SELECT PASSWORD...');  -- Should fail (type mismatch)

-- Test application context
EXEC SET_BANK_CONTEXT(101, 1);  -- Set teller context
SELECT SYS_CONTEXT('BANK_CONTEXT', 'USER_BRANCH') FROM DUAL;  -- Should return 1
EXEC GET_ACCOUNT_INFO_VALIDATED(1001);  -- Should succeed (same branch)
EXEC GET_ACCOUNT_INFO_VALIDATED(1004);  -- Should fail (different branch)
```

---

## Phase 9: Complexity Enhancements (N3 - Optional) 🌟 BONUS

**Objective**: Implement advanced security features for maximum grade  
**Estimated Effort**: 8 hours  
**Blocking**: Depends on Phase 2 (tables), Phase 6 (masking completed)  
**Deliverables**: Advanced SQL scripts, technical report (optional)

### Tasks

- [ ] T059 [N3] Implement row-level security using VPD: create BRANCH_SECURITY_POLICY function in `sql/complexity_vpd.sql`
- [ ] T060 [N3] Apply VPD policy to ACCOUNTS table using DBMS_RLS.ADD_POLICY in `sql/complexity_vpd.sql`
- [ ] T061 [N3] Implement tablespace-level encryption: create SECURE_DATA tablespace with encryption in `sql/complexity_tablespace.sql`
- [ ] T062 [N3] Move sensitive tables (ACCOUNTS, TRANSACTIONS) to encrypted tablespace in `sql/complexity_tablespace.sql`
- [ ] T063 [N3] Create complex audit analysis queries: detect failed login patterns, unusual transactions, data access anomalies in `sql/complexity_audit_analytics.sql`
- [ ] T064 [N3] Develop original security scenario: time-based access restrictions or geolocation checks in `sql/complexity_custom.sql`

**Completion Criteria**:
- ✅ VPD policy enforces branch isolation (tellers see only their branch)
- ✅ Tablespace encryption configured and verified
- ✅ Audit analytics queries produce actionable insights
- ✅ Original scenario demonstrates creative security thinking
- ✅ All advanced features documented with rationale

**Parallel Execution**:
Tasks T059-T060 (VPD), T061-T062 (tablespace), T063 (analytics), T064 (custom) are independent and can run in parallel.

**Testing Checklist**:
```sql
-- Test VPD policy
CONNECT TELLER_01/password
SELECT COUNT(*) FROM BANK_SCHEMA.ACCOUNTS;  -- Should see only branch 1 accounts

CONNECT TELLER_02/password  
SELECT COUNT(*) FROM BANK_SCHEMA.ACCOUNTS;  -- Should see only branch 2 accounts

-- Verify tablespace encryption
SELECT tablespace_name, encrypted 
FROM DBA_TABLESPACES 
WHERE tablespace_name = 'SECURE_DATA';

-- Run audit analytics
@sql/complexity_audit_analytics.sql
-- Should identify: multiple failed logins, high-value transactions, unusual patterns
```

---

## Phase 10: Documentation & Delivery 🎯 CRITICAL

**Objective**: Complete project documentation and prepare deliverables  
**Estimated Effort**: 6 hours  
**Blocking**: Depends on completion of N1 phases (minimum) or all phases (maximum)  
**Deliverables**: Project document (PDF/DOCX), all SQL scripts, screenshots

### Tasks

- [ ] T065 [DOC] Compile all SQL scripts with proper file naming: `<grupa>-<Nume>_<Prenume>-<tipo>.txt`
- [ ] T066 [DOC] Create project document: Introduction with ERD, schemas, security rules in `docs/<grupa>-<Nume>_<Prenume>-proiect.docx`
- [ ] T067 [DOC] Document each requirement (2-7) with explanation, SQL code, and screenshots in project document
- [ ] T068 [DOC] Add three access matrices (Process-User, Entity-Process, Entity-User) to project document
- [ ] T069 [DOC] Prepare presentation: select 2-3 key demonstrations, highlight complexity, practice timing (10 min)

**Completion Criteria**:
- ✅ All SQL files named correctly per course specification
- ✅ Project document includes all requirements with screenshots
- ✅ SQL code embedded as text (not just images)
- ✅ All deliverables under 50MB total size
- ✅ Presentation ready (10 minutes, live demo prepared)
- ✅ Files uploaded 7 days before exam date

**Parallel Execution**:
Tasks T066-T068 (documentation) can be written in parallel. Task T065 (file naming) must complete first.

**Documentation Checklist**:
- [ ] Introduction section complete (ERD, schemas, security overview)
- [ ] Requirement 1: Schema creation documented
- [ ] Requirement 2: Encryption documented with screenshots
- [ ] Requirement 3: Auditing documented with screenshots
- [ ] Requirement 4: Identity management with matrices
- [ ] Requirement 7: Masking documented with screenshots
- [ ] Requirement 5: Privileges/roles documented (if N2) with screenshots
- [ ] Requirement 6: SQL injection documented (if N2) with screenshots
- [ ] Complexity section documented (if N3)
- [ ] All SQL code embedded as text
- [ ] File naming verified

---

## Dependency Graph

### Critical Path (Must be sequential)
```
Phase 1 (Setup)
    ↓
Phase 2 (Schema) ← BLOCKING FOR ALL OTHERS
    ↓
Phase 3-6 (N1 Requirements) ← Can run in parallel
    ↓
Phase 10 (Documentation)
```

### Detailed Dependencies
```
T001-T005 (Setup) → Foundation for all work
    ↓
T006-T015 (Schema) → BLOCKS everything
    ├→ T016-T022 (Encryption)
    ├→ T023-T031 (Auditing)
    ├→ T032-T039 (Identity Management)
    ├→ T040-T045 (Masking - also needs T032-T039)
    ├→ T046-T052 (Privileges - needs T032-T039)
    ├→ T053-T058 (SQL Injection)
    └→ T059-T064 (Complexity - needs T040-T045)
        ↓
    T065-T069 (Documentation)
```

### Parallelization Opportunities

**After Phase 2 completes, these can run in parallel:**
- Phase 3 (Encryption) - independent
- Phase 4 (Auditing) - independent  
- Phase 5 (Identity Management) - independent
- Phase 8 (SQL Injection) - independent

**After Phase 5 completes:**
- Phase 6 (Masking) - needs users from Phase 5
- Phase 7 (Privileges) - needs users from Phase 5

**After Phase 6 completes:**
- Phase 9 (Complexity) - needs masking from Phase 6

---

## Incremental Delivery Plan

### Week 1: Foundation + Encryption
**Goal**: Database schema + TDE encryption  
**Tasks**: T001-T022  
**Deliverable**: Working database with encrypted balances  
**Risk**: LOW

### Week 2: Auditing + Identity
**Goal**: Complete audit trail + user management  
**Tasks**: T023-T039  
**Deliverable**: Comprehensive logging + resource quotas  
**Risk**: LOW

### Week 3: Masking + Privileges (N1→N2 Transition)
**Goal**: Data masking + RBAC  
**Tasks**: T040-T052  
**Deliverable**: Complete N1, start N2  
**Risk**: LOW

### Week 4: SQL Injection + Documentation
**Goal**: SQL injection protection + deliverables  
**Tasks**: T053-T069 (skip T059-T064 if time constrained)  
**Deliverable**: Complete N1+N2 project  
**Risk**: MEDIUM (time pressure)

### Week 5 (Optional): Complexity + Polish
**Goal**: Advanced features for N3  
**Tasks**: T059-T064 + final polish  
**Deliverable**: Maximum grade potential  
**Risk**: LOW (bonus only)

---

## Testing Strategy

### Per-Phase Testing
Each phase includes inline testing checklist for immediate validation.

### Integration Testing (After Phase 6)
```sql
-- End-to-end scenario 1: Teller transaction processing
CONNECT TELLER_01/password
EXEC SET_BANK_CONTEXT(101, 1);
SELECT account_number, balance FROM BANK_SCHEMA.V_ACCOUNTS_MASKED WHERE branch_id = 1;  -- See masked, decrypted
INSERT INTO BANK_SCHEMA.TRANSACTIONS VALUES (...);  -- Record transaction
-- Verify: Transaction logged in AUDIT_LOG

-- End-to-end scenario 2: Manager account creation
CONNECT MANAGER_01/password
INSERT INTO BANK_SCHEMA.ACCOUNTS VALUES (...);  -- Create account
SELECT account_number FROM BANK_SCHEMA.ACCOUNTS;  -- See unmasked
-- Verify: Account created, balance encrypted, action audited

-- End-to-end scenario 3: Auditor review
CONNECT AUDITOR_01/password
SELECT * FROM BANK_SCHEMA.AUDIT_LOG ORDER BY audit_timestamp DESC;  -- Review logs
SELECT * FROM DBA_AUDIT_TRAIL WHERE owner = 'BANK_SCHEMA';  -- Standard audit
-- Verify: Complete audit trail visible, no write access
```

### Acceptance Testing (Before Submission)
- [ ] Run all SQL scripts on fresh database instance
- [ ] Verify all screenshots match current implementation
- [ ] Confirm all file names follow naming convention
- [ ] Test all demonstrations that will be shown at exam
- [ ] Validate project document completeness
- [ ] Ensure total file size < 50MB

---

## Risk Mitigation

### High-Priority Risks

**Risk 1: TDE Not Available (Oracle XE Limitation)**
- **Impact**: Cannot complete Requirement 2 as designed
- **Mitigation**: Use DBMS_CRYPTO fallback (Task T020 already includes this)
- **Contingency**: Document limitation, show DBMS_CRYPTO as alternative

**Risk 2: Insufficient SYSDBA Privileges**
- **Impact**: Cannot configure auditing or TDE
- **Mitigation**: Use personal Oracle installation or Docker container with full control
- **Contingency**: Work with instructor to get necessary privileges

**Risk 3: Time Pressure for N3 Features**
- **Impact**: Cannot achieve maximum grade (Grade 10)
- **Mitigation**: Focus on N1+N2 first (ensures Grade 7), add N3 only if time permits
- **Contingency**: N3 is optional - Grade 7 is excellent outcome

### Medium-Priority Risks

**Risk 4: Audit Log Growth**
- **Impact**: Database performance degradation
- **Mitigation**: Include audit purge procedure in deliverables
- **Contingency**: Demo environment - not a real concern

**Risk 5: Complex VPD Policy Debugging**
- **Impact**: Time spent debugging row-level security
- **Mitigation**: Start with simple predicate, test incrementally
- **Contingency**: VPD is N3 (optional) - can skip if problematic

---

## Progress Tracking

### Task Status Legend
- ⬜ Not Started
- 🟦 In Progress
- ✅ Complete
- ⏸️ Blocked (waiting on dependency)
- ⚠️ Issue (requires attention)

### Milestone Checklist

- [ ] **Milestone 1**: Database schema created and populated (Phase 2 complete)
- [ ] **Milestone 2**: N1 requirements complete (Phases 2-6 complete) → **Grade 5 achievable**
- [ ] **Milestone 3**: N2 requirements complete (Phases 7-8 complete) → **Grade 7 achievable**
- [ ] **Milestone 4**: N3 complexity complete (Phase 9 complete) → **Grade 10 achievable**
- [ ] **Milestone 5**: Documentation complete (Phase 10 complete) → **Ready for submission**

### Weekly Progress Report Template

```markdown
## Week [N] Progress Report

**Completed**: [List task IDs]  
**In Progress**: [List task IDs]  
**Blocked**: [List task IDs with blocker description]  
**Next Week**: [Planned task IDs]  

**Issues**:
- [Describe any problems encountered]

**Decisions**:
- [Document any technical decisions made]

**Screenshots Captured**:
- [List screenshots taken this week]
```

---

## Next Steps

### Option 1: Start Implementation
Begin with Phase 1 (Setup) and proceed sequentially through tasks.

```bash
# Create working directory
mkdir -p ~/banking-security-project/{sql,docs,screenshots}
cd ~/banking-security-project

# Start with T001
sqlplus / as sysdba
```

### Option 2: Validate Consistency
Run `/speckit analyze` to check cross-artifact consistency before implementation.

### Option 3: Generate Additional Checklists
Run `/speckit checklist` to create requirements quality validation checklists.

---

**Status**: 🟢 **READY FOR IMPLEMENTATION**

All tasks defined with clear acceptance criteria. Start with MVP scope (Phases 1-6) for guaranteed passing grade, then expand to N2 and N3 as time permits.

---

*Task breakdown generated: 2026-04-04*
*Total tasks: 69 | Estimated effort: 44 hours | Phases: 10*
