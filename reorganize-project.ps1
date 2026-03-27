#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Reorganize MediSafe-MAS v3 project into clean architecture structure
.DESCRIPTION
    This script reorganizes the project files into a clean architecture folder structure
    with proper separation of concerns: config, scripts, workflows, data, docs
#>

$ErrorActionPreference = 'Stop'

Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host "  MediSafe-MAS v3 - Project Reorganization" -ForegroundColor Cyan
Write-Host "  Clean Architecture Structure" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Create folder structure ──
Write-Host "[1/6] Creating clean architecture folder structure..." -ForegroundColor Yellow

$folders = @(
    "config",
    "config/database",
    "scripts",
    "scripts/deploy",
    "scripts/data",
    "workflows",
    "workflows/medisafe-mas-v3",
    "workflows/archive",
    "workflows/tools",
    "data",
    "data/guidelines",
    "data/cases",
    "docs",
    "docs/use-cases"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "  ✅ Created: $folder" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Exists: $folder" -ForegroundColor Cyan
    }
}

# ── Step 2: Move configuration files ──
Write-Host "`n[2/6] Moving configuration files..." -ForegroundColor Yellow

$configMoves = @{
    ".env.example" = "config/.env.example"
    ".env.template" = "config/.env.template"
    "docker-compose.yml" = "config/docker-compose.yml"
    "init-db.sql" = "config/database/init-db.sql"
}

foreach ($source in $configMoves.Keys) {
    $dest = $configMoves[$source]
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✅ Copied: $source → $dest" -ForegroundColor Green
    }
}

# ── Step 3: Move scripts ──
Write-Host "`n[3/6] Moving scripts..." -ForegroundColor Yellow

$scriptMoves = @{
    "start-medisafe.sh" = "scripts/deploy/start-medisafe.sh"
    "start-medisafe.ps1" = "scripts/deploy/start-medisafe.ps1"
    "install-docker.sh" = "scripts/deploy/install-docker.sh"
    "upload-vectors.py" = "scripts/data/upload-vectors.py"
}

foreach ($source in $scriptMoves.Keys) {
    $dest = $scriptMoves[$source]
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✅ Copied: $source → $dest" -ForegroundColor Green
    }
}

# ── Step 4: Move workflows ──
Write-Host "`n[4/6] Moving workflows..." -ForegroundColor Yellow

$workflowMoves = @{
    "MediSafe-MAS v3 — Industrial (Ollama + Qdrant RAG + Tools + PostgreSQL Audit)2.json" = "workflows/medisafe-mas-v3/MediSafe-MAS-v3.json"
    "MediSafe_MAS_v3_Industrial_Ollama.json" = "workflows/archive/MediSafe_MAS_v3_Industrial_Ollama.json"
    "WiseAI_Multi_Agent_v2_Fixed.json" = "workflows/archive/WiseAI_Multi_Agent_v2_Fixed.json"
    "icd10-lookup-tool.js" = "workflows/tools/icd10-lookup-tool.js"
}

foreach ($source in $workflowMoves.Keys) {
    $dest = $workflowMoves[$source]
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✅ Copied: $source → $dest" -ForegroundColor Green
    }
}

# ── Step 5: Move data files ──
Write-Host "`n[5/6] Moving data files..." -ForegroundColor Yellow

$dataMoves = @{
    "sample-guidelines.json" = "data/guidelines/sample-guidelines.json"
    "sample-cases.json" = "data/cases/sample-cases.json"
}

foreach ($source in $dataMoves.Keys) {
    $dest = $dataMoves[$source]
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✅ Copied: $source → $dest" -ForegroundColor Green
    }
}

# ── Step 6: Move documentation ──
Write-Host "`n[6/6] Moving documentation..." -ForegroundColor Yellow

$docMoves = @{
    "DEPLOY.md" = "docs/DEPLOY.md"
    "QUICKSTART.md" = "docs/QUICKSTART.md"
    "SETUP_MEDISAFE_V3.md" = "docs/SETUP_MEDISAFE_V3.md"
    "MediSafe_MAS_ICCSIC2026_UseCase.docx" = "docs/use-cases/MediSafe_MAS_ICCSIC2026_UseCase.docx"
    "MediSafe_MAS_ICCSIC2026_UseCase (1).docx" = "docs/use-cases/MediSafe_MAS_ICCSIC2026_UseCase_v2.docx"
    "doc.m" = "docs/doc.m"
}

foreach ($source in $docMoves.Keys) {
    $dest = $docMoves[$source]
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✅ Copied: $source → $dest" -ForegroundColor Green
    }
}

# Keep README.md in root
if (Test-Path "README.md") {
    Write-Host "  ℹ️  Keeping README.md in project root" -ForegroundColor Cyan
}

# ── Summary ──
Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Green
Write-Host "  ✅ Project Reorganization Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green
Write-Host "`nNew structure:" -ForegroundColor Cyan
Write-Host "  [config/]          - Configuration files" -ForegroundColor White
Write-Host "  [scripts/]         - Deployment and utility scripts" -ForegroundColor White
Write-Host "  [workflows/]       - N8N workflows and tools" -ForegroundColor White
Write-Host "  [data/]            - Clinical data and knowledge base" -ForegroundColor White
Write-Host "  [docs/]            - Documentation" -ForegroundColor White
Write-Host "  [n8n/]             - N8N runtime data" -ForegroundColor White
Write-Host "  [shared/]          - Shared container data" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Review PROJECT_STRUCTURE.md for details" -ForegroundColor White
Write-Host "  2. Update docker-compose.yml paths (run update-paths.ps1)" -ForegroundColor White
Write-Host "  3. Test deployment with new structure" -ForegroundColor White
Write-Host ""
