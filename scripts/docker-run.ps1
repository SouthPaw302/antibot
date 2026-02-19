# Build and run AntiBot Gateway in Docker (Windows).
# Requires: Docker Desktop, docker compose v2
# Usage: .\scripts\docker-run.ps1   # build, then start gateway
#        .\scripts\docker-run.ps1 -BuildOnly   # only build image
#        .\scripts\docker-run.ps1 -StartOnly   # only start (assumes image exists and .env is set)

param(
    [switch] $BuildOnly,
    [switch] $StartOnly
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $RootDir ".env"

# Defaults: use project-local docker-data. Override with ANTIBOT_CONFIG_DIR / ANTIBOT_WORKSPACE_DIR to use e.g. $HOME\.antibot
$ConfigDir = if ($env:ANTIBOT_CONFIG_DIR) { $env:ANTIBOT_CONFIG_DIR } else { Join-Path (Join-Path $RootDir "docker-data") ".antibot" }
$WorkspaceDir = if ($env:ANTIBOT_WORKSPACE_DIR) { $env:ANTIBOT_WORKSPACE_DIR } else { Join-Path $ConfigDir "workspace" }
$Port = if ($env:ANTIBOT_GATEWAY_PORT) { $env:ANTIBOT_GATEWAY_PORT } else { "18789" }
$ImageName = if ($env:ANTIBOT_IMAGE) { $env:ANTIBOT_IMAGE } else { "antibot:local" }

# Ensure token exists
$Token = $env:ANTIBOT_GATEWAY_TOKEN
if (-not $Token) {
    if (Test-Path $EnvFile) {
        Get-Content $EnvFile | ForEach-Object {
            if ($_ -match '^\s*ANTIBOT_GATEWAY_TOKEN=(.+)$') { $Token = $matches[1].Trim() }
        }
    }
}
if (-not $Token) {
    $Token = -join ((1..32) | ForEach-Object { "{0:x2}" -f (Get-Random -Maximum 256) })
    Write-Host "Generated ANTIBOT_GATEWAY_TOKEN (saved to .env)"
}

# Write .env so docker compose can use it
$envContent = @"
ANTIBOT_CONFIG_DIR=$ConfigDir
ANTIBOT_WORKSPACE_DIR=$WorkspaceDir
ANTIBOT_GATEWAY_PORT=$Port
ANTIBOT_GATEWAY_TOKEN=$Token
ANTIBOT_IMAGE=$ImageName
ANTIBOT_GATEWAY_BIND=lan
"@
Set-Content -Path $EnvFile -Value $envContent -Encoding utf8

# Ensure config/workspace dirs exist on host for volume mount
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path $WorkspaceDir | Out-Null

Set-Location $RootDir

if (-not $StartOnly) {
    Write-Host "Building Docker image: $ImageName (this may take several minutes)..."
    docker build -t $ImageName -f Dockerfile .
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    Write-Host "Build complete."
}
if ($BuildOnly) { exit 0 }

Write-Host "Starting AntiBot Gateway container..."
docker compose up -d antibot-gateway
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "AntiBot Gateway is running."
Write-Host "  Dashboard: http://127.0.0.1:${Port}/"
Write-Host "  Token: $Token"
Write-Host "  Config dir: $ConfigDir"
Write-Host ""
Write-Host "Useful commands:"
Write-Host "  docker compose logs -f antibot-gateway"
Write-Host "  docker compose run --rm antibot-cli dashboard --no-open"
Write-Host "  docker compose down"
