# Research: Oracle Database Security Implementation

**Feature**: 001-oracle-db-security  
**Research Date**: 2026-04-04  
**Purpose**: Resolve technical decisions for implementation

---

## Research Question 1: TDE vs DBMS_CRYPTO for Encryption

### Context
Need to encrypt ACCOUNTS.BALANCE column. Oracle offers two primary encryption mechanisms.

### Options Evaluated

#### Option A: Transparent Data Encryption (TDE)
**Description**: Oracle's native column/tablespace encryption feature

**Pros**:
- ✅ Transparent to applications (no code changes)
- ✅ Automatic encryption/decryption
- ✅ Hardware acceleration support
- ✅ Industry standard for Oracle databases
- ✅ Key management through Oracle Wallet
- ✅ No performance impact on queries (optimized)

**Cons**:
- ❌ Not available in Oracle XE (Express Edition)
- ❌ Requires SYSDBA privileges for setup
- ❌ Wallet management adds complexity

**Implementation**:
```sql
ALTER TABLE ACCOUNTS MODIFY (BALANCE ENCRYPT USING 'AES256');
```

#### Option B: DBMS_CRYPTO Package
**Description**: Programmatic encryption/decryption using PL/SQL

**Pros**:
- ✅ Available in all Oracle editions including XE
- ✅ Flexible - can encrypt any data type
- ✅ No special privileges required
- ✅ Portable code

**Cons**:
- ❌ Application must handle encryption/decryption
- ❌ Requires triggers or procedure wrappers
- ❌ Performance overhead in PL/SQL layer
- ❌ More complex code maintenance
- ❌ Key management must be manual

**Implementation**:
```sql
-- Encryption
encrypted_value := DBMS_CRYPTO.ENCRYPT(
  src => UTL_I18N.STRING_TO_RAW(p_balance, 'AL32UTF8'),
  typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
  key => l_key
);

-- Decryption
decrypted_value := UTL_I18N.RAW_TO_CHAR(
  DBMS_CRYPTO.DECRYPT(
    src => encrypted_value,
    typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
    key => l_key
  ),
  'AL32UTF8'
);
```

### Decision: TDE (with DBMS_CRYPTO fallback)

**Rationale**:
1. TDE is the industry-standard approach for column encryption in Oracle
2. Demonstrates professional-level knowledge (better for grading)
3. More realistic for banking scenario
4. If TDE unavailable (Oracle XE), fall back to DBMS_CRYPTO

**Implementation Strategy**:
- Primary: Document TDE setup and usage
- Fallback: Provide DBMS_CRYPTO alternative in appendix
- Clearly label which approach was used in final submission

**References**:
- Oracle Database Security Guide: Transparent Data Encryption
- Oracle Documentation: DBMS_CRYPTO Package

---

## Research Question 2: Auditing Strategy

### Context
Need comprehensive auditing covering three types: standard, FGA, and custom triggers.

### Options Evaluated

#### Approach A: Pure Standard Auditing
**Pros**: Simple, built-in, low overhead  
**Cons**: Limited customization, can't capture old/new values

#### Approach B: Only Custom Triggers
**Pros**: Full control, custom audit table  
**Cons**: High overhead, audit triggers can fail, missing system-level events

#### Approach C: Hybrid (Standard + FGA + Triggers)
**Pros**: Comprehensive coverage, best of all approaches  
**Cons**: More complex setup

### Decision: Hybrid Auditing Approach

**Rationale**:
- Standard auditing for system events (logins, DDL)
- FGA for column-level access tracking (BALANCE column)
- Custom triggers for DML with old/new values (TRANSACTIONS)

**Three-Layer Implementation**:

**Layer 1 - Standard Auditing**:
```sql
-- Login/logout
AUDIT SESSION BY ACCESS;

-- DDL operations
AUDIT CREATE TABLE, DROP TABLE, ALTER TABLE BY ACCESS;

-- Sensitive SELECT
AUDIT SELECT ON ACCOUNTS BY ACCESS;
```

**Layer 2 - Fine-Grained Auditing (FGA)**:
```sql
BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'BANK_SCHEMA',
    object_name     => 'ACCOUNTS',
    policy_name     => 'AUDIT_BALANCE_ACCESS',
    audit_column    => 'BALANCE',
    enable          => TRUE
  );
END;
/
```

**Layer 3 - Custom Audit Triggers**:
```sql
CREATE TABLE AUDIT_LOG (
  audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  audit_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
  username VARCHAR2(128),
  action_type VARCHAR2(10),
  table_name VARCHAR2(128),
  record_id NUMBER,
  old_value VARCHAR2(4000),
  new_value VARCHAR2(4000),
  ip_address VARCHAR2(50)
);

CREATE OR REPLACE TRIGGER TRG_AUDIT_TRANSACTIONS
AFTER INSERT OR UPDATE OR DELETE ON TRANSACTIONS
FOR EACH ROW
DECLARE
  v_action VARCHAR2(10);
  v_old_val VARCHAR2(4000);
  v_new_val VARCHAR2(4000);
BEGIN
  IF INSERTING THEN
    v_action := 'INSERT';
    v_new_val := 'AMOUNT=' || :NEW.AMOUNT || ',TYPE=' || :NEW.TXN_TYPE;
  ELSIF UPDATING THEN
    v_action := 'UPDATE';
    v_old_val := 'AMOUNT=' || :OLD.AMOUNT || ',STATUS=' || :OLD.STATUS;
    v_new_val := 'AMOUNT=' || :NEW.AMOUNT || ',STATUS=' || :NEW.STATUS;
  ELSIF DELETING THEN
    v_action := 'DELETE';
    v_old_val := 'TXN_ID=' || :OLD.TRANSACTION_ID;
  END IF;
  
  INSERT INTO AUDIT_LOG (
    username, action_type, table_name, record_id, old_value, new_value, ip_address
  ) VALUES (
    USER, v_action, 'TRANSACTIONS', 
    COALESCE(:NEW.TRANSACTION_ID, :OLD.TRANSACTION_ID),
    v_old_val, v_new_val,
    SYS_CONTEXT('USERENV', 'IP_ADDRESS')
  );
END;
/
```

**References**:
- Oracle Database Security Guide: Configuring Audit Policies
- Oracle Database PL/SQL Packages: DBMS_FGA
- Oracle Documentation: Audit Trail Views (DBA_AUDIT_TRAIL, DBA_FGA_AUDIT_TRAIL)

---

## Research Question 3: Data Masking Implementation

### Context
Account numbers must show only last 4 digits for unauthorized users.

### Options Evaluated

#### Option A: Oracle Data Redaction
**Pros**: Built-in feature, policy-based, no app changes  
**Cons**: Enterprise Edition only, limited format flexibility

#### Option B: VPD with Masking Views
**Pros**: Works in all editions, flexible  
**Cons**: Requires view management, users must query views

#### Option C: Custom Masking Function + Views
**Pros**: Simple, flexible, works everywhere  
**Cons**: Users must use views, not base tables

### Decision: Custom Masking Function + Views

**Rationale**:
1. Works in all Oracle editions (including XE)
2. Simple to understand and implement
3. Flexible format control (XXXX-XXXX-XXXX-1234)
4. Privilege-based unmasking is straightforward

**Implementation Pattern**:
```sql
-- Step 1: Create masking function
CREATE OR REPLACE FUNCTION MASK_ACCOUNT_NUMBER(
  p_account_number VARCHAR2
) RETURN VARCHAR2 IS
  v_unmasked_role VARCHAR2(30) := 'UNMASK_ACCOUNT_ROLE';
  v_has_role NUMBER;
BEGIN
  -- Check if user has unmask privilege
  SELECT COUNT(*) INTO v_has_role
  FROM USER_ROLE_PRIVS
  WHERE GRANTED_ROLE = v_unmasked_role;
  
  IF v_has_role > 0 THEN
    -- User can see full account number
    RETURN p_account_number;
  ELSE
    -- Mask all but last 4 digits
    RETURN RPAD('X', LENGTH(p_account_number) - 4, 'X') || 
           SUBSTR(p_account_number, -4);
  END IF;
END;
/

-- Step 2: Create masked view
CREATE OR REPLACE VIEW V_ACCOUNTS_MASKED AS
SELECT 
  ACCOUNT_ID,
  MASK_ACCOUNT_NUMBER(ACCOUNT_NUMBER) AS ACCOUNT_NUMBER,
  ACCOUNT_TYPE,
  BALANCE,
  OPENING_DATE,
  STATUS
FROM ACCOUNTS;

-- Step 3: Grant access
GRANT SELECT ON V_ACCOUNTS_MASKED TO TELLER_ROLE;
GRANT SELECT ON ACCOUNTS TO MANAGER_ROLE;  -- Full access

-- Step 4: Create unmask role
CREATE ROLE UNMASK_ACCOUNT_ROLE;
GRANT UNMASK_ACCOUNT_ROLE TO MANAGER_ROLE;
```

**Alternative for Oracle Enterprise Edition** (document but don't require):
```sql
-- Using Data Redaction (EE only)
BEGIN
  DBMS_REDACT.ADD_POLICY(
    object_schema => 'BANK_SCHEMA',
    object_name   => 'ACCOUNTS',
    policy_name   => 'MASK_ACCOUNT_NUMBER',
    column_name   => 'ACCOUNT_NUMBER',
    function_type => DBMS_REDACT.PARTIAL,
    function_parameters => 'VVVVFVVVVFVVVVFVVVV,VVV-VVV-VVV-,X,1,12',
    expression    => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') != ''MANAGER'''
  );
END;
/
```

**References**:
- Oracle Database Security Guide: Data Redaction
- Custom PL/SQL function patterns for data masking

---

## Research Question 4: VPD vs Application Context

### Context
Need row-level security so tellers only see accounts from their branch.

### Options Evaluated

#### Option A: Virtual Private Database (VPD) Only
**Pros**: Automatic WHERE clause injection, transparent  
**Cons**: Complex setup, requires policy function

#### Option B: Application Context Only
**Pros**: Simple session variables, flexible  
**Cons**: Application must manually check context in WHERE clauses

#### Option C: Both (Context drives VPD)
**Pros**: Best of both - context stores user info, VPD enforces automatically  
**Cons**: Most complex setup

### Decision: Use Both - Application Context + VPD

**Rationale**:
1. Application context stores user metadata (branch, role, etc.)
2. VPD policies use context to automatically filter rows
3. Demonstrates advanced Oracle security knowledge (good for N3 complexity)
4. Industry best practice for row-level security

**Implementation Pattern**:

**Step 1: Create Application Context**
```sql
-- Create context namespace
CREATE OR REPLACE CONTEXT BANK_CONTEXT USING SET_BANK_CONTEXT;

-- Create context setter procedure
CREATE OR REPLACE PROCEDURE SET_BANK_CONTEXT(
  p_user_id NUMBER,
  p_branch_id NUMBER,
  p_role VARCHAR2
) IS
BEGIN
  DBMS_SESSION.SET_CONTEXT('BANK_CONTEXT', 'USER_ID', p_user_id);
  DBMS_SESSION.SET_CONTEXT('BANK_CONTEXT', 'USER_BRANCH', p_branch_id);
  DBMS_SESSION.SET_CONTEXT('BANK_CONTEXT', 'USER_ROLE', p_role);
END;
/

-- Call on user login (simulated)
EXEC SET_BANK_CONTEXT(101, 1, 'TELLER');
```

**Step 2: Create VPD Policy Function**
```sql
CREATE OR REPLACE FUNCTION BRANCH_SECURITY_POLICY(
  p_schema VARCHAR2,
  p_object VARCHAR2
) RETURN VARCHAR2 IS
  v_user_role VARCHAR2(50);
  v_user_branch NUMBER;
  v_predicate VARCHAR2(400);
BEGIN
  -- Get context values
  v_user_role := SYS_CONTEXT('BANK_CONTEXT', 'USER_ROLE');
  v_user_branch := SYS_CONTEXT('BANK_CONTEXT', 'USER_BRANCH');
  
  -- DBA and Managers see all
  IF v_user_role IN ('DBA', 'MANAGER') THEN
    v_predicate := '1=1';  -- No restriction
  -- Tellers see only their branch
  ELSIF v_user_role = 'TELLER' THEN
    v_predicate := 'BRANCH_ID = ' || v_user_branch;
  -- Default: see nothing
  ELSE
    v_predicate := '1=0';
  END IF;
  
  RETURN v_predicate;
END;
/
```

**Step 3: Apply VPD Policy**
```sql
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'BANK_SCHEMA',
    object_name     => 'ACCOUNTS',
    policy_name     => 'BRANCH_ISOLATION',
    function_schema => 'BANK_SCHEMA',
    policy_function => 'BRANCH_SECURITY_POLICY',
    statement_types => 'SELECT, INSERT, UPDATE, DELETE',
    update_check    => TRUE
  );
END;
/
```

**Result**: Tellers automatically see only their branch's accounts in all queries, with zero application code changes.

**References**:
- Oracle Database Security Guide: Virtual Private Database
- Oracle Documentation: DBMS_RLS Package
- Oracle Documentation: Application Context (DBMS_SESSION)

---

## Research Question 5: Key Management for TDE

### Context
TDE requires encryption keys stored securely. How to manage in development/academic setting?

### Options Evaluated

#### Option A: Oracle Wallet (File-based)
**Pros**: Standard approach, simple backup  
**Cons**: File permissions critical

#### Option B: Oracle Key Vault (OKV)
**Pros**: Enterprise-grade, centralized  
**Cons**: Requires separate OKV installation, overkill for project

#### Option C: Hardcoded Key (DBMS_CRYPTO fallback)
**Pros**: Simple for demo  
**Cons**: Insecure, only acceptable for DBMS_CRYPTO in academic setting

### Decision: Oracle Wallet (with documented backup)

**Rationale**:
1. Industry-standard approach for TDE
2. Demonstrates proper key management understanding
3. Simple enough for academic project
4. Wallet file can be backed up and included in submission

**Implementation Steps**:

**Step 1: Create Wallet**
```bash
# Create wallet directory
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/wallet

# Create wallet (will prompt for password)
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -create
```

**Step 2: Configure sqlnet.ora**
```
# Add to $ORACLE_HOME/network/admin/sqlnet.ora
ENCRYPTION_WALLET_LOCATION =
  (SOURCE = (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = /u01/app/oracle/admin/ORCL/wallet)
    )
  )
```

**Step 3: Open Wallet and Set Master Key**
```sql
-- Open wallet
ALTER SYSTEM SET ENCRYPTION WALLET OPEN IDENTIFIED BY "wallet_password";

-- Set TDE master encryption key
ALTER SYSTEM SET ENCRYPTION KEY IDENTIFIED BY "wallet_password";
```

**Step 4: Backup Wallet**
```bash
# Backup wallet file
cp -r $ORACLE_BASE/admin/$ORACLE_SID/wallet /backup/location/

# Include in project submission as documentation
# (DO NOT include actual wallet in public repos!)
```

**For DBMS_CRYPTO Fallback** (if TDE not available):
```sql
-- Store key in application table (DEMO ONLY - not secure)
CREATE TABLE ENCRYPTION_KEYS (
  key_id NUMBER PRIMARY KEY,
  key_value RAW(32),  -- 256-bit key
  created_date DATE DEFAULT SYSDATE
);

-- Generate key (one-time)
INSERT INTO ENCRYPTION_KEYS (key_id, key_value) 
VALUES (1, DBMS_CRYPTO.RANDOMBYTES(32));
```

**Documentation Note**: In project document, explain:
- Production systems use Oracle Key Vault or HSM
- This project uses simplified wallet for demonstration
- Key backup procedures documented
- Wallet password stored securely (not in code)

**References**:
- Oracle Database Security Guide: Configuring Transparent Data Encryption
- Oracle Database Administrator's Guide: Managing Encryption Keys
- Oracle Wallet Manager documentation

---

## Summary of Technical Decisions

| Decision Area | Chosen Approach | Rationale |
|---------------|-----------------|-----------|
| **Encryption** | TDE (primary), DBMS_CRYPTO (fallback) | Industry standard, transparent to apps |
| **Auditing** | Hybrid (Standard + FGA + Triggers) | Comprehensive coverage, meets all requirements |
| **Masking** | Custom function + Views | Works in all editions, flexible |
| **Row Security** | Application Context + VPD | Best practice, automatic enforcement |
| **Key Management** | Oracle Wallet | Standard approach, simple backup |

All decisions prioritize:
1. ✅ Meeting course requirements
2. ✅ Demonstrating professional knowledge
3. ✅ Working in Oracle XE (fallback options provided)
4. ✅ Realistic banking security practices

---

## Additional Resources

### Oracle Documentation
- Oracle Database Security Guide 19c
- Oracle Database PL/SQL Packages and Types Reference
- Oracle Database Administrator's Guide

### Best Practices
- OWASP Database Security Cheat Sheet
- PCI-DSS Data Security Standards
- NIST Guidelines for Database Security

### Tools
- SQL Developer for development and testing
- SQL*Plus for script execution
- Oracle Enterprise Manager (if available) for monitoring

---

*Research completed: 2026-04-04*
