# MediSafe-MAS v3 — Complete Setup Guide

## 🎯 Overview
This guide provides step-by-step instructions to deploy the MediSafe-MAS v3 clinical AI multi-agent system with full functionality including PostgreSQL audit logging, Qdrant RAG, and Ollama LLMs.

---

## 📋 Prerequisites Checklist

- [ ] Docker Desktop installed and running
- [ ] At least 16GB RAM available (8GB minimum)
- [ ] 20GB free disk space for models and data
- [ ] PowerShell or terminal access
- [ ] Internet connection for model downloads

---

## 🔧 Phase 1: Environment Configuration

### 1.1 Create .env File

```powershell
cd "d:\Data2AI Academy\N8N_AgenticAI_WiseAI"
copy .env.example .env
```

### 1.2 Generate Encryption Keys

**PowerShell:**
```powershell
# Generate N8N_ENCRYPTION_KEY (32 bytes)
$encKey = [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
Write-Host "N8N_ENCRYPTION_KEY=$encKey"

# Generate JWT Secret (32 bytes)
$jwtSecret = [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
Write-Host "N8N_USER_MANAGEMENT_JWT_SECRET=$jwtSecret"

# Generate PostgreSQL password (16 chars)
$pgPass = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
Write-Host "POSTGRES_PASSWORD=$pgPass"
```

### 1.3 Complete .env File

Add these lines to your `.env` file:

```env
# ============= N8N Configuration =============
N8N_PORT=5678
N8N_HOST=localhost
N8N_PROTOCOL=http
WEBHOOK_URL=
GENERIC_TIMEZONE=Europe/Paris
N8N_RUNNERS_ENABLED=true

# Security Keys (REPLACE with generated values)
N8N_ENCRYPTION_KEY=<YOUR_GENERATED_KEY>
N8N_USER_MANAGEMENT_JWT_SECRET=<YOUR_GENERATED_JWT>

# ============= PostgreSQL Configuration =============
POSTGRES_USER=medisafe_admin
POSTGRES_PASSWORD=<YOUR_GENERATED_PASSWORD>
POSTGRES_DB=medisafe_db

# ============= Ollama Configuration =============
OLLAMA_HOST=ollama:11434
```

---

## 🗄️ Phase 2: PostgreSQL Database Setup

### 2.1 Create Database Schema File

Create `init-db.sql`:

```sql
-- MediSafe-MAS v3 Audit Log Schema
-- This table tracks all pipeline stages for compliance and debugging

CREATE TABLE IF NOT EXISTS medisafe_audit_log (
    id SERIAL PRIMARY KEY,
    case_id VARCHAR(50) NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    stage VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Input stage fields
    input_length INTEGER,
    injection_flag BOOLEAN,
    pipeline_version VARCHAR(50),
    
    -- Safety stage fields
    safety_score INTEGER,
    approved BOOLEAN,
    quality_badge TEXT,
    
    -- Report stage fields
    report_snippet TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_case_id ON medisafe_audit_log(case_id);
CREATE INDEX idx_session_id ON medisafe_audit_log(session_id);
CREATE INDEX idx_stage ON medisafe_audit_log(stage);
CREATE INDEX idx_timestamp ON medisafe_audit_log(timestamp DESC);

-- View for case timeline
CREATE OR REPLACE VIEW v_case_timeline AS
SELECT 
    case_id,
    session_id,
    stage,
    timestamp,
    safety_score,
    approved,
    quality_badge
FROM medisafe_audit_log
ORDER BY case_id, timestamp;

-- Sample query to verify
-- SELECT * FROM medisafe_audit_log ORDER BY timestamp DESC LIMIT 10;
```

### 2.2 Update docker-compose.yml

Add volume mount for init script in the `postgres` service:

```yaml
postgres:
  image: postgres:16-alpine
  hostname: postgres
  networks: ['demo']
  restart: unless-stopped
  environment:
    - POSTGRES_USER
    - POSTGRES_PASSWORD
    - POSTGRES_DB
  ports:
    - 5433:5432
  volumes:
    - postgres_storage:/var/lib/postgresql/data
    - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql:ro  # ADD THIS LINE
  healthcheck:
    test: ['CMD-SHELL', 'pg_isready -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB}']
    interval: 5s
    timeout: 5s
    retries: 10
```

---

## 🔍 Phase 3: Qdrant Vector Store Setup

### 3.1 Create Qdrant Collections

After starting services, create collections:

```bash
# Create clinical_guidelines collection
curl -X PUT 'http://localhost:6333/collections/clinical_guidelines' \
  -H 'Content-Type: application/json' \
  -d '{
    "vectors": {
      "size": 768,
      "distance": "Cosine"
    }
  }'

# Create clinical_cases collection
curl -X PUT 'http://localhost:6333/collections/clinical_cases' \
  -H 'Content-Type: application/json' \
  -d '{
    "vectors": {
      "size": 768,
      "distance": "Cosine"
    }
  }'
```

**PowerShell equivalent:**
```powershell
# Create clinical_guidelines collection
Invoke-RestMethod -Uri 'http://localhost:6333/collections/clinical_guidelines' -Method Put -ContentType 'application/json' -Body '{"vectors":{"size":768,"distance":"Cosine"}}'

# Create clinical_cases collection
Invoke-RestMethod -Uri 'http://localhost:6333/collections/clinical_cases' -Method Put -ContentType 'application/json' -Body '{"vectors":{"size":768,"distance":"Cosine"}}'
```

### 3.2 Verify Collections

```bash
curl http://localhost:6333/collections
```

---

## 🦙 Phase 4: Ollama Model Setup

### 4.1 Choose Hardware Profile

**For CPU-only systems:**
```powershell
docker compose --profile cpu up -d
```

**For NVIDIA GPU systems:**
```powershell
docker compose --profile gpu-nvidia up -d
```

**For AMD GPU systems:**
```powershell
docker compose --profile gpu-amd up -d
```

### 4.2 Pull Required Models

The docker-compose will auto-pull `llama3.2`, but you need additional models:

```bash
# Wait for Ollama to be ready
docker exec ollama ollama list

# Pull all required models
docker exec ollama ollama pull llama3.2:latest
docker exec ollama ollama pull llama3.1:8b
docker exec ollama ollama pull mistral:7b
docker exec ollama ollama pull nomic-embed-text:latest
```

**PowerShell:**
```powershell
# Check Ollama status
docker exec ollama ollama list

# Pull models (this will take 15-30 minutes depending on connection)
docker exec ollama ollama pull llama3.2:latest
docker exec ollama ollama pull llama3.1:8b
docker exec ollama ollama pull mistral:7b
docker exec ollama ollama pull nomic-embed-text:latest
```

### 4.3 Verify Models

```bash
docker exec ollama ollama list
```

Expected output should show all 4 models.

---

## 📦 Phase 5: N8N Workflow Import

### 5.1 Prepare Workflow Directory

```powershell
# Create workflow import directory
New-Item -ItemType Directory -Force -Path "n8n\demo-data\workflows"

# Copy workflow file
Copy-Item "MediSafe-MAS v3 — Industrial (Ollama + Qdrant RAG + Tools + PostgreSQL Audit)2.json" `
  -Destination "n8n\demo-data\workflows\MediSafe-MAS-v3.json"
```

### 5.2 Start Services

```powershell
# Start all services (choose your profile)
docker compose --profile cpu up -d

# Check status
docker compose ps

# Watch logs
docker compose logs -f n8n
```

### 5.3 Access N8N

1. Open browser: `http://localhost:5678`
2. Create owner account (first-time setup)
3. Workflow should auto-import from `demo-data/workflows/`

---

## 🔑 Phase 6: Configure N8N Credentials

### 6.1 PostgreSQL Credential

1. Go to **Settings** → **Credentials** → **New**
2. Select **Postgres**
3. Configure:
   - **Host:** `postgres`
   - **Database:** `medisafe_db`
   - **User:** `medisafe_admin`
   - **Password:** (from your .env)
   - **Port:** `5432` (internal Docker port)
   - **SSL:** Disabled

### 6.2 Ollama Credential

1. **Settings** → **Credentials** → **New**
2. Select **Ollama API**
3. Configure:
   - **Base URL:** `http://ollama:11434`
   - Leave authentication empty (local)

### 6.3 Qdrant Credential

1. **Settings** → **Credentials** → **New**
2. Select **Qdrant API**
3. Configure:
   - **URL:** `http://qdrant:6333`
   - **API Key:** Leave empty (no auth in local setup)

---

## 📊 Phase 7: Populate Vector Stores (Sample Data)

### 7.1 Create Sample Clinical Guidelines

Create `sample-guidelines.json`:

```json
[
  {
    "text": "Chest Pain Assessment: HEART Score - History (highly suspicious=2, moderately=1, slightly=0), ECG (significant ST changes=2, non-specific=1, normal=0), Age (≥65=2, 45-64=1, <45=0), Risk factors (≥3=2, 1-2=1, none=0), Troponin (>3x normal=2, 1-3x=1, normal=0). Score ≥7: High risk (>50% MACE). Score 4-6: Moderate risk. Score 0-3: Low risk (<2% MACE).",
    "source": "ESC Guidelines 2020"
  },
  {
    "text": "NEWS2 Scoring: Respiratory rate (≤8 or ≥25=3, 9-11 or 21-24=2, 12-20=0), SpO2 (≤91=3, 92-93=2, 94-95=1, ≥96=0), Supplemental O2 (yes=2, no=0), Systolic BP (≤90 or ≥220=3, 91-100=2, 101-110=1, 111-219=0), Heart rate (≤40 or ≥131=3, 41-50 or 111-130=1, 51-90=0, 91-110=1), Consciousness (Alert=0, CVPU=3), Temperature (≤35.0 or ≥39.1=3, 35.1-36.0 or 38.1-39.0=1, 36.1-38.0=0). Aggregate score: 0-4=Low, 5-6=Medium, ≥7=High clinical risk.",
    "source": "Royal College of Physicians UK"
  },
  {
    "text": "Acute Coronary Syndrome Red Flags: Sudden onset chest pain with radiation to jaw/arm, diaphoresis, nausea, dyspnea. ECG changes: ST elevation (STEMI), ST depression, T-wave inversion. Troponin elevation. Immediate actions: Aspirin 300mg, oxygen if SpO2<94%, IV access, 12-lead ECG within 10 minutes, activate cath lab for STEMI.",
    "source": "AHA/ACC Guidelines"
  },
  {
    "text": "Sepsis Recognition (qSOFA): Altered mental status (GCS<15), Systolic BP ≤100 mmHg, Respiratory rate ≥22/min. If ≥2 criteria met, suspect sepsis. Full SOFA score for ICU. Immediate management: Blood cultures before antibiotics, broad-spectrum antibiotics within 1 hour, fluid resuscitation 30ml/kg crystalloid, lactate measurement.",
    "source": "Surviving Sepsis Campaign 2021"
  },
  {
    "text": "Stroke Assessment (FAST): Face drooping, Arm weakness, Speech difficulty, Time to call emergency. Additional signs: sudden severe headache, vision loss, confusion, balance problems. Immediate CT/MRI to rule out hemorrhage. tPA window: 4.5 hours from symptom onset. Thrombectomy window: up to 24 hours in selected cases.",
    "source": "AHA/ASA Stroke Guidelines"
  }
]
```

### 7.2 Create Sample Clinical Cases

Create `sample-cases.json`:

```json
[
  {
    "text": "Case: 58yo male, sudden crushing chest pain radiating to left arm, diaphoresis. Vitals: BP 145/90, HR 102, RR 22, SpO2 96%. ECG: ST elevation in leads II, III, aVF. Troponin elevated 5x normal. Diagnosis: Inferior STEMI. Management: Aspirin, clopidogrel, heparin, emergent PCI. Outcome: Successful revascularization, discharged day 5.",
    "diagnosis": "Acute Myocardial Infarction (STEMI)",
    "icd10": "I21.1"
  },
  {
    "text": "Case: 72yo female, fever 39.2°C, confusion, hypotension BP 88/50. HR 128, RR 28, SpO2 91% on room air. WBC 18,000, lactate 4.2. Blood cultures positive for E.coli. Diagnosis: Urosepsis with septic shock. Management: IV fluids 2L, norepinephrine, meropenem. ICU admission. Outcome: Stabilized after 48h, completed 10-day antibiotic course.",
    "diagnosis": "Septic Shock",
    "icd10": "R65.21"
  },
  {
    "text": "Case: 45yo male, sudden severe headache 'worst of life', photophobia, neck stiffness. BP 180/105, HR 88, alert. CT head: subarachnoid hemorrhage. CTA: anterior communicating artery aneurysm. Diagnosis: Aneurysmal SAH. Management: Nimodipine, BP control, neurosurgery consult, coiling performed day 2. Outcome: Good recovery, modified Rankin 1 at 3 months.",
    "diagnosis": "Subarachnoid Hemorrhage",
    "icd10": "I60.0"
  }
]
```

### 7.3 Upload to Qdrant

Create `upload-vectors.py`:

```python
import json
import requests

# Configuration
OLLAMA_URL = "http://localhost:11434/api/embeddings"
QDRANT_URL = "http://localhost:6333"

def get_embedding(text):
    """Get embedding from Ollama"""
    response = requests.post(OLLAMA_URL, json={
        "model": "nomic-embed-text:latest",
        "prompt": text
    })
    return response.json()["embedding"]

def upload_guidelines():
    """Upload clinical guidelines to Qdrant"""
    with open('sample-guidelines.json', 'r') as f:
        guidelines = json.load(f)
    
    points = []
    for idx, item in enumerate(guidelines):
        embedding = get_embedding(item["text"])
        points.append({
            "id": idx + 1,
            "vector": embedding,
            "payload": item
        })
    
    response = requests.put(
        f"{QDRANT_URL}/collections/clinical_guidelines/points",
        json={"points": points}
    )
    print(f"Guidelines uploaded: {response.status_code}")

def upload_cases():
    """Upload clinical cases to Qdrant"""
    with open('sample-cases.json', 'r') as f:
        cases = json.load(f)
    
    points = []
    for idx, item in enumerate(cases):
        embedding = get_embedding(item["text"])
        points.append({
            "id": idx + 1,
            "vector": embedding,
            "payload": item
        })
    
    response = requests.put(
        f"{QDRANT_URL}/collections/clinical_cases/points",
        json={"points": points}
    )
    print(f"Cases uploaded: {response.status_code}")

if __name__ == "__main__":
    print("Uploading clinical guidelines...")
    upload_guidelines()
    print("Uploading clinical cases...")
    upload_cases()
    print("Done!")
```

Run the script:
```powershell
python upload-vectors.py
```

---

## ✅ Phase 8: Testing & Validation

### 8.1 Test Database Connection

```powershell
# Connect to PostgreSQL
docker exec -it n8n-postgres-1 psql -U medisafe_admin -d medisafe_db

# Verify table exists
\dt

# Check schema
\d medisafe_audit_log

# Exit
\q
```

### 8.2 Test Qdrant Collections

```bash
# Check collections
curl http://localhost:6333/collections

# Check collection info
curl http://localhost:6333/collections/clinical_guidelines
curl http://localhost:6333/collections/clinical_cases
```

### 8.3 Test Ollama Models

```bash
# Test llama3.2
docker exec ollama ollama run llama3.2 "What is sepsis?"

# Test embeddings
curl http://localhost:11434/api/embeddings -d '{
  "model": "nomic-embed-text:latest",
  "prompt": "chest pain"
}'
```

### 8.4 Test MediSafe Workflow

1. Open N8N: `http://localhost:5678`
2. Open **MediSafe-MAS v3** workflow
3. Click **Test workflow** button
4. In chat input, enter:
   ```
   58-year-old male presenting with sudden onset crushing chest pain radiating to left arm, started 2 hours ago. Associated with shortness of breath and sweating. History of hypertension and smoking. Current medications: lisinopril 10mg daily. Vitals: BP 145/92, HR 105, RR 24, SpO2 94% on room air, Temp 37.1°C. Patient appears anxious and diaphoretic.
   ```
5. Verify pipeline executes through all 5 agents
6. Check PostgreSQL for audit entries:
   ```sql
   SELECT * FROM medisafe_audit_log ORDER BY timestamp DESC LIMIT 5;
   ```

---

## 🔍 Troubleshooting

### Issue: Ollama models not found
**Solution:** 
```bash
docker exec ollama ollama pull llama3.2:latest
docker exec ollama ollama pull llama3.1:8b
docker exec ollama ollama pull mistral:7b
docker exec ollama ollama pull nomic-embed-text:latest
```

### Issue: PostgreSQL connection refused
**Solution:**
- Check `.env` has correct `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- Verify postgres container is healthy: `docker compose ps`
- Check logs: `docker compose logs postgres`

### Issue: Qdrant collections not found
**Solution:**
```bash
# Recreate collections
curl -X PUT 'http://localhost:6333/collections/clinical_guidelines' \
  -H 'Content-Type: application/json' \
  -d '{"vectors":{"size":768,"distance":"Cosine"}}'
```

### Issue: N8N credentials not working
**Solution:**
- Delete and recreate credentials
- Ensure internal Docker hostnames: `postgres`, `ollama`, `qdrant` (not `localhost`)
- Test connection in credential modal

### Issue: Workflow execution timeout
**Solution:**
- Increase timeout in workflow settings
- Check Ollama has sufficient resources
- Verify models are loaded: `docker exec ollama ollama list`

---

## 📊 Monitoring & Maintenance

### View Logs
```powershell
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n
docker compose logs -f ollama
docker compose logs -f postgres
docker compose logs -f qdrant
```

### Check Resource Usage
```powershell
docker stats
```

### Backup Database
```powershell
docker exec n8n-postgres-1 pg_dump -U medisafe_admin medisafe_db > backup.sql
```

### Backup Qdrant
```powershell
# Create snapshot
curl -X POST 'http://localhost:6333/collections/clinical_guidelines/snapshots'
curl -X POST 'http://localhost:6333/collections/clinical_cases/snapshots'
```

---

## 🎓 Next Steps

1. **Populate more clinical data** - Add comprehensive guidelines and cases
2. **Configure ICD-10 lookup tool** - Integrate with medical coding API
3. **Set up monitoring** - Add Prometheus/Grafana for metrics
4. **Enable HTTPS** - Configure reverse proxy for production
5. **Implement authentication** - Set up SSO for multi-user access

---

## 📚 References

- [N8N Documentation](https://docs.n8n.io/)
- [Ollama Documentation](https://ollama.ai/docs)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## ⚠️ Important Notes

- **This is a research/educational system** - Not for clinical use without proper validation
- **EU AI Act compliance** - High-risk AI system requiring human oversight
- **Data privacy** - Ensure GDPR/HIPAA compliance before processing real patient data
- **Model limitations** - LLMs can hallucinate; always validate outputs
- **Resource requirements** - Minimum 8GB RAM, recommended 16GB+
