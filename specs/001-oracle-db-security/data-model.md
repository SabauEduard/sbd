# Data Model: Oracle Database Security for Banking Transactions

**Feature**: 001-oracle-db-security  
**Model Date**: 2026-04-04  
**Purpose**: Complete entity-relationship design for secure banking database

---

## Conceptual Model (ERD)

```
┌──────────────┐         ┌──────────────┐         ┌──────────────────┐
│    BANKS     │         │   BRANCHES   │         │    ACCOUNTS      │
│──────────────│         │──────────────│         │──────────────────│
│ *bank_id     │────────<│ *branch_id   │────────<│ *account_id      │
│  bank_name   │   1:N   │  branch_name │   1:N   │  account_number  │
│  swift_code  │         │  address     │         │  account_type    │
│  country     │         │  phone       │         │  balance (ENC)   │
└──────────────┘         │  bank_id (FK)│         │  opening_date    │
                         └──────────────┘         │  status          │
                                                   │  branch_id (FK)  │
                                                   │  created_by      │
                                                   └──────────────────┘
                                                            │
                                                            │ 1:N
                                                            │
                                                            ▼
                                         ┌─────────────────────────────┐
                                         │      TRANSACTIONS           │
                                         │─────────────────────────────│
                                         │ *transaction_id             │
                                         │  txn_type                   │
                                         │  amount                     │
                                         │  txn_timestamp              │
                                         │  status                     │
                                         │  from_account_id (FK)       │
                                         │  to_account_id (FK) [null]  │
                                         │  initiated_by (FK)          │
                                         │  description                │
                                         └─────────────────────────────┘
                                                      △
                                                      │
                                                      │ N:1
                                                      │
┌──────────────┐         ┌──────────────┐            │
│    ROLES     │         │   DB_USERS   │────────────┘
│──────────────│         │──────────────│     Initiates
│ *role_id     │<───────>│ *user_id     │
│  role_name   │   N:M   │  username    │
│  description │         │  email       │
└──────────────┘         │  status      │
       △                 │  branch_id(FK)│
       │                 │  created_date │
       │ 1:N             └──────────────┘
       │                         │
       │                         │ 1:N
┌──────────────┐                 ▼
│ ROLE_PRIVS   │         ┌──────────────┐
│──────────────│         │USER_SESSIONS │
│*priv_id      │         │──────────────│
│ role_id (FK) │         │*session_id   │
│ privilege    │         │ user_id (FK) │
│ object_name  │         │ login_time   │
└──────────────┘         │ logout_time  │
                         │ ip_address   │
                         │ branch_id    │
                         └──────────────┘

       ┌──────────────────────────┐
       │      AUDIT_LOG           │
       │──────────────────────────│
       │ *audit_id                │
       │  audit_timestamp         │
       │  username                │
       │  action_type             │
       │  table_name              │
       │  record_id               │
       │  old_value               │
       │  new_value               │
       │  ip_address              │
       │  session_id              │
       └──────────────────────────┘

Legend:
* = Primary Key
FK = Foreign Key
(ENC) = Encrypted column
<──> = Many-to-Many
──<  = One-to-Many
```

---

## Entities

### 1. BANKS

**Purpose**: Store bank master data and regulatory information.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| bank_id | NUMBER | PK, NOT NULL | Unique bank identifier |
| bank_name | VARCHAR2(100) | NOT NULL, UNIQUE | Official bank name |
| swift_code | VARCHAR2(11) | UNIQUE | International bank code |
| country | VARCHAR2(50) | NOT NULL | Country of registration |
| regulatory_id | VARCHAR2(50) | | National banking authority ID |
| established_date | DATE | | Bank founding date |
| created_date | DATE | DEFAULT SYSDATE | Record creation timestamp |

**Business Rules**:
- SWIFT code must be 8 or 11 characters (BIC format)
- Bank names must be unique within country
- Cannot delete bank if branches exist

**Sample Data**:
```sql
INSERT INTO BANKS VALUES (1, 'National Bank of Romania', 'NBORROBB', 'Romania', 'RO-BNK-001', DATE '1990-01-01', SYSDATE);
INSERT INTO BANKS VALUES (2, 'UniCredit Bank', 'BACXROBU', 'Romania', 'RO-BNK-002', DATE '1997-05-15', SYSDATE);
```

---

### 2. BRANCHES

**Purpose**: Store bank branch locations.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| branch_id | NUMBER | PK, NOT NULL | Unique branch identifier |
| bank_id | NUMBER | FK → BANKS, NOT NULL | Parent bank |
| branch_name | VARCHAR2(100) | NOT NULL | Branch name |
| branch_code | VARCHAR2(20) | UNIQUE, NOT NULL | Branch code (routing) |
| address | VARCHAR2(200) | NOT NULL | Physical address |
| city | VARCHAR2(50) | NOT NULL | City location |
| phone | VARCHAR2(20) | | Contact phone |
| manager_name | VARCHAR2(100) | | Branch manager |
| status | VARCHAR2(10) | DEFAULT 'ACTIVE' | ACTIVE/INACTIVE |

**Business Rules**:
- Branch codes unique within bank
- Cannot delete branch if accounts exist
- At least one active branch per bank

**Sample Data**:
```sql
INSERT INTO BRANCHES VALUES (1, 1, 'NBR Bucharest Central', 'NBR-BUC-001', 'Strada Lipscani 25', 'Bucharest', '+40-21-312-4567', 'Ion Popescu', 'ACTIVE');
INSERT INTO BRANCHES VALUES (2, 1, 'NBR Cluj Branch', 'NBR-CLJ-001', 'Piata Unirii 10', 'Cluj-Napoca', '+40-264-432-111', 'Maria Ionescu', 'ACTIVE');
```

---

### 3. ACCOUNTS

**Purpose**: Store customer account information with encrypted balances.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| account_id | NUMBER | PK, NOT NULL | Unique account identifier |
| account_number | VARCHAR2(34) | UNIQUE, NOT NULL | IBAN format account number |
| account_type | VARCHAR2(20) | NOT NULL | CHECKING/SAVINGS/BUSINESS |
| balance | NUMBER(15,2) | **ENCRYPTED**, NOT NULL | Current balance (sensitive) |
| currency | VARCHAR2(3) | DEFAULT 'RON' | Currency code (ISO 4217) |
| opening_date | DATE | DEFAULT SYSDATE | Account opening date |
| status | VARCHAR2(10) | DEFAULT 'ACTIVE' | ACTIVE/FROZEN/CLOSED |
| branch_id | NUMBER | FK → BRANCHES, NOT NULL | Home branch |
| customer_name | VARCHAR2(100) | NOT NULL | Account holder name |
| customer_tax_id | VARCHAR2(20) | | Tax identification number |
| created_by | VARCHAR2(128) | | Database user who created |
| created_date | DATE | DEFAULT SYSDATE | Creation timestamp |
| last_modified | DATE | | Last modification timestamp |

**Business Rules**:
- Account numbers follow IBAN format (RO49AAAA1B31007593840000)
- Balance cannot be negative (CHECK constraint)
- Balance column encrypted with TDE (AES256)
- Cannot delete account with non-zero balance
- Status transitions: ACTIVE → FROZEN → CLOSED (irreversible)

**Security Requirements**:
- **ENCRYPTION**: Balance column encrypted at rest
- **MASKING**: Account number masked for unauthorized users
- **AUDIT**: All updates logged
- **ACCESS**: Row-level security by branch (VPD policy)

**Sample Data**:
```sql
INSERT INTO ACCOUNTS VALUES (1001, 'RO49AAAA1B31007593840001', 'CHECKING', 25000.00, 'RON', DATE '2024-01-15', 'ACTIVE', 1, 'Andrei Vasilescu', 'RO123456789', 'MANAGER_01', SYSDATE, NULL);
INSERT INTO ACCOUNTS VALUES (1002, 'RO49AAAA1B31007593840002', 'SAVINGS', 50000.00, 'RON', DATE '2024-02-20', 'ACTIVE', 1, 'Elena Dumitrescu', 'RO987654321', 'MANAGER_01', SYSDATE, NULL);
```

---

### 4. TRANSACTIONS

**Purpose**: Store complete transaction history for all accounts.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| transaction_id | NUMBER | PK, NOT NULL | Unique transaction ID |
| txn_type | VARCHAR2(20) | NOT NULL | DEPOSIT/WITHDRAWAL/TRANSFER |
| amount | NUMBER(15,2) | NOT NULL, CHECK > 0 | Transaction amount |
| txn_timestamp | TIMESTAMP | DEFAULT SYSTIMESTAMP | Transaction timestamp |
| status | VARCHAR2(20) | DEFAULT 'COMPLETED' | PENDING/COMPLETED/FAILED/REVERSED |
| from_account_id | NUMBER | FK → ACCOUNTS, NOT NULL | Source account |
| to_account_id | NUMBER | FK → ACCOUNTS | Destination (transfers only) |
| initiated_by | NUMBER | FK → DB_USERS | User who initiated |
| description | VARCHAR2(200) | | Transaction description |
| reference_number | VARCHAR2(50) | UNIQUE | External reference |
| reversal_of | NUMBER | FK → TRANSACTIONS | Original txn if reversal |

**Business Rules**:
- Amount must be positive
- For DEPOSIT: to_account_id must be NULL
- For WITHDRAWAL: to_account_id must be NULL
- For TRANSFER: both from_account_id and to_account_id required
- Cannot transfer to same account
- Cannot modify completed transactions
- Reversals create new transaction with reversal_of link

**Security Requirements**:
- **AUDIT**: All INSERT/UPDATE/DELETE trigger custom audit
- **ACCESS**: Users can only see transactions for accounts they access
- **INTEGRITY**: Transaction triggers update account balances

**Sample Data**:
```sql
INSERT INTO TRANSACTIONS VALUES (1, 'DEPOSIT', 5000.00, SYSTIMESTAMP, 'COMPLETED', 1001, NULL, 101, 'Initial deposit', 'REF-001', NULL);
INSERT INTO TRANSACTIONS VALUES (2, 'WITHDRAWAL', 500.00, SYSTIMESTAMP, 'COMPLETED', 1001, NULL, 101, 'ATM withdrawal', 'REF-002', NULL);
INSERT INTO TRANSACTIONS VALUES (3, 'TRANSFER', 1000.00, SYSTIMESTAMP, 'COMPLETED', 1001, 1002, 101, 'Monthly savings', 'REF-003', NULL);
```

---

### 5. DB_USERS

**Purpose**: Store application user metadata (not Oracle database users).

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | NUMBER | PK, NOT NULL | Unique user identifier |
| username | VARCHAR2(50) | UNIQUE, NOT NULL | Login username |
| email | VARCHAR2(100) | UNIQUE | User email |
| employee_id | VARCHAR2(20) | | Employee badge number |
| full_name | VARCHAR2(100) | NOT NULL | Full legal name |
| status | VARCHAR2(10) | DEFAULT 'ACTIVE' | ACTIVE/SUSPENDED/TERMINATED |
| branch_id | NUMBER | FK → BRANCHES, NOT NULL | Assigned branch |
| department | VARCHAR2(50) | | Department (TELLER/MANAGER/AUDIT) |
| hire_date | DATE | DEFAULT SYSDATE | Employment start date |
| created_date | DATE | DEFAULT SYSDATE | Record creation date |
| last_login | TIMESTAMP | | Last successful login |

**Business Rules**:
- Username must be unique
- Email must be valid format
- Cannot delete user with transaction history
- Terminated users retain records for audit

**Security Requirements**:
- Passwords stored in Oracle user accounts (not this table)
- This table used for application context population
- Resource quotas assigned via Oracle profiles

**Sample Data**:
```sql
INSERT INTO DB_USERS VALUES (101, 'teller01', 'teller01@bank.ro', 'EMP-1001', 'Ana Teller', 'ACTIVE', 1, 'TELLER', DATE '2023-01-10', SYSDATE, NULL);
INSERT INTO DB_USERS VALUES (102, 'manager01', 'manager01@bank.ro', 'EMP-2001', 'Ion Manager', 'ACTIVE', 1, 'MANAGER', DATE '2020-05-15', SYSDATE, NULL);
INSERT INTO DB_USERS VALUES (103, 'auditor01', 'auditor01@bank.ro', 'EMP-3001', 'Maria Auditor', 'ACTIVE', NULL, 'AUDIT', DATE '2021-03-20', SYSDATE, NULL);
```

---

### 6. ROLES

**Purpose**: Define security roles for RBAC.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| role_id | NUMBER | PK, NOT NULL | Unique role identifier |
| role_name | VARCHAR2(50) | UNIQUE, NOT NULL | Role name (Oracle role name) |
| description | VARCHAR2(200) | | Role purpose description |
| parent_role_id | NUMBER | FK → ROLES | Parent role (hierarchy) |
| created_date | DATE | DEFAULT SYSDATE | Role creation date |

**Business Rules**:
- Role names match Oracle role names
- Hierarchy: BASE_EMPLOYEE → TELLER → SENIOR_TELLER → MANAGER
- Cannot delete role assigned to users

**Sample Data**:
```sql
INSERT INTO ROLES VALUES (1, 'BASE_EMPLOYEE_ROLE', 'Basic privileges for all employees', NULL, SYSDATE);
INSERT INTO ROLES VALUES (2, 'TELLER_ROLE', 'Standard teller privileges', 1, SYSDATE);
INSERT INTO ROLES VALUES (3, 'SENIOR_TELLER_ROLE', 'Senior teller with elevated access', 2, SYSDATE);
INSERT INTO ROLES VALUES (4, 'MANAGER_ROLE', 'Branch manager full access', 3, SYSDATE);
INSERT INTO ROLES VALUES (5, 'AUDITOR_ROLE', 'Read-only audit access', 1, SYSDATE);
INSERT INTO ROLES VALUES (6, 'DBA_ROLE', 'Database administrator', NULL, SYSDATE);
```

---

### 7. ROLE_PRIVS

**Purpose**: Map privileges to roles.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| priv_id | NUMBER | PK, NOT NULL | Unique privilege mapping ID |
| role_id | NUMBER | FK → ROLES, NOT NULL | Role |
| privilege_type | VARCHAR2(20) | NOT NULL | SYSTEM/OBJECT |
| privilege_name | VARCHAR2(50) | NOT NULL | Privilege name |
| object_name | VARCHAR2(100) | | Object (for OBJECT privs) |
| grantable | VARCHAR2(1) | DEFAULT 'N' | Y/N - can grant to others |

**Business Rules**:
- System privileges: CREATE SESSION, CREATE TABLE, etc.
- Object privileges: SELECT, INSERT, UPDATE, DELETE
- Unique constraint on (role_id, privilege_name, object_name)

**Sample Data**:
```sql
INSERT INTO ROLE_PRIVS VALUES (1, 1, 'SYSTEM', 'CREATE SESSION', NULL, 'N');
INSERT INTO ROLE_PRIVS VALUES (2, 2, 'OBJECT', 'SELECT', 'ACCOUNTS', 'N');
INSERT INTO ROLE_PRIVS VALUES (3, 2, 'OBJECT', 'INSERT', 'TRANSACTIONS', 'N');
INSERT INTO ROLE_PRIVS VALUES (4, 4, 'OBJECT', 'INSERT', 'ACCOUNTS', 'Y');
INSERT INTO ROLE_PRIVS VALUES (5, 4, 'OBJECT', 'UPDATE', 'ACCOUNTS', 'Y');
```

---

### 8. USER_SESSIONS

**Purpose**: Track user login sessions for application context.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| session_id | NUMBER | PK, NOT NULL | Unique session ID |
| user_id | NUMBER | FK → DB_USERS, NOT NULL | Logged-in user |
| login_time | TIMESTAMP | DEFAULT SYSTIMESTAMP | Session start |
| logout_time | TIMESTAMP | | Session end |
| ip_address | VARCHAR2(50) | | Client IP address |
| branch_id | NUMBER | | Branch at login time |
| oracle_sid | NUMBER | | Oracle session ID |
| status | VARCHAR2(20) | DEFAULT 'ACTIVE' | ACTIVE/EXPIRED/TERMINATED |

**Business Rules**:
- One active session per user (concurrent logins configurable)
- Sessions expire after idle timeout (30 minutes)
- Logout updates logout_time

**Security Requirements**:
- Used to populate BANK_CONTEXT application context
- Failed login attempts logged separately
- Session hijacking detection via IP monitoring

**Sample Data**:
```sql
INSERT INTO USER_SESSIONS VALUES (1, 101, SYSTIMESTAMP, NULL, '192.168.1.100', 1, 1234, 'ACTIVE');
INSERT INTO USER_SESSIONS VALUES (2, 102, SYSTIMESTAMP, NULL, '192.168.1.101', 1, 1235, 'ACTIVE');
```

---

### 9. AUDIT_LOG

**Purpose**: Custom audit trail for detailed transaction auditing.

**Attributes**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| audit_id | NUMBER | PK, AUTO-INCREMENT | Unique audit record ID |
| audit_timestamp | TIMESTAMP | DEFAULT SYSTIMESTAMP | Event timestamp |
| username | VARCHAR2(128) | NOT NULL | Oracle session user |
| action_type | VARCHAR2(10) | NOT NULL | INSERT/UPDATE/DELETE |
| table_name | VARCHAR2(128) | NOT NULL | Target table |
| record_id | NUMBER | | Primary key of affected record |
| old_value | VARCHAR2(4000) | | Old value (for UPDATE/DELETE) |
| new_value | VARCHAR2(4000) | | New value (for INSERT/UPDATE) |
| ip_address | VARCHAR2(50) | | Client IP address |
| session_id | NUMBER | | Session identifier |
| sql_text | CLOB | | SQL statement (optional) |

**Business Rules**:
- Immutable - no updates/deletes allowed (enforced by trigger)
- Retention policy: keep 7 years
- Archive old records to separate tablespace

**Security Requirements**:
- Only DBAs can query all records
- Users can only see audits of their own actions
- Trigger-based population (automatic)

**Sample Data**:
```sql
-- Populated automatically by triggers
-- Example manual insert for testing:
INSERT INTO AUDIT_LOG (username, action_type, table_name, record_id, old_value, new_value, ip_address)
VALUES (USER, 'UPDATE', 'ACCOUNTS', 1001, 'BALANCE=25000', 'BALANCE=24500', SYS_CONTEXT('USERENV','IP_ADDRESS'));
```

---

## Relationships

### Primary Relationships

1. **BANKS → BRANCHES** (1:N)
   - One bank has many branches
   - FK: BRANCHES.bank_id → BANKS.bank_id
   - ON DELETE RESTRICT (cannot delete bank with branches)

2. **BRANCHES → ACCOUNTS** (1:N)
   - One branch manages many accounts
   - FK: ACCOUNTS.branch_id → BRANCHES.branch_id
   - ON DELETE RESTRICT

3. **ACCOUNTS → TRANSACTIONS** (1:N)
   - One account has many transactions
   - FK: TRANSACTIONS.from_account_id → ACCOUNTS.account_id
   - FK: TRANSACTIONS.to_account_id → ACCOUNTS.account_id (nullable)
   - ON DELETE RESTRICT

4. **DB_USERS → TRANSACTIONS** (1:N)
   - One user initiates many transactions
   - FK: TRANSACTIONS.initiated_by → DB_USERS.user_id
   - ON DELETE RESTRICT

5. **BRANCHES → DB_USERS** (1:N)
   - One branch has many employees
   - FK: DB_USERS.branch_id → BRANCHES.branch_id
   - ON DELETE RESTRICT

6. **ROLES → DB_USERS** (N:M via USER_ROLE_ASSIGNMENT)
   - Many-to-many relationship
   - Implemented via Oracle's GRANT role mechanism

7. **ROLES → ROLES** (Self-referencing hierarchy)
   - Role inheritance
   - FK: ROLES.parent_role_id → ROLES.role_id

8. **TRANSACTIONS → TRANSACTIONS** (Self-referencing)
   - Reversal tracking
   - FK: TRANSACTIONS.reversal_of → TRANSACTIONS.transaction_id

---

## Constraints

### Check Constraints

```sql
-- ACCOUNTS
ALTER TABLE ACCOUNTS ADD CONSTRAINT CHK_BALANCE_NON_NEGATIVE
  CHECK (balance >= 0);

ALTER TABLE ACCOUNTS ADD CONSTRAINT CHK_ACCOUNT_STATUS
  CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED'));

ALTER TABLE ACCOUNTS ADD CONSTRAINT CHK_ACCOUNT_TYPE
  CHECK (account_type IN ('CHECKING', 'SAVINGS', 'BUSINESS'));

-- TRANSACTIONS
ALTER TABLE TRANSACTIONS ADD CONSTRAINT CHK_TXN_AMOUNT_POSITIVE
  CHECK (amount > 0);

ALTER TABLE TRANSACTIONS ADD CONSTRAINT CHK_TXN_STATUS
  CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REVERSED'));

ALTER TABLE TRANSACTIONS ADD CONSTRAINT CHK_TXN_TYPE
  CHECK (txn_type IN ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER'));

-- Prevent self-transfers
ALTER TABLE TRANSACTIONS ADD CONSTRAINT CHK_NO_SELF_TRANSFER
  CHECK (from_account_id != to_account_id OR to_account_id IS NULL);

-- DB_USERS
ALTER TABLE DB_USERS ADD CONSTRAINT CHK_USER_STATUS
  CHECK (status IN ('ACTIVE', 'SUSPENDED', 'TERMINATED'));
```

### Unique Constraints

```sql
ALTER TABLE BANKS ADD CONSTRAINT UQ_BANK_SWIFT UNIQUE (swift_code);
ALTER TABLE BRANCHES ADD CONSTRAINT UQ_BRANCH_CODE UNIQUE (branch_code);
ALTER TABLE ACCOUNTS ADD CONSTRAINT UQ_ACCOUNT_NUMBER UNIQUE (account_number);
ALTER TABLE TRANSACTIONS ADD CONSTRAINT UQ_TXN_REFERENCE UNIQUE (reference_number);
ALTER TABLE DB_USERS ADD CONSTRAINT UQ_USERNAME UNIQUE (username);
ALTER TABLE DB_USERS ADD CONSTRAINT UQ_EMAIL UNIQUE (email);
ALTER TABLE ROLES ADD CONSTRAINT UQ_ROLE_NAME UNIQUE (role_name);
```

### Foreign Key Constraints

```sql
-- BRANCHES
ALTER TABLE BRANCHES ADD CONSTRAINT FK_BRANCH_BANK
  FOREIGN KEY (bank_id) REFERENCES BANKS(bank_id);

-- ACCOUNTS
ALTER TABLE ACCOUNTS ADD CONSTRAINT FK_ACCOUNT_BRANCH
  FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id);

-- TRANSACTIONS
ALTER TABLE TRANSACTIONS ADD CONSTRAINT FK_TXN_FROM_ACCOUNT
  FOREIGN KEY (from_account_id) REFERENCES ACCOUNTS(account_id);

ALTER TABLE TRANSACTIONS ADD CONSTRAINT FK_TXN_TO_ACCOUNT
  FOREIGN KEY (to_account_id) REFERENCES ACCOUNTS(account_id);

ALTER TABLE TRANSACTIONS ADD CONSTRAINT FK_TXN_INITIATED_BY
  FOREIGN KEY (initiated_by) REFERENCES DB_USERS(user_id);

ALTER TABLE TRANSACTIONS ADD CONSTRAINT FK_TXN_REVERSAL
  FOREIGN KEY (reversal_of) REFERENCES TRANSACTIONS(transaction_id);

-- DB_USERS
ALTER TABLE DB_USERS ADD CONSTRAINT FK_USER_BRANCH
  FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id);

-- ROLES
ALTER TABLE ROLES ADD CONSTRAINT FK_ROLE_PARENT
  FOREIGN KEY (parent_role_id) REFERENCES ROLES(role_id);

-- ROLE_PRIVS
ALTER TABLE ROLE_PRIVS ADD CONSTRAINT FK_PRIV_ROLE
  FOREIGN KEY (role_id) REFERENCES ROLES(role_id);

-- USER_SESSIONS
ALTER TABLE USER_SESSIONS ADD CONSTRAINT FK_SESSION_USER
  FOREIGN KEY (user_id) REFERENCES DB_USERS(user_id);
```

---

## Indexes

### Performance Indexes

```sql
-- Frequently queried columns
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
```

---

## Sequences

```sql
-- Auto-increment primary keys
CREATE SEQUENCE SEQ_BANK_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_BRANCH_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_ACCOUNT_ID START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TRANSACTION_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_USER_ID START WITH 101 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_ROLE_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_PRIV_ID START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_SESSION_ID START WITH 1 INCREMENT BY 1 NOCACHE;

-- AUDIT_LOG uses IDENTITY column (Oracle 12c+)
-- If using Oracle 11g, create sequence:
CREATE SEQUENCE SEQ_AUDIT_ID START WITH 1 INCREMENT BY 1 NOCACHE;
```

---

## Views

### Masked Account View

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

-- Grant to roles that need masking
GRANT SELECT ON V_ACCOUNTS_MASKED TO TELLER_ROLE;
```

### Transaction Summary View

```sql
CREATE OR REPLACE VIEW V_TRANSACTION_SUMMARY AS
SELECT 
  a.account_number,
  a.customer_name,
  t.txn_type,
  t.amount,
  t.txn_timestamp,
  t.status,
  u.full_name AS initiated_by_name
FROM TRANSACTIONS t
JOIN ACCOUNTS a ON t.from_account_id = a.account_id
LEFT JOIN DB_USERS u ON t.initiated_by = u.user_id
ORDER BY t.txn_timestamp DESC;

GRANT SELECT ON V_TRANSACTION_SUMMARY TO AUDITOR_ROLE;
```

### Audit Trail View

```sql
CREATE OR REPLACE VIEW V_AUDIT_TRAIL AS
SELECT 
  audit_id,
  audit_timestamp,
  username,
  action_type,
  table_name,
  record_id,
  ip_address
FROM AUDIT_LOG
WHERE username = USER  -- Users see only their own audits
  OR USER IN (SELECT username FROM DB_USERS WHERE department = 'AUDIT')
ORDER BY audit_timestamp DESC;

GRANT SELECT ON V_AUDIT_TRAIL TO BASE_EMPLOYEE_ROLE;
```

---

## Data Validation Rules

### Business Logic Validation

1. **Account Creation**:
   - Customer name must be at least 3 characters
   - Initial balance >= 0
   - IBAN format validation
   - Branch must be ACTIVE

2. **Transaction Processing**:
   - Source account must have sufficient balance (withdrawal/transfer)
   - Both accounts must be ACTIVE
   - Amount must be positive
   - Transaction type must match account configuration

3. **User Management**:
   - Username must be alphanumeric
   - Email must match pattern: `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$`
   - Branch assignment required for non-audit users

---

## Security Layer Integration

### Encryption Integration

```sql
-- Column encryption on ACCOUNTS.balance
ALTER TABLE ACCOUNTS MODIFY (balance ENCRYPT USING 'AES256');

-- Verify encryption
SELECT table_name, column_name, encryption_alg
FROM DBA_ENCRYPTED_COLUMNS
WHERE table_name = 'ACCOUNTS';
```

### VPD Policy Integration

```sql
-- Apply branch isolation policy
BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'BANK_SCHEMA',
    object_name     => 'ACCOUNTS',
    policy_name     => 'BRANCH_ISOLATION',
    function_schema => 'BANK_SCHEMA',
    policy_function => 'BRANCH_SECURITY_POLICY',
    statement_types => 'SELECT,INSERT,UPDATE,DELETE'
  );
END;
/
```

### Audit Trigger Integration

```sql
-- Example audit trigger on TRANSACTIONS
CREATE OR REPLACE TRIGGER TRG_AUDIT_TRANSACTIONS
AFTER INSERT OR UPDATE OR DELETE ON TRANSACTIONS
FOR EACH ROW
BEGIN
  INSERT INTO AUDIT_LOG (
    username, action_type, table_name, record_id, 
    old_value, new_value, ip_address
  ) VALUES (
    USER,
    CASE WHEN INSERTING THEN 'INSERT'
         WHEN UPDATING THEN 'UPDATE'
         WHEN DELETING THEN 'DELETE'
    END,
    'TRANSACTIONS',
    COALESCE(:NEW.transaction_id, :OLD.transaction_id),
    CASE WHEN DELETING OR UPDATING THEN 
      'AMOUNT=' || :OLD.amount || ',STATUS=' || :OLD.status
    END,
    CASE WHEN INSERTING OR UPDATING THEN
      'AMOUNT=' || :NEW.amount || ',STATUS=' || :NEW.status
    END,
    SYS_CONTEXT('USERENV', 'IP_ADDRESS')
  );
END;
/
```

---

## Sample Data Requirements

### Minimum Data for Demonstration

- **Banks**: 2 banks
- **Branches**: 3 branches (2 for bank 1, 1 for bank 2)
- **Accounts**: 10 accounts across branches
- **Transactions**: 20 transactions (deposits, withdrawals, transfers)
- **DB_Users**: 6 users (2 tellers, 2 managers, 1 auditor, 1 DBA)
- **Roles**: 6 roles (as defined above)
- **User_Sessions**: 3 active sessions

---

## Database Schema Size Estimate

| Table | Estimated Rows | Row Size | Total Size |
|-------|----------------|----------|------------|
| BANKS | 2-5 | 200 bytes | 1 KB |
| BRANCHES | 5-10 | 300 bytes | 3 KB |
| ACCOUNTS | 10-100 | 400 bytes | 40 KB |
| TRANSACTIONS | 100-1000 | 250 bytes | 250 KB |
| DB_USERS | 10-20 | 300 bytes | 6 KB |
| ROLES | 6-10 | 200 bytes | 2 KB |
| ROLE_PRIVS | 20-50 | 150 bytes | 7.5 KB |
| USER_SESSIONS | 5-20 | 200 bytes | 4 KB |
| AUDIT_LOG | 1000+ | 500 bytes | 500 KB+ |
| **TOTAL** | | | **~1 MB** |

Comfortable for development and demonstration purposes.

---

## Normalization Level

**Target**: 3rd Normal Form (3NF)

**Verification**:
- ✅ 1NF: All columns atomic (no multi-valued attributes)
- ✅ 2NF: No partial dependencies on composite keys
- ✅ 3NF: No transitive dependencies

**Denormalization Considerations** (if needed for performance):
- Add `branch_name` to ACCOUNTS (avoid join for common queries)
- Add `balance_snapshot` to ACCOUNTS for historical reporting
- Cache customer risk score in ACCOUNTS

**Decision**: Keep normalized for academic project (demonstrates proper design).

---

*Data model completed: 2026-04-04*
