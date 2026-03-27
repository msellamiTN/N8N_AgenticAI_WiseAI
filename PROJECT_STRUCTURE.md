# MediSafe-MAS v3 - Clean Architecture Project Structure

```
N8N_AgenticAI_WiseAI/
│
├── 📁 config/                          # Configuration files
│   ├── .env.example                    # Environment template
│   ├── docker-compose.yml              # Docker orchestration
│   └── database/
│       └── init-db.sql                 # PostgreSQL schema
│
├── 📁 scripts/                         # Deployment & utility scripts
│   ├── deploy/
│   │   ├── start-medisafe.sh          # Linux/macOS deployment
│   │   ├── start-medisafe.ps1         # Windows deployment
│   │   └── install-docker.sh          # Docker installation helper
│   └── data/
│       └── upload-vectors.py          # Vector data upload script
│
├── 📁 workflows/                       # N8N workflow definitions
│   ├── medisafe-mas-v3/
│   │   └── MediSafe-MAS-v3.json       # Main clinical workflow
│   ├── archive/
│   │   ├── MediSafe_MAS_v3_Industrial_Ollama.json
│   │   └── WiseAI_Multi_Agent_v2_Fixed.json
│   └── tools/
│       └── icd10-lookup-tool.js       # ICD-10 lookup implementation
│
├── 📁 data/                            # Clinical data & knowledge base
│   ├── guidelines/
│   │   └── sample-guidelines.json     # Clinical guidelines for RAG
│   └── cases/
│       └── sample-cases.json          # Sample clinical cases
│
├── 📁 docs/                            # Documentation
│   ├── README.md                       # Main documentation
│   ├── QUICKSTART.md                   # Quick start guide
│   ├── DEPLOY.md                       # Deployment guide
│   ├── SETUP_MEDISAFE_V3.md           # Detailed setup instructions
│   └── use-cases/
│       └── MediSafe_MAS_ICCSIC2026_UseCase.docx
│
├── 📁 n8n/                             # N8N application data
│   └── demo-data/
│       ├── credentials/                # Auto-import credentials
│       │   ├── postgres.json
│       │   ├── ollama.json
│       │   └── qdrant.json
│       └── workflows/                  # Auto-import workflows
│           └── MediSafe-MAS-v3.json
│
├── 📁 shared/                          # Shared data between containers
│
├── .env                                # Environment variables (gitignored)
├── .gitignore                          # Git ignore rules
└── PROJECT_STRUCTURE.md                # This file

```

## 📋 Directory Descriptions

### `/config` - Configuration Layer
- **Purpose**: All configuration files for infrastructure and services
- **Contents**: Environment templates, Docker Compose, database schemas
- **Access**: Read by deployment scripts and Docker

### `/scripts` - Automation Layer
- **Purpose**: Deployment, setup, and utility scripts
- **Subdirectories**:
  - `deploy/`: Deployment automation scripts
  - `data/`: Data management scripts (vector upload, migrations)
- **Usage**: Run from project root

### `/workflows` - Application Layer
- **Purpose**: N8N workflow definitions and tools
- **Subdirectories**:
  - `medisafe-mas-v3/`: Active production workflows
  - `archive/`: Previous versions and deprecated workflows
  - `tools/`: Reusable workflow tools and functions
- **Format**: JSON workflow definitions, JavaScript tools

### `/data` - Data Layer
- **Purpose**: Clinical knowledge base and sample data
- **Subdirectories**:
  - `guidelines/`: Clinical guidelines for RAG retrieval
  - `cases/`: Sample clinical cases for testing and RAG
- **Format**: JSON structured data

### `/docs` - Documentation Layer
- **Purpose**: All project documentation
- **Contents**: Setup guides, API docs, use cases, architecture diagrams
- **Audience**: Developers, operators, researchers

### `/n8n` - Runtime Layer
- **Purpose**: N8N application runtime data
- **Managed by**: Docker volumes and N8N import process
- **Contents**: Auto-imported credentials and workflows

### `/shared` - Integration Layer
- **Purpose**: Shared data between Docker containers
- **Usage**: File exchange, temporary data, logs

## 🔄 Migration Plan

To reorganize existing files into this structure:

1. **Create folder structure** (automated)
2. **Move files to new locations** (automated)
3. **Update references in**:
   - `docker-compose.yml` → Update volume paths
   - Deployment scripts → Update file paths
   - Documentation → Update file references
4. **Test deployment** → Verify all paths work

## 🎯 Benefits

- ✅ **Clear separation of concerns** (config, scripts, data, docs)
- ✅ **Easy navigation** (logical grouping)
- ✅ **Scalable** (easy to add new workflows, data, docs)
- ✅ **Maintainable** (clear ownership and purpose)
- ✅ **Professional** (industry-standard structure)
