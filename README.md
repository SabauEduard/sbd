# Oracle Database Security for Banking Transactions

**Course**: Securitatea Bazelor de Date (Database Security)  
**Academic Year**: 2025-2026, Semester 1  
**Project Type**: Database Security Implementation (N1 + N2 + N3)  
**Target Grade**: 10/10

## 📋 Project Overview

Implementation of a comprehensive security framework for a banking transaction database using Oracle Database. The project demonstrates:

- ✅ **Data Encryption** (TDE/DBMS_CRYPTO)
- ✅ **Comprehensive Auditing** (Standard + FGA + Custom Triggers)
- ✅ **Identity & Access Management** (User Profiles + Resource Quotas)
- ✅ **Role-Based Access Control** (RBAC with Privilege Hierarchies)
- ✅ **Data Masking** (Account Number Protection)
- ✅ **SQL Injection Protection** (Bind Variables + Application Context)
- ✅ **Virtual Private Database** (Row-Level Security)

---

## 🎯 Grading Breakdown

| Component | Requirements | Points | Status |
|-----------|--------------|--------|--------|
| **N1** (Pass) | Req 1, 2, 3, 4, 7 | 4 pts | ⬜ Not Started |
| **N2** (Higher Grade) | Req 5, 6 | 2 pts | ⬜ Not Started |
| **N3** (Maximum) | Complexity + Report | 3 pts | ⬜ Not Started |
| **Oficiu** | Baseline | 1 pt | ✅ Automatic |
| **Total** | All requirements | **10 pts** | Target |

**Formula**: `Nota = 1 + N1 + N2 + N3`

---

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** installed and running
- **Git** (for version control)
- **8GB RAM** minimum (Oracle requirement)

### 1. Start Oracle Database

```bash
# Navigate to project directory
cd /Users/esabau/code/facultate/an2sem2/sbd

# Start Oracle container
docker-compose up -d

# Wait for Oracle to initialize (2-3 minutes)
docker-compose logs -f oracle

# Look for: "DATABASE IS READY TO USE!"
# Press Ctrl+C when you see it
```

### 2. Verify Installation

```bash
# Check container status
docker-compose ps

# Expected output:
# NAME              IMAGE                      STATUS         PORTS
# oracle-banking    gvenzl/oracle-xe:21-slim   Up (healthy)   0.0.0.0:1521->1521/tcp

# Test database connection
docker exec -it oracle-banking sqlplus system/SecurePass123!@XEPDB1 <<< "SELECT 'Connection Successful!' FROM DUAL;"

# Expected output: "Connection Successful!"
```

### 3. Create Application Schema

```bash
# Connect as SYSDBA and create schema
docker exec -i oracle-banking sqlplus system/SecurePass123!@XEPDB1 <<EOF
-- Create main schema
CREATE USER BANK_SCHEMA IDENTIFIED BY SecurePass123!;

-- Grant necessary privileges
GRANT CONNECT, RESOURCE TO BANK_SCHEMA;
GRANT CREATE VIEW, CREATE TRIGGER, CREATE PROCEDURE TO BANK_SCHEMA;
GRANT CREATE ROLE, CREATE USER TO BANK_SCHEMA;
GRANT SELECT ON DBA_AUDIT_TRAIL TO BANK_SCHEMA;
GRANT EXECUTE ON DBMS_FGA TO BANK_SCHEMA;
GRANT EXECUTE ON DBMS_RLS TO BANK_SCHEMA;
GRANT EXECUTE ON DBMS_SESSION TO BANK_SCHEMA;
GRANT EXECUTE ON DBMS_CRYPTO TO BANK_SCHEMA;

-- Grant unlimited tablespace quota
ALTER USER BANK_SCHEMA QUOTA UNLIMITED ON USERS;

-- Verify schema created
SELECT username, account_status FROM dba_users WHERE username = 'BANK_SCHEMA';

EXIT
EOF
```

---

## 📁 Project Structure

```
sbd/
├── README.md                          # This file
├── docker-compose.yml                 # Oracle container configuration
├── .gitignore                        # Git ignore rules
├── idee.txt                          # Original project idea
├── Modalitate notare.pdf             # Grading rubric
│
├── specs/                            # SpecKit artifacts
│   └── 001-oracle-db-security/
│       ├── spec.md                   # Feature specification
│       ├── plan.md                   # Implementation plan
│       ├── tasks.md                  # Task breakdown (69 tasks)
│       ├── research.md               # Technical decisions
│       ├── data-model.md             # Database design (ERD + schemas)
│       ├── quickstart.md             # Implementation scenarios
│       └── checklists/
│           └── requirements.md       # Quality validation
│
├── sql/                              # SQL implementation scripts
│   ├── 00-setup.sql                  # Schema creation (auto-run)
│   ├── 01-creare_inserare.sql       # Tables + sample data
│   ├── 02-criptare.sql              # Encryption (TDE/DBMS_CRYPTO)
│   ├── 03-audit.sql                 # Auditing (3 layers)
│   ├── 04-gestiune_identitati.sql   # Identity management
│   ├── 05-privs_roles.sql           # Privileges & roles
│   ├── 06-securitate_aplicatii.sql  # SQL injection protection
│   ├── 07-mascare_date.sql          # Data masking
│   └── 08-complexity.sql            # N3 advanced features
│
├── docs/                             # Project documentation
│   ├── erd.png                       # Entity-relationship diagram
│   ├── schemas.md                    # Relational schemas
│   └── matrices.md                   # Access control matrices
│
└── screenshots/                      # Evidence for submission
    ├── encryption/
    ├── auditing/
    ├── masking/
    └── sql-injection/
```

---

## 🔧 Docker Management

### Start/Stop Database

```bash
# Start Oracle
docker-compose up -d

# Stop Oracle (keeps data)
docker-compose down

# Stop and remove data (clean slate)
docker-compose down -v

# Restart Oracle
docker-compose restart
```

### Access Oracle

```bash
# SQL*Plus as BANK_SCHEMA (our application user)
docker exec -it oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1

# SQL*Plus as SYSDBA (database administrator)
docker exec -it oracle-banking sqlplus system/SecurePass123!@XEPDB1

# Execute SQL file
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 < sql/01-creare_inserare.sql

# Execute SQL from stdin
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
SELECT * FROM user_tables;
EXIT
EOF
```

### View Logs

```bash
# Follow logs in real-time
docker-compose logs -f

# View last 100 lines
docker-compose logs --tail=100

# View Oracle alert log
docker exec -it oracle-banking tail -f /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
```

### Container Information

```bash
# Check container health
docker-compose ps

# View resource usage
docker stats oracle-banking

# Enter container shell
docker exec -it oracle-banking bash

# Inside container, you can:
# - cd /sql  (your SQL scripts)
# - cd /docs (your documentation)
# - sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1
```

---

## 📚 Implementation Phases

### Phase 1: Foundation (N1 - Requirement 1) 🔴 CRITICAL
**Status**: ⬜ Not Started  
**Effort**: 5 hours  
**Script**: `sql/01-creare_inserare.sql`

**Objective**: Create normalized banking database schema

**Deliverables**:
- 9 tables (BANKS, BRANCHES, ACCOUNTS, TRANSACTIONS, DB_USERS, ROLES, ROLE_PRIVS, USER_SESSIONS, AUDIT_LOG)
- Foreign key constraints
- Sample data (2 banks, 3 branches, 6 accounts, 10+ transactions)
- ERD diagram

**Validation**:
```bash
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
SELECT table_name FROM user_tables ORDER BY table_name;
SELECT 'BANKS', COUNT(*) FROM BANKS UNION ALL
SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS;
EXIT
EOF
```

---

### Phase 2: Encryption (N1 - Requirement 2) 🟠 HIGH
**Status**: ⬜ Not Started  
**Effort**: 4 hours  
**Script**: `sql/02-criptare.sql`

**Objective**: Encrypt ACCOUNTS.BALANCE column

**Implementation**:
- **Primary**: TDE column encryption (if available)
- **Fallback**: DBMS_CRYPTO triggers (for Oracle XE)

**Validation**:
```bash
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
-- Check encryption
SELECT table_name, column_name, encryption_alg 
FROM USER_ENCRYPTED_COLUMNS WHERE table_name = 'ACCOUNTS';

-- Test decryption
SELECT account_id, balance FROM ACCOUNTS WHERE ROWNUM <= 3;
EXIT
EOF
```

---

### Phase 3: Auditing (N1 - Requirement 3) 🟠 HIGH
**Status**: ⬜ Not Started  
**Effort**: 5 hours  
**Script**: `sql/03-audit.sql`

**Objective**: Three-layer audit implementation

**Layers**:
1. **Standard Auditing**: Sessions, DDL, DML
2. **Fine-Grained Auditing (FGA)**: BALANCE column access
3. **Custom Triggers**: Transaction old/new values

**Validation**:
```bash
docker exec -i oracle-banking sqlplus system/SecurePass123!@XEPDB1 <<EOF
SELECT username, timestamp, action_name FROM DBA_AUDIT_TRAIL WHERE ROWNUM <= 5;
SELECT db_user, sql_text FROM DBA_FGA_AUDIT_TRAIL WHERE ROWNUM <= 5;
EXIT
EOF

docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
SELECT * FROM AUDIT_LOG ORDER BY audit_timestamp DESC FETCH FIRST 5 ROWS ONLY;
EXIT
EOF
```

---

### Phase 4: Identity Management (N1 - Requirement 4) 🟠 HIGH
**Status**: ⬜ Not Started  
**Effort**: 4 hours  
**Script**: `sql/04-gestiune_identitati.sql`

**Objective**: User profiles, resource quotas, access matrices

**Deliverables**:
- Process-User Matrix
- Entity-Process Matrix
- Entity-User Matrix
- 4 profiles (TELLER, MANAGER, AUDITOR, DBA)
- Resource quotas (sessions, CPU, connect time)

**Validation**:
```bash
docker exec -i oracle-banking sqlplus system/SecurePass123!@XEPDB1 <<EOF
SELECT profile, resource_name, limit 
FROM DBA_PROFILES 
WHERE profile IN ('TELLER_PROFILE', 'MANAGER_PROFILE', 'AUDITOR_PROFILE')
ORDER BY profile, resource_name;

SELECT username, profile, account_status 
FROM DBA_USERS 
WHERE username IN ('TELLER_01', 'MANAGER_01', 'AUDITOR_01');
EXIT
EOF
```

---

### Phase 5: Privileges & Roles (N2 - Requirement 5) 🟡 MEDIUM
**Status**: ⬜ Not Started  
**Effort**: 4 hours  
**Script**: `sql/05-privs_roles.sql`

**Objective**: Role-based access control with hierarchy

**Role Hierarchy**:
```
DBA_ROLE
  ↓
MANAGER_ROLE
  ↓
SENIOR_TELLER_ROLE
  ↓
TELLER_ROLE
  ↓
BASE_EMPLOYEE_ROLE
  ↓
AUDITOR_ROLE (read-only)
```

**Validation**:
```bash
docker exec -i oracle-banking sqlplus system/SecurePass123!@XEPDB1 <<EOF
SELECT granted_role, grantee 
FROM DBA_ROLE_PRIVS 
WHERE granted_role LIKE '%_ROLE'
ORDER BY granted_role;

SELECT grantee, privilege, table_name 
FROM DBA_TAB_PRIVS 
WHERE grantee LIKE '%_ROLE'
ORDER BY grantee;
EXIT
EOF
```

---

### Phase 6: SQL Injection Protection (N2 - Requirement 6) 🟡 MEDIUM
**Status**: ⬜ Not Started  
**Effort**: 4 hours  
**Script**: `sql/06-securitate_aplicatii.sql`

**Objective**: Demonstrate vulnerability and protection

**Components**:
- Application context (BANK_CONTEXT)
- Vulnerable procedure (dynamic SQL)
- Secure procedure (bind variables)
- Context-validated procedure

**Validation**:
```bash
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
-- Test injection attack (will fail gracefully if protected)
EXEC GET_ACCOUNT_INFO_VULN('1 OR 1=1');

-- Test secure version
EXEC GET_ACCOUNT_INFO_SECURE(1001);

-- Test context
EXEC SET_BANK_CONTEXT(101, 1, 'TELLER');
SELECT SYS_CONTEXT('BANK_CONTEXT', 'USER_BRANCH') FROM DUAL;
EXIT
EOF
```

---

### Phase 7: Data Masking (N1 - Requirement 7) 🟠 HIGH
**Status**: ⬜ Not Started  
**Effort**: 3 hours  
**Script**: `sql/07-mascare_date.sql`

**Objective**: Mask account numbers for unauthorized users

**Implementation**:
- MASK_ACCOUNT_NUMBER function
- V_ACCOUNTS_MASKED view
- UNMASK_ACCOUNT_ROLE privilege

**Expected Output**:
- Teller: `XXXXXXXXXXXXXXXXXXXX1234`
- Manager: `RO49AAAA1B31007593840001`

**Validation**:
```bash
# As BANK_SCHEMA (sees unmasked - has privilege)
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
SELECT account_id, account_number FROM ACCOUNTS WHERE ROWNUM <= 3;
EXIT
EOF

# After granting TELLER_01, test as teller (should see masked)
docker exec -i oracle-banking sqlplus TELLER_01/SecurePass123!@XEPDB1 <<EOF
SELECT account_id, account_number FROM BANK_SCHEMA.V_ACCOUNTS_MASKED WHERE ROWNUM <= 3;
EXIT
EOF
```

---

### Phase 8: Complexity (N3 - Optional) 🟢 BONUS
**Status**: ⬜ Not Started  
**Effort**: 8 hours  
**Script**: `sql/08-complexity.sql`

**Objective**: Advanced features for maximum grade

**Features**:
- Virtual Private Database (VPD) - row-level security
- Tablespace encryption
- Advanced audit analytics
- Original security scenarios

**Validation**:
```bash
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
-- Test VPD policy exists
SELECT object_name, policy_name, policy_type
FROM USER_POLICIES;

-- Verify tablespace encryption
SELECT tablespace_name, encrypted 
FROM USER_TABLESPACES;
EXIT
EOF
```

---

## 🧪 Testing & Validation

### Quick Health Check

```bash
# Run comprehensive health check
docker exec -i oracle-banking sqlplus BANK_SCHEMA/SecurePass123!@XEPDB1 <<EOF
SET LINESIZE 200
SET PAGESIZE 100

PROMPT === TABLE COUNT ===
SELECT COUNT(*) AS table_count FROM user_tables;

PROMPT === SAMPLE DATA ===
SELECT 'BANKS' AS table_name, COUNT(*) AS row_count FROM BANKS UNION ALL
SELECT 'BRANCHES', COUNT(*) FROM BRANCHES UNION ALL
SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS UNION ALL
SELECT 'DB_USERS', COUNT(*) FROM DB_USERS UNION ALL
SELECT 'ROLES', COUNT(*) FROM ROLES;

PROMPT === ENCRYPTION STATUS ===
SELECT COUNT(*) AS encrypted_columns FROM USER_ENCRYPTED_COLUMNS;

PROMPT === AUDIT RECORDS ===
SELECT COUNT(*) AS audit_records FROM AUDIT_LOG;

PROMPT === ROLES ===
SELECT COUNT(*) AS role_count FROM DBA_ROLES WHERE role LIKE '%_ROLE';

EXIT
EOF
```

### End-to-End Test Scenarios

```bash
# Scenario 1: Teller processes transaction
docker exec -i oracle-banking sqlplus TELLER_01/SecurePass123!@XEPDB1 <<EOF
-- View accounts (masked)
SELECT account_number, balance 
FROM BANK_SCHEMA.V_ACCOUNTS_MASKED 
WHERE ROWNUM <= 3;

-- Process transaction
INSERT INTO BANK_SCHEMA.TRANSACTIONS VALUES (
  BANK_SCHEMA.SEQ_TRANSACTION_ID.NEXTVAL,
  'DEPOSIT',
  1000.00,
  SYSTIMESTAMP,
  'COMPLETED',
  1001,
  NULL,
  101,
  'Test transaction',
  'REF-TEST-' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS'),
  NULL
);
COMMIT;
EXIT
EOF

# Scenario 2: Auditor reviews logs
docker exec -i oracle-banking sqlplus AUDITOR_01/SecurePass123!@XEPDB1 <<EOF
SELECT * FROM BANK_SCHEMA.AUDIT_LOG 
ORDER BY audit_timestamp DESC 
FETCH FIRST 10 ROWS ONLY;
EXIT
EOF
```

---

## 📊 Progress Tracking

### Implementation Checklist

- [ ] **Phase 1**: Database Schema (Requirement 1) - N1
- [ ] **Phase 2**: Encryption (Requirement 2) - N1
- [ ] **Phase 3**: Auditing (Requirement 3) - N1
- [ ] **Phase 4**: Identity Management (Requirement 4) - N1
- [ ] **Phase 7**: Data Masking (Requirement 7) - N1
- [ ] **Milestone**: N1 Complete → **Grade 5 Achievable**
- [ ] **Phase 5**: Privileges & Roles (Requirement 5) - N2
- [ ] **Phase 6**: SQL Injection Protection (Requirement 6) - N2
- [ ] **Milestone**: N2 Complete → **Grade 7 Achievable**
- [ ] **Phase 8**: Complexity Features - N3
- [ ] **Milestone**: N3 Complete → **Grade 10 Achievable**

### Deliverables Checklist

- [ ] `<grupa>-<Nume>_<Prenume>-proiect.docx` - Main document
- [ ] `<grupa>-<Nume>_<Prenume>-creare_inserare.txt` - Schema script
- [ ] `<grupa>-<Nume>_<Prenume>-criptare.txt` - Encryption script
- [ ] `<grupa>-<Nume>_<Prenume>-audit.txt` - Auditing script
- [ ] `<grupa>-<Nume>_<Prenume>-gestiune_identitati_resurse_comp.txt` - Identity script
- [ ] `<grupa>-<Nume>_<Prenume>-privs_roles.txt` - Privileges script (N2)
- [ ] `<grupa>-<Nume>_<Prenume>-securitate_aplicatii.txt` - SQL injection script (N2)
- [ ] `<grupa>-<Nume>_<Prenume>-mascare_date.txt` - Masking script
- [ ] All screenshots captured
- [ ] Presentation prepared (10 minutes)
- [ ] Files uploaded 7 days before exam

---

## 🛠️ Troubleshooting

### Container Issues

```bash
# Container won't start
docker-compose down
docker volume rm sbd_oracle-data
docker-compose up -d

# Check Docker resources
# Docker Desktop → Settings → Resources
# Minimum: 4GB RAM, 2 CPUs, 20GB disk
```

### Connection Issues

```bash
# Cannot connect to Oracle
# Wait for full startup (2-3 minutes)
docker-compose logs -f oracle
# Look for: "DATABASE IS READY TO USE!"

# Check if port 1521 is available
lsof -i :1521

# If port in use, edit docker-compose.yml:
# ports: - "1522:1521"
# Then connect to port 1522 instead
```

### Permission Issues

```bash
# BANK_SCHEMA lacks privileges
docker exec -i oracle-banking sqlplus system/SecurePass123!@XEPDB1 <<EOF
GRANT ALL PRIVILEGES TO BANK_SCHEMA;
GRANT SELECT ANY DICTIONARY TO BANK_SCHEMA;
EXIT
EOF
```

### TDE Not Available

Oracle XE doesn't support TDE. The project will use DBMS_CRYPTO fallback:
- See `sql/02-criptare.sql` for fallback implementation
- Uses encryption/decryption triggers
- Functionally equivalent for academic purposes

### Reset Everything

```bash
# Nuclear option - start fresh
docker-compose down -v
docker-compose up -d
# Wait for startup, then re-run setup from Step 3
```

---

## 📖 References

### Documentation
- [Oracle Database Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/)
- [Oracle PL/SQL Packages Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/)
- [Transparent Data Encryption (TDE)](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/introduction-to-transparent-data-encryption.html)
- [Oracle Database SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/)

### SpecKit Artifacts
- `specs/001-oracle-db-security/spec.md` - Feature requirements
- `specs/001-oracle-db-security/plan.md` - Technical implementation plan (44h estimated)
- `specs/001-oracle-db-security/tasks.md` - 69 executable tasks with dependencies
- `specs/001-oracle-db-security/data-model.md` - Complete ERD and schemas
- `specs/001-oracle-db-security/quickstart.md` - Copy-paste implementation scenarios
- `specs/001-oracle-db-security/research.md` - Technical decisions (TDE vs DBMS_CRYPTO, etc.)

### Docker Resources
- [gvenzl/oracle-xe Docker Image](https://hub.docker.com/r/gvenzl/oracle-xe)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 👥 Project Information

**Student**: [Your Name]  
**Group**: [Your Group]  
**Academic Year**: 2025-2026  
**Course**: Securitatea Bazelor de Date (Database Security)  
**Institution**: [Your University]

---

## 📝 License

This is an academic project for educational purposes.

---

## 🎓 Submission Guidelines

**Deadline**: 7 days before exam date  
**Presentation**: Mandatory at exam session (10 minutes)  
**Upload Location**: Teams/Moodle (link announced on Teams)

**Grading Formula**: `Nota = 1 + N1 + N2 + N3`

- **N1** (4 pts): Requirements 1, 2, 3, 4, 7 → Grade 5 (Pass)
- **N2** (2 pts): Requirements 5, 6 → Grade 7
- **N3** (3 pts): Complexity + Optional Report → Grade 10

**To Pass**: N1 = 4 points (all 5 N1 requirements functional)

**File Naming Convention**:
```
<grupa>-<Nume>_<Prenume>-proiect.docx
<grupa>-<Nume>_<Prenume>-creare_inserare.txt
<grupa>-<Nume>_<Prenume>-criptare.txt
... (see Deliverables Checklist)
```

---

**Last Updated**: 2026-04-04  
**Project Status**: 🟢 Ready for Implementation  
**Current Phase**: Setup & Planning Complete

---

## 🚀 Next Steps

1. **Start Docker**: `docker-compose up -d`
2. **Wait for Oracle**: `docker-compose logs -f oracle` (look for "DATABASE IS READY")
3. **Create Schema**: Run setup from Step 3 above
4. **Begin Implementation**: Start with Phase 1 (Database Schema)
5. **Track Progress**: Check off items in Implementation Checklist

**Estimated Time to Grade 5**: 22 hours (N1 requirements)  
**Estimated Time to Grade 7**: 30 hours (N1 + N2)  
**Estimated Time to Grade 10**: 44 hours (Full implementation)

Good luck! 🎓

---

## ⚠️ ARM Mac (M1/M2/M3) Users - Important Note

Oracle Database XE does not run reliably on Apple Silicon Macs due to emulation limitations.

### ✅ **Working Solutions**

#### Option 1: Oracle Cloud Free Tier (Recommended - 5 min setup)
```bash
# 1. Sign up: https://www.oracle.com/cloud/free/
# 2. Create Always Free Oracle Database instance
# 3. Download connection wallet
# 4. Connect via SQL Developer:
#    - Host: your-cloud-instance.oraclecloud.com
#    - Port: 1521
#    - Service: your_service_name
```

#### Option 2: Use University Lab Computers
If your university has Oracle-equipped lab computers, run scripts there.

#### Option 3: Intel Mac / Windows PC
Docker works perfectly on Intel machines. Use `docker-compose up -d`.

#### Option 4: Colima (x86 emulation)
```bash
brew install colima
colima start --arch x86_64 --memory 4 --cpu 2
docker-compose up -d
```

### 📝 All SQL Scripts Generated

Even without local Oracle, all implementation scripts are ready in `sql/` directory:
- ✅ `01-creare_inserare.sql` - Complete schema with sample data
- 🔜 `02-criptare.sql` - Encryption (to be generated)
- 🔜 `03-audit.sql` - Auditing (to be generated)
- 🔜 `04-gestiune_identitati.sql` - Identity management (to be generated)
- 🔜 More scripts on request

You can run these scripts on any Oracle instance (cloud, lab, or Intel Mac).

