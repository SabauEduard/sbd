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
| **N1** (Pass) | Req 1, 2, 3, 4, 7 | 4 pts | 🔄 In Progress (1/5 done) |
| **N2** (Higher Grade) | Req 5, 6 | 2 pts | ⬜ Not Started |
| **N3** (Maximum) | Complexity + Report | 3 pts | ⬜ Not Started |
| **Oficiu** | Baseline | 1 pt | ✅ Automatic |
| **Total** | All requirements | **10 pts** | Target |

**Formula**: `Nota = 1 + N1 + N2 + N3`

---

## 🚀 Quick Start

### Prerequisites

- **Oracle Cloud Account** (Free Tier - no credit card required)
- **SQLcl** installed (`brew install sqlcl`)
- **Git** (for version control)
- **macOS/Linux/Windows** (works on ARM Macs!)

### 1. Database Connection (Oracle Cloud)

This project uses **Oracle Autonomous Database** on Oracle Cloud Free Tier instead of local Docker. Why? ARM Mac compatibility + real cloud database experience!

**Connection Details**:
- **Database**: Oracle Autonomous Database 19c
- **Region**: EU Turin (Italy)
- **Service**: `bankdb_high` (high performance connection)
- **Host**: `adb.eu-turin-1.oraclecloud.com`
- **Port**: 1522 (TCPS - secure)
- **Wallet Location**: `~/.oracle/wallet/`

### 2. Environment Variables

Copy `.env.example` to `.env` and configure your credentials:

```bash
cp .env.example .env
```

**Key variables in `.env`**:
```bash
# Oracle version
ORACLE_VERSION=19c
ORACLE_DATABASE=BANKDB

# Admin user (full control)
ADMIN_USERNAME=ADMIN
ADMIN_PASSWORD=SecurePass123!

# Application schema (our main user)
BANK_SCHEMA_USERNAME=BANK_SCHEMA
BANK_SCHEMA_PASSWORD=SecurePass123!

# Wallet configuration
WALLET_PASSWORD=WalletPass123!
WALLET_LOCATION=~/.oracle/wallet
TNS_ADMIN=~/.oracle/wallet

# Connection strings
CONNECTION_STRING_HIGH=bankdb_high
CONNECTION_STRING_MEDIUM=bankdb_medium
CONNECTION_STRING_LOW=bankdb_low

# SQLcl path
SQLCL_PATH=/opt/homebrew/Caskroom/sqlcl/26.1.0.086.1709/sqlcl/bin
```

⚠️ **Security**: `.env` is git-ignored and contains real passwords. Never commit it!

### 3. Oracle Wallet Setup

The Oracle Wallet contains certificates and connection configuration for secure TCPS access.

**Wallet Structure** (`~/.oracle/wallet/`):
```
~/.oracle/wallet/
├── cwallet.sso       # Auto-login wallet
├── ewallet.p12       # Encrypted wallet
├── sqlnet.ora        # SQL*Net configuration
├── tnsnames.ora      # Connection descriptors
└── truststore.jks    # Java keystore
```

**Extract wallet** (if you have `Wallet_BANKDB.zip`):
```bash
mkdir -p ~/.oracle/wallet
unzip -o Wallet_BANKDB.zip -d ~/.oracle/wallet
chmod 600 ~/.oracle/wallet/*
```

**Verify wallet**:
```bash
export TNS_ADMIN=~/.oracle/wallet
cat ~/.oracle/wallet/tnsnames.ora | grep bankdb_high
```

### 4. Test Connection

Use the helper script for easy access:

```bash
# Test connection
./connect.sh test

# Expected output:
# STATUS
# ----------------
# Connection OK!

# Interactive connection as BANK_SCHEMA
./connect.sh bank

# Interactive connection as ADMIN
./connect.sh admin

# Run a SQL script
./connect.sh run sql/01-creare_inserare.sql
```

**Direct SQLcl usage**:
```bash
# Export wallet location
export TNS_ADMIN=~/.oracle/wallet

# Connect as BANK_SCHEMA
sql BANK_SCHEMA/SecurePass123!@bankdb_high

# Connect as ADMIN
sql ADMIN/SecurePass123!@bankdb_high

# Run script from file
sql BANK_SCHEMA/SecurePass123!@bankdb_high < sql/01-creare_inserare.sql

# Run inline query
echo "SELECT * FROM ACCOUNTS WHERE ROWNUM <= 3;" | sql BANK_SCHEMA/SecurePass123!@bankdb_high
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

## 🔧 Database Management

### Connection Helper Script

The `connect.sh` script simplifies database access:

```bash
# Show help
./connect.sh

# Test connection
./connect.sh test

# Interactive session as BANK_SCHEMA (application user)
./connect.sh bank

# Interactive session as ADMIN (database administrator)
./connect.sh admin

# Run a SQL script as BANK_SCHEMA
./connect.sh run sql/02-criptare.sql
```

### Direct SQLcl Commands

```bash
# Always set wallet location first
export TNS_ADMIN=~/.oracle/wallet

# Interactive session
sql BANK_SCHEMA/SecurePass123!@bankdb_high

# Run SQL from file
sql BANK_SCHEMA/SecurePass123!@bankdb_high < sql/01-creare_inserare.sql

# Run inline query
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
SELECT table_name FROM user_tables ORDER BY table_name;
EXIT
EOF

# Silent mode (cleaner output)
echo "SELECT * FROM ACCOUNTS WHERE ROWNUM <= 3;" | sql BANK_SCHEMA/SecurePass123!@bankdb_high
```

### Common Operations

```bash
# List all tables
echo "SELECT table_name FROM user_tables ORDER BY table_name;" | sql BANK_SCHEMA/SecurePass123!@bankdb_high

# Count rows in tables
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
SELECT 'ACCOUNTS' AS tbl, COUNT(*) AS rows FROM ACCOUNTS
UNION ALL SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS
UNION ALL SELECT 'BANKS', COUNT(*) FROM BANKS;
EXIT
EOF

# View table structure
echo "DESC ACCOUNTS;" | sql BANK_SCHEMA/SecurePass123!@bankdb_high

# Check encryption status
echo "SELECT table_name, column_name, encryption_alg FROM USER_ENCRYPTED_COLUMNS;" | sql BANK_SCHEMA/SecurePass123!@bankdb_high
```

### Oracle Cloud Console

Access your database through the web console:
1. Login: https://cloud.oracle.com
2. Navigate to: **Oracle Database** → **Autonomous Database**
3. Select: **BANKDB**
4. Features: SQL Developer Web, Performance Hub, Database Actions

---

## 📚 Implementation Phases

### Phase 1: Foundation (N1 - Requirement 1) ✅ COMPLETE
**Status**: ✅ Complete (Executed: 2026-04-04 23:10)  
**Effort**: 5 hours  
**Script**: `sql/01-creare_inserare.sql`

**Objective**: Create normalized banking database schema

**Deliverables**:
- ✅ 9 tables (BANKS, BRANCHES, ACCOUNTS, TRANSACTIONS, DB_USERS, ROLES, ROLE_PRIVS, USER_SESSIONS, AUDIT_LOG)
- ✅ 8 sequences for auto-increment IDs
- ✅ 13 performance indexes
- ✅ 33 constraints (CHECK, FK, PK, UNIQUE)
- ✅ Sample data (2 banks, 3 branches, 6 accounts, 10+ transactions)
- ✅ ERD diagram in `specs/001-oracle-db-security/data-model.md`

**Validation**:
```bash
export TNS_ADMIN=~/.oracle/wallet

# List all tables
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
SELECT table_name FROM user_tables ORDER BY table_name;
EXIT
EOF

# Count rows
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
SELECT 'BANKS' AS tbl, COUNT(*) AS rows FROM BANKS
UNION ALL SELECT 'ACCOUNTS', COUNT(*) FROM ACCOUNTS
UNION ALL SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS;
EXIT
EOF

# Sample data
./connect.sh bank
SELECT * FROM ACCOUNTS WHERE ROWNUM <= 3;
EXIT;
```

---

### Phase 2: Encryption (N1 - Requirement 2) 🔄 IN PROGRESS
**Status**: 🔄 Script Generated - Ready to Execute  
**Effort**: 4 hours  
**Script**: `sql/02-criptare.sql` ✅ Created

**Objective**: Encrypt ACCOUNTS.BALANCE column

**Implementation**:
- **Primary**: TDE column encryption with AES256 (Oracle Autonomous DB supports this)
- **Fallback**: DBMS_CRYPTO triggers (if TDE unavailable)
- **Algorithm**: AES256 with SHA256 integrity
- **Salt**: NO SALT (allows indexes to work on encrypted column)

**Execute**:
```bash
./connect.sh run sql/02-criptare.sql
```

**Validation**:
```bash
export TNS_ADMIN=~/.oracle/wallet

# Check encryption status
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
SELECT table_name, column_name, encryption_alg, integrity_alg, salt
FROM USER_ENCRYPTED_COLUMNS WHERE table_name = 'ACCOUNTS';
EXIT
EOF

# Test transparent decryption
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
SELECT account_number, balance FROM ACCOUNTS WHERE ROWNUM <= 3;
EXIT
EOF

# Or use helper script
./connect.sh bank
SELECT * FROM USER_ENCRYPTED_COLUMNS WHERE table_name = 'ACCOUNTS';
EXIT;
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
export TNS_ADMIN=~/.oracle/wallet

# Check standard auditing
sql ADMIN/SecurePass123!@bankdb_high <<EOF
SELECT username, timestamp, action_name FROM DBA_AUDIT_TRAIL WHERE ROWNUM <= 5;
SELECT db_user, sql_text FROM DBA_FGA_AUDIT_TRAIL WHERE ROWNUM <= 5;
EXIT
EOF

# Check custom audit log
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
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
export TNS_ADMIN=~/.oracle/wallet

sql ADMIN/SecurePass123!@bankdb_high <<EOF
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
export TNS_ADMIN=~/.oracle/wallet

sql ADMIN/SecurePass123!@bankdb_high <<EOF
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
export TNS_ADMIN=~/.oracle/wallet

sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
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
export TNS_ADMIN=~/.oracle/wallet

# As BANK_SCHEMA (sees unmasked - has privilege)
sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
SELECT account_id, account_number FROM ACCOUNTS WHERE ROWNUM <= 3;
EXIT
EOF

# After granting TELLER_01, test as teller (should see masked)
sql TELLER_01/SecurePass123!@bankdb_high <<EOF
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
export TNS_ADMIN=~/.oracle/wallet

sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
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
export TNS_ADMIN=~/.oracle/wallet

sql BANK_SCHEMA/SecurePass123!@bankdb_high <<EOF
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

EXIT
EOF

# Check roles (requires ADMIN)
sql ADMIN/SecurePass123!@bankdb_high <<EOF
SELECT COUNT(*) AS role_count FROM DBA_ROLES WHERE role LIKE '%_ROLE';
EXIT
EOF
```

### End-to-End Test Scenarios

```bash
export TNS_ADMIN=~/.oracle/wallet

# Scenario 1: Teller processes transaction
sql TELLER_01/SecurePass123!@bankdb_high <<EOF
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
sql AUDITOR_01/SecurePass123!@bankdb_high <<EOF
SELECT * FROM BANK_SCHEMA.AUDIT_LOG 
ORDER BY audit_timestamp DESC 
FETCH FIRST 10 ROWS ONLY;
EXIT
EOF
```

---

## 📊 Progress Tracking

### Implementation Checklist

- [x] **Phase 1**: Database Schema (Requirement 1) - N1 ✅ **COMPLETE**
- [ ] **Phase 2**: Encryption (Requirement 2) - N1 🔄 Script Generated
- [ ] **Phase 3**: Auditing (Requirement 3) - N1
- [ ] **Phase 4**: Identity Management (Requirement 4) - N1
- [ ] **Phase 7**: Data Masking (Requirement 7) - N1
- [ ] **Milestone**: N1 Complete → **Grade 5 Achievable** (1/5 done = 20%)
- [ ] **Phase 5**: Privileges & Roles (Requirement 5) - N2
- [ ] **Phase 6**: SQL Injection Protection (Requirement 6) - N2
- [ ] **Milestone**: N2 Complete → **Grade 7 Achievable**
- [ ] **Phase 8**: Complexity Features - N3
- [ ] **Milestone**: N3 Complete → **Grade 10 Achievable**

**Current Status**: N1 in progress (20% complete)

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

### Connection Issues

```bash
# Test basic connection
./connect.sh test

# Check wallet location
ls -la ~/.oracle/wallet/

# Verify TNS_ADMIN is set
echo $TNS_ADMIN  # Should show: /Users/esabau/.oracle/wallet

# Check connection strings
cat ~/.oracle/wallet/tnsnames.ora | grep bankdb

# Try connecting with explicit wallet path
TNS_ADMIN=~/.oracle/wallet sql BANK_SCHEMA/SecurePass123!@bankdb_high
```

### Wallet Issues

```bash
# If wallet files are missing
# Re-download from Oracle Cloud Console:
# 1. Go to https://cloud.oracle.com
# 2. Navigate to Autonomous Database → BANKDB
# 3. Click "DB Connection"
# 4. Download wallet (Wallet_BANKDB.zip)
# 5. Extract to ~/.oracle/wallet/

unzip -o Wallet_BANKDB.zip -d ~/.oracle/wallet/
chmod 600 ~/.oracle/wallet/*
```

### Password Issues

```bash
# If you forget passwords, check .env file
cat .env | grep PASSWORD

# NEVER commit .env to git!
# If .env is missing, copy from template:
cp .env.example .env
# Then edit with your real passwords
```

### SQLcl Not Found

```bash
# Install SQLcl via Homebrew
brew install sqlcl

# Verify installation
which sql
sql -V  # Should show: SQLcl: Release 26.1

# Add to PATH if needed
export PATH="/opt/homebrew/Caskroom/sqlcl/26.1.0.086.1709/sqlcl/bin:$PATH"
```

### Permission Denied on Scripts

```bash
# Make connect.sh executable
chmod +x connect.sh

# Run directly
./connect.sh test
```

### TDE Support

Oracle Autonomous Database **DOES support TDE** (unlike Oracle XE):
- AES256 encryption available
- Transparent encryption/decryption
- No need for DBMS_CRYPTO fallback
- Wallet-managed encryption keys

### Database Performance

```bash
# Use different service levels based on workload:
# - bankdb_high: Maximum performance (parallel queries)
# - bankdb_medium: Balanced
# - bankdb_low: Minimum CPU usage

# Switch service in connection string
sql BANK_SCHEMA/SecurePass123!@bankdb_medium
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

**Last Updated**: 2026-04-04 23:15  
**Project Status**: 🟡 Phase 1 Complete - Implementation In Progress  
**Current Phase**: Phase 2 (Encryption)  
**Database**: 🟢 Oracle Cloud Autonomous Database (OPERATIONAL)

---

## 🚀 Next Steps

1. ✅ **Setup Complete**: Oracle Cloud database operational
2. ✅ **Phase 1 Complete**: Schema with sample data loaded
3. 🔄 **Current Task**: Execute Phase 2 encryption script
   ```bash
   ./connect.sh run sql/02-criptare.sql
   ```
4. 📸 **Take Screenshots**: For project documentation
5. **Continue**: Phase 3 (Auditing) → Phase 4 (Identity) → Phase 7 (Masking)

**Progress**:
- ✅ N1 Requirement 1 (Schema): **DONE**
- 🔄 N1 Requirement 2 (Encryption): **Script Ready**
- ⬜ N1 Requirements 3, 4, 7: **TODO**

**Estimated Time Remaining**:
- To Grade 5 (Pass): ~17 hours (4 more N1 requirements)
- To Grade 7: ~25 hours (+ N2 requirements)
- To Grade 10 (Maximum): ~39 hours (+ N3 complexity)

**Current Grade Projection**: 1 (oficiu only) → Target: 5 (Pass) → Stretch: 10

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

