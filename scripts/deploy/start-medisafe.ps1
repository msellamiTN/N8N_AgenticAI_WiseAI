#!/usr/bin/env pwsh
<#
.SYNOPSIS
    MediSafe-MAS v3 Deployment Script for Windows
.DESCRIPTION
    Automated deployment script that:
    - Validates prerequisites
    - Generates secure encryption keys
    - Starts Docker services
    - Initializes PostgreSQL database
    - Uploads vector data to Qdrant
    - Pulls required Ollama models
.PARAMETER Profile
    Docker Compose profile to use (cpu, gpu-nvidia, gpu-amd). Default: cpu
.PARAMETER SkipVectorUpload
    Skip uploading vector data to Qdrant
.PARAMETER SkipModelPull
    Skip pulling Ollama models
#>

param(
    [ValidateSet('cpu', 'gpu-nvidia', 'gpu-amd')]
    [string]$Profile = 'cpu',
    [switch]$SkipVectorUpload,
    [switch]$SkipModelPull
)

$ErrorActionPreference = 'Stop'

Write-Host "=" -NoNewline -ForegroundColor Cyan
Write-Host ("=" * 59) -ForegroundColor Cyan
Write-Host "  MediSafe-MAS v3 - Clinical AI Multi-Agent System" -ForegroundColor Cyan
Write-Host "  Deployment Script for Windows" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host ""

# ── Step 1: Check Prerequisites ──
Write-Host "[1/7] Checking prerequisites..." -ForegroundColor Yellow

# Check Docker
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker installed: $dockerVersion" -ForegroundColor Green
    } else {
        throw "Docker not found"
    }
} catch {
    Write-Host "  ❌ Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "     Install from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Check Docker Compose
try {
    $composeVersion = docker compose version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Docker Compose available: $composeVersion" -ForegroundColor Green
    } else {
        throw "Docker Compose not found"
    }
} catch {
    Write-Host "  ❌ Docker Compose is not available" -ForegroundColor Red
    exit 1
}

# Check Python (for vector upload)
if (-not $SkipVectorUpload) {
    try {
        $pythonVersion = python --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Python installed: $pythonVersion" -ForegroundColor Green
        } else {
            throw "Python not found"
        }
    } catch {
        Write-Host "  ⚠️  Python not found - vector upload will be skipped" -ForegroundColor Yellow
        $SkipVectorUpload = $true
    }
}

# ── Step 2: Generate Encryption Keys ──
Write-Host "`n[2/7] Configuring environment..." -ForegroundColor Yellow

if (Test-Path ".env") {
    Write-Host "  ℹ️  .env file exists" -ForegroundColor Cyan
    
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "CHANGE_ME") {
        Write-Host "  🔐 Generating secure encryption keys..." -ForegroundColor Cyan
        
        # Generate N8N_ENCRYPTION_KEY
        $encryptionKey = [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
        $envContent = $envContent -replace 'N8N_ENCRYPTION_KEY=CHANGE_ME_GENERATE_RANDOM_32_BYTE_KEY', "N8N_ENCRYPTION_KEY=$encryptionKey"
        
        # Generate N8N_USER_MANAGEMENT_JWT_SECRET
        $jwtSecret = [Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
        $envContent = $envContent -replace 'N8N_USER_MANAGEMENT_JWT_SECRET=CHANGE_ME_GENERATE_RANDOM_32_BYTE_KEY', "N8N_USER_MANAGEMENT_JWT_SECRET=$jwtSecret"
        
        # Update COMPOSE_PROFILES
        $envContent = $envContent -replace 'COMPOSE_PROFILES=cpu', "COMPOSE_PROFILES=$Profile"
        
        Set-Content ".env" -Value $envContent
        Write-Host "  ✅ Encryption keys generated and saved to .env" -ForegroundColor Green
    } else {
        Write-Host "  ✅ Encryption keys already configured" -ForegroundColor Green
    }
} else {
    Write-Host "  ❌ .env file not found!" -ForegroundColor Red
    Write-Host "     Run this script from the project root directory" -ForegroundColor Yellow
    exit 1
}

# ── Step 3: Start Docker Services ──
Write-Host "`n[3/7] Starting Docker services (profile: $Profile)..." -ForegroundColor Yellow

# Navigate to project root
Set-Location (Join-Path $PSScriptRoot "../..")

try {
    # Use --env-file to explicitly pass .env to Docker Compose
    docker compose --env-file .env --profile $Profile up -d
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose failed"
    }
    Write-Host "  ✅ Docker services started" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Failed to start Docker services" -ForegroundColor Red
    exit 1
}

# ── Step 4: Wait for Services ──
Write-Host "`n[4/7] Waiting for services to be ready..." -ForegroundColor Yellow

Write-Host "  ⏳ Waiting for PostgreSQL..." -NoNewline
$maxRetries = 30
$retryCount = 0
while ($retryCount -lt $maxRetries) {
    try {
        $result = docker exec postgres pg_isready -U n8n_user -d n8n 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅" -ForegroundColor Green
            break
        }
    } catch {}
    Start-Sleep -Seconds 2
    $retryCount++
    Write-Host "." -NoNewline
}
if ($retryCount -ge $maxRetries) {
    Write-Host " ❌ Timeout" -ForegroundColor Red
    exit 1
}

Write-Host "  ⏳ Waiting for Qdrant..." -NoNewline
$retryCount = 0
while ($retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:6333/collections" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host " ✅" -ForegroundColor Green
            break
        }
    } catch {}
    Start-Sleep -Seconds 2
    $retryCount++
    Write-Host "." -NoNewline
}
if ($retryCount -ge $maxRetries) {
    Write-Host " ❌ Timeout" -ForegroundColor Red
    exit 1
}

Write-Host "  ⏳ Waiting for Ollama..." -NoNewline
$retryCount = 0
while ($retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host " ✅" -ForegroundColor Green
            break
        }
    } catch {}
    Start-Sleep -Seconds 2
    $retryCount++
    Write-Host "." -NoNewline
}
if ($retryCount -ge $maxRetries) {
    Write-Host " ❌ Timeout" -ForegroundColor Red
    exit 1
}

# Pull Ollama Models (immediately after Ollama is ready)
if (-not $SkipModelPull) {
    Write-Host "`n  📥 Pulling required Ollama models..." -ForegroundColor Cyan
    
    $models = @(
        "llama3.2:latest",
        "nomic-embed-text:latest"
    )
    
    foreach ($model in $models) {
        Write-Host "    Pulling $model..." -ForegroundColor Cyan
        docker exec ollama ollama pull $model 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✅ $model ready" -ForegroundColor Green
        } else {
            Write-Host "    ⚠️  Failed to pull $model (will retry later)" -ForegroundColor Yellow
        }
    }
}

# ── Step 5: Initialize Database ──
Write-Host "`n[5/7] Initializing PostgreSQL database..." -ForegroundColor Yellow

try {
    Get-Content "config/database/init-db.sql" | docker exec -i postgres psql -U n8n_user -d n8n 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Database schema created" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Database may already be initialized" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Database initialization had warnings (may already exist)" -ForegroundColor Yellow
}

# ── Step 6: Upload Vector Data ──
if (-not $SkipVectorUpload) {
    Write-Host "`n[6/6] Uploading vector data to Qdrant..." -ForegroundColor Yellow
    
    try {
        # Install Python dependencies
        Write-Host "  📦 Installing Python dependencies..." -ForegroundColor Cyan
        python -m pip install --quiet requests 2>$null
        
        # Run upload script
        python scripts/data/upload-vectors.py
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Vector data uploaded successfully" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Vector upload had issues" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ⚠️  Vector upload failed: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[6/6] Skipping vector data upload" -ForegroundColor Yellow
}

# ── Deployment Complete ──
Write-Host "`n" -NoNewline
Write-Host ("=" * 60) -ForegroundColor Green
Write-Host "  ✅ MediSafe-MAS v3 Deployment Complete!" -ForegroundColor Green
Write-Host ("=" * 60) -ForegroundColor Green
Write-Host "`nServices available at:" -ForegroundColor Cyan
Write-Host "  • N8N Workflow UI:    http://localhost:5678" -ForegroundColor White
Write-Host "  • Qdrant Dashboard:   http://localhost:6333/dashboard" -ForegroundColor White
Write-Host "  • Portainer:          https://localhost:9443" -ForegroundColor White
Write-Host "  • PostgreSQL:         localhost:5433" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Open N8N at http://localhost:5678" -ForegroundColor White
Write-Host "  2. The MediSafe-MAS v3 workflow should be auto-imported" -ForegroundColor White
Write-Host "  3. Activate the workflow and test with clinical input" -ForegroundColor White
Write-Host "`nTo stop services:" -ForegroundColor Cyan
Write-Host "  docker compose --profile $Profile down" -ForegroundColor White
Write-Host "`nTo view logs:" -ForegroundColor Cyan
Write-Host "  docker compose logs -f" -ForegroundColor White
Write-Host ""

