# Feature Specification: Oracle Database Security for Banking Transactions

**Feature ID**: 001-oracle-db-security  
**Created**: 2026-04-04  
**Status**: Draft  
**Target Database**: Oracle  

---

## 1. Overview

### Purpose
Design and implement a comprehensive security framework for a banking transaction database system. The system will protect sensitive financial data through encryption, maintain detailed audit trails of all database activities, enforce strict access controls through role-based privileges, and mask sensitive account information from unauthorized users.

### Business Context
Financial institutions handle highly sensitive customer data including account balances, transaction histories, and personal information. Regulatory requirements (such as GDPR, PCI-DSS, and banking regulations) mandate:
- Protection of sensitive financial data at rest and in transit
- Complete auditability of all data access and modifications
- Strict access controls based on job function and need-to-know principles
- Protection of customer privacy through data masking

This project demonstrates industry-standard database security practices applied to a banking scenario.

### Scope
**In Scope:**
- Database schema design for banks, accounts, and transactions
- Encryption of sensitive financial data (account balances)
- Comprehensive auditing of database activities
- Identity and access management with role-based privileges
- Data masking for sensitive account information
- Protection against SQL injection attacks

**Out of Scope:**
- Frontend application development
- Network-level security (firewalls, VPNs)
- Application server configuration
- Backup and disaster recovery procedures
- Performance tuning and optimization

---

## 2. Success Criteria

The project will be considered successful when:

1. **Data Protection**: Sensitive financial data (account balances) are stored in encrypted format and can only be decrypted by authorized users
2. **Audit Completeness**: All database operations (SELECT, INSERT, UPDATE, DELETE) on critical tables are logged with timestamp, user, and operation details
3. **Access Control**: Users can only perform operations explicitly granted to their assigned roles
4. **Privacy Compliance**: Sensitive account numbers are masked (e.g., XXXX-XXXX-XXXX-1234) for users without specific privileges
5. **SQL Injection Protection**: Database demonstrates resistance to common SQL injection attack patterns
6. **Functional Completeness**: Database supports typical banking operations (account creation, deposits, withdrawals, transfers) while enforcing all security controls

---

## 3. Grading Requirements Mapping

### N1 (4 points) - Core Requirements
To achieve the minimum passing grade, the project must implement:

**Requirement 1: Introduction** (MANDATORY)
- Complete conceptual database diagram (ERD) showing entities, relationships, and cardinalities
- Relational schemas derived from conceptual diagram
- Separate SQL script for table creation with constraints
- Documentation of security rules to be applied

**Requirement 2: Data Encryption**
- Encryption of account balance information
- Key management approach
- Demonstration of encrypted data storage and decryption for authorized access

**Requirement 3: Database Auditing**
- Standard Oracle auditing configuration
- Custom audit triggers for transaction tracking
- Audit policies for security-sensitive operations

**Requirement 4: User and Resource Management**
- Process-User matrix (which users perform which business processes)
- Entity-Process matrix (which processes access which entities)
- Entity-User matrix (which users can access which entities)
- Implementation of user profiles and resource quotas

**Requirement 7: Data Masking**
- Account number masking for unauthorized users
- Context-aware masking (showing full data to authorized roles)
- Demonstration of masking in queries

### N2 (2 points) - Additional Requirements
After completing N1, implement these requirements for additional points:

**Requirement 5: Privileges and Roles**
- System privileges (CREATE SESSION, CREATE TABLE, etc.)
- Object privileges (SELECT, INSERT, UPDATE, DELETE on specific tables)
- Privilege hierarchies (roles containing other roles)
- Privileges on dependent objects (views, procedures)

**Requirement 6: Application Security**
- Application context configuration
- SQL injection vulnerability demonstration
- Protection mechanisms against SQL injection

### N3 (3 points) - Complexity
Demonstrate project complexity through:
- Advanced encryption techniques (column-level vs. tablespace encryption)
- Comprehensive audit analysis queries
- Complex role hierarchies (departmental and functional roles)
- Fine-grained access control (row-level security)
- Virtual Private Database (VPD) policies
- Original examples and scenarios not covered in laboratory exercises
- Optional: Technical report on database security best practices

---

## 4. Key Entities

### Banks
- Bank identification
- Bank name and location
- Regulatory information

### Accounts
- Account number (sensitive - requires masking)
- Account type (checking, savings, etc.)
- Account holder information
- Current balance (sensitive - requires encryption)
- Opening date
- Account status

### Transactions
- Transaction ID
- Source account
- Destination account (for transfers)
- Transaction type (deposit, withdrawal, transfer)
- Amount
- Timestamp
- Status
- Initiating user

### Users
- User identification
- User name and credentials
- Assigned roles
- Employment information
- Resource quotas

### Roles
- Role name
- Privilege sets
- Role hierarchies

### Audit Logs
- Timestamp
- User performing action
- Action type
- Target object
- Operation details
- Success/failure status

---

## 5. User Scenarios & Acceptance Criteria

### Scenario 1: Bank Teller Operations
**Actor**: Bank Teller  
**Goal**: Process customer deposits and withdrawals

**Flow:**
1. Teller logs into database with assigned credentials
2. Teller searches for customer account
3. Teller views account balance (decrypted because teller has privilege)
4. Teller records deposit transaction
5. Account balance is updated (encrypted)
6. All operations are logged in audit trail

**Acceptance Criteria:**
- Teller can view decrypted balances only for accounts within their branch
- Teller cannot directly modify balance fields (only through transaction procedures)
- All teller actions are recorded with timestamp and teller ID
- Sensitive account numbers show last 4 digits only

### Scenario 2: Auditor Review
**Actor**: Internal Auditor  
**Goal**: Review transaction history for compliance

**Flow:**
1. Auditor logs in with read-only privileges
2. Auditor queries audit logs for date range
3. Auditor views transaction history
4. Auditor identifies unusual patterns
5. Auditor generates compliance report

**Acceptance Criteria:**
- Auditor has read-only access to audit logs
- Auditor cannot modify any transaction data
- Account balances are visible but account holder personal details are masked
- Audit logs show complete history with no gaps

### Scenario 3: Account Manager Operations
**Actor**: Account Manager  
**Goal**: Create new customer accounts and manage account settings

**Flow:**
1. Manager logs in with elevated privileges
2. Manager creates new account record
3. Manager assigns initial encrypted balance
4. Manager configures account parameters
5. All creation steps are audited

**Acceptance Criteria:**
- Manager can create accounts and set initial balances
- Manager can view full account details including unmasked account numbers
- Account creation is logged with all relevant details
- Manager cannot delete audit records

### Scenario 4: Security Administrator
**Actor**: Database Security Administrator  
**Goal**: Configure user access and monitor security

**Flow:**
1. Admin logs in with DBA privileges
2. Admin creates new user accounts
3. Admin assigns roles to users
4. Admin configures audit policies
5. Admin reviews failed login attempts

**Acceptance Criteria:**
- Admin can create users and assign roles
- Admin can view all audit logs including security events
- Admin can enable/disable auditing policies
- Admin operations are themselves audited

### Scenario 5: SQL Injection Attack Prevention
**Actor**: Malicious User (simulated)  
**Goal**: Attempt to exploit database through SQL injection

**Flow:**
1. Attacker attempts to inject SQL through application input
2. Database validates and sanitizes input
3. Attack is blocked
4. Security event is logged

**Acceptance Criteria:**
- Common SQL injection patterns are blocked
- Application context prevents unauthorized data access
- Attack attempts are logged for security review
- No data exposure occurs from injection attempts

---

## 6. Functional Requirements

### FR-1: Database Schema
The database must implement a normalized relational schema for banking operations including:
- Banks table with regulatory information
- Accounts table with encrypted balance column
- Transactions table with complete transaction history
- Users table with role assignments
- Audit tables for comprehensive logging

### FR-2: Data Encryption
The system must:
- Encrypt account balance data at rest using Oracle encryption features
- Provide transparent decryption for authorized users
- Maintain encryption keys securely within Oracle wallet or key management
- Demonstrate that unauthorized users cannot read encrypted data

### FR-3: Standard Auditing
The system must:
- Enable Oracle standard auditing for login attempts
- Audit all DDL operations (CREATE, ALTER, DROP)
- Audit SELECT operations on sensitive tables
- Audit all DML operations (INSERT, UPDATE, DELETE) on transaction tables
- Store audit records in system audit trail

### FR-4: Trigger-Based Auditing
The system must:
- Create custom audit triggers on transaction tables
- Log old and new values for UPDATE operations
- Record timestamp, username, and operation type
- Store audit data in application-specific audit tables

### FR-5: Audit Policies
The system must:
- Configure fine-grained audit (FGA) policies for sensitive columns
- Audit access to encrypted balance columns
- Audit queries with specific WHERE clause conditions
- Generate alerts for suspicious access patterns

### FR-6: Identity Management
The system must:
- Define user roles based on job functions (Teller, Manager, Auditor, Admin)
- Create process-user matrix documenting which users perform which processes
- Create entity-process matrix documenting which processes access which entities
- Create entity-user matrix documenting which users access which entities
- Implement resource quotas per user (connection limits, CPU time)

### FR-7: Privileges and Roles
The system must:
- Grant system privileges appropriately (CREATE SESSION, CREATE TABLE, etc.)
- Grant object privileges at table level (SELECT, INSERT, UPDATE, DELETE)
- Create role hierarchies (Junior_Teller inherits from Base_Employee)
- Demonstrate privilege inheritance through role membership
- Show privileges on dependent objects (views based on tables)

### FR-8: Application Context
The system must:
- Configure application context to track user session information
- Use context values to enforce row-level security
- Demonstrate context-based access control (users see only their branch's accounts)

### FR-9: SQL Injection Protection
The system must:
- Demonstrate vulnerable code pattern
- Show exploitation attempt
- Implement protection through parameterized queries or bind variables
- Validate that protection prevents exploitation

### FR-10: Data Masking
The system must:
- Mask account numbers for users without UNMASK_ACCOUNT privilege
- Show format "XXXX-XXXX-XXXX-1234" (last 4 digits visible)
- Provide unmasked data to authorized roles
- Demonstrate masking in SELECT queries and views

---

## 7. Non-Functional Requirements

### Security
- All sensitive data (balances) must be encrypted using industry-standard algorithms
- Password policies must enforce minimum complexity
- Failed login attempts must be logged and limited

### Auditability
- Audit records must be tamper-proof (read-only for most users)
- Audit trail must be complete with no gaps
- Audit data must be retained according to regulatory requirements

### Performance
- Encryption/decryption must not cause noticeable delay (< 100ms) for typical queries
- Audit trigger overhead must not exceed 10% of transaction processing time
- Masking functions must execute efficiently for large result sets

### Usability
- Security controls must not prevent legitimate business operations
- Error messages for access denied must be clear and actionable
- Masked data must remain readable and meaningful

### Maintainability
- Security configuration must be documented and reproducible
- Role definitions must be clear and logically organized
- Audit policies must be manageable and tunable

---

## 8. Assumptions

1. **Database Platform**: Oracle Database 19c or higher is available with necessary security features enabled
2. **User Knowledge**: Users understand basic SQL and database concepts
3. **Realistic Data**: Sample data represents realistic banking scenarios without actual customer information
4. **Single Instance**: All security is implemented within a single Oracle database instance (no distributed considerations)
5. **No Application Layer**: Security is enforced at database level; no application server considerations
6. **Standard Compliance**: Requirements align with general banking security standards (project scope, not actual compliance certification)

---

## 9. Dependencies

### External Dependencies
- Oracle Database 19c or higher installation
- Oracle SQL Developer or similar SQL client
- Oracle Wallet for key management (if using TDE)

### Internal Dependencies
- Requirement 1 (Database Schema) must be completed before all other requirements
- Requirement 2 (Encryption) must be implemented before Requirement 7 (Masking) for complete data protection
- Requirement 4 (User Management) must be completed before Requirement 5 (Privileges and Roles)

---

## 10. Constraints

### Technical Constraints
- Must use Oracle Database (requirement from course)
- Must use Oracle native security features (Transparent Data Encryption, Database Vault features, etc.)
- All code must be in SQL and PL/SQL (no application programming languages)

### Time Constraints
- Project must be completed and uploaded 7 days before exam date
- Presentation at exam session is mandatory

### Scope Constraints
- Focus is on database security features, not application development
- No requirement for GUI or web interface
- No requirement for production-level performance optimization

---

## 11. Success Metrics

### Quantitative Metrics
1. **Schema Completeness**: Minimum 5 tables with appropriate relationships
2. **Encryption Coverage**: 100% of sensitive financial columns encrypted
3. **Audit Coverage**: 100% of DML operations on transaction tables logged
4. **Role Implementation**: Minimum 4 distinct user roles with different privilege sets
5. **Masking Implementation**: All sensitive identifiers masked for unauthorized users
6. **SQL Injection Tests**: Minimum 3 attack patterns tested and blocked

### Qualitative Metrics
1. **Code Quality**: SQL scripts are well-organized, commented, and follow Oracle conventions
2. **Documentation Quality**: All requirements clearly explained with screenshots showing execution
3. **Originality**: Examples and scenarios demonstrate understanding beyond laboratory exercises
4. **Presentation Quality**: Clear explanation of security controls and their business justification

---

## 12. Deliverables

### Required Deliverables
1. **Project Document** (PDF/DOCX):
   - All requirement sections with explanations
   - Screenshots demonstrating functionality
   - SQL code embedded as text (not just images)
   
2. **Database Creation Script** (SQL):
   - CREATE TABLE statements
   - INSERT statements for sample data
   - Table constraints and relationships
   
3. **Security Implementation Scripts** (SQL):
   - Separate file for each requirement (encryption, auditing, etc.)
   - Natural language comments explaining each requirement
   - Executable code demonstrating each security control

### Optional Deliverables
4. **Technical Report** (for N3 complexity points):
   - Abstract summarizing security approach
   - Bibliography with referenced sources
   - Practical implementation examples
   - Advanced topics not covered in laboratory

---

## 13. Risk Assessment

### High Risks
1. **Encryption Key Loss**: If TDE keys are lost, encrypted data becomes unrecoverable
   - **Mitigation**: Document key management procedures, backup wallet files

2. **Performance Impact**: Encryption and audit triggers may slow operations
   - **Mitigation**: Use selective auditing, benchmark critical operations

### Medium Risks
3. **Privilege Escalation**: Incorrectly configured roles may grant excessive access
   - **Mitigation**: Follow principle of least privilege, test each role thoroughly

4. **Audit Log Growth**: Comprehensive auditing generates large data volumes
   - **Mitigation**: Implement audit log retention policy, archive old records

### Low Risks
5. **Masking Bypass**: Users may find ways to unmask data through complex queries
   - **Mitigation**: Use views and VPD policies instead of simple masking functions

---

## 14. Next Steps

After specification approval:
1. Review specification for completeness and clarity
2. Proceed to `/speckit plan` to create technical implementation plan
3. Generate task breakdown with `/speckit tasks`
4. Begin implementation starting with Requirement 1 (database schema)
5. Implement N1 requirements (1, 2, 3, 4, 7) to ensure minimum grade
6. Implement N2 requirements (5, 6) for additional points
7. Add complexity elements for N3 points
8. Document all work with screenshots and explanations
9. Prepare presentation for exam session

---

## Appendix A: Requirement-to-Grade Mapping

| Requirement | Description | Grade Component | Points | Priority |
|-------------|-------------|-----------------|---------|----------|
| 1 | Introduction (Schema, ERD, Tables) | N1 (mandatory) | Part of 4 | CRITICAL |
| 2 | Data Encryption | N1 | Part of 4 | HIGH |
| 3 | Database Auditing | N1 | Part of 4 | HIGH |
| 4 | User & Resource Management | N1 | Part of 4 | HIGH |
| 7 | Data Masking | N1 | Part of 4 | HIGH |
| 5 | Privileges and Roles | N2 | Part of 2 | MEDIUM |
| 6 | Application Security (SQL Injection) | N2 | Part of 2 | MEDIUM |
| Complexity | Advanced techniques, originality | N3 | Up to 3 | BONUS |

**To Pass (Grade 5)**: Complete all of N1 (Req 1, 2, 3, 4, 7) = 1 + 4 = 5 points  
**For Higher Grades**: Add N2 (Req 5, 6) = +2 points  
**For Maximum Grade**: Add N3 complexity = +3 points  
**Maximum Possible Grade**: 1 + 4 + 2 + 3 = 10 points

---

## Appendix B: Implementation Phases

### Phase 1: Foundation (N1 - Requirement 1)
**Objective**: Create functional database schema  
**Tasks**:
- Design conceptual ERD with entities: Banks, Accounts, Transactions, Users, Audit_Logs
- Derive relational schemas with foreign keys
- Write CREATE TABLE scripts
- Populate with realistic sample data
- Document business rules

### Phase 2: Data Protection (N1 - Requirement 2)
**Objective**: Encrypt sensitive financial data  
**Tasks**:
- Configure Oracle TDE or DBMS_CRYPTO
- Encrypt ACCOUNT.BALANCE column
- Demonstrate encrypted storage
- Show decryption for authorized users
- Document key management

### Phase 3: Audit Trail (N1 - Requirement 3)
**Objective**: Log all database activities  
**Tasks**:
- Enable standard auditing for logins and DDL
- Create audit triggers on TRANSACTIONS table
- Configure FGA policies for BALANCE column access
- Query and analyze audit data
- Demonstrate audit trail completeness

### Phase 4: Identity Management (N1 - Requirement 4)
**Objective**: Manage users and resources  
**Tasks**:
- Document process-user matrix
- Document entity-process matrix
- Document entity-user matrix
- Create user profiles with resource quotas
- Demonstrate quota enforcement

### Phase 5: Data Privacy (N1 - Requirement 7)
**Objective**: Mask sensitive information  
**Tasks**:
- Create masking function for account numbers
- Implement masking view or VPD policy
- Grant UNMASK privilege to authorized roles
- Demonstrate masked vs. unmasked access

### Phase 6: Access Control (N2 - Requirement 5)
**Objective**: Implement role-based security  
**Tasks**:
- Create system and object privileges
- Define role hierarchy (BASE_EMPLOYEE → TELLER → SENIOR_TELLER)
- Grant privileges to roles
- Assign roles to users
- Demonstrate privilege inheritance and dependent object access

### Phase 7: Application Security (N2 - Requirement 6)
**Objective**: Protect against SQL injection  
**Tasks**:
- Configure application context
- Demonstrate vulnerable code pattern
- Show SQL injection exploit
- Implement protection with bind variables
- Document prevention techniques

### Phase 8: Complexity Enhancements (N3)
**Objective**: Demonstrate advanced understanding  
**Tasks**:
- Implement row-level security (RLS/VPD)
- Create complex audit analysis queries
- Add advanced encryption (tablespace-level TDE)
- Develop original security scenarios
- Optional: Write technical report
