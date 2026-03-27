#!/bin/bash
# =============================================================================
# MediSafe-MAS v3 Deployment Script for Linux/macOS
# =============================================================================
# Automated deployment script that:
# - Validates prerequisites
# - Generates secure encryption keys
# - Starts Docker services
# - Initializes PostgreSQL database
# - Uploads vector data to Qdrant
# - Pulls required Ollama models
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default parameters
PROFILE="${1:-cpu}"
SKIP_VECTOR_UPLOAD=false
SKIP_MODEL_PULL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-vector-upload)
            SKIP_VECTOR_UPLOAD=true
            shift
            ;;
        --skip-model-pull)
            SKIP_MODEL_PULL=true
            shift
            ;;
        cpu|gpu-nvidia|gpu-amd)
            PROFILE=$1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  MediSafe-MAS v3 - Clinical AI Multi-Agent System${NC}"
echo -e "${CYAN}  Deployment Script for Linux/macOS${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# ── Step 1: Check Prerequisites ──
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "  ${GREEN}✅ Docker installed: $DOCKER_VERSION${NC}"
else
    echo -e "  ${RED}❌ Docker is not installed${NC}"
    echo -e "     Install from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check Docker Compose
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    echo -e "  ${GREEN}✅ Docker Compose available: $COMPOSE_VERSION${NC}"
else
    echo -e "  ${RED}❌ Docker Compose is not available${NC}"
    exit 1
fi

# Check Python (for vector upload)
if [ "$SKIP_VECTOR_UPLOAD" = false ]; then
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        echo -e "  ${GREEN}✅ Python installed: $PYTHON_VERSION${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Python not found - vector upload will be skipped${NC}"
        SKIP_VECTOR_UPLOAD=true
    fi
fi

# ── Step 2: Generate Encryption Keys ──
echo -e "\n${YELLOW}[2/7] Configuring environment...${NC}"

if [ -f ".env" ]; then
    echo -e "  ${CYAN}ℹ️  .env file exists${NC}"
    
    if grep -q "CHANGE_ME" .env; then
        echo -e "  ${CYAN}🔐 Generating secure encryption keys...${NC}"
        
        # Generate N8N_ENCRYPTION_KEY
        ENCRYPTION_KEY=$(openssl rand -base64 32)
        sed -i.bak "s|N8N_ENCRYPTION_KEY=CHANGE_ME_GENERATE_RANDOM_32_BYTE_KEY|N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY|g" .env
        
        # Generate N8N_USER_MANAGEMENT_JWT_SECRET
        JWT_SECRET=$(openssl rand -base64 32)
        sed -i.bak "s|N8N_USER_MANAGEMENT_JWT_SECRET=CHANGE_ME_GENERATE_RANDOM_32_BYTE_KEY|N8N_USER_MANAGEMENT_JWT_SECRET=$JWT_SECRET|g" .env
        
        # Update COMPOSE_PROFILES
        sed -i.bak "s|COMPOSE_PROFILES=cpu|COMPOSE_PROFILES=$PROFILE|g" .env
        
        rm -f .env.bak
        echo -e "  ${GREEN}✅ Encryption keys generated and saved to .env${NC}"
    else
        echo -e "  ${GREEN}✅ Encryption keys already configured${NC}"
    fi
    
    # Export all variables from .env for Docker Compose
    echo -e "  ${CYAN}📋 Loading environment variables...${NC}"
    set -a
    source .env
    set +a
    echo -e "  ${GREEN}✅ Environment variables loaded${NC}"
else
    echo -e "  ${RED}❌ .env file not found!${NC}"
    echo -e "     Run this script from the project root directory"
    exit 1
fi

# ── Step 3: Start Docker Services ──
echo -e "\n${YELLOW}[3/7] Starting Docker services (profile: $PROFILE)...${NC}"

if docker compose --profile "$PROFILE" up -d; then
    echo -e "  ${GREEN}✅ Docker services started${NC}"
else
    echo -e "  ${RED}❌ Failed to start Docker services${NC}"
    exit 1
fi

# ── Step 4: Wait for Services ──
echo -e "\n${YELLOW}[4/7] Waiting for services to be ready...${NC}"

# Wait for PostgreSQL
echo -n "  ⏳ Waiting for PostgreSQL..."
MAX_RETRIES=30
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if docker exec postgres pg_isready -U n8n_user -d n8n &> /dev/null; then
        echo -e " ${GREEN}✅${NC}"
        break
    fi
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
done
if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo -e " ${RED}❌ Timeout${NC}"
    exit 1
fi

# Wait for Qdrant
echo -n "  ⏳ Waiting for Qdrant..."
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:6333/collections &> /dev/null; then
        echo -e " ${GREEN}✅${NC}"
        break
    fi
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
done
if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo -e " ${RED}❌ Timeout${NC}"
    exit 1
fi

# Wait for Ollama
echo -n "  ⏳ Waiting for Ollama..."
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:11434/api/tags &> /dev/null; then
        echo -e " ${GREEN}✅${NC}"
        break
    fi
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -n "."
done
if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo -e " ${RED}❌ Timeout${NC}"
    exit 1
fi

# ── Step 5: Initialize Database ──
echo -e "\n${YELLOW}[5/7] Initializing PostgreSQL database...${NC}"

if docker exec -i postgres psql -U n8n_user -d n8n < init-db.sql &> /dev/null; then
    echo -e "  ${GREEN}✅ Database schema created${NC}"
else
    echo -e "  ${YELLOW}⚠️  Database may already be initialized${NC}"
fi

# ── Step 6: Pull Ollama Models ──
if [ "$SKIP_MODEL_PULL" = false ]; then
    echo -e "\n${YELLOW}[6/7] Pulling required Ollama models...${NC}"
    
    MODELS=(
        "llama3.2:latest"
        "llama3.1:8b"
        "mistral:7b"
        "nomic-embed-text:latest"
    )
    
    for MODEL in "${MODELS[@]}"; do
        echo -e "  ${CYAN}📥 Pulling $MODEL...${NC}"
        if docker exec ollama ollama pull "$MODEL"; then
            echo -e "  ${GREEN}✅ $MODEL ready${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Failed to pull $MODEL${NC}"
        fi
    done
else
    echo -e "\n${YELLOW}[6/7] Skipping Ollama model pull${NC}"
fi

# ── Step 7: Upload Vector Data ──
if [ "$SKIP_VECTOR_UPLOAD" = false ]; then
    echo -e "\n${YELLOW}[7/7] Uploading vector data to Qdrant...${NC}"
    
    # Install Python dependencies
    echo -e "  ${CYAN}📦 Installing Python dependencies...${NC}"
    python3 -m pip install --quiet requests 2> /dev/null || true
    
    # Run upload script
    if python3 upload-vectors.py; then
        echo -e "  ${GREEN}✅ Vector data uploaded successfully${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Vector upload had issues${NC}"
    fi
else
    echo -e "\n${YELLOW}[7/7] Skipping vector data upload${NC}"
fi

# ── Deployment Complete ──
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  ✅ MediSafe-MAS v3 Deployment Complete!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo -e "\n${CYAN}Services available at:${NC}"
echo -e "  • N8N Workflow UI:    http://localhost:5678"
echo -e "  • Qdrant Dashboard:   http://localhost:6333/dashboard"
echo -e "  • Portainer:          https://localhost:9443"
echo -e "  • PostgreSQL:         localhost:5433"
echo -e "\n${CYAN}Next steps:${NC}"
echo -e "  1. Open N8N at http://localhost:5678"
echo -e "  2. The MediSafe-MAS v3 workflow should be auto-imported"
echo -e "  3. Activate the workflow and test with clinical input"
echo -e "\n${CYAN}To stop services:${NC}"
echo -e "  docker compose --profile $PROFILE down"
echo -e "\n${CYAN}To view logs:${NC}"
echo -e "  docker compose logs -f"
echo ""
