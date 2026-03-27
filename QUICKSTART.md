# MediSafe-MAS v3 — Quick Start Guide

## 🚀 One-Command Deployment

### Linux/Ubuntu (Your Current System)

```bash
# 1. Navigate to project directory
cd ~/N8N_AgenticAI_WiseAI

# 2. Run deployment script
sudo ./start-medisafe.sh
```

**Note**: The script will automatically:
- ✅ Validate Docker and Python
- 🔐 Load environment variables from `.env`
- 🐳 Pull and start all Docker containers
- 📊 Initialize PostgreSQL database
- 📥 Pull Ollama models (llama3.2, llama3.1, mistral, nomic-embed-text)
- 📚 Upload clinical data to Qdrant

### Expected Output

```
============================================================
  MediSafe-MAS v3 - Clinical AI Multi-Agent System
============================================================

[1/7] Checking prerequisites...
  ✅ Docker installed
  ✅ Docker Compose available
  ✅ Python installed

[2/7] Configuring environment...
  ✅ Environment variables loaded

[3/7] Starting Docker services...
  ✅ Docker services started

[4/7] Waiting for services...
  ✅ PostgreSQL ready
  ✅ Qdrant ready
  ✅ Ollama ready

[5/7] Initializing database...
  ✅ Database schema created

[6/7] Pulling Ollama models...
  ✅ llama3.2:latest ready
  ✅ llama3.1:8b ready
  ✅ mistral:7b ready
  ✅ nomic-embed-text:latest ready

[7/7] Uploading vector data...
  ✅ Vector data uploaded

============================================================
  ✅ MediSafe-MAS v3 Deployment Complete!
============================================================
```

## 📍 Access Your System

Once deployment completes, open these URLs:

| Service | URL | Purpose |
|---------|-----|---------|
| **N8N Workflow** | http://localhost:5678 | Main workflow interface |
| **Qdrant Dashboard** | http://localhost:6333/dashboard | Vector database UI |
| **Portainer** | https://localhost:9443 | Container management |

## 🧪 Test the System

1. **Open N8N**: Navigate to http://localhost:5678
2. **Find Workflow**: Look for "MediSafe-MAS v3" in the workflows list
3. **Activate**: Toggle the workflow to "Active"
4. **Test Input**: Click "Test Workflow" and enter:

```
67-year-old male with crushing chest pain radiating to left arm, 
onset 2 hours ago. Diaphoresis and nausea present.
History: HTN, Type 2 DM, ex-smoker.
Vitals: BP 145/92, HR 98, RR 22, SpO2 94%, Temp 37.1°C.
ECG: ST elevation in II, III, aVF.
```

5. **Review Output**: You'll receive a comprehensive clinical report with:
   - Safety score
   - Triage level (IMMEDIATE/URGENT/etc.)
   - Differential diagnoses with ICD-10 codes
   - Drug interaction alerts
   - Recommended workup

## 🛑 Stop the System

```bash
cd ~/N8N_AgenticAI_WiseAI
docker compose --profile cpu down
```

## 🔍 View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n
docker compose logs -f ollama
```

## ⚠️ Troubleshooting

### Environment Variable Warnings

If you see warnings like:
```
WARN[0000] The "POSTGRES_USER" variable is not set
```

**Solution**: The updated script now automatically loads `.env` variables. Re-run:
```bash
sudo ./start-medisafe.sh
```

### Services Not Starting

```bash
# Check Docker status
docker ps

# Restart services
docker compose --profile cpu down
docker compose --profile cpu up -d
```

### Ollama Models Not Downloading

Models are large (3-7GB each). First deployment may take 15-30 minutes depending on your internet speed.

Check progress:
```bash
docker logs -f ollama
```

### Port Already in Use

If port 5678, 6333, or 5433 is already in use, edit `.env`:
```bash
nano .env
# Change N8N_PORT, QDRANT_PORT, or PostgreSQL port
```

## 📚 Next Steps

- Review the full [README.md](README.md) for detailed documentation
- Check [SETUP_MEDISAFE_V3.md](SETUP_MEDISAFE_V3.md) for workflow architecture
- Explore sample cases in `sample-cases.json`
- Review audit logs in PostgreSQL

## 🆘 Need Help?

1. Check logs: `docker compose logs`
2. Verify services: `docker ps`
3. Review troubleshooting in README.md
4. Check existing documentation files

---

**Ready to deploy? Run:** `sudo ./start-medisafe.sh`
