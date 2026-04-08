-- ============================================
-- BANK SECURITY PROJECT - SCHEMA CREATION
-- Phase 1: Database Schema (N1 - Requirement 1)
-- ============================================
-- Student: <Your Name>
-- Group: <Your Group>
-- Date: 2026-04-04
-- Requirement: N1 - Requirement 1 (CRITICAL - MANDATORY)
-- ============================================

-- Set output formatting
SET SERVEROUTPUT ON
SET LINESIZE 200
SET PAGESIZE 100

PROMPT ========================================
PROMPT Starting Schema Creation
PROMPT ========================================

-- Drop existing objects for clean re-runs
BEGIN
  FOR t IN (SELECT table_name FROM user_tables ORDER BY table_name DESC) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    DBMS_OUTPUT.PUT_LINE('Dropped table: ' || t.table_name);
  END LOOP;

  FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    DBMS_OUTPUT.PUT_LINE('Dropped sequence: ' || s.sequence_name);
  END LOOP;
END;
/

PROMPT ========================================
PROMPT Creating Sequences
PROMPT ========================================

CREATE SEQUENCE SEQ_BANK_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_BRANCH_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_ACCOUNT_ID START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TRANSACTION_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_USER_ID START WITH 101 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_ROLE_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_PRIV_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_SESSION_ID START WITH 1 INCREMENT BY 1 NOCACHE;

PROMPT Sequences created successfully

PROMPT ========================================
PROMPT Creating Tables
PROMPT ========================================

-- ============================================
-- Table 1: BANKS
-- ============================================
PROMPT Creating BANKS table...

CREATE TABLE BANKS (
  bank_id NUMBER PRIMARY KEY,
  bank_name VARCHAR2(100) NOT NULL UNIQUE,
  swift_code VARCHAR2(11) UNIQUE,
  country VARCHAR2(50) NOT NULL,
  regulatory_id VARCHAR2(50),
  established_date DATE,
  created_date DATE DEFAULT SYSDATE
);

COMMENT ON TABLE BANKS IS 'Bank master data and regulatory information';
COMMENT ON COLUMN BANKS.bank_id IS 'Unique bank identifier';
COMMENT ON COLUMN BANKS.swift_code IS 'International bank code (BIC format - 8 or 11 characters)';

-- ============================================
-- Table 2: BRANCHES
-- ============================================
PROMPT Creating BRANCHES table...

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

COMMENT ON TABLE BRANCHES IS 'Bank branch locations';
COMMENT ON COLUMN BRANCHES.branch_code IS 'Branch code for routing (unique within bank)';

-- ============================================
-- Table 3: ACCOUNTS
-- ============================================
PROMPT Creating ACCOUNTS table...

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
  created_by VARCHAR2(128) DEFAULT USER,
  created_date DATE DEFAULT SYSDATE,
  last_modified DATE,
  CONSTRAINT FK_ACCOUNT_BRANCH FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id),
  CONSTRAINT CHK_BALANCE_NON_NEGATIVE CHECK (balance >= 0),
  CONSTRAINT CHK_ACCOUNT_STATUS CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
  CONSTRAINT CHK_ACCOUNT_TYPE CHECK (account_type IN ('CHECKING', 'SAVINGS', 'BUSINESS'))
);

COMMENT ON TABLE ACCOUNTS IS 'Customer account information - BALANCE WILL BE ENCRYPTED IN PHASE 2';
COMMENT ON COLUMN ACCOUNTS.balance IS 'Current balance - SENSITIVE DATA - will be encrypted';
COMMENT ON COLUMN ACCOUNTS.account_number IS 'IBAN format - SENSITIVE DATA - will be masked';

-- ============================================
-- Table 4: DB_USERS
-- ============================================
PROMPT Creating DB_USERS table...

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

COMMENT ON TABLE DB_USERS IS 'Application user metadata (not Oracle users)';
COMMENT ON COLUMN DB_USERS.department IS 'TELLER, MANAGER, AUDIT, IT';

-- ============================================
-- Table 5: TRANSACTIONS
-- ============================================
PROMPT Creating TRANSACTIONS table...

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

COMMENT ON TABLE TRANSACTIONS IS 'Complete transaction history - ALL DML WILL BE AUDITED';
COMMENT ON COLUMN TRANSACTIONS.reversal_of IS 'References original transaction if this is a reversal';

-- ============================================
-- Table 6: ROLES
-- ============================================
PROMPT Creating ROLES table...

CREATE TABLE ROLES (
  role_id NUMBER PRIMARY KEY,
  role_name VARCHAR2(50) UNIQUE NOT NULL,
  description VARCHAR2(200),
  parent_role_id NUMBER,
  created_date DATE DEFAULT SYSDATE,
  CONSTRAINT FK_ROLE_PARENT FOREIGN KEY (parent_role_id) REFERENCES ROLES(role_id)
);

COMMENT ON TABLE ROLES IS 'Security roles for RBAC - maps to Oracle roles';
COMMENT ON COLUMN ROLES.parent_role_id IS 'Role hierarchy - child inherits parent privileges';

-- ============================================
-- Table 7: ROLE_PRIVS
-- ============================================
PROMPT Creating ROLE_PRIVS table...

CREATE TABLE ROLE_PRIVS (
  priv_id NUMBER PRIMARY KEY,
  role_id NUMBER NOT NULL,
  privilege_type VARCHAR2(20) NOT NULL,
  privilege_name VARCHAR2(50) NOT NULL,
  object_name VARCHAR2(100),
  grantable VARCHAR2(1) DEFAULT 'N',
  CONSTRAINT FK_PRIV_ROLE FOREIGN KEY (role_id) REFERENCES ROLES(role_id),
  CONSTRAINT UQ_ROLE_PRIV UNIQUE (role_id, privilege_name, object_name),
  CONSTRAINT CHK_PRIV_TYPE CHECK (privilege_type IN ('SYSTEM', 'OBJECT')),
  CONSTRAINT CHK_GRANTABLE CHECK (grantable IN ('Y', 'N'))
);

COMMENT ON TABLE ROLE_PRIVS IS 'Privilege mappings to roles';

-- ============================================
-- Table 8: USER_SESSIONS
-- ============================================
PROMPT Creating USER_SESSIONS table...

CREATE TABLE USER_SESSIONS (
  session_id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  login_time TIMESTAMP DEFAULT SYSTIMESTAMP,
  logout_time TIMESTAMP,
  ip_address VARCHAR2(50),
  branch_id NUMBER,
  oracle_sid NUMBER,
  status VARCHAR2(20) DEFAULT 'ACTIVE',
  CONSTRAINT FK_SESSION_USER FOREIGN KEY (user_id) REFERENCES DB_USERS(user_id),
  CONSTRAINT CHK_SESSION_STATUS CHECK (status IN ('ACTIVE', 'EXPIRED', 'TERMINATED'))
);

COMMENT ON TABLE USER_SESSIONS IS 'User login sessions - used for application context';

-- ============================================
-- Table 9: AUDIT_LOG
-- ============================================
PROMPT Creating AUDIT_LOG table...

CREATE TABLE AUDIT_LOG (
  audit_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  audit_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  username VARCHAR2(128) NOT NULL,
  action_type VARCHAR2(10) NOT NULL,
  table_name VARCHAR2(128) NOT NULL,
  record_id NUMBER,
  old_value VARCHAR2(4000),
  new_value VARCHAR2(4000),
  ip_address VARCHAR2(50),
  session_id NUMBER,
  sql_text CLOB,
  CONSTRAINT CHK_AUDIT_ACTION CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT'))
);

COMMENT ON TABLE AUDIT_LOG IS 'Custom audit trail - IMMUTABLE (trigger prevents UPDATE/DELETE)';

PROMPT ========================================
PROMPT Creating Indexes
PROMPT ========================================

-- Performance indexes
CREATE INDEX IDX_ACCOUNTS_BRANCH ON ACCOUNTS(branch_id);
CREATE INDEX IDX_ACCOUNTS_STATUS ON ACCOUNTS(status);
CREATE INDEX IDX_ACCOUNTS_CUSTOMER ON ACCOUNTS(customer_name);

CREATE INDEX IDX_TXN_FROM_ACCOUNT ON TRANSACTIONS(from_account_id);
CREATE INDEX IDX_TXN_TO_ACCOUNT ON TRANSACTIONS(to_account_id);
CREATE INDEX IDX_TXN_TIMESTAMP ON TRANSACTIONS(txn_timestamp);
CREATE INDEX IDX_TXN_STATUS ON TRANSACTIONS(status);

CREATE INDEX IDX_AUDIT_TIMESTAMP ON AUDIT_LOG(audit_timestamp);
CREATE INDEX IDX_AUDIT_USERNAME ON AUDIT_LOG(username);
CREATE INDEX IDX_AUDIT_TABLE ON AUDIT_LOG(table_name);

CREATE INDEX IDX_USERS_BRANCH ON DB_USERS(branch_id);
CREATE INDEX IDX_USERS_STATUS ON DB_USERS(status);

PROMPT Indexes created successfully

PROMPT ========================================
PROMPT Inserting Sample Data
PROMPT ========================================

-- ============================================
-- Sample Data: BANKS
-- ============================================
PROMPT Inserting BANKS...

INSERT INTO BANKS VALUES (
  SEQ_BANK_ID.NEXTVAL,
  'National Bank of Romania',
  'NBORROBB',
  'Romania',
  'RO-BNK-001',
  DATE '1990-01-01',
  SYSDATE
);

INSERT INTO BANKS VALUES (
  SEQ_BANK_ID.NEXTVAL,
  'UniCredit Bank Romania',
  'BACXROBU',
  'Romania',
  'RO-BNK-002',
  DATE '1997-05-15',
  SYSDATE
);

PROMPT BANKS: 2 rows inserted

-- ============================================
-- Sample Data: BRANCHES
-- ============================================
PROMPT Inserting BRANCHES...

INSERT INTO BRANCHES VALUES (
  SEQ_BRANCH_ID.NEXTVAL,
  1,
  'NBR Bucharest Central',
  'NBR-BUC-001',
  'Strada Lipscani 25',
  'Bucharest',
  '+40-21-312-4567',
  'Ion Popescu',
  'ACTIVE'
);

INSERT INTO BRANCHES VALUES (
  SEQ_BRANCH_ID.NEXTVAL,
  1,
  'NBR Cluj Branch',
  'NBR-CLJ-001',
  'Piata Unirii 10',
  'Cluj-Napoca',
  '+40-264-432-111',
  'Maria Ionescu',
  'ACTIVE'
);

INSERT INTO BRANCHES VALUES (
  SEQ_BRANCH_ID.NEXTVAL,
  2,
  'UniCredit Timisoara',
  'UCI-TIM-001',
  'Bulevardul Revolutiei 5',
  'Timisoara',
  '+40-256-123-456',
  'Andrei Vasilescu',
  'ACTIVE'
);

PROMPT BRANCHES: 3 rows inserted

-- ============================================
-- Sample Data: DB_USERS
-- ============================================
PROMPT Inserting DB_USERS...

INSERT INTO DB_USERS VALUES (
  SEQ_USER_ID.NEXTVAL,
  'teller01',
  'teller01@bank.ro',
  'EMP-1001',
  'Ana Teller',
  'ACTIVE',
  1,
  'TELLER',
  DATE '2023-01-10',
  SYSDATE,
  NULL
);

INSERT INTO DB_USERS VALUES (
  SEQ_USER_ID.NEXTVAL,
  'teller02',
  'teller02@bank.ro',
  'EMP-1002',
  'Mihai Teller',
  'ACTIVE',
  2,
  'TELLER',
  DATE '2023-03-15',
  SYSDATE,
  NULL
);

INSERT INTO DB_USERS VALUES (
  SEQ_USER_ID.NEXTVAL,
  'manager01',
  'manager01@bank.ro',
  'EMP-2001',
  'Ion Manager',
  'ACTIVE',
  1,
  'MANAGER',
  DATE '2020-05-15',
  SYSDATE,
  NULL
);

INSERT INTO DB_USERS VALUES (
  SEQ_USER_ID.NEXTVAL,
  'manager02',
  'manager02@bank.ro',
  'EMP-2002',
  'Elena Manager',
  'ACTIVE',
  2,
  'MANAGER',
  DATE '2021-02-20',
  SYSDATE,
  NULL
);

INSERT INTO DB_USERS VALUES (
  SEQ_USER_ID.NEXTVAL,
  'auditor01',
  'auditor01@bank.ro',
  'EMP-3001',
  'Maria Auditor',
  'ACTIVE',
  NULL,
  'AUDIT',
  DATE '2021-03-20',
  SYSDATE,
  NULL
);

INSERT INTO DB_USERS VALUES (
  SEQ_USER_ID.NEXTVAL,
  'dba01',
  'dba01@bank.ro',
  'EMP-4001',
  'Vasile DBA',
  'ACTIVE',
  NULL,
  'IT',
  DATE '2019-01-05',
  SYSDATE,
  NULL
);

PROMPT DB_USERS: 6 rows inserted

-- ============================================
-- Sample Data: ACCOUNTS
-- ============================================
PROMPT Inserting ACCOUNTS...

INSERT INTO ACCOUNTS VALUES (
  SEQ_ACCOUNT_ID.NEXTVAL,
  'RO49AAAA1B31007593840001',
  'CHECKING',
  25000.00,
  'RON',
  DATE '2024-01-15',
  'ACTIVE',
  1,
  'Andrei Vasilescu',
  'RO123456789',
  USER,
  SYSDATE,
  NULL
);

INSERT INTO ACCOUNTS VALUES (
  SEQ_ACCOUNT_ID.NEXTVAL,
  'RO49AAAA1B31007593840002',
  'SAVINGS',
  50000.00,
  'RON',
  DATE '2024-02-20',
  'ACTIVE',
  1,
  'Elena Dumitrescu',
  'RO987654321',
  USER,
  SYSDATE,
  NULL
);

INSERT INTO ACCOUNTS VALUES (
  SEQ_ACCOUNT_ID.NEXTVAL,
  'RO49AAAA1B31007593840003',
  'CHECKING',
  15000.00,
  'RON',
  DATE '2024-03-10',
  'ACTIVE',
  1,
  'Mihai Popescu',
  'RO111222333',
  USER,
  SYSDATE,
  NULL
);

INSERT INTO ACCOUNTS VALUES (
  SEQ_ACCOUNT_ID.NEXTVAL,
  'RO49AAAA2B31007593840004',
  'BUSINESS',
  100000.00,
  'RON',
  DATE '2024-01-05',
  'ACTIVE',
  2,
  'Tech Consulting SRL',
  'RO444555666',
  USER,
  SYSDATE,
  NULL
);

INSERT INTO ACCOUNTS VALUES (
  SEQ_ACCOUNT_ID.NEXTVAL,
  'RO49AAAA2B31007593840005',
  'SAVINGS',
  75000.00,
  'RON',
  DATE '2024-02-15',
  'ACTIVE',
  2,
  'Ana Ionescu',
  'RO777888999',
  USER,
  SYSDATE,
  NULL
);

INSERT INTO ACCOUNTS VALUES (
  SEQ_ACCOUNT_ID.NEXTVAL,
  'RO49AAAA3B31007593840006',
  'CHECKING',
  30000.00,
  'RON',
  DATE '2024-03-20',
  'ACTIVE',
  3,
  'Ion Georgescu',
  'RO000111222',
  USER,
  SYSDATE,
  NULL
);

PROMPT ACCOUNTS: 6 rows inserted

-- ============================================
-- Sample Data: TRANSACTIONS
-- ============================================
PROMPT Inserting TRANSACTIONS...

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'DEPOSIT',
  5000.00,
  SYSTIMESTAMP,
  'COMPLETED',
  1001,
  NULL,
  101,
  'Initial deposit',
  'REF-001-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'WITHDRAWAL',
  500.00,
  SYSTIMESTAMP - INTERVAL '2' HOUR,
  'COMPLETED',
  1001,
  NULL,
  101,
  'ATM withdrawal',
  'REF-002-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'TRANSFER',
  1000.00,
  SYSTIMESTAMP - INTERVAL '1' DAY,
  'COMPLETED',
  1001,
  1002,
  101,
  'Monthly savings',
  'REF-003-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'DEPOSIT',
  10000.00,
  SYSTIMESTAMP - INTERVAL '3' DAY,
  'COMPLETED',
  1002,
  NULL,
  103,
  'Salary deposit',
  'REF-004-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'WITHDRAWAL',
  2000.00,
  SYSTIMESTAMP - INTERVAL '5' DAY,
  'COMPLETED',
  1003,
  NULL,
  102,
  'Cash withdrawal',
  'REF-005-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'TRANSFER',
  5000.00,
  SYSTIMESTAMP - INTERVAL '7' DAY,
  'COMPLETED',
  1004,
  1005,
  104,
  'Business payment',
  'REF-006-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'DEPOSIT',
  15000.00,
  SYSTIMESTAMP - INTERVAL '10' DAY,
  'COMPLETED',
  1005,
  NULL,
  104,
  'Investment return',
  'REF-007-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'WITHDRAWAL',
  800.00,
  SYSTIMESTAMP - INTERVAL '12' DAY,
  'COMPLETED',
  1006,
  NULL,
  102,
  'ATM withdrawal',
  'REF-008-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'TRANSFER',
  3000.00,
  SYSTIMESTAMP - INTERVAL '15' DAY,
  'COMPLETED',
  1003,
  1004,
  101,
  'Service payment',
  'REF-009-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

INSERT INTO TRANSACTIONS VALUES (
  SEQ_TRANSACTION_ID.NEXTVAL,
  'DEPOSIT',
  7500.00,
  SYSTIMESTAMP - INTERVAL '20' DAY,
  'COMPLETED',
  1006,
  NULL,
  102,
  'Client payment',
  'REF-010-' || TO_CHAR(SYSDATE, 'YYYYMMDD'),
  NULL
);

PROMPT TRANSACTIONS: 10 rows inserted

-- ============================================
-- Sample Data: ROLES
-- ============================================
PROMPT Inserting ROLES...

INSERT INTO ROLES VALUES (
  SEQ_ROLE_ID.NEXTVAL,
  'BASE_EMPLOYEE_ROLE',
  'Basic privileges for all employees',
  NULL,
  SYSDATE
);

INSERT INTO ROLES VALUES (
  SEQ_ROLE_ID.NEXTVAL,
  'TELLER_ROLE',
  'Standard teller privileges',
  1,  -- inherits from BASE_EMPLOYEE_ROLE
  SYSDATE
);

INSERT INTO ROLES VALUES (
  SEQ_ROLE_ID.NEXTVAL,
  'SENIOR_TELLER_ROLE',
  'Senior teller with elevated access',
  2,  -- inherits from TELLER_ROLE
  SYSDATE
);

INSERT INTO ROLES VALUES (
  SEQ_ROLE_ID.NEXTVAL,
  'MANAGER_ROLE',
  'Branch manager full access',
  3,  -- inherits from SENIOR_TELLER_ROLE
  SYSDATE
);

INSERT INTO ROLES VALUES (
  SEQ_ROLE_ID.NEXTVAL,
  'AUDITOR_ROLE',
  'Read-only audit access',
  1,  -- inherits from BASE_EMPLOYEE_ROLE
  SYSDATE
);

INSERT INTO ROLES VALUES (
  SEQ_ROLE_ID.NEXTVAL,
  'DBA_ROLE',
  'Database administrator',
  NULL,  -- top-level role
  SYSDATE
);

PROMPT ROLES: 6 rows inserted

COMMIT;

PROMPT ========================================
PROMPT Verification
PROMPT ========================================

SET LINESIZE 200

PROMPT Table row counts:
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
SELECT 'ROLES', COUNT(*) FROM ROLES
UNION ALL
SELECT 'ROLE_PRIVS', COUNT(*) FROM ROLE_PRIVS
UNION ALL
SELECT 'USER_SESSIONS', COUNT(*) FROM USER_SESSIONS
UNION ALL
SELECT 'AUDIT_LOG', COUNT(*) FROM AUDIT_LOG
ORDER BY table_name;

PROMPT
PROMPT Constraint verification:
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('ACCOUNTS', 'TRANSACTIONS', 'BRANCHES')
ORDER BY table_name, constraint_type;

PROMPT
PROMPT Index verification:
SELECT index_name, table_name, uniqueness
FROM user_indexes
WHERE table_name IN ('ACCOUNTS', 'TRANSACTIONS', 'AUDIT_LOG')
ORDER BY table_name, index_name;

PROMPT ========================================
PROMPT Schema Creation Complete!
PROMPT ========================================
PROMPT
PROMPT Summary:
PROMPT - 9 tables created with constraints
PROMPT - 8 sequences created
PROMPT - 13 indexes created for performance
PROMPT - Sample data: 2 banks, 3 branches, 6 accounts, 10 transactions, 6 users, 6 roles
PROMPT
PROMPT Next Steps:
PROMPT 1. Run 02-criptare.sql for encryption (N1 - Requirement 2)
PROMPT 2. Run 03-audit.sql for auditing (N1 - Requirement 3)
PROMPT 3. Run 04-gestiune_identitati.sql for identity management (N1 - Requirement 4)
PROMPT
PROMPT Status: Phase 1 Complete - N1 Requirement 1 DONE
PROMPT ========================================
