# Implementation Plan: Oracle Database Security for Banking Transactions

**Feature ID**: 001-oracle-db-security  
**Plan Created**: 2026-04-04  
**Status**: Ready for Implementation  
**Target**: Oracle Database 19c+

---

## Technical Context

### Technology Stack
- **Database**: Oracle Database 19c or higher (XE for development acceptable)
- **Tools**: SQL*Plus, Oracle SQL Developer, or SQLcl
- **Languages**: SQL, PL/SQL
- **Security Features**:
  - Transparent Data Encryption (TDE) or DBMS_CRYPTO package
  - Oracle Auditing (Standard, FGA, Triggers)
  - Virtual Private Database (VPD) for row-level security
  - Oracle Application Context
  - Oracle Data Redaction or custom masking functions

### Development Environment
- **Oracle XE 21c** (free edition) or **Oracle 19c** (licensed)
- SQL client: SQL Developer 21.x or SQLcl
- Text editor for SQL script development
- Git for version control

### Key Technical Decisions
1. **Encryption Method**: Use TDE for column encryption (preferred) with fallback to DBMS_CRYPTO if TDE not available
2. **Audit Approach**: Combination of standard auditing + FGA + custom triggers for comprehensive coverage
3. **Masking Strategy**: Custom PL/SQL function + views for flexibility
4. **Access Control**: Role-based with VPD policies for row-level security
5. **SQL Injection Protection**: Bind variables + application context validation

---

## Constitution Check

### Pre-Design Constitution Review
No project constitution file exists yet. Proceeding with standard database security principles:

**Core Principles Applied:**
- ✅ **Least Privilege**: Users granted only necessary permissions
- ✅ **Defense in Depth**: Multiple security layers (encryption + audit + access control)
- ✅ **Auditability**: All security-relevant actions logged
- ✅ **Data Minimization**: Masking reduces exposure of sensitive data
- ✅ **Fail Secure**: Access denied by default, granted explicitly

**Gates:**
- No constitutional violations identified
- Standard security best practices applied throughout

---

## Phase 0: Research & Technical Decisions

**Status**: ✅ COMPLETED  
**Output**: [research.md](./research.md)

### Research Questions Resolved:
1. **TDE vs DBMS_CRYPTO** → Decision: TDE preferred (see research.md)
2. **Auditing Strategy** → Decision: Hybrid approach (see research.md)
3. **Masking Implementation** → Decision: Custom functions + views (see research.md)
4. **VPD vs Context** → Decision: Both, context for VPD policies (see research.md)
5. **Key Management** → Decision: Oracle Wallet for TDE (see research.md)

All technical unknowns resolved. Ready for Phase 1 design.

---

## Phase 1: Design & Contracts

**Status**: ✅ COMPLETED  
**Outputs**: 
- [data-model.md](./data-model.md) - Complete entity-relationship model
- [quickstart.md](./quickstart.md) - Implementation scenarios
- No external contracts needed (internal database project)

---

## Implementation Roadmap

### Phase 1: Foundation - Database Schema (N1 - Requirement 1) 🎯 CRITICAL

**Objective**: Create normalized, production-ready banking database schema

**Design Artifacts**:
- Conceptual ERD (entities, relationships, cardinalities)
- Relational schema with all constraints
- CREATE TABLE scripts with foreign keys
- Sample data generation scripts

**Tables to Create**:
1. **BANKS** - Bank master data
2. **ACCOUNTS** - Customer accounts with encrypted balance
3. **TRANSACTIONS** - Transaction history
4. **DB_USERS** - Application users (not Oracle users, metadata)
5. **AUDIT_LOG** - Custom audit trail
6. **USER_SESSIONS** - Session tracking for context

**Deliverables**:
- `001-<grupa>-<Nume>_<Prenume>-creare_inserare.sql`
- ERD diagram (PNG/PDF embedded in project document)
- Relational schema documentation

**Success Criteria**:
- All tables created without errors
- Foreign key constraints validated
- Sample data inserted successfully (minimum 20 records per table)
- All constraints tested (NOT NULL, CHECK, UNIQUE, FK)

**Estimated Effort**: 4-6 hours

---

### Phase 2: Data Protection - Encryption (N1 - Requirement 2) 🎯 HIGH

**Objective**: Encrypt sensitive account balance data

**Encryption Strategy**:
```sql
-- Option A: TDE Column Encryption (PREFERRED)
ALTER TABLE ACCOUNTS MODIFY (BALANCE ENCRYPT USING 'AES256');

-- Option B: DBMS_CRYPTO (if TDE unavailable)
-- Use DBMS_CRYPTO.ENCRYPT/DECRYPT in triggers
```

**Implementation Steps**:
1. **Setup**: Configure Oracle Wallet for TDE keys
2. **Encrypt**: Apply encryption to ACCOUNTS.BALANCE column
3. **Test**: Verify encrypted storage (query raw data)
4. **Grant**: Provide decryption privilege to authorized roles
5. **Document**: Key management procedures

**Key Management**:
- Create Oracle Wallet: `mkstore -wrl /path/to/wallet -create`
- Set ENCRYPTION_WALLET_LOCATION in sqlnet.ora
- Backup wallet regularly

**Deliverables**:
- `002-<grupa>-<Nume>_<Prenume>-criptare.sql`
- Screenshots showing encrypted vs decrypted data
- Wallet backup documentation

**Success Criteria**:
- BALANCE column encrypted at rest
- Authorized users can read decrypted values
- Unauthorized users see encrypted gibberish or get errors
- Encryption keys backed up securely

**Estimated Effort**: 3-4 hours

---

### Phase 3: Audit Trail - Database Auditing (N1 - Requirement 3) 🎯 HIGH

**Objective**: Comprehensive auditing of all database activities

**Three-Layer Audit Approach**:

#### Layer 1: Standard Oracle Auditing
```sql
-- Enable auditing
AUDIT SESSION BY ACCESS;
AUDIT SELECT ON ACCOUNTS BY ACCESS;
AUDIT INSERT, UPDATE, DELETE ON TRANSACTIONS BY ACCESS;
AUDIT CREATE TABLE, DROP TABLE BY ACCESS;
```

**Logs To**: DBA_AUDIT_TRAIL (system audit trail)

#### Layer 2: Fine-Grained Auditing (FGA)
```sql
-- Audit access to encrypted balance column
BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'BANK_SCHEMA',
    object_name     => 'ACCOUNTS',
    policy_name     => 'AUDIT_BALANCE_ACCESS',
    audit_column    => 'BALANCE',
    enable          => TRUE
  );
END;
```

**Logs To**: DBA_FGA_AUDIT_TRAIL

#### Layer 3: Custom Audit Triggers
```sql
-- Capture old/new values for TRANSACTIONS
CREATE OR REPLACE TRIGGER TRG_AUDIT_TRANSACTIONS
AFTER INSERT OR UPDATE OR DELETE ON TRANSACTIONS
FOR EACH ROW
BEGIN
  INSERT INTO AUDIT_LOG (
    audit_timestamp,
    username,
    action_type,
    table_name,
    old_value,
    new_value
  ) VALUES (
    SYSTIMESTAMP,
    USER,
    CASE WHEN INSERTING THEN 'INSERT'
         WHEN UPDATING THEN 'UPDATE'
         WHEN DELETING THEN 'DELETE'
    END,
    'TRANSACTIONS',
    -- old/new values as JSON or concatenated string
  );
END;
```

**Logs To**: Custom AUDIT_LOG table

**Deliverables**:
- `003-<grupa>-<Nume>_<Prenume>-audit.sql`
- Audit configuration scripts
- Query scripts to analyze audit data
- Screenshots of audit trail

**Success Criteria**:
- All login attempts logged (successful and failed)
- All DML on TRANSACTIONS logged with old/new values
- All access to BALANCE column logged
- Audit logs queryable by date, user, action
- No gaps in audit trail

**Estimated Effort**: 4-5 hours

---

### Phase 4: Identity Management - Users & Resources (N1 - Requirement 4) 🎯 HIGH

**Objective**: Design and implement identity and resource management

**Process-User Matrix**:
| Process | Teller | Manager | Auditor | DBA |
|---------|--------|---------|---------|-----|
| Create Account | ❌ | ✅ | ❌ | ✅ |
| View Balance | ✅ | ✅ | ✅ | ✅ |
| Process Transaction | ✅ | ✅ | ❌ | ✅ |
| View Audit Logs | ❌ | ❌ | ✅ | ✅ |
| Manage Users | ❌ | ❌ | ❌ | ✅ |

**Entity-Process Matrix**:
| Entity | Create Account | Process Transaction | View Audit | Manage Users |
|--------|----------------|---------------------|------------|--------------|
| BANKS | ❌ | ❌ | ✅ | ❌ |
| ACCOUNTS | ✅ | ✅ | ✅ | ❌ |
| TRANSACTIONS | ❌ | ✅ | ✅ | ❌ |
| AUDIT_LOG | ❌ | ❌ | ✅ | ❌ |
| DB_USERS | ❌ | ❌ | ❌ | ✅ |

**Entity-User Matrix**:
| Entity | Teller | Manager | Auditor | DBA |
|--------|--------|---------|---------|-----|
| BANKS | SELECT | SELECT | SELECT | ALL |
| ACCOUNTS | SELECT, UPDATE | ALL | SELECT | ALL |
| TRANSACTIONS | INSERT, SELECT | ALL | SELECT | ALL |
| AUDIT_LOG | ❌ | ❌ | SELECT | ALL |
| DB_USERS | ❌ | ❌ | ❌ | ALL |

**Resource Quotas Implementation**:
```sql
-- Create profile for tellers
CREATE PROFILE TELLER_PROFILE LIMIT
  SESSIONS_PER_USER 2
  CPU_PER_SESSION 60000  -- 60 seconds
  CONNECT_TIME 480        -- 8 hours
  IDLE_TIME 30;           -- 30 minutes

-- Create profile for managers
CREATE PROFILE MANAGER_PROFILE LIMIT
  SESSIONS_PER_USER 3
  CPU_PER_SESSION UNLIMITED
  CONNECT_TIME 600        -- 10 hours
  IDLE_TIME 60;

-- Create users with profiles
CREATE USER TELLER_01 IDENTIFIED BY password
  PROFILE TELLER_PROFILE;
```

**Deliverables**:
- `004-<grupa>-<Nume>_<Prenume>-gestiune_identitati_resurse_comp.sql`
- Three matrices documented in project document
- User creation scripts with profiles
- Resource quota demonstration

**Success Criteria**:
- All three matrices documented clearly
- Minimum 4 user profiles created
- Resource quotas enforced (demonstrate quota exceeded error)
- Users assigned to appropriate profiles

**Estimated Effort**: 3-4 hours

---

### Phase 5: Data Privacy - Data Masking (N1 - Requirement 7) 🎯 HIGH

**Objective**: Mask sensitive account numbers for unauthorized users

**Masking Strategy**:

#### Approach 1: Masking Function
```sql
CREATE OR REPLACE FUNCTION MASK_ACCOUNT_NUMBER(
  p_account_number VARCHAR2
) RETURN VARCHAR2 IS
  v_has_privilege NUMBER;
BEGIN
  -- Check if user has UNMASK_ACCOUNT privilege
  SELECT COUNT(*) INTO v_has_privilege
  FROM SESSION_PRIVS
  WHERE PRIVILEGE = 'UNMASK_ACCOUNT';
  
  IF v_has_privilege > 0 THEN
    RETURN p_account_number;
  ELSE
    RETURN 'XXXX-XXXX-XXXX-' || SUBSTR(p_account_number, -4);
  END IF;
END;
/

-- Create view with masking
CREATE OR REPLACE VIEW V_ACCOUNTS_MASKED AS
SELECT 
  ACCOUNT_ID,
  MASK_ACCOUNT_NUMBER(ACCOUNT_NUMBER) AS ACCOUNT_NUMBER,
  ACCOUNT_TYPE,
  BALANCE,
  OPENING_DATE
FROM ACCOUNTS;
```

#### Approach 2: Oracle Data Redaction (if available)
```sql
BEGIN
  DBMS_REDACT.ADD_POLICY(
    object_schema => 'BANK_SCHEMA',
    object_name   => 'ACCOUNTS',
    policy_name   => 'MASK_ACCOUNT_POLICY',
    column_name   => 'ACCOUNT_NUMBER',
    function_type => DBMS_REDACT.PARTIAL,
    function_parameters => '1,1,X,12,16',  -- Show last 4 digits
    expression    => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') NOT IN (''MANAGER'',''DBA'')'
  );
END;
```

**Privilege Management**:
```sql
-- Create system privilege for unmasking
CREATE ROLE UNMASK_ACCOUNT_ROLE;
GRANT SELECT ON ACCOUNTS TO UNMASK_ACCOUNT_ROLE;

-- Grant to managers
GRANT UNMASK_ACCOUNT_ROLE TO MANAGER_01;
```

**Deliverables**:
- `007-<grupa>-<Nume>_<Prenume>-mascare_date.sql`
- Masking function and view
- Privilege configuration
- Side-by-side screenshots (masked vs unmasked)

**Success Criteria**:
- Tellers see masked account numbers (XXXX-XXXX-XXXX-1234)
- Managers see full account numbers
- Masking applied consistently across all queries
- No way to bypass masking without privilege

**Estimated Effort**: 2-3 hours

---

### Phase 6: Access Control - Privileges & Roles (N2 - Requirement 5) 💎 MEDIUM

**Objective**: Implement comprehensive role-based access control

**Role Hierarchy**:
```
DBA_ROLE (top level)
    ↓
MANAGER_ROLE
    ↓
SENIOR_TELLER_ROLE
    ↓
TELLER_ROLE
    ↓
BASE_EMPLOYEE_ROLE
    ↓
AUDITOR_ROLE (read-only branch)
```

**System Privileges**:
```sql
-- Base privileges for all employees
CREATE ROLE BASE_EMPLOYEE_ROLE;
GRANT CREATE SESSION TO BASE_EMPLOYEE_ROLE;

-- Teller privileges
CREATE ROLE TELLER_ROLE;
GRANT BASE_EMPLOYEE_ROLE TO TELLER_ROLE;
GRANT SELECT ON ACCOUNTS TO TELLER_ROLE;
GRANT INSERT ON TRANSACTIONS TO TELLER_ROLE;

-- Manager privileges (includes teller)
CREATE ROLE MANAGER_ROLE;
GRANT TELLER_ROLE TO MANAGER_ROLE;
GRANT INSERT, UPDATE, DELETE ON ACCOUNTS TO MANAGER_ROLE;
GRANT SELECT ON AUDIT_LOG TO MANAGER_ROLE;

-- Auditor (read-only)
CREATE ROLE AUDITOR_ROLE;
GRANT BASE_EMPLOYEE_ROLE TO AUDITOR_ROLE;
GRANT SELECT ON ACCOUNTS TO AUDITOR_ROLE;
GRANT SELECT ON TRANSACTIONS TO AUDITOR_ROLE;
GRANT SELECT ON AUDIT_LOG TO AUDITOR_ROLE;

-- DBA (full control)
CREATE ROLE DBA_ROLE;
GRANT ALL PRIVILEGES TO DBA_ROLE;
```

**Object Privileges on Dependent Objects**:
```sql
-- Create view based on TRANSACTIONS
CREATE OR REPLACE VIEW V_DAILY_TRANSACTIONS AS
SELECT TRANSACTION_DATE, COUNT(*) AS TXN_COUNT, SUM(AMOUNT) AS TOTAL_AMOUNT
FROM TRANSACTIONS
GROUP BY TRANSACTION_DATE;

-- Privileges automatically don't extend to view
-- Must explicitly grant
GRANT SELECT ON V_DAILY_TRANSACTIONS TO AUDITOR_ROLE;
```

**Deliverables**:
- `005-<grupa>-<Nume>_<Prenume>-privs_roles.sql`
- Complete role hierarchy diagram
- System and object privilege grants
- Dependent object privilege demonstration

**Success Criteria**:
- Minimum 4 roles created with hierarchy
- Privilege inheritance demonstrated (junior role gets senior privileges)
- Object privileges correctly scoped
- Dependent object privileges explicitly granted
- Users cannot access objects without explicit grant

**Estimated Effort**: 3-4 hours

---

### Phase 7: Application Security - SQL Injection Protection (N2 - Requirement 6) 💎 MEDIUM

**Objective**: Demonstrate SQL injection vulnerability and protection

**Vulnerability Demonstration**:
```sql
-- VULNERABLE: Dynamic SQL without bind variables
CREATE OR REPLACE PROCEDURE GET_ACCOUNT_INFO_VULN(
  p_account_id VARCHAR2
) IS
  v_sql VARCHAR2(1000);
  v_balance NUMBER;
BEGIN
  v_sql := 'SELECT BALANCE FROM ACCOUNTS WHERE ACCOUNT_ID = ' || p_account_id;
  EXECUTE IMMEDIATE v_sql INTO v_balance;
  DBMS_OUTPUT.PUT_LINE('Balance: ' || v_balance);
END;
/

-- SQL INJECTION ATTACK:
-- Input: "1 UNION SELECT PASSWORD FROM DBA_USERS WHERE USERNAME='SYS'"
-- This would expose system passwords!
```

**Protection Implementation**:
```sql
-- SECURE: Using bind variables
CREATE OR REPLACE PROCEDURE GET_ACCOUNT_INFO_SECURE(
  p_account_id NUMBER  -- Note: Strong typing
) IS
  v_balance NUMBER;
BEGIN
  SELECT BALANCE INTO v_balance
  FROM ACCOUNTS
  WHERE ACCOUNT_ID = p_account_id;  -- Direct binding, not concatenation
  
  DBMS_OUTPUT.PUT_LINE('Balance: ' || v_balance);
END;
/

-- Even more secure: With input validation
CREATE OR REPLACE PROCEDURE GET_ACCOUNT_INFO_VALIDATED(
  p_account_id NUMBER
) IS
  v_balance NUMBER;
  v_user_branch NUMBER;
BEGIN
  -- Validate user has access to this account via application context
  v_user_branch := SYS_CONTEXT('BANK_CONTEXT', 'USER_BRANCH');
  
  SELECT BALANCE INTO v_balance
  FROM ACCOUNTS
  WHERE ACCOUNT_ID = p_account_id
    AND BRANCH_ID = v_user_branch;  -- Row-level security
  
  DBMS_OUTPUT.PUT_LINE('Balance: ' || v_balance);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20001, 'Access denied or account not found');
END;
/
```

**Application Context Setup**:
```sql
-- Create context
CREATE OR REPLACE CONTEXT BANK_CONTEXT USING SET_BANK_CONTEXT;

-- Context setter procedure
CREATE OR REPLACE PROCEDURE SET_BANK_CONTEXT(
  p_user_id NUMBER,
  p_branch_id NUMBER
) IS
BEGIN
  DBMS_SESSION.SET_CONTEXT('BANK_CONTEXT', 'USER_ID', p_user_id);
  DBMS_SESSION.SET_CONTEXT('BANK_CONTEXT', 'USER_BRANCH', p_branch_id);
END;
/

-- Call on login
EXEC SET_BANK_CONTEXT(101, 1);
```

**Deliverables**:
- `006-<grupa>-<Nume>_<Prenume>-securitate_aplicatii.sql`
- Vulnerable procedure with exploit demonstration
- Secure procedure with bind variables
- Application context configuration
- Side-by-side comparison screenshots

**Success Criteria**:
- Vulnerable code successfully exploited
- Secure code prevents same exploitation
- Application context validated in queries
- Minimum 3 SQL injection patterns tested

**Estimated Effort**: 3-4 hours

---

### Phase 8: Complexity Enhancements (N3 - Optional) 🌟 BONUS

**Objective**: Demonstrate advanced database security techniques

#### Enhancement 1: Row-Level Security with VPD
```sql
-- Create policy function
CREATE OR REPLACE FUNCTION ACCOUNT_SECURITY_POLICY(
  schema_var IN VARCHAR2,
  table_var  IN VARCHAR2
) RETURN VARCHAR2 IS
  v_branch_id NUMBER;
  v_predicate VARCHAR2(400);
BEGIN
  -- Get user's branch from context
  v_branch_id := SYS_CONTEXT('BANK_CONTEXT', 'USER_BRANCH');
  
  -- Build predicate
  v_predicate := 'BRANCH_ID = ' || v_branch_id;
  
  RETURN v_predicate;
END;
/

-- Apply VPD policy
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'BANK_SCHEMA',
    object_name     => 'ACCOUNTS',
    policy_name     => 'BRANCH_ISOLATION_POLICY',
    function_schema => 'BANK_SCHEMA',
    policy_function => 'ACCOUNT_SECURITY_POLICY',
    statement_types => 'SELECT, INSERT, UPDATE, DELETE'
  );
END;
/
```

**Effect**: Users automatically see only accounts from their branch, enforced at SQL execution level.

#### Enhancement 2: Tablespace Encryption
```sql
-- Encrypt entire tablespace
CREATE TABLESPACE SECURE_DATA
  DATAFILE '/u01/app/oracle/oradata/secure_data01.dbf'
  SIZE 100M
  ENCRYPTION USING 'AES256'
  DEFAULT STORAGE(ENCRYPT);

-- Move sensitive tables to encrypted tablespace
ALTER TABLE ACCOUNTS MOVE TABLESPACE SECURE_DATA;
```

#### Enhancement 3: Complex Audit Analysis Queries
```sql
-- Identify suspicious access patterns
SELECT 
  username,
  COUNT(*) AS failed_attempts,
  MIN(audit_timestamp) AS first_attempt,
  MAX(audit_timestamp) AS last_attempt
FROM AUDIT_LOG
WHERE action_type = 'LOGIN'
  AND success_flag = 'N'
  AND audit_timestamp >= SYSDATE - 1
GROUP BY username
HAVING COUNT(*) >= 5
ORDER BY COUNT(*) DESC;

-- Detect unusual transaction patterns
WITH hourly_stats AS (
  SELECT 
    TRUNC(txn_timestamp, 'HH24') AS hour,
    COUNT(*) AS txn_count,
    AVG(COUNT(*)) OVER (ORDER BY TRUNC(txn_timestamp, 'HH24') 
                        ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) AS avg_count
  FROM TRANSACTIONS
  GROUP BY TRUNC(txn_timestamp, 'HH24')
)
SELECT * FROM hourly_stats
WHERE txn_count > avg_count * 2;  -- More than 2x average
```

#### Enhancement 4: Original Scenarios
- **Geolocation-based access control**: Block access if IP changes country
- **Time-based restrictions**: Prevent after-hours transactions without approval
- **Transaction velocity checks**: Flag rapid successive withdrawals
- **Cascade auditing**: Audit all dependent object access when parent accessed

**Deliverables** (Optional):
- Advanced feature SQL scripts
- Technical report (abstract + bibliography + practical examples)
- Original security scenarios documentation

**Success Criteria**:
- VPD policies enforcing row-level security
- Tablespace encryption configured
- Advanced audit queries producing actionable insights
- Original scenarios demonstrating creative security thinking

**Estimated Effort**: 5-8 hours (optional)

---

## Testing Strategy

### Unit Testing (Per Phase)
Each phase must be tested independently:

1. **Schema Testing**: 
   - Insert violates constraints → expect error
   - Foreign key violations → expect error
   - Valid data → expect success

2. **Encryption Testing**:
   - Query raw storage → see encrypted bytes
   - Query with authorized user → see plaintext
   - Query with unauthorized user → see encrypted or error

3. **Audit Testing**:
   - Perform action → verify audit log entry
   - Check timestamp accuracy
   - Verify old/new values captured

4. **Access Control Testing**:
   - User without role → access denied
   - User with role → access granted
   - Test each role's permissions

5. **Masking Testing**:
   - Query as teller → see masked data
   - Query as manager → see full data
   - Attempt to unmask without privilege → fail

### Integration Testing
After all phases complete:
- End-to-end scenario: Teller creates transaction, auditor reviews logs
- Security scenario: Attempt unauthorized access, verify blocked and logged
- Performance check: Encryption/audit overhead acceptable

### Acceptance Testing
Match against success criteria from specification:
- ✅ All N1 requirements functional
- ✅ All N2 requirements functional (if implemented)
- ✅ All scenarios from spec executable
- ✅ All security controls demonstrable

---

## Risk Mitigation

### Technical Risks

**Risk 1: TDE Not Available in Oracle XE**
- **Likelihood**: High (XE has limited features)
- **Impact**: Medium (affects encryption requirement)
- **Mitigation**: Use DBMS_CRYPTO as fallback; document limitation

**Risk 2: Insufficient Privileges for Auditing Configuration**
- **Likelihood**: Medium (student account may be restricted)
- **Impact**: High (can't complete Requirement 3)
- **Mitigation**: Work with DBA or use personal Oracle instance with SYSDBA

**Risk 3: Audit Log Growth**
- **Likelihood**: High (comprehensive auditing generates volume)
- **Impact**: Low (demo environment)
- **Mitigation**: Include audit log purge procedure in deliverables

**Risk 4: Wallet Management Complexity**
- **Likelihood**: Medium
- **Impact**: Medium (lost keys = unrecoverable data)
- **Mitigation**: Document wallet backup; use simple password; keep backup in repo

### Schedule Risks

**Risk 5: Underestimating Complexity of VPD**
- **Likelihood**: Medium
- **Impact**: Medium (may not complete N3)
- **Mitigation**: Complete N1 and N2 first; VPD is bonus only

---

## Deliverables Checklist

### Required Files

#### 1. Project Document (PDF/DOCX)
**Filename**: `<grupa>-<Nume>_<Prenume>-proiect.docx`

**Contents**:
- [ ] Introduction with ERD diagram
- [ ] Relational schemas
- [ ] Security rules overview
- [ ] Requirement 2: Encryption (with screenshots)
- [ ] Requirement 3: Auditing (with screenshots)
- [ ] Requirement 4: Identity management (matrices + screenshots)
- [ ] Requirement 7: Masking (with screenshots)
- [ ] Requirement 5: Privileges & roles (with screenshots) [if N2]
- [ ] Requirement 6: SQL injection (with screenshots) [if N2]
- [ ] Complexity discussion [if N3]
- [ ] All SQL code as text (not just images)

#### 2. SQL Scripts

- [ ] `<grupa>-<Nume>_<Prenume>-creare_inserare.txt` - Schema + data
- [ ] `<grupa>-<Nume>_<Prenume>-criptare.txt` - Encryption
- [ ] `<grupa>-<Nume>_<Prenume>-audit.txt` - Auditing
- [ ] `<grupa>-<Nume>_<Prenume>-gestiune_identitati_resurse_comp.txt` - Identity mgmt
- [ ] `<grupa>-<Nume>_<Prenume>-mascare_date.txt` - Masking
- [ ] `<grupa>-<Nume>_<Prenume>-privs_roles.txt` - Privileges/roles [if N2]
- [ ] `<grupa>-<Nume>_<Prenume>-securitate_aplicatii.txt` - SQL injection [if N2]

#### 3. Optional Report (for N3)
**Filename**: `<grupa>-<Nume>_<Prenume>-referat.docx`

**Contents**:
- [ ] Abstract
- [ ] Bibliography (referenced in text)
- [ ] Practical examples
- [ ] Screenshots of advanced features

---

## Success Metrics

### Quantitative Targets
- ✅ 5+ tables in database schema
- ✅ 100% of BALANCE columns encrypted
- ✅ 100% of TRANSACTIONS DML audited
- ✅ 4+ distinct user roles
- ✅ 100% of account numbers masked for non-privileged users
- ✅ 3+ SQL injection patterns tested

### Qualitative Targets
- ✅ Code well-commented with natural language explanations
- ✅ Screenshots clearly show security features working
- ✅ Project document flows logically through requirements
- ✅ Original examples beyond laboratory work

---

## Post-Implementation

### Before Submission
1. ✅ Run all SQL scripts fresh on clean database
2. ✅ Capture all screenshots
3. ✅ Embed screenshots in project document
4. ✅ Embed SQL code as text (not images) in document
5. ✅ Name all files correctly per convention
6. ✅ Verify file sizes reasonable (< 50MB total)
7. ✅ Upload 7 days before exam

### Presentation Preparation
1. ✅ Prepare live demo of 2-3 key scenarios
2. ✅ Highlight original/complex aspects
3. ✅ Prepare to explain design decisions
4. ✅ Know your code thoroughly (expect questions)
5. ✅ Practice 10-minute presentation

---

## Appendix: Quick Reference SQL Patterns

### Pattern 1: Create Encrypted Table
```sql
CREATE TABLE ACCOUNTS (
  ACCOUNT_ID NUMBER PRIMARY KEY,
  ACCOUNT_NUMBER VARCHAR2(20) NOT NULL UNIQUE,
  BALANCE NUMBER(15,2) ENCRYPT USING 'AES256',  -- TDE encryption
  CREATED_DATE DATE DEFAULT SYSDATE
);
```

### Pattern 2: Audit Trigger Template
```sql
CREATE OR REPLACE TRIGGER TRG_AUDIT_<TABLE>
AFTER INSERT OR UPDATE OR DELETE ON <TABLE>
FOR EACH ROW
BEGIN
  INSERT INTO AUDIT_LOG VALUES (
    SYSTIMESTAMP,
    USER,
    CASE WHEN INSERTING THEN 'I' WHEN UPDATING THEN 'U' ELSE 'D' END,
    '<TABLE>',
    :OLD.<KEY>, :NEW.<KEY>
  );
END;
```

### Pattern 3: Masking Function Template
```sql
CREATE OR REPLACE FUNCTION MASK_<FIELD>(p_value VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
  IF SYS_CONTEXT('USERENV','SESSION_USER') IN ('MANAGER','DBA') THEN
    RETURN p_value;
  ELSE
    RETURN REGEXP_REPLACE(p_value, '.', 'X', 1, LENGTH(p_value)-4);
  END IF;
END;
```

### Pattern 4: VPD Policy Template
```sql
CREATE OR REPLACE FUNCTION POLICY_<TABLE>(
  p_schema VARCHAR2, p_object VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
  RETURN 'CREATED_BY = SYS_CONTEXT(''USERENV'',''SESSION_USER'')';
END;
/

BEGIN
  DBMS_RLS.ADD_POLICY('SCHEMA','TABLE','POLICY_NAME','SCHEMA','POLICY_<TABLE>');
END;
```

---

## Timeline Estimate

| Phase | Requirement | Priority | Effort | Cumulative |
|-------|-------------|----------|--------|------------|
| Phase 1 | Schema (Req 1) | CRITICAL | 4-6h | 6h |
| Phase 2 | Encryption (Req 2) | HIGH | 3-4h | 10h |
| Phase 3 | Auditing (Req 3) | HIGH | 4-5h | 15h |
| Phase 4 | Identity Mgmt (Req 4) | HIGH | 3-4h | 19h |
| Phase 5 | Masking (Req 7) | HIGH | 2-3h | 22h |
| **N1 Total** | **5 requirements** | **Pass** | **22h** | **N1 Complete** |
| Phase 6 | Privileges (Req 5) | MEDIUM | 3-4h | 26h |
| Phase 7 | SQL Injection (Req 6) | MEDIUM | 3-4h | 30h |
| **N2 Total** | **2 requirements** | **+2 pts** | **8h** | **N2 Complete** |
| Phase 8 | Complexity (N3) | BONUS | 5-8h | 38h |
| Documentation | Project doc + screenshots | REQUIRED | 4-6h | 44h |
| **Grand Total** | **All requirements** | **Max** | **44h** | **Done** |

**Recommended Schedule** (assuming 8-10h/week):
- Week 1: Phases 1-2 (schema + encryption)
- Week 2: Phases 3-4 (auditing + identity)
- Week 3: Phase 5 + Phase 6 (masking + privileges)
- Week 4: Phase 7 + documentation (SQL injection + write-up)
- Week 5: Phase 8 + final review (complexity + polish)

---

## Next Steps

1. ✅ Specification approved and plan created
2. → Run `/speckit tasks` to generate detailed task breakdown
3. → Begin Phase 1 implementation (database schema)
4. → Complete N1 requirements for passing grade
5. → Add N2 requirements for higher grade
6. → Optionally add N3 complexity for maximum grade
7. → Document all work with screenshots
8. → Prepare presentation

**Status**: 🟢 READY FOR IMPLEMENTATION

---

*Plan generated by SpecKit on 2026-04-04*
