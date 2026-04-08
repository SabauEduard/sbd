# Quick Start Guide: Oracle Database Security Implementation

**Feature**: 001-oracle-db-security  
**Date**: 2026-04-04  
**Purpose**: Step-by-step scenarios for implementing and demonstrating security features

---

## Prerequisites

### Required Software
- Oracle Database 19c or higher (XE acceptable)
- SQL*Plus, SQL Developer, or SQLcl
- Text editor for SQL scripts
- Git for version control

### Database Setup
```sql
-- Connect as SYSDBA
CONNECT sys AS SYSDBA

-- Create main schema
CREATE USER BANK_SCHEMA IDENTIFIED BY SecurePass123!
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- Grant necessary privileges
GRANT CONNECT, RESOURCE TO BANK_SCHEMA;
GRANT CREATE VIEW, CREATE TRIGGER, CREATE PROCEDURE TO BANK_SCHEMA;
GRANT SELECT ON DBA_AUDIT_TRAIL TO BANK_SCHEMA;
GRANT EXECUTE ON DBMS_FGA TO BANK_SCHEMA;
GRANT EXECUTE ON DBMS_RLS TO BANK_SCHEMA;
GRANT EXECUTE ON DBMS_SESSION TO BANK_SCHEMA;
```

---

## Scenario 1: Complete Database Setup (Phase 1 - Requirement 1)

**Objective**: Create all tables, constraints, and sample data

### Step 1.1: Execute Schema Creation Script

```sql
-- Connect as schema owner
CONNECT BANK_SCHEMA/SecurePass123!

-- Run creation script
@creare_inserare.sql
```

**Script Contents** (`creare_inserare.sql`):

```sql
-- ============================================
-- BANK SECURITY PROJECT - SCHEMA CREATION
-- Student: <Your Name>
-- Group: <Your Group>
-- Date: 2026-04-04
-- ============================================

-- Drop existing objects (for clean re-runs)
BEGIN
  FOR t IN (SELECT table_name FROM user_tables) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/

-- Create sequences
CREATE SEQUENCE SEQ_BANK_ID START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_BRANCH_ID START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ACCOUNT_ID START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_TRANSACTION_ID START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_USER_ID START WITH 101 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ROLE_ID START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_SESSION_ID START WITH 1 INCREMENT BY 1;

-- 1. BANKS
CREATE TABLE BANKS (
  bank_id NUMBER PRIMARY KEY,
  bank_name VARCHAR2(100) NOT NULL UNIQUE,
  swift_code VARCHAR2(11) UNIQUE,
  country VARCHAR2(50) NOT NULL,
  regulatory_id VARCHAR2(50),
  established_date DATE,
  created_date DATE DEFAULT SYSDATE
);

-- 2. BRANCHES
CREATE TABLE BRANCHES (
  branch_id NUMBER PRIMARY KEY,
  bank_id NUMBER NOT NULL,
  branch_name VARCHAR2(100) NOT NULL,
  branch_code VARCHAR2(20) UNIQUE NOT NULL,
  address VARCHAR2(200) NOT NULL,
  city VARCHAR2(50) NOT NULL,
  phone VARCHAR2(20),
  manager_name VARCHAR2(100),
  status VARCHAR2(10) DEFAULT 'ACTIVE',
  CONSTRAINT FK_BRANCH_BANK FOREIGN KEY (bank_id) REFERENCES BANKS(bank_id),
  CONSTRAINT CHK_BRANCH_STATUS CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- 3. ACCOUNTS (balance will be encrypted in next phase)
CREATE TABLE ACCOUNTS (
  account_id NUMBER PRIMARY KEY,
  account_number VARCHAR2(34) UNIQUE NOT NULL,
  account_type VARCHAR2(20) NOT NULL,
  balance NUMBER(15,2) NOT NULL,  -- Will be encrypted in Phase 2
  currency VARCHAR2(3) DEFAULT 'RON',
  opening_date DATE DEFAULT SYSDATE,
  status VARCHAR2(10) DEFAULT 'ACTIVE',
  branch_id NUMBER NOT NULL,
  customer_name VARCHAR2(100) NOT NULL,
  customer_tax_id VARCHAR2(20),
  created_by VARCHAR2(128),
  created_date DATE DEFAULT SYSDATE,
  last_modified DATE,
  CONSTRAINT FK_ACCOUNT_BRANCH FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id),
  CONSTRAINT CHK_BALANCE_NON_NEGATIVE CHECK (balance >= 0),
  CONSTRAINT CHK_ACCOUNT_STATUS CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
  CONSTRAINT CHK_ACCOUNT_TYPE CHECK (account_type IN ('CHECKING', 'SAVINGS', 'BUSINESS'))
);

-- 4. DB_USERS
CREATE TABLE DB_USERS (
  user_id NUMBER PRIMARY KEY,
  username VARCHAR2(50) UNIQUE NOT NULL,
  email VARCHAR2(100) UNIQUE,
  employee_id VARCHAR2(20),
  full_name VARCHAR2(100) NOT NULL,
  status VARCHAR2(10) DEFAULT 'ACTIVE',
  branch_id NUMBER,
  department VARCHAR2(50),
  hire_date DATE DEFAULT SYSDATE,
  created_date DATE DEFAULT SYSDATE,
  last_login TIMESTAMP,
  CONSTRAINT FK_USER_BRANCH FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id),
  CONSTRAINT CHK_USER_STATUS CHECK (status IN ('ACTIVE', 'SUSPENDED', 'TERMINATED'))
);

-- 5. TRANSACTIONS
CREATE TABLE TRANSACTIONS (
  transaction_id NUMBER PRIMARY KEY,
  txn_type VARCHAR2(20) NOT NULL,
  amount NUMBER(15,2) NOT NULL,
  txn_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
  status VARCHAR2(20) DEFAULT 'COMPLETED',
  from_account_id NUMBER NOT NULL,
  to_account_id NUMBER,
  initiated_by NUMBER,
  description VARCHAR2(200),
  reference_number VARCHAR2(50) UNIQUE,
  reversal_of NUMBER,
  CONSTRAINT FK_TXN_FROM_ACCOUNT FOREIGN KEY (from_account_id) REFERENCES ACCOUNTS(account_id),
  CONSTRAINT FK_TXN_TO_ACCOUNT FOREIGN KEY (to_account_id) REFERENCES ACCOUNTS(account_id),
  CONSTRAINT FK_TXN_INITIATED_BY FOREIGN KEY (initiated_by) REFERENCES DB_USERS(user_id),
  CONSTRAINT FK_TXN_REVERSAL FOREIGN KEY (reversal_of) REFERENCES TRANSACTIONS(transaction_id),
  CONSTRAINT CHK_TXN_AMOUNT_POSITIVE CHECK (amount > 0),
  CONSTRAINT CHK_TXN_STATUS CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REVERSED')),
  CONSTRAINT CHK_TXN_TYPE CHECK (txn_type IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER')),
  CONSTRAINT CHK_NO_SELF_TRANSFER CHECK (from_account_id != to_account_id OR to_account_id IS NULL)
);

-- 6. ROLES
CREATE TABLE ROLES (
  role_id NUMBER PRIMARY KEY,
  role_name VARCHAR2(50) UNIQUE NOT NULL,
  description VARCHAR2(200),
  parent_role_id NUMBER,
  created_date DATE DEFAULT SYSDATE,
  CONSTRAINT FK_ROLE_PARENT FOREIGN KEY (parent_role_id) REFERENCES ROLES(role_id)
);

-- 7. ROLE_PRIVS
CREATE TABLE ROLE_PRIVS (
  priv_id NUMBER PRIMARY KEY,
  role_id NUMBER NOT NULL,
  privilege_type VARCHAR2(20) NOT NULL,
  privilege_name VARCHAR2(50) NOT NULL,
  object_name VARCHAR2(100),
  grantable VARCHAR2(1) DEFAULT 'N',
  CONSTRAINT FK_PRIV_ROLE FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
  CONSTRAINT UQ_ROLE_PRIV UNIQUE (role_id, privilege_name, object_name)
);

-- 8. USER_SESSIONS
CREATE TABLE USER_SESSIONS (
  session_id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  login_time TIMESTAMP DEFAULT SYSTIMESTAMP,
  logout_time TIMESTAMP,
  ip_address VARCHAR2(50),
  branch_id NUMBER,
  oracle_sid NUMBER,
  status VARCHAR2(20) DEFAULT 'ACTIVE',
  CONSTRAINT FK_SESSION_USER FOREIGN KEY (user_id) REFERENCES DB_USERS(user_id)
);

-- 9. AUDIT_LOG
CREATE TABLE AUDIT_LOG (
  audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  audit_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
  username VARCHAR2(128) NOT NULL,
  action_type VARCHAR2(10) NOT NULL,
  table_name VARCHAR2(128) NOT NULL,
  record_id NUMBER,
  old_value VARCHAR2(4000),
  new_value VARCHAR2(4000),
  ip_address VARCHAR2(50),
  session_id NUMBER,
  sql_text CLOB
);

-- Create indexes
CREATE INDEX IDX_ACCOUNTS_BRANCH ON ACCOUNTS(branch_id);
CREATE INDEX IDX_TXN_FROM_ACCOUNT ON TRANSACTIONS(from_account_id);
CREATE INDEX IDX_TXN_TIMESTAMP ON TRANSACTIONS(txn_timestamp);
CREATE INDEX IDX_AUDIT_TIMESTAMP ON AUDIT_LOG(audit_timestamp);
CREATE INDEX IDX_AUDIT_USERNAME ON AUDIT_LOG(username);

-- Insert sample data
-- BANKS
INSERT INTO BANKS VALUES (SEQ_BANK_ID.NEXTVAL, 'National Bank of Romania', 'NBORROBB', 'Romania', 'RO-BNK-001', DATE '1990-01-01', SYSDATE);
INSERT INTO BANKS VALUES (SEQ_BANK_ID.NEXTVAL, 'UniCredit Bank Romania', 'BACXROBU', 'Romania', 'RO-BNK-002', DATE '1997-05-15', SYSDATE);

-- BRANCHES
INSERT INTO BRANCHES VALUES (SEQ_BRANCH_ID.NEXTVAL, 1, 'NBR Bucharest Central', 'NBR-BUC-001', 'Strada Lipscani 25', 'Bucharest', '+40-21-312-4567', 'Ion Popescu', 'ACTIVE');
INSERT INTO BRANCHES VALUES (SEQ_BRANCH_ID.NEXTVAL, 1, 'NBR Cluj Branch', 'NBR-CLJ-001', 'Piata Unirii 10', 'Cluj-Napoca', '+40-264-432-111', 'Maria Ionescu', 'ACTIVE');
INSERT INTO BRANCHES VALUES (SEQ_BRANCH_ID.NEXTVAL, 2, 'UniCredit Timisoara', 'UCI-TIM-001', 'Bulevardul Revolutiei 5', 'Timisoara', '+40-256-123-456', 'Andrei Vasilescu', 'ACTIVE');

-- DB_USERS
INSERT INTO DB_USERS VALUES (SEQ_USER_ID.NEXTVAL, 'teller01', 'teller01@bank.ro', 'EMP-1001', 'Ana Teller', 'ACTIVE', 1, 'TELLER', DATE '2023-01-10', SYSDATE, NULL);
INSERT INTO DB_USERS VALUES (SEQ_USER_ID.NEXTVAL, 'teller02', 'teller02@bank.ro', 'EMP-1002', 'Mihai Teller', 'ACTIVE', 2, 'TELLER', DATE '2023-03-15', SYSDATE, NULL);
INSERT INTO DB_USERS VALUES (SEQ_USER_ID.NEXTVAL, 'manager01', 'manager01@bank.ro', 'EMP-2001', 'Ion Manager', 'ACTIVE', 1, 'MANAGER', DATE '2020-05-15', SYSDATE, NULL);
INSERT INTO DB_USERS VALUES (SEQ_USER_ID.NEXTVAL, 'manager02', 'manager02@bank.ro', 'EMP-2002', 'Elena Manager', 'ACTIVE', 2, 'MANAGER', DATE '2021-02-20', SYSDATE, NULL);
INSERT INTO DB_USERS VALUES (SEQ_USER_ID.NEXTVAL, 'auditor01', 'auditor01@bank.ro', 'EMP-3001', 'Maria Auditor', 'ACTIVE', NULL, 'AUDIT', DATE '2021-03-20', SYSDATE, NULL);
INSERT INTO DB_USERS VALUES (SEQ_USER_ID.NEXTVAL, 'dba01', 'dba01@bank.ro', 'EMP-4001', 'Vasile DBA', 'ACTIVE', NULL, 'IT', DATE '2019-01-05', SYSDATE, NULL);

-- ACCOUNTS
INSERT INTO ACCOUNTS VALUES (SEQ_ACCOUNT_ID.NEXTVAL, 'RO49AAAA1B31007593840001', 'CHECKING', 25000.00, 'RON', DATE '2024-01-15', 'ACTIVE', 1, 'Andrei Vasilescu', 'RO123456789', USER, SYSDATE, NULL);
INSERT INTO ACCOUNTS VALUES (SEQ_ACCOUNT_ID.NEXTVAL, 'RO49AAAA1B31007593840002', 'SAVINGS', 50000.00, 'RON', DATE '2024-02-20', 'ACTIVE', 1, 'Elena Dumitrescu', 'RO987654321', USER, SYSDATE, NULL);
INSERT INTO ACCOUNTS VALUES (SEQ_ACCOUNT_ID.NEXTVAL, 'RO49AAAA1B31007593840003', 'CHECKING', 15000.00, 'RON', DATE '2024-03-10', 'ACTIVE', 1, 'Mihai Popescu', 'RO111222333', USER, SYSDATE, NULL);
INSERT INTO ACCOUNTS VALUES (SEQ_ACCOUNT_ID.NEXTVAL, 'RO49AAAA2B31007593840004', 'BUSINESS', 100000.00, 'RON', DATE '2024-01-05', 'ACTIVE', 2, 'SRL Consulting SRL', 'RO444555666', USER, SYSDATE, NULL);
INSERT INTO ACCOUNTS VALUES (SEQ_ACCOUNT_ID.NEXTVAL, 'RO49AAAA2B31007593840005', 'SAVINGS', 75000.00, 'RON', DATE '2024-02-15', 'ACTIVE', 2, 'Ana Ionescu', 'RO777888999', USER, SYSDATE, NULL);
INSERT INTO ACCOUNTS VALUES (SEQ_ACCOUNT_ID.NEXTVAL, 'RO49AAAA3B31007593840006', 'CHECKING', 30000.00, 'RON', DATE '2024-03-20', 'ACTIVE', 3, 'Ion Georgescu', 'RO000111222', USER, SYSDATE, NULL);

-- TRANSACTIONS
INSERT INTO TRANSACTIONS VALUES (SEQ_TRANSACTION_ID.NEXTVAL, 'DEPOSIT', 5000.00, SYSTIMESTAMP, 'COMPLETED', 1001, NULL, 101, 'Initial deposit', 'REF-001', NULL);
INSERT INTO TRANSACTIONS VALUES (SEQ_TRANSACTION_ID.NEXTVAL, 'WITHDRAWAL', 500.00, SYSTIMESTAMP, 'COMPLETED', 1001, NULL, 101, 'ATM withdrawal', 'REF-002', NULL);
INSERT INTO TRANSACTIONS VALUES (SEQ_TRANSACTION_ID.NEXTVAL, 'TRANSFER', 1000.00, SYSTIMESTAMP, 'COMPLETED', 1001, 1002, 101, 'Monthly savings', 'REF-003', NULL);
INSERT INTO TRANSACTIONS VALUES (SEQ_TRANSACTION_ID.NEXTVAL, 'DEPOSIT', 10000.00, SYSTIMESTAMP, 'COMPLETED', 1002, NULL, 103, 'Salary deposit', 'REF-004', NULL);
INSERT INTO TRANSACTIONS VALUES (SEQ_TRANSACTION_ID.NEXTVAL, 'WITHDRAWAL', 2000.00, SYSTIMESTAMP, 'COMPLETED', 1003, NULL, 102, 'Cash withdrawal', 'REF-005', NULL);

-- ROLES
INSERT INTO ROLES VALUES (SEQ_ROLE_ID.NEXTVAL, 'BASE_EMPLOYEE_ROLE', 'Basic privileges for all employees', NULL, SYSDATE);
INSERT INTO ROLES VALUES (SEQ_ROLE_ID.NEXTVAL, 'TELLER_ROLE', 'Standard teller privileges', 1, SYSDATE);
INSERT INTO ROLES VALUES (SEQ_ROLE_ID.NEXTVAL, 'SENIOR_TELLER_ROLE', 'Senior teller with elevated access', 2, SYSDATE);
INSERT INTO ROLES VALUES (SEQ_ROLE_ID.NEXTVAL, 'MANAGER_ROLE', 'Branch manager full access', 3, SYSDATE);
INSERT INTO ROLES VALUES (SEQ_ROLE_ID.NEXTVAL, 'AUDITOR_ROLE', 'Read-only audit access', 1, SYSDATE);
INSERT INTO ROLES VALUES (SEQ_ROLE_ID.NEXTVAL, 'DBA_ROLE', 'Database administrator', NULL, SYSDATE);

COMMIT;

-- Verify data
SELECT 'BANKS' AS table_name, COUNT(*) AS row_count FROM BANKS
UNION ALL
SELECT 'BRANCHES', COUNT(*) FROM BRANCHES
UNION ALL
SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS
UNION ALL
SELECT 'DB_USERS', COUNT(*) FROM DB_USERS
UNION ALL
SELECT 'ROLES', COUNT(*) FROM ROLES;

PROMPT Schema creation completed successfully!
```

### Step 1.2: Verify Schema

```sql
-- Check all tables created
SELECT table_name FROM user_tables ORDER BY table_name;

-- Verify row counts
SELECT 'BANKS' AS table_name, COUNT(*) FROM BANKS
UNION ALL SELECT 'BRANCHES', COUNT(*) FROM BRANCHES
UNION ALL SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS;

-- Verify constraints
SELECT constraint_name, constraint_type, table_name
FROM user_constraints
WHERE table_name IN ('ACCOUNTS', 'TRANSACTIONS')
ORDER BY table_name, constraint_type;
```

**Expected Output**:
- 9 tables created
- 6 accounts, 5 transactions, 6 users
- All foreign key constraints active

---

## Scenario 2: Implement Encryption (Phase 2 - Requirement 2)

**Objective**: Encrypt ACCOUNTS.BALANCE column

### Step 2.1: Configure TDE (if available)

```sql
-- Connect as SYSDBA
CONNECT sys AS SYSDBA

-- Check if TDE is available
SELECT * FROM V$ENCRYPTION_WALLET;

-- If wallet not configured, create it
-- (Run from OS command line, not SQL*Plus)
```

```bash
# Create wallet directory
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/wallet

# Create wallet
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -create
# Enter password when prompted: WalletPass123!
```

```sql
-- Configure sqlnet.ora (add these lines)
ENCRYPTION_WALLET_LOCATION =
  (SOURCE = (METHOD = FILE)
    (METHOD_DATA =
      (DIRECTORY = /path/to/wallet)
    )
  )

-- Open wallet
ALTER SYSTEM SET ENCRYPTION WALLET OPEN IDENTIFIED BY "WalletPass123!";

-- Set master key
ALTER SYSTEM SET ENCRYPTION KEY IDENTIFIED BY "WalletPass123!";
```

### Step 2.2: Apply Column Encryption

```sql
-- Connect as schema owner
CONNECT BANK_SCHEMA/SecurePass123!

-- Encrypt balance column
ALTER TABLE ACCOUNTS MODIFY (balance ENCRYPT USING 'AES256');

-- Verify encryption
SELECT table_name, column_name, encryption_alg
FROM USER_ENCRYPTED_COLUMNS
WHERE table_name = 'ACCOUNTS';
```

### Step 2.3: Test Encryption

```sql
-- Query as authorized user (should see plaintext)
SELECT account_id, account_number, balance
FROM ACCOUNTS
WHERE account_id = 1001;

-- Check raw storage (requires DBA privileges)
CONNECT sys AS SYSDBA
SELECT dbms_lob.substr(to_lob(balance), 100, 1) AS encrypted_value
FROM BANK_SCHEMA.ACCOUNTS
WHERE account_id = 1001;
-- Should see garbled binary data
```

### Alternative: DBMS_CRYPTO (if TDE not available)

See `research.md` for DBMS_CRYPTO implementation using triggers.

---

## Scenario 3: Configure Auditing (Phase 3 - Requirement 3)

**Objective**: Three-layer audit implementation

### Step 3.1: Standard Auditing

```sql
-- Connect as SYSDBA
CONNECT sys AS SYSDBA

-- Enable auditing
ALTER SYSTEM SET AUDIT_TRAIL=DB,EXTENDED SCOPE=SPFILE;
-- Restart database for this to take effect

-- Configure audit policies
AUDIT SESSION BY ACCESS;
AUDIT SELECT ON BANK_SCHEMA.ACCOUNTS BY ACCESS;
AUDIT INSERT, UPDATE, DELETE ON BANK_SCHEMA.TRANSACTIONS BY ACCESS;
AUDIT CREATE TABLE, DROP TABLE BY ACCESS;

-- Verify auditing enabled
SELECT name, value FROM v$parameter WHERE name LIKE 'audit%';
```

### Step 3.2: Fine-Grained Auditing

```sql
-- Connect as schema owner
CONNECT BANK_SCHEMA/SecurePass123!

-- Create FGA policy for BALANCE column access
BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'BANK_SCHEMA',
    object_name     => 'ACCOUNTS',
    policy_name     => 'AUDIT_BALANCE_ACCESS',
    audit_column    => 'BALANCE',
    enable          => TRUE,
    statement_types => 'SELECT,UPDATE'
  );
END;
/

-- Verify policy created
SELECT object_name, policy_name, enabled
FROM DBA_AUDIT_POLICIES
WHERE object_schema = 'BANK_SCHEMA';
```

### Step 3.3: Custom Audit Triggers

```sql
-- Connect as schema owner
CONNECT BANK_SCHEMA/SecurePass123!

-- Create audit trigger
CREATE OR REPLACE TRIGGER TRG_AUDIT_TRANSACTIONS
AFTER INSERT OR UPDATE OR DELETE ON TRANSACTIONS
FOR EACH ROW
DECLARE
  v_action VARCHAR2(10);
  v_old_val VARCHAR2(4000);
  v_new_val VARCHAR2(4000);
BEGIN
  -- Determine action
  IF INSERTING THEN
    v_action := 'INSERT';
    v_new_val := 'TXN_ID=' || :NEW.transaction_id || ',AMOUNT=' || :NEW.amount || ',TYPE=' || :NEW.txn_type;
  ELSIF UPDATING THEN
    v_action := 'UPDATE';
    v_old_val := 'AMOUNT=' || :OLD.amount || ',STATUS=' || :OLD.status;
    v_new_val := 'AMOUNT=' || :NEW.amount || ',STATUS=' || :NEW.status;
  ELSIF DELETING THEN
    v_action := 'DELETE';
    v_old_val := 'TXN_ID=' || :OLD.transaction_id || ',AMOUNT=' || :OLD.amount;
  END IF;
  
  -- Log to audit table
  INSERT INTO AUDIT_LOG (
    username, action_type, table_name, record_id,
    old_value, new_value, ip_address
  ) VALUES (
    USER,
    v_action,
    'TRANSACTIONS',
    COALESCE(:NEW.transaction_id, :OLD.transaction_id),
    v_old_val,
    v_new_val,
    SYS_CONTEXT('USERENV', 'IP_ADDRESS')
  );
END;
/

-- Test trigger
INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL, 'DEPOSIT', 1000.00,
  SYSTIMESTAMP, 'COMPLETED', 1001, NULL,
  101, 'Test deposit', 'REF-TEST-001', NULL
);

-- Check audit log
SELECT * FROM AUDIT_LOG ORDER BY audit_timestamp DESC;
```

### Step 3.4: Query Audit Data

```sql
-- Standard audit trail
SELECT username, timestamp, action_name, obj_name
FROM DBA_AUDIT_TRAIL
WHERE owner = 'BANK_SCHEMA'
  AND timestamp >= SYSDATE - 1
ORDER BY timestamp DESC;

-- FGA audit trail
SELECT db_user, timestamp, object_name, sql_text
FROM DBA_FGA_AUDIT_TRAIL
WHERE object_schema = 'BANK_SCHEMA'
ORDER BY timestamp DESC;

-- Custom audit log
SELECT username, action_type, table_name, old_value, new_value
FROM AUDIT_LOG
ORDER BY audit_timestamp DESC;
```

---

## Scenario 4: Identity & Resource Management (Phase 4 - Requirement 4)

**Objective**: Implement user profiles and document access matrices

### Step 4.1: Create User Profiles

```sql
-- Connect as SYSDBA
CONNECT sys AS SYSDBA

-- Teller profile
CREATE PROFILE TELLER_PROFILE LIMIT
  SESSIONS_PER_USER 2
  CPU_PER_SESSION 60000        -- 60 seconds
  CONNECT_TIME 480             -- 8 hours
  IDLE_TIME 30                 -- 30 minutes
  FAILED_LOGIN_ATTEMPTS 3;

-- Manager profile
CREATE PROFILE MANAGER_PROFILE LIMIT
  SESSIONS_PER_USER 3
  CPU_PER_SESSION UNLIMITED
  CONNECT_TIME 600             -- 10 hours
  IDLE_TIME 60
  FAILED_LOGIN_ATTEMPTS 5;

-- Auditor profile
CREATE PROFILE AUDITOR_PROFILE LIMIT
  SESSIONS_PER_USER 2
  CPU_PER_SESSION UNLIMITED
  CONNECT_TIME UNLIMITED
  IDLE_TIME 120
  FAILED_LOGIN_ATTEMPTS 5;

-- Verify profiles
SELECT profile, resource_name, limit
FROM DBA_PROFILES
WHERE profile IN ('TELLER_PROFILE', 'MANAGER_PROFILE', 'AUDITOR_PROFILE')
ORDER BY profile, resource_name;
```

### Step 4.2: Create Oracle Users

```sql
-- Create teller users
CREATE USER TELLER_01 IDENTIFIED BY Teller01Pass!
  DEFAULT TABLESPACE USERS
  PROFILE TELLER_PROFILE;

CREATE USER TELLER_02 IDENTIFIED BY Teller02Pass!
  DEFAULT TABLESPACE USERS
  PROFILE TELLER_PROFILE;

-- Create manager users
CREATE USER MANAGER_01 IDENTIFIED BY Manager01Pass!
  DEFAULT TABLESPACE USERS
  PROFILE MANAGER_PROFILE;

-- Create auditor user
CREATE USER AUDITOR_01 IDENTIFIED BY Auditor01Pass!
  DEFAULT TABLESPACE USERS
  PROFILE AUDITOR_PROFILE;

-- Verify users
SELECT username, profile, account_status
FROM DBA_USERS
WHERE username IN ('TELLER_01', 'TELLER_02', 'MANAGER_01', 'AUDITOR_01');
```

### Step 4.3: Document Access Matrices

**Process-User Matrix**: (Include in project document)
```
| Process               | Teller | Manager | Auditor | DBA |
|-----------------------|--------|---------|---------|-----|
| Create Account        | NO     | YES     | NO      | YES |
| View Balance          | YES    | YES     | YES     | YES |
| Process Transaction   | YES    | YES     | NO      | YES |
| View Audit Logs       | NO     | PARTIAL | YES     | YES |
| Manage Users          | NO     | NO      | NO      | YES |
| Configure Security    | NO     | NO      | NO      | YES |
```

**Entity-Process Matrix**: (Include in project document)
**Entity-User Matrix**: (Include in project document)

---

## Scenario 5: Data Masking (Phase 5 - Requirement 7)

**Objective**: Mask account numbers for unauthorized users

### Step 5.1: Create Masking Function

```sql
-- Connect as schema owner
CONNECT BANK_SCHEMA/SecurePass123!

-- Create masking function
CREATE OR REPLACE FUNCTION MASK_ACCOUNT_NUMBER(
  p_account_number VARCHAR2
) RETURN VARCHAR2 IS
  v_has_unmask_role NUMBER;
BEGIN
  -- Check if current user has unmask role
  BEGIN
    SELECT COUNT(*) INTO v_has_unmask_role
    FROM USER_ROLE_PRIVS
    WHERE GRANTED_ROLE = 'UNMASK_ACCOUNT_ROLE';
  EXCEPTION
    WHEN OTHERS THEN
      v_has_unmask_role := 0;
  END;
  
  -- Return masked or full number
  IF v_has_unmask_role > 0 OR USER IN ('BANK_SCHEMA', 'MANAGER_01') THEN
    RETURN p_account_number;
  ELSE
    -- Mask all but last 4 digits
    RETURN LPAD('X', LENGTH(p_account_number) - 4, 'X') || SUBSTR(p_account_number, -4);
  END IF;
END MASK_ACCOUNT_NUMBER;
/
```

### Step 5.2: Create Masked View

```sql
CREATE OR REPLACE VIEW V_ACCOUNTS_MASKED AS
SELECT 
  account_id,
  MASK_ACCOUNT_NUMBER(account_number) AS account_number,
  account_type,
  balance,
  currency,
  opening_date,
  status,
  branch_id,
  customer_name
FROM ACCOUNTS;

-- Create unmask role
CONNECT sys AS SYSDBA
CREATE ROLE UNMASK_ACCOUNT_ROLE;
```

### Step 5.3: Test Masking

```sql
-- As teller (should see masked)
CONNECT TELLER_01/Teller01Pass!
GRANT SELECT ON BANK_SCHEMA.V_ACCOUNTS_MASKED TO TELLER_01;

SELECT account_number FROM BANK_SCHEMA.V_ACCOUNTS_MASKED;
-- Expected: XXXXXXXXXXXXXXXXXXXXXX0001

-- As manager (grant unmask role first)
CONNECT sys AS SYSDBA
GRANT UNMASK_ACCOUNT_ROLE TO MANAGER_01;
GRANT SELECT ON BANK_SCHEMA.ACCOUNTS TO MANAGER_01;

CONNECT MANAGER_01/Manager01Pass!
SELECT account_number FROM BANK_SCHEMA.ACCOUNTS;
-- Expected: RO49AAAA1B31007593840001 (full number)
```

---

## Scenario 6: Complete Demonstration Flow

**Objective**: End-to-end scenario showing all security features

### Demo Script

```sql
-- ==================================================================
-- COMPLETE SECURITY DEMONSTRATION
-- Shows all N1 requirements in action
-- ==================================================================

-- 1. TELLER LOGIN
CONNECT TELLER_01/Teller01Pass!

-- Teller views accounts (sees masked account numbers)
SELECT account_id, account_number, balance
FROM BANK_SCHEMA.V_ACCOUNTS_MASKED
WHERE branch_id = 1;

-- Teller processes deposit
INSERT INTO BANK_SCHEMA.TRANSACTIONS VALUES (
  BANK_SCHEMA.SEQ_TRANSACTION_ID.NEXTVAL,
  'DEPOSIT',
  2000.00,
  SYSTIMESTAMP,
  'COMPLETED',
  1001,
  NULL,
  101,
  'Customer deposit',
  'REF-DEMO-001',
  NULL
);
COMMIT;

-- 2. MANAGER LOGIN
CONNECT MANAGER_01/Manager01Pass!

-- Manager views full account details (unmasked)
SELECT account_id, account_number, balance
FROM BANK_SCHEMA.ACCOUNTS
WHERE branch_id = 1;

-- Manager creates new account
INSERT INTO BANK_SCHEMA.ACCOUNTS VALUES (
  BANK_SCHEMA.SEQ_ACCOUNT_ID.NEXTVAL,
  'RO49AAAA1B31007593840099',
  'SAVINGS',
  10000.00,
  'RON',
  SYSDATE,
  'ACTIVE',
  1,
  'New Customer',
  'RO999888777',
  USER,
  SYSDATE,
  NULL
);
COMMIT;

-- 3. AUDITOR REVIEW
CONNECT AUDITOR_01/Auditor01Pass!

-- Auditor views standard audit trail
SELECT username, timestamp, action_name, obj_name
FROM DBA_AUDIT_TRAIL
WHERE owner = 'BANK_SCHEMA'
  AND timestamp >= SYSDATE - 1
ORDER BY timestamp DESC
FETCH FIRST 10 ROWS ONLY;

-- Auditor views FGA trail (balance access)
SELECT db_user, timestamp, sql_text
FROM DBA_FGA_AUDIT_TRAIL
WHERE object_schema = 'BANK_SCHEMA'
ORDER BY timestamp DESC
FETCH FIRST 5 ROWS ONLY;

-- Auditor views custom audit log
SELECT username, action_type, table_name, audit_timestamp
FROM BANK_SCHEMA.AUDIT_LOG
ORDER BY audit_timestamp DESC
FETCH FIRST 10 ROWS ONLY;

-- 4. SECURITY VERIFICATION
CONNECT sys AS SYSDBA

-- Verify encryption
SELECT table_name, column_name, encryption_alg
FROM DBA_ENCRYPTED_COLUMNS
WHERE owner = 'BANK_SCHEMA';

-- Verify audit policies
SELECT object_name, policy_name, enabled
FROM DBA_AUDIT_POLICIES
WHERE object_schema = 'BANK_SCHEMA';

-- Verify resource limits
SELECT username, profile, account_status, resource_name, limit
FROM DBA_USERS u
JOIN DBA_PROFILES p ON u.profile = p.profile
WHERE username IN ('TELLER_01', 'MANAGER_01', 'AUDITOR_01')
  AND resource_name IN ('SESSIONS_PER_USER', 'CONNECT_TIME', 'IDLE_TIME')
ORDER BY username, resource_name;

PROMPT Demonstration completed successfully!
PROMPT All N1 security requirements verified.
```

---

## Troubleshooting

### Issue 1: TDE Not Available

**Symptom**: `ORA-28336: cannot encrypt SYS owned objects`

**Solution**: Use DBMS_CRYPTO fallback (see `research.md`)

### Issue 2: Audit Trail Not Logging

**Symptom**: No records in DBA_AUDIT_TRAIL

**Solution**:
```sql
-- Check audit_trail parameter
SHOW PARAMETER audit_trail;

-- Enable if not set
ALTER SYSTEM SET AUDIT_TRAIL=DB,EXTENDED SCOPE=SPFILE;
SHUTDOWN IMMEDIATE;
STARTUP;
```

### Issue 3: Masking Function Not Working

**Symptom**: All users see masked data

**Solution**:
```sql
-- Grant unmask role explicitly
GRANT UNMASK_ACCOUNT_ROLE TO MANAGER_01;

-- Or check role in function
SELECT granted_role FROM USER_ROLE_PRIVS;
```

---

## Next Steps

1. ✅ Complete N1 requirements (Phases 1-5)
2. → Implement N2 requirements (Phases 6-7)
3. → Add N3 complexity features (Phase 8)
4. → Document with screenshots
5. → Prepare presentation

---

*Quick start guide completed: 2026-04-04*
