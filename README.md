# MediSafe-MAS v3 - Multi-Agent Clinical Decision Support System

**WiseAI 2026 Self-Training Framework**  
*By Mokhtar Sellami*

---

## 🎯 Overview

MediSafe-MAS v3 is an advanced multi-agent clinical decision support system powered by local LLMs (Ollama), vector search (Qdrant), and workflow automation (n8n). This system provides intelligent clinical analysis, differential diagnosis, risk stratification, and safety compliance checking - all running locally with full data privacy.

### Key Features

- 🤖 **Multi-Agent Architecture** - Specialized agents for feature extraction, diagnosis, risk assessment, and safety compliance
- 🔒 **100% Local & Private** - All processing happens on your infrastructure
- 📊 **PostgreSQL Audit Logging** - Complete traceability of all clinical decisions
- 🧠 **RAG-Enhanced** - Retrieval-Augmented Generation using clinical guidelines
- 🛠️ **Clinical Tools** - ICD-10 lookup, NEWS2 calculator, HEART score, drug interaction checker
- 🎨 **Clean Architecture** - Professional folder structure with separation of concerns

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [Deploying the Workflow](#deploying-the-workflow)
- [Accessing Services](#accessing-services)
- [Using the System](#using-the-system)
- [Troubleshooting](#troubleshooting)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)

---

## 🔧 Prerequisites

### Required Software

- **Docker** (v20.10+) and **Docker Compose** (v2.0+)
- **Python 3.8+** (for vector data upload)
- **Git** (for cloning the repository)

### Hardware Requirements

**Minimum:**
- CPU: 4 cores
- RAM: 8 GB
- Storage: 20 GB free space

**Recommended:**
- CPU: 8+ cores (or GPU for faster inference)
- RAM: 16+ GB
- Storage: 50+ GB SSD
- GPU: NVIDIA (CUDA) or AMD (ROCm) for accelerated inference

### Operating Systems

- ✅ Linux (Ubuntu 20.04+, Debian 11+)
- ✅ macOS (Intel or Apple Silicon)
- ✅ Windows 10/11 (with WSL2 recommended)

---

## 🚀 Quick Start

### 🪟 Windows Quick Start (Recommended)

#### 1. Install Docker Desktop

**Download and Install:**
1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop/
2. Run the installer (`Docker Desktop Installer.exe`)
3. Follow the installation wizard
4. **Important:** Enable WSL 2 during installation (recommended for better performance)
5. Restart your computer when prompted

**Verify Installation:**
```powershell
# Open PowerShell as Administrator and run:
docker --version
docker compose version
```

Expected output:
```
Docker version 24.x.x
Docker Compose version v2.x.x
```

**Start Docker Desktop:**
- Launch Docker Desktop from Start Menu
- Wait for Docker Engine to start (whale icon in system tray should be steady)
- Ensure "Docker Desktop is running" appears in the system tray

#### 2. Clone the Repository

```powershell
# Open PowerShell and navigate to your desired directory
cd "D:\Data2AI Academy"

# Clone the repository
git clone https://github.com/yourusername/N8N_AgenticAI_WiseAI.git
cd N8N_AgenticAI_WiseAI
```

#### 3. Configure Environment

```powershell
# Copy the environment template
Copy-Item config\.env.example .env

# Edit .env with your preferred editor (Notepad, VS Code, etc.)
notepad .env
```

**Important:** Update these values in `.env`:
- `POSTGRES_USER=root`
- `POSTGRES_PASSWORD=your_secure_password`
- `N8N_ENCRYPTION_KEY` - Generate with: `openssl rand -base64 32` (or use any 32-character string)
- `N8N_USER_MANAGEMENT_JWT_SECRET` - Generate with: `openssl rand -base64 32`

**Example `.env` configuration:**
```env
POSTGRES_USER=root
POSTGRES_PASSWORD=password
POSTGRES_DB=n8n
N8N_PORT=5678
N8N_ENCRYPTION_KEY=super-secret-key
N8N_USER_MANAGEMENT_JWT_SECRET=even-more-secret
```

#### 4. Deploy with PowerShell

**Open PowerShell as Administrator** and run:

```powershell
# Navigate to project directory
cd "D:\Data2AI Academy\N8N_AgenticAI_WiseAI"

# Run the deployment script
.\scripts\deploy\start-medisafe.ps1
```

The deployment script will automatically:
- ✅ Check prerequisites (Docker, Python)
- ✅ Start all Docker services
- ✅ Pull Ollama models (llama3.2:latest & nomic-embed-text:latest) - **~2.3GB download**
- ✅ Initialize PostgreSQL database
- ✅ Upload clinical data to Qdrant

**Deployment takes 5-10 minutes** depending on your internet speed (first time only).

#### 5. Access the System

Once deployment completes, open your browser:

- **n8n Workflow Editor**: http://localhost:5678
- **Qdrant Dashboard**: http://localhost:6333/dashboard
- **Portainer (Docker Management)**: http://localhost:9000

**First-time n8n setup:**
1. Open http://localhost:5678
2. Create your admin account
3. Workflows and credentials are automatically imported!

---

### 🐧 Linux/macOS Quick Start

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/N8N_AgenticAI_WiseAI.git
cd N8N_AgenticAI_WiseAI
```

#### 2. Configure Environment

```bash
# Copy the environment template
cp config/.env.example .env

# Edit .env with your settings
nano .env  # or use your preferred editor
```

**Important:** Update these values in `.env`:
- `POSTGRES_USER` and `POSTGRES_PASSWORD` - Database credentials
- `N8N_ENCRYPTION_KEY` - Generate with: `openssl rand -base64 32`
- `N8N_USER_MANAGEMENT_JWT_SECRET` - Generate with: `openssl rand -base64 32`

#### 3. Deploy the System

```bash
chmod +x scripts/deploy/start-medisafe.sh
./scripts/deploy/start-medisafe.sh
```

The deployment script will automatically:
- ✅ Start all Docker services
- ✅ Pull Ollama models (llama3.2 & nomic-embed-text)
- ✅ Initialize PostgreSQL database
- ✅ Upload clinical data to Qdrant

#### 4. Access the System

Once deployment completes, access:

- **n8n Workflow Editor**: http://localhost:5678
- **Qdrant Dashboard**: http://localhost:6333/dashboard
- **Portainer (Docker Management)**: http://localhost:9000

---

## 📦 Installation

### Step 1: Install Docker

**Ubuntu/Debian:**
```bash
./scripts/deploy/install-docker.sh
```

**Other Systems:**
- Follow official Docker installation: https://docs.docker.com/get-docker/

### Step 2: Verify Installation

```bash
docker --version
docker compose version
python3 --version
```

### Step 3: Configure Environment Variables

Edit the `.env` file in the project root:

```bash
# PostgreSQL Configuration
POSTGRES_USER=root
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=n8n

# N8N Configuration
N8N_PORT=5678
N8N_HOST=localhost

# Security Keys (generate with: openssl rand -base64 32)
N8N_ENCRYPTION_KEY=your_generated_key_here
N8N_USER_MANAGEMENT_JWT_SECRET=your_generated_jwt_secret_here

# Ollama Configuration
OLLAMA_HOST=ollama:11434

# Qdrant Configuration
QDRANT_URL=http://qdrant:6333

# Docker Compose Profile (cpu, gpu-nvidia, or gpu-amd)
COMPOSE_PROFILES=cpu
```

### Step 4: Choose Hardware Profile

**CPU-only (default):**
```bash
export COMPOSE_PROFILES=cpu
```

**NVIDIA GPU:**
```bash
export COMPOSE_PROFILES=gpu-nvidia
```

**AMD GPU:**
```bash
export COMPOSE_PROFILES=gpu-amd
```

---

## ⚙️ Configuration

### Database Configuration

PostgreSQL is used for:
- n8n workflow data
- Clinical audit logs
- Session tracking

Default credentials (change in `.env`):
- User: `root`
- Password: `password`
- Database: `n8n`

### Vector Store Configuration

Qdrant stores:
- Clinical guidelines embeddings
- Case history embeddings
- Retrieved context for RAG

Collections created automatically:
- `clinical_guidelines`
- `clinical_cases`

### LLM Configuration

Ollama models are **automatically pulled during deployment**:
- `llama3.2:latest` (2GB) - Main reasoning model for clinical analysis
- `nomic-embed-text:latest` (274MB) - Embedding model for RAG

**Automatic Pulling:**
The deployment script automatically downloads these models when Ollama starts. No manual intervention required!

**Custom Models:**
To use different models, edit the model list in:
- Linux/macOS: `scripts/deploy/start-medisafe.sh` (lines 199-202)
- Windows: `scripts/deploy/start-medisafe.ps1` (lines 197-200)

**Manual Pulling:**
If you need to pull models manually, see `docs/PULL_OLLAMA_MODELS.md`

---

## 🔄 Deploying the Workflow

### Automatic Import (Recommended)

The deployment script automatically imports:
- ✅ Workflow: `workflows/medisafe-mas-v3/MediSafe-MAS-v3.json`
- ✅ Credentials: PostgreSQL, Ollama, Qdrant

### Manual Import

If automatic import fails:

1. **Access n8n**: http://localhost:5678

2. **Create Credentials:**
   - Go to **Settings** → **Credentials**
   - Add **PostgreSQL** credential:
     - Host: `postgres`
     - Port: `5432`
     - Database: `n8n`
     - User: `root` (or your configured user)
     - Password: `password` (or your configured password)
   
   - Add **Ollama** credential:
     - Base URL: `http://ollama:11434`
   
   - Add **Qdrant** credential:
     - URL: `http://qdrant:6333`

3. **Import Workflow:**
   - Click **Workflows** → **Import from File**
   - Select: `workflows/medisafe-mas-v3/MediSafe-MAS-v3.json`
   - Click **Import**

4. **Activate Workflow:**
   - Open the imported workflow
   - Click **Active** toggle in top-right
   - Workflow is now ready to receive requests

### Workflow Configuration

The workflow includes these agents:

1. **Feature Extraction Agent** - Extracts clinical features from patient data
2. **Differential Diagnosis Agent** - Generates possible diagnoses with probabilities
3. **Risk Stratification Agent** - Calculates NEWS2, HEART scores, and risk levels
4. **Safety & Compliance Agent** - Checks drug interactions and contraindications
5. **Clinical Report Synthesizer** - Generates final structured report

---

## 🌐 Accessing Services

### n8n Workflow Editor

**URL:** http://localhost:5678

**First-time Setup:**
1. Create admin account (first user becomes admin)
2. Set email and password
3. Access workflow editor

**Features:**
- Visual workflow editor
- Execution history
- Credential management
- Webhook endpoints

### Qdrant Vector Database

**URL:** http://localhost:6333/dashboard

**Features:**
- Collection browser
- Vector search testing
- Cluster monitoring
- Point inspection

### Portainer (Docker Management)

**URL:** http://localhost:9000

**First-time Setup:**
1. Create admin password
2. Select "Docker" environment
3. Connect to local Docker

**Features:**
- Container management
- Log viewing
- Resource monitoring
- Volume management

### PostgreSQL Database

**Connection Details:**
- Host: `localhost`
- Port: `5432`
- Database: `n8n`
- User: `root` (or configured)
- Password: `password` (or configured)

**Access via CLI:**
```bash
docker exec -it postgres psql -U root -d n8n
```

**View Audit Logs:**
```sql
SELECT * FROM medisafe_audit_log ORDER BY created_at DESC LIMIT 10;
```

---

## 🎮 Using the System

### Test the Workflow

1. **Via n8n Interface:**
   - Open workflow in n8n
   - Click **Execute Workflow**
   - Provide test patient data
   - View results in execution panel

2. **Via Webhook (API):**

```bash
curl -X POST http://localhost:5678/webhook/medisafe-clinical-analysis \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "P12345",
    "age": 65,
    "gender": "M",
    "chief_complaint": "Chest pain radiating to left arm",
    "vital_signs": {
      "bp": "150/95",
      "hr": 95,
      "rr": 18,
      "temp": 37.2,
      "spo2": 96
    },
    "history": "Hypertension, Type 2 Diabetes",
    "medications": ["Metformin 1000mg", "Lisinopril 10mg"]
  }'
```

3. **Expected Response:**

```json
{
  "case_id": "CASE-20260327-001",
  "patient_id": "P12345",
  "timestamp": "2026-03-27T01:00:00Z",
  "differential_diagnosis": [
    {
      "condition": "Acute Coronary Syndrome",
      "probability": 0.75,
      "icd10": "I24.9"
    }
  ],
  "risk_scores": {
    "NEWS2": 3,
    "HEART": 6,
    "risk_level": "MODERATE"
  },
  "safety_alerts": [],
  "recommendations": [
    "Immediate ECG",
    "Troponin levels",
    "Cardiology consult"
  ]
}
```

### Upload Custom Clinical Data

Add your own guidelines and cases:

1. **Edit Data Files:**
   - Guidelines: `data/guidelines/sample-guidelines.json`
   - Cases: `data/cases/sample-cases.json`

2. **Upload to Qdrant:**

```bash
python3 scripts/data/upload-vectors.py
```

3. **Verify Upload:**
   - Visit http://localhost:6333/dashboard
   - Check collections: `clinical_guidelines`, `clinical_cases`

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Docker Services Won't Start

**Symptom:** `docker compose up` fails

**Solutions:**
```bash
# Check Docker is running
docker ps

# Check logs
docker compose logs

# Restart Docker daemon
sudo systemctl restart docker  # Linux
```

#### 2. PostgreSQL Connection Failed

**Symptom:** n8n can't connect to database

**Solutions:**
```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Check environment variables
cat .env | grep POSTGRES

# Restart PostgreSQL
docker compose restart postgres
```

#### 3. Windows-Specific Issues

**Docker Desktop Not Starting:**
- Ensure WSL 2 is installed and enabled
- Check Windows Features: "Virtual Machine Platform" and "Windows Subsystem for Linux" are enabled
- Restart Docker Desktop from system tray
- Check Docker Desktop logs: Settings → Troubleshoot → View logs

**PowerShell Execution Policy Error:**
```powershell
# If you get "cannot be loaded because running scripts is disabled"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Port Already in Use:**
```powershell
# Check what's using port 5678 (or other ports)
netstat -ano | findstr :5678

# Stop the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

**Docker Compose Command Not Found:**
- Ensure Docker Desktop is running
- Restart PowerShell after Docker Desktop installation
- Use `docker compose` (with space) not `docker-compose` (with hyphen)

**Python Not Found:**
```powershell
# Install Python from Microsoft Store or python.org
# Verify installation
python --version

# If still not found, add Python to PATH
```

#### 4. Ollama Models Not Loading

**Symptom:** LLM requests timeout or models not found

**Note:** Models are automatically pulled during deployment. If you're experiencing issues:

**Solutions:**
```bash
# Check Ollama container
docker logs ollama

# Verify models are installed
docker exec ollama ollama list

# If models are missing, pull them manually
docker exec ollama ollama pull llama3.2:latest
docker exec ollama ollama pull nomic-embed-text:latest

# Check models again
docker exec ollama ollama list
```

#### 4. Qdrant Collections Empty

**Symptom:** No search results from RAG

**Solutions:**
```bash
# Re-upload vector data
python3 scripts/data/upload-vectors.py

# Check collections via API
curl http://localhost:6333/collections
```

#### 5. n8n Workflow Import Fails

**Symptom:** Cannot import workflow JSON

**Solutions:**
1. Ensure n8n is fully started (wait 30 seconds after container starts)
2. Import manually via n8n UI
3. Check workflow JSON is valid
4. Verify credentials are created first

### Getting Help

- **Documentation:** See `docs/` folder for detailed guides
- **Logs:** Check container logs with `docker compose logs <service>`
- **Community:** Open an issue on GitHub
- **Author:** Contact Mokhtar Sellami for WiseAI 2026 support

---

## 🏗️ Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                        User / API                           │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    n8n Workflow Engine                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Feature    │  │ Differential │  │     Risk     │     │
│  │  Extraction  │→ │  Diagnosis   │→ │Stratification│     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                  │                  │             │
│         ▼                  ▼                  ▼             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Safety    │  │   Clinical   │  │  PostgreSQL  │     │
│  │  Compliance  │→ │    Report    │→ │ Audit Logger │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────┬───────────────┬───────────────┬─────────────┘
              │               │               │
              ▼               ▼               ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │   Ollama    │  │   Qdrant    │  │ PostgreSQL  │
    │ (LLM/Embed) │  │  (Vectors)  │  │   (Audit)   │
    └─────────────┘  └─────────────┘  └─────────────┘
```

### Project Structure

```
N8N_AgenticAI_WiseAI/
├── .env                         # Environment variables (gitignored)
├── .gitignore                   # Git ignore rules
├── docker-compose.yml           # Docker orchestration
├── README.md                    # Main documentation
│
├── config/                      # Configuration Layer
│   ├── .env.example             # Environment template
│   └── database/
│       └── init-db.sql          # PostgreSQL schema
│
├── scripts/                     # Automation Layer
│   ├── deploy/
│   │   ├── start-medisafe.sh    # Linux/macOS deployment (auto-pulls models)
│   │   ├── start-medisafe.ps1   # Windows deployment (auto-pulls models)
│   │   └── install-docker.sh    # Docker installer
│   └── data/
│       └── upload-vectors.py    # Vector data uploader
│
├── workflows/                   # Application Layer
│   ├── medisafe-mas-v3/
│   │   └── MediSafe-MAS-v3.json # Main clinical workflow
│   ├── archive/                 # Previous workflow versions
│   └── tools/
│       └── icd10-lookup-tool.js # Clinical tools
│
├── data/                        # Data Layer
│   ├── guidelines/
│   │   └── sample-guidelines.json
│   └── cases/
│       └── sample-cases.json
│
├── docs/                        # Documentation Layer
│   ├── PULL_OLLAMA_MODELS.md    # Model pulling guide
│   ├── QUICKSTART.md            # Quick start guide
│   ├── DEPLOY.md                # Deployment guide
│   └── SETUP_MEDISAFE_V3.md     # Setup documentation
│
└── n8n/                         # Runtime Layer
    └── demo-data/
        ├── credentials/         # Auto-import credentials
        └── workflows/           # Auto-import workflows
```

---

## 🤝 Contributing

We welcome contributions to improve MediSafe-MAS v3!

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow clean architecture principles
- Add tests for new features
- Update documentation
- Ensure all scripts are cross-platform compatible

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**Mokhtar Sellami**  
WiseAI 2026 Self-Training Framework

- 🌐 Website: [Your Website]
- 📧 Email: [Your Email]
- 💼 LinkedIn: [Your LinkedIn]
- 🐙 GitHub: [Your GitHub]

---

## 🙏 Acknowledgments

- **n8n** - Workflow automation platform
- **Ollama** - Local LLM inference
- **Qdrant** - Vector similarity search
- **PostgreSQL** - Reliable database system
- **Docker** - Containerization platform

---

## ⚠️ Disclaimer

**IMPORTANT:** MediSafe-MAS v3 is a research and educational tool. It is **NOT** intended for:
- Clinical diagnosis or treatment decisions
- Replacing professional medical judgment
- Use in production healthcare environments without proper validation
- Emergency medical situations

Always consult qualified healthcare professionals for medical advice and decisions.

---

## 📊 Project Status

- ✅ Core multi-agent workflow
- ✅ RAG integration with Qdrant
- ✅ PostgreSQL audit logging
- ✅ Clinical tools (ICD-10, NEWS2, HEART)
- ✅ Docker deployment automation
- ✅ Clean architecture migration
- 🔄 Advanced safety checks (in progress)
- 🔄 FHIR integration (planned)
- 🔄 Multi-language support (planned)

---

**Built with ❤️ by WiseAI 2026**  
*Empowering Clinical Intelligence through Local AI*
