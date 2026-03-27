# MediSafe-MAS v3 - Project Reorganization Guide

## 🎯 Overview

This guide explains how to reorganize the MediSafe-MAS v3 project into a clean architecture structure with proper separation of concerns.

## 📁 New Structure

```
N8N_AgenticAI_WiseAI/
├── config/                    # All configuration files
│   ├── .env.example
│   ├── docker-compose.yml
│   └── database/
│       └── init-db.sql
│
├── scripts/                   # Automation scripts
│   ├── deploy/
│   │   ├── start-medisafe.sh
│   │   ├── start-medisafe.ps1
│   │   └── install-docker.sh
│   └── data/
│       └── upload-vectors.py
│
├── workflows/                 # N8N workflows
│   ├── medisafe-mas-v3/
│   │   └── MediSafe-MAS-v3.json
│   ├── archive/
│   └── tools/
│       └── icd10-lookup-tool.js
│
├── data/                      # Clinical data
│   ├── guidelines/
│   │   └── sample-guidelines.json
│   └── cases/
│       └── sample-cases.json
│
├── docs/                      # Documentation
│   ├── DEPLOY.md
│   ├── QUICKSTART.md
│   ├── SETUP_MEDISAFE_V3.md
│   └── use-cases/
│
├── n8n/                       # N8N runtime
└── shared/                    # Shared data
```

## 🚀 Quick Reorganization

### Option 1: Automated (Recommended)

**Windows (PowerShell):**
```powershell
.\reorganize-project.ps1
.\update-paths.ps1
```

**Linux/macOS:**
```bash
chmod +x reorganize-project.sh update-paths.sh
./reorganize-project.sh
./update-paths.sh
```

### Option 2: Manual

Follow the steps in `PROJECT_STRUCTURE.md`

## ✅ What Gets Reorganized

### Configuration Files → `config/`
- `.env.example`
- `.env.template`
- `docker-compose.yml`
- `init-db.sql` → `config/database/`

### Scripts → `scripts/`
- `start-medisafe.sh` → `scripts/deploy/`
- `start-medisafe.ps1` → `scripts/deploy/`
- `install-docker.sh` → `scripts/deploy/`
- `upload-vectors.py` → `scripts/data/`

### Workflows → `workflows/`
- Main workflow → `workflows/medisafe-mas-v3/`
- Old versions → `workflows/archive/`
- Tools → `workflows/tools/`

### Data → `data/`
- `sample-guidelines.json` → `data/guidelines/`
- `sample-cases.json` → `data/cases/`

### Documentation → `docs/`
- All `.md` files except `README.md` (stays in root)
- Use case documents → `docs/use-cases/`

## 🔄 After Reorganization

### 1. Verify Structure
```bash
# Check all folders were created
ls -la config/ scripts/ workflows/ data/ docs/
```

### 2. Test Deployment

**Windows:**
```powershell
.\scripts\deploy\start-medisafe.ps1
```

**Linux/macOS:**
```bash
./scripts/deploy/start-medisafe.sh
```

### 3. Backward Compatibility

The reorganization creates symlinks for backward compatibility:
- `docker-compose.yml` → `config/docker-compose.yml`

This ensures existing commands still work:
```bash
docker compose up -d  # Still works!
```

## 📝 Updated File Paths

After reorganization, use these new paths:

| Old Path | New Path |
|----------|----------|
| `docker-compose.yml` | `config/docker-compose.yml` |
| `init-db.sql` | `config/database/init-db.sql` |
| `start-medisafe.sh` | `scripts/deploy/start-medisafe.sh` |
| `upload-vectors.py` | `scripts/data/upload-vectors.py` |
| `sample-guidelines.json` | `data/guidelines/sample-guidelines.json` |
| `sample-cases.json` | `data/cases/sample-cases.json` |
| `DEPLOY.md` | `docs/DEPLOY.md` |
| `icd10-lookup-tool.js` | `workflows/tools/icd10-lookup-tool.js` |

## 🎯 Benefits

✅ **Clear Separation of Concerns**
- Configuration separate from code
- Scripts separate from data
- Documentation centralized

✅ **Easier Navigation**
- Logical folder grouping
- Predictable file locations

✅ **Better Scalability**
- Easy to add new workflows
- Easy to add new data sources
- Easy to add new documentation

✅ **Professional Structure**
- Industry-standard organization
- Clean architecture principles
- Maintainable codebase

## ⚠️ Important Notes

1. **`.env` file stays in root** - Docker Compose expects it there
2. **`README.md` stays in root** - GitHub/GitLab convention
3. **Original files are copied, not moved** - Safe reorganization
4. **Symlinks created for compatibility** - Existing scripts still work

## 🔧 Troubleshooting

### Issue: Scripts can't find files

**Solution:** Run the path update script:
```bash
./update-paths.sh  # Linux/macOS
.\update-paths.ps1 # Windows
```

### Issue: Docker Compose fails

**Solution:** Use the symlink or update your command:
```bash
# Option 1: Use symlink (created automatically)
docker compose up -d

# Option 2: Specify config file
docker compose -f config/docker-compose.yml up -d
```

### Issue: Want to revert changes

**Solution:** Original files are preserved. Simply delete the new folders:
```bash
rm -rf config/ scripts/ workflows/ data/ docs/
```

## 📚 Additional Resources

- `PROJECT_STRUCTURE.md` - Detailed structure documentation
- `README.md` - Main project documentation
- `docs/QUICKSTART.md` - Quick start guide
- `docs/DEPLOY.md` - Deployment guide

---

**Ready to reorganize?** Run `./reorganize-project.sh` (Linux/macOS) or `.\reorganize-project.ps1` (Windows)
