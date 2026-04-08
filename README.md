# Oracle Database Security - Final Project

**Student**: Sabău Eduard  
**Grupă**: 506  
**Status**: ✅ Implementation Complete

---

## Project Structure

```
.
├── sql/                          # All SQL scripts (ready)
│   ├── 00-cleanup.sql           # Database cleanup
│   ├── 01-creare_inserare.sql   # Phase 1: Schema + data
│   ├── 02-criptare.sql          # Phase 2: TDE encryption
│   ├── 03-audit.sql             # Phase 3: Auditing
│   ├── 04-gestiune_identitati.sql  # Phase 4: Identity management
│   ├── 05-privs_roles.sql       # Phase 5: Privileges & roles
│   ├── 06-securitate_aplicatii.sql # Phase 6: SQL injection
│   ├── 07-mascare_date.sql      # Phase 7: Data masking
│   └── 08-complexity.sql        # Phase 8: VPD + complexity
│
├── assets/
│   ├── diagrams/                # Mermaid diagrams
│   └── screenshots/             # Phase outputs + your screenshots
│
├── proiect-sbd.tex              # LaTeX document (edit this)
├── compile-latex.sh             # PDF compilation script
│
├── 506-Sabau_Eduard-cerinte.txt           # Phases 2-8 (for submission)
├── 506-Sabau_Eduard-creare_inserare.txt   # Phase 1 (for submission)
│
├── ESSENTIAL_SCREENSHOTS.md     # 📸 Screenshot guide (23 screenshots)
├── LATEX_WORKFLOW.md            # 📝 LaTeX compilation guide
└── DOCUMENT_TEMPLATE.md         # Content reference for LaTeX
```

---

## What's Done ✅

- ✅ All 8 SQL phases complete (4,308 lines of code)
- ✅ Database populated with all security features
- ✅ All outputs saved to `assets/screenshots/*/phase*-output.txt`
- ✅ LaTeX template created with your info
- ✅ Submission files created (506-Sabau_Eduard-*.txt)

**Grade potential**: 10/10 (all N1 + N2 + N3 requirements met)

---

## What You Need to Do

### 1. Capture Screenshots (1-2 hours)

Follow **`ESSENTIAL_SCREENSHOTS.md`** - it has:
- 23 essential screenshots (organized by sections 1-8)
- Exact SQL query to run for each
- Exact filename to save as

**Start**:
```bash
./connect.sh bank
# Then run queries from ESSENTIAL_SCREENSHOTS.md
```

### 2. Complete LaTeX Document (1-2 hours)

Open `proiect-sbd.tex` and add missing content for sections 4-7:
- Copy content from **`DOCUMENT_TEMPLATE.md`**
- Insert your screenshots where you see `[INSERT SCREENSHOT]`

### 3. Compile to PDF (30 mins)

```bash
./compile-latex.sh
```

This creates `proiect-sbd.pdf`. Verify it looks good.

### 4. Create Final Submission (10 mins)

```bash
zip 506-Sabau_Eduard-proiect.zip \
    proiect-sbd.pdf \
    506-Sabau_Eduard-creare_inserare.txt \
    506-Sabau_Eduard-cerinte.txt
```

Submit: **`506-Sabau_Eduard-proiect.zip`**

---

## Database Connection

```bash
export TNS_ADMIN=~/.oracle/wallet
sql BANK_SCHEMA/SecurePass123!@bankdb_high
```

Or use helper: `./connect.sh bank`

---

## Quick Stats

| Metric | Value |
|--------|-------|
| SQL Lines | 4,308 |
| Tables | 9 |
| Constraints | 68 |
| Indexes | 13 |
| Roles | 6 |
| Privileges | 37 |
| Screenshots Needed | 23 |
| Est. Time to Complete | 3-4 hours |

---

## Need Help?

- **Screenshots**: See `ESSENTIAL_SCREENSHOTS.md`
- **LaTeX**: See `LATEX_WORKFLOW.md`
- **Content**: See `DOCUMENT_TEMPLATE.md`
