#!/bin/bash
# =============================================================================
# MediSafe-MAS v3 - Project Reorganization Script for Linux/macOS
# =============================================================================
# This script reorganizes the project files into a clean architecture structure
# with proper separation of concerns: config, scripts, workflows, data, docs
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  MediSafe-MAS v3 - Project Reorganization${NC}"
echo -e "${CYAN}  Clean Architecture Structure${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# ── Step 1: Create folder structure ──
echo -e "${YELLOW}[1/6] Creating clean architecture folder structure...${NC}"

folders=(
    "config"
    "config/database"
    "scripts"
    "scripts/deploy"
    "scripts/data"
    "workflows"
    "workflows/medisafe-mas-v3"
    "workflows/archive"
    "workflows/tools"
    "data"
    "data/guidelines"
    "data/cases"
    "docs"
    "docs/use-cases"
)

for folder in "${folders[@]}"; do
    if [ ! -d "$folder" ]; then
        mkdir -p "$folder"
        echo -e "  ${GREEN}✅ Created: $folder${NC}"
    else
        echo -e "  ${CYAN}ℹ️  Exists: $folder${NC}"
    fi
done

# ── Step 2: Move configuration files ──
echo -e "\n${YELLOW}[2/6] Moving configuration files...${NC}"

declare -A config_moves=(
    [".env.example"]="config/.env.example"
    [".env.template"]="config/.env.template"
    ["docker-compose.yml"]="config/docker-compose.yml"
    ["init-db.sql"]="config/database/init-db.sql"
)

for source in "${!config_moves[@]}"; do
    dest="${config_moves[$source]}"
    if [ -f "$source" ]; then
        cp "$source" "$dest"
        echo -e "  ${GREEN}✅ Copied: $source → $dest${NC}"
    fi
done

# ── Step 3: Move scripts ──
echo -e "\n${YELLOW}[3/6] Moving scripts...${NC}"

declare -A script_moves=(
    ["start-medisafe.sh"]="scripts/deploy/start-medisafe.sh"
    ["start-medisafe.ps1"]="scripts/deploy/start-medisafe.ps1"
    ["install-docker.sh"]="scripts/deploy/install-docker.sh"
    ["upload-vectors.py"]="scripts/data/upload-vectors.py"
)

for source in "${!script_moves[@]}"; do
    dest="${script_moves[$source]}"
    if [ -f "$source" ]; then
        cp "$source" "$dest"
        chmod +x "$dest" 2>/dev/null || true
        echo -e "  ${GREEN}✅ Copied: $source → $dest${NC}"
    fi
done

# ── Step 4: Move workflows ──
echo -e "\n${YELLOW}[4/6] Moving workflows...${NC}"

declare -A workflow_moves=(
    ["MediSafe-MAS v3 — Industrial (Ollama + Qdrant RAG + Tools + PostgreSQL Audit)2.json"]="workflows/medisafe-mas-v3/MediSafe-MAS-v3.json"
    ["MediSafe_MAS_v3_Industrial_Ollama.json"]="workflows/archive/MediSafe_MAS_v3_Industrial_Ollama.json"
    ["WiseAI_Multi_Agent_v2_Fixed.json"]="workflows/archive/WiseAI_Multi_Agent_v2_Fixed.json"
    ["icd10-lookup-tool.js"]="workflows/tools/icd10-lookup-tool.js"
)

for source in "${!workflow_moves[@]}"; do
    dest="${workflow_moves[$source]}"
    if [ -f "$source" ]; then
        cp "$source" "$dest"
        echo -e "  ${GREEN}✅ Copied: $source → $dest${NC}"
    fi
done

# ── Step 5: Move data files ──
echo -e "\n${YELLOW}[5/6] Moving data files...${NC}"

declare -A data_moves=(
    ["sample-guidelines.json"]="data/guidelines/sample-guidelines.json"
    ["sample-cases.json"]="data/cases/sample-cases.json"
)

for source in "${!data_moves[@]}"; do
    dest="${data_moves[$source]}"
    if [ -f "$source" ]; then
        cp "$source" "$dest"
        echo -e "  ${GREEN}✅ Copied: $source → $dest${NC}"
    fi
done

# ── Step 6: Move documentation ──
echo -e "\n${YELLOW}[6/6] Moving documentation...${NC}"

declare -A doc_moves=(
    ["DEPLOY.md"]="docs/DEPLOY.md"
    ["QUICKSTART.md"]="docs/QUICKSTART.md"
    ["SETUP_MEDISAFE_V3.md"]="docs/SETUP_MEDISAFE_V3.md"
    ["MediSafe_MAS_ICCSIC2026_UseCase.docx"]="docs/use-cases/MediSafe_MAS_ICCSIC2026_UseCase.docx"
    ["MediSafe_MAS_ICCSIC2026_UseCase (1).docx"]="docs/use-cases/MediSafe_MAS_ICCSIC2026_UseCase_v2.docx"
    ["doc.m"]="docs/doc.m"
)

for source in "${!doc_moves[@]}"; do
    dest="${doc_moves[$source]}"
    if [ -f "$source" ]; then
        cp "$source" "$dest"
        echo -e "  ${GREEN}✅ Copied: $source → $dest${NC}"
    fi
done

# Keep README.md in root
if [ -f "README.md" ]; then
    echo -e "  ${CYAN}ℹ️  Keeping README.md in project root${NC}"
fi

# ── Summary ──
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  ✅ Project Reorganization Complete!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo -e "\n${CYAN}New structure:${NC}"
echo -e "  📁 config/          - Configuration files"
echo -e "  📁 scripts/         - Deployment & utility scripts"
echo -e "  📁 workflows/       - N8N workflows & tools"
echo -e "  📁 data/            - Clinical data & knowledge base"
echo -e "  📁 docs/            - Documentation"
echo -e "  📁 n8n/             - N8N runtime data"
echo -e "  📁 shared/          - Shared container data"
echo -e "\n${CYAN}Next steps:${NC}"
echo -e "  1. Review PROJECT_STRUCTURE.md for details"
echo -e "  2. Update docker-compose.yml paths (run update-paths.sh)"
echo -e "  3. Test deployment with new structure"
echo ""
