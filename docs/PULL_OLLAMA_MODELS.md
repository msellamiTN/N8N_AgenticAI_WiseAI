# Pulling Ollama Models for MediSafe-MAS v3

## Quick Commands

Run these commands on your Ubuntu server to pull the required models:

```bash
# Pull the main reasoning model (choose one)
docker exec ollama ollama pull llama3.2:latest

# OR use llama3.1 (8B parameters, faster)
docker exec ollama ollama pull llama3.1:8b

# Pull the embedding model (required for RAG)
docker exec ollama ollama pull nomic-embed-text:latest
```

## Verify Models

Check that models are installed:

```bash
docker exec ollama ollama list
```

Expected output:
```
NAME                     ID              SIZE      MODIFIED
llama3.2:latest          a80c4f17acd5    2.0 GB    X minutes ago
nomic-embed-text:latest  0a109f422b47    274 MB    X minutes ago
```

## Test Models

Test the LLM:
```bash
docker exec ollama ollama run llama3.2:latest "Hello, how are you?"
```

Test the embedding model:
```bash
docker exec ollama ollama run nomic-embed-text:latest "Test embedding"
```

## Model Options

### For Main Reasoning (choose one):

- **llama3.2:latest** (2GB) - Latest, best quality
- **llama3.1:8b** (4.7GB) - Larger, more capable
- **mistral:7b** (4.1GB) - Alternative, good performance
- **phi3:mini** (2.3GB) - Smallest, fastest

### For Embeddings (required):

- **nomic-embed-text:latest** (274MB) - Best for RAG

## Troubleshooting

### Model Pull Fails

If pulling fails with network errors:

```bash
# Check Ollama is running
docker ps | grep ollama

# Check Ollama logs
docker logs ollama

# Restart Ollama if needed
docker restart ollama

# Try pulling again
docker exec ollama ollama pull llama3.2:latest
```

### Disk Space Issues

Check available space:
```bash
df -h
docker system df
```

Clean up unused Docker resources:
```bash
docker system prune -a
```

### Slow Download

Models are large (2-5GB). Download time depends on your internet speed:
- 100 Mbps: ~5-10 minutes
- 50 Mbps: ~10-20 minutes
- 10 Mbps: ~30-60 minutes

## After Pulling Models

Once models are pulled, upload the vector data:

```bash
cd ~/N8N_AgenticAI_WiseAI
python3 scripts/data/upload-vectors.py
```

Then test the workflow in n8n at http://your-server:5678
