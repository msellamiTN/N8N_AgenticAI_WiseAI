#!/bin/bash
# =============================================================================
# Update file paths in configuration files after reorganization
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Updating file paths in configuration files...${NC}\n"

# Update docker-compose.yml
if [ -f "config/docker-compose.yml" ]; then
    echo -e "${YELLOW}Updating config/docker-compose.yml...${NC}"
    
    # Update init-db.sql path reference (if any)
    sed -i.bak 's|./init-db.sql|./config/database/init-db.sql|g' config/docker-compose.yml
    
    # Update sample data paths
    sed -i.bak 's|./sample-guidelines.json|./data/guidelines/sample-guidelines.json|g' config/docker-compose.yml
    sed -i.bak 's|./sample-cases.json|./data/cases/sample-cases.json|g' config/docker-compose.yml
    
    rm -f config/docker-compose.yml.bak
    echo -e "  ${GREEN}✅ Updated docker-compose.yml${NC}"
fi

# Update deployment scripts
if [ -f "scripts/deploy/start-medisafe.sh" ]; then
    echo -e "${YELLOW}Updating scripts/deploy/start-medisafe.sh...${NC}"
    
    sed -i.bak 's|docker-compose.yml|config/docker-compose.yml|g' scripts/deploy/start-medisafe.sh
    sed -i.bak 's|init-db.sql|config/database/init-db.sql|g' scripts/deploy/start-medisafe.sh
    sed -i.bak 's|upload-vectors.py|scripts/data/upload-vectors.py|g' scripts/deploy/start-medisafe.sh
    
    rm -f scripts/deploy/start-medisafe.sh.bak
    echo -e "  ${GREEN}✅ Updated start-medisafe.sh${NC}"
fi

# Update vector upload script
if [ -f "scripts/data/upload-vectors.py" ]; then
    echo -e "${YELLOW}Updating scripts/data/upload-vectors.py...${NC}"
    
    sed -i.bak "s|'sample-guidelines.json'|'data/guidelines/sample-guidelines.json'|g" scripts/data/upload-vectors.py
    sed -i.bak "s|'sample-cases.json'|'data/cases/sample-cases.json'|g" scripts/data/upload-vectors.py
    
    rm -f scripts/data/upload-vectors.py.bak
    echo -e "  ${GREEN}✅ Updated upload-vectors.py${NC}"
fi

# Create symlinks in root for backward compatibility
echo -e "\n${YELLOW}Creating backward compatibility symlinks...${NC}"

ln -sf config/docker-compose.yml docker-compose.yml 2>/dev/null || true
echo -e "  ${GREEN}✅ Created symlink: docker-compose.yml → config/docker-compose.yml${NC}"

echo -e "\n${GREEN}✅ Path updates complete!${NC}\n"
