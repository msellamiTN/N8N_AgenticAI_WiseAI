# MediSafe-MAS v3 — Industrial Multi-Agent Clinical Decision Support System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![N8N](https://img.shields.io/badge/N8N-Workflow-orange.svg)](https://n8n.io/)

**MediSafe-MAS v3** is a production-grade, multi-agent clinical AI system built with n8n, Ollama (local LLMs), Qdrant (vector database), and PostgreSQL. It provides evidence-based clinical decision support with full audit logging, EU AI Act compliance checks, and RAG-enhanced reasoning.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MediSafe-MAS v3 Pipeline                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🏥 Patient Input → 🔒 Validator → 📊 Audit Log (PostgreSQL)   │
│                          ↓                                       │
│              🔬 Feature Extraction Agent                         │
│                   (Ollama: llama3.2)                            │
│                   • ICD-10 Lookup Tool                          │
│                   • NEWS2 Calculator Tool                       │
│                          ↓                                       │
│              🧠 Differential Diagnosis Agent                     │
│                   (Ollama: llama3.1:8b)                         │
│                   • Clinical Guidelines RAG (Qdrant)            │
│                   • Similar Case Retrieval (Qdrant)             │
│                   • ICD-10 Verification                         │
│                          ↓                                       │
│              ⚠️ Risk Stratification Agent                        │
│                   (Ollama: llama3.1:8b)                         │
│                   • Drug Interaction Checker (RxNav API)        │
│                   • HEART Score Calculator                      │
│                   • Manchester Triage System                    │
│                          ↓                                       │
│              🛡️ Safety & Compliance Agent                        │
│                   (Ollama: llama3.2:1b)                         │
│                   • EU AI Act Compliance                        │
│                   • Hallucination Detection                     │
│                   • Bias & Omission Checks                      │
│                          ↓                                       │
│              📋 Clinical Report Synthesizer                      │
│                   (Ollama: mistral:7b)                          │
│                   • Safety Gate Enforcement                     │
│                   • Human-Readable Report                       │
│                          ↓                                       │
│                   📊 Final Audit Log                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## ✨ Features

- **🤖 Multi-Agent Architecture**: 5 specialized AI agents with distinct roles
- **📚 RAG-Enhanced Reasoning**: Clinical guidelines & case precedents via Qdrant
- **🔧 Clinical Tools**: NEWS2, HEART score, ICD-10 lookup, drug interactions
- **🛡️ Safety-First Design**: EU AI Act compliance, hallucination detection, bias checks
- **📊 Full Audit Trail**: PostgreSQL logging at every pipeline stage
- **🦙 Local LLMs**: Ollama-powered (llama3.2, llama3.1, mistral) - no API costs
- **🔒 Prompt Injection Protection**: Input validation with security heuristics
- **⚕️ Manchester Triage System**: Evidence-based 5-level triage (IMMEDIATE → ROUTINE)

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** (with Docker Compose)
- **Python 3.8+** (for vector data upload)
- **8GB+ RAM** recommended (16GB for GPU mode)
- **20GB+ disk space** (for Ollama models)

### Installation

#### Windows (PowerShell)

```powershell
# Clone the repository
git clone <repository-url>
cd N8N_AgenticAI_WiseAI

# Run the automated deployment script
.\start-medisafe.ps1
```

#### Linux/macOS (Bash)

```bash
# Clone the repository
git clone <repository-url>
cd N8N_AgenticAI_WiseAI

# Make script executable and run
chmod +x start-medisafe.sh
./start-medisafe.sh
```

The deployment script will:
1. ✅ Validate prerequisites (Docker, Python)
2. 🔐 Generate secure encryption keys
3. 🐳 Start all Docker services
4. 📊 Initialize PostgreSQL audit database
5. 📥 Pull required Ollama models (llama3.2, llama3.1, mistral, nomic-embed-text)
6. 📚 Upload clinical guidelines & cases to Qdrant

### Manual Setup (Advanced)

<details>
<summary>Click to expand manual setup instructions</summary>

#### 1. Configure Environment

```bash
# Copy and edit .env file
cp .env.example .env

# Generate encryption keys (Linux/macOS)
openssl rand -base64 32  # Use for N8N_ENCRYPTION_KEY
openssl rand -base64 32  # Use for N8N_USER_MANAGEMENT_JWT_SECRET

# Generate encryption keys (Windows PowerShell)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

Edit `.env` and set the generated keys.

#### 2. Start Docker Services

```bash
# For CPU-only systems
docker compose --profile cpu up -d

# For NVIDIA GPU systems
docker compose --profile gpu-nvidia up -d

# For AMD GPU systems
docker compose --profile gpu-amd up -d
```

#### 3. Initialize Database

```bash
# Wait for PostgreSQL to be ready
docker exec postgres pg_isready -U n8n_user -d n8n

# Initialize schema
docker exec -i postgres psql -U n8n_user -d n8n < init-db.sql
```

#### 4. Pull Ollama Models

```bash
docker exec ollama ollama pull llama3.2:latest
docker exec ollama ollama pull llama3.1:8b
docker exec ollama ollama pull mistral:7b
docker exec ollama ollama pull nomic-embed-text:latest
```

#### 5. Upload Vector Data

```bash
# Install Python dependencies
pip install requests

# Upload clinical guidelines and cases to Qdrant
python upload-vectors.py
```

</details>

## 🌐 Access Points

After deployment, access the following services:

| Service | URL | Credentials |
|---------|-----|-------------|
| **N8N Workflow UI** | http://localhost:5678 | Set on first access |
| **Qdrant Dashboard** | http://localhost:6333/dashboard | No auth required |
| **Portainer** | https://localhost:9443 | Set on first access |
| **PostgreSQL** | `localhost:5433` | See `.env` file |

## 📖 Usage

### 1. Access N8N

Open http://localhost:5678 in your browser. The MediSafe-MAS v3 workflow should be auto-imported.

### 2. Activate Workflow

- Click on the **"🏥 Patient Input"** workflow
- Click the **"Active"** toggle in the top-right corner
- The workflow is now ready to receive clinical inputs

### 3. Test with Clinical Input

Click the **"Test Workflow"** button and enter a clinical scenario:

**Example Input:**
```
67-year-old male presenting with crushing central chest pain radiating to left arm, 
onset 2 hours ago. Associated with diaphoresis and nausea. 
History: Hypertension, Type 2 Diabetes, ex-smoker (30 pack-years).
Medications: Metformin 1000mg BD, Ramipril 10mg OD, Atorvastatin 40mg ON.
Vitals: BP 145/92, HR 98, RR 22, SpO2 94% on air, Temp 37.1°C.
ECG shows ST elevation in leads II, III, aVF.
```

### 4. Review Output

The system will generate a comprehensive clinical report including:
- ✅ **Safety Score** (0-10)
- 🚨 **Triage Level** (IMMEDIATE/URGENT/STANDARD/NON-URGENT/ROUTINE)
- 🔬 **Differential Diagnoses** (with ICD-10 codes, confidence, evidence)
- 💊 **Drug Interaction Alerts**
- ⚡ **Immediate Actions & Workup**
- 📊 **Clinical Scores** (NEWS2, HEART if applicable)

## 🔧 Configuration

### GPU Acceleration

Edit `.env` and set:
```bash
# For NVIDIA GPUs
COMPOSE_PROFILES=gpu-nvidia

# For AMD GPUs
COMPOSE_PROFILES=gpu-amd
```

Then restart services:
```bash
docker compose --profile gpu-nvidia down
docker compose --profile gpu-nvidia up -d
```

### Ollama Model Selection

Edit the workflow in N8N to change models:
- **Feature Extraction**: llama3.2:latest (fast, accurate)
- **Diagnosis**: llama3.1:8b (balanced reasoning)
- **Triage**: llama3.1:8b (clinical scoring)
- **Safety**: llama3.2:1b (lightweight compliance checks)
- **Synthesizer**: mistral:7b (excellent report generation)

### Custom Clinical Data

Add your own clinical guidelines and cases:

1. Edit `sample-guidelines.json` and `sample-cases.json`
2. Re-run the vector upload:
   ```bash
   python upload-vectors.py
   ```

## 📊 Monitoring & Audit

### View Audit Logs

```sql
-- Connect to PostgreSQL
docker exec -it postgres psql -U n8n_user -d n8n

-- Recent audit entries
SELECT * FROM medisafe_audit_log ORDER BY timestamp DESC LIMIT 10;

-- Daily safety metrics
SELECT * FROM v_safety_metrics LIMIT 7;

-- Pipeline performance
SELECT * FROM v_pipeline_performance LIMIT 10;

-- Cases requiring review (safety score < 7)
SELECT case_id, safety_score, quality_badge, timestamp
FROM medisafe_audit_log
WHERE stage = 'SAFETY_EVALUATED' AND safety_score < 7
ORDER BY timestamp DESC;
```

### View Container Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n
docker compose logs -f ollama
docker compose logs -f qdrant
docker compose logs -f postgres
```

## 🛠️ Troubleshooting

### Services Not Starting

```bash
# Check Docker status
docker ps

# Restart all services
docker compose --profile cpu down
docker compose --profile cpu up -d

# Check logs for errors
docker compose logs
```

### Ollama Models Not Loading

```bash
# Verify models are pulled
docker exec ollama ollama list

# Manually pull a model
docker exec ollama ollama pull llama3.2:latest

# Check Ollama logs
docker logs ollama
```

### Qdrant Collections Empty

```bash
# Re-run vector upload
python upload-vectors.py

# Verify collections
curl http://localhost:6333/collections
```

### PostgreSQL Connection Issues

```bash
# Check PostgreSQL is ready
docker exec postgres pg_isready -U n8n_user -d n8n

# Re-initialize database
docker exec -i postgres psql -U n8n_user -d n8n < init-db.sql
```

### N8N Workflow Not Imported

```bash
# Check n8n-import container logs
docker logs n8n-import

# Manually import workflow
# 1. Open N8N at http://localhost:5678
# 2. Click "Import from File"
# 3. Select: n8n/demo-data/workflows/MediSafe-MAS-v3.json
```

## 🔒 Security Considerations

### Production Deployment

Before deploying to production:

1. **Change default passwords** in `.env`
2. **Use strong encryption keys** (32+ bytes random)
3. **Enable HTTPS** with reverse proxy (nginx, Traefik)
4. **Restrict network access** (firewall rules, VPN)
5. **Enable authentication** for Qdrant and Portainer
6. **Regular backups** of PostgreSQL and Qdrant data
7. **Monitor audit logs** for security events

### HIPAA/GDPR Compliance

⚠️ **Important**: This system processes clinical data. Ensure compliance with:
- **HIPAA** (US): Encrypt data at rest and in transit, access controls, audit logs
- **GDPR** (EU): Data minimization, right to erasure, consent management
- **EU AI Act**: High-risk AI system requirements (human oversight, transparency)

### Prompt Injection Protection

The system includes basic prompt injection detection. For production:
- Review `🔒 Input Validator & Case ID` node logic
- Add additional security patterns
- Consider rate limiting and IP filtering

## 📚 Documentation

- **Workflow Design**: See `SETUP_MEDISAFE_V3.md`
- **Deployment Guide**: See `DEPLOY.md`
- **Database Schema**: See `init-db.sql`
- **Vector Upload**: See `upload-vectors.py`

## 🧪 Testing

### Sample Test Cases

The system includes sample clinical cases in `sample-cases.json`:
- Acute Myocardial Infarction (STEMI)
- Pulmonary Embolism
- Septic Shock
- Diabetic Ketoacidosis
- Acute Appendicitis
- And more...

### Integration Testing

```bash
# Test Qdrant search
curl -X POST http://localhost:6333/collections/clinical_guidelines/points/search \
  -H "Content-Type: application/json" \
  -d '{"vector": [0.1, 0.2, ...], "limit": 3}'

# Test PostgreSQL
docker exec postgres psql -U n8n_user -d n8n -c "SELECT COUNT(*) FROM medisafe_audit_log;"

# Test Ollama
curl http://localhost:11434/api/generate -d '{"model": "llama3.2", "prompt": "Test"}'
```

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## ⚠️ Disclaimer

**MediSafe-MAS v3 is a research prototype for clinical decision support.**

- ❌ **NOT a medical device** (not FDA/CE approved)
- ❌ **NOT a substitute for clinical judgment**
- ✅ **Requires human oversight** by licensed medical professionals
- ✅ **All outputs must be validated** before clinical use

This system is designed to **assist**, not **replace**, healthcare providers.

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Review existing documentation
- Check troubleshooting section above

---

**Built with ❤️ for safer clinical decision-making**

*Powered by: n8n • Ollama • Qdrant • PostgreSQL*
