#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update file paths in configuration files after reorganization
#>

$ErrorActionPreference = 'Stop'

Write-Host "Updating file paths in configuration files...`n" -ForegroundColor Cyan

# Update docker-compose.yml
if (Test-Path "config/docker-compose.yml") {
    Write-Host "Updating config/docker-compose.yml..." -ForegroundColor Yellow
    
    $content = Get-Content "config/docker-compose.yml" -Raw
    $content = $content -replace './init-db.sql', './config/database/init-db.sql'
    $content = $content -replace './sample-guidelines.json', './data/guidelines/sample-guidelines.json'
    $content = $content -replace './sample-cases.json', './data/cases/sample-cases.json'
    Set-Content "config/docker-compose.yml" -Value $content
    
    Write-Host "  ✅ Updated docker-compose.yml" -ForegroundColor Green
}

# Update deployment scripts
if (Test-Path "scripts/deploy/start-medisafe.sh") {
    Write-Host "Updating scripts/deploy/start-medisafe.sh..." -ForegroundColor Yellow
    
    $content = Get-Content "scripts/deploy/start-medisafe.sh" -Raw
    $content = $content -replace 'docker-compose.yml', 'config/docker-compose.yml'
    $content = $content -replace 'init-db.sql', 'config/database/init-db.sql'
    $content = $content -replace 'upload-vectors.py', 'scripts/data/upload-vectors.py'
    Set-Content "scripts/deploy/start-medisafe.sh" -Value $content
    
    Write-Host "  ✅ Updated start-medisafe.sh" -ForegroundColor Green
}

if (Test-Path "scripts/deploy/start-medisafe.ps1") {
    Write-Host "Updating scripts/deploy/start-medisafe.ps1..." -ForegroundColor Yellow
    
    $content = Get-Content "scripts/deploy/start-medisafe.ps1" -Raw
    $content = $content -replace 'docker-compose.yml', 'config/docker-compose.yml'
    $content = $content -replace 'init-db.sql', 'config/database/init-db.sql'
    $content = $content -replace 'upload-vectors.py', 'scripts/data/upload-vectors.py'
    Set-Content "scripts/deploy/start-medisafe.ps1" -Value $content
    
    Write-Host "  ✅ Updated start-medisafe.ps1" -ForegroundColor Green
}

# Update vector upload script
if (Test-Path "scripts/data/upload-vectors.py") {
    Write-Host "Updating scripts/data/upload-vectors.py..." -ForegroundColor Yellow
    
    $content = Get-Content "scripts/data/upload-vectors.py" -Raw
    $content = $content -replace "'sample-guidelines.json'", "'data/guidelines/sample-guidelines.json'"
    $content = $content -replace "'sample-cases.json'", "'data/cases/sample-cases.json'"
    Set-Content "scripts/data/upload-vectors.py" -Value $content
    
    Write-Host "  ✅ Updated upload-vectors.py" -ForegroundColor Green
}

# Create symlinks in root for backward compatibility
Write-Host "`nCreating backward compatibility symlinks..." -ForegroundColor Yellow

if (Test-Path "config/docker-compose.yml") {
    if (Test-Path "docker-compose.yml") {
        Remove-Item "docker-compose.yml" -Force
    }
    New-Item -ItemType SymbolicLink -Path "docker-compose.yml" -Target "config/docker-compose.yml" -Force | Out-Null
    Write-Host "  ✅ Created symlink: docker-compose.yml → config/docker-compose.yml" -ForegroundColor Green
}

Write-Host "`n✅ Path updates complete!`n" -ForegroundColor Green
