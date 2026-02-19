# AntiBot local launcher for Windows (PowerShell).
# Sets ANTIBOT_STATE_DIR, ensures minimal config, then starts the gateway.
# Run from repo root (e.g. c:\Projects\antibot). Requires Node >= 22.12.

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AntibotRoot = Split-Path -Parent $ScriptDir

$env:ANTIBOT_STATE_DIR = if ($env:ANTIBOT_STATE_DIR) { $env:ANTIBOT_STATE_DIR } else { Join-Path $env:USERPROFILE ".antibot" }
$ConfigPath = Join-Path $env:ANTIBOT_STATE_DIR "antibot.json"
$BaseUrl = "http://127.0.0.1:18889/"

# Ensure config dir and minimal config (gateway.mode=local)
if (-not (Test-Path $env:ANTIBOT_STATE_DIR)) {
  New-Item -ItemType Directory -Force -Path $env:ANTIBOT_STATE_DIR | Out-Null
}
$minimalConfig = '{"gateway":{"mode":"local","bind":"loopback"}}'
$needWrite = $true
if (Test-Path $ConfigPath) {
  try {
    $content = Get-Content -Raw -Path $ConfigPath
    if ($content -match '"mode"\s*:\s*"local"') { $needWrite = $false }
  } catch {}
}
if ($needWrite) {
  Set-Content -Path $ConfigPath -Value $minimalConfig -Encoding utf8 -NoNewline
  Write-Host "Created/updated config: $ConfigPath"
}

# Start Ollama in WSL if not responding
$ollamaRunning = $false
try {
  $null = Invoke-WebRequest -Uri "http://127.0.0.1:11434/api/tags" -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop
  $ollamaRunning = $true
} catch {}

if (-not $ollamaRunning) {
  Write-Host "Starting Ollama in WSL..."
  $keepAlive = if ($env:OLLAMA_KEEP_ALIVE) { $env:OLLAMA_KEEP_ALIVE } else { "-1" }
  # Start Ollama serve in background (don't pass env vars to avoid duplicate key issues)
  Start-Process -NoNewWindow -FilePath "wsl" -ArgumentList "bash", "-c", "export OLLAMA_KEEP_ALIVE=$keepAlive; nohup ollama serve >/tmp/ollama-serve.log 2>&1 &" -ErrorAction SilentlyContinue | Out-Null
  Start-Sleep -Seconds 1
  # Pre-warm model in background
  Start-Process -NoNewWindow -FilePath "wsl" -ArgumentList "bash", "-c", "ollama run lume-llama-unbound 'hi' >/dev/null 2>&1 &" -ErrorAction SilentlyContinue | Out-Null
  Write-Host "Ollama starting (model loading in background)..."
}

# Check if gateway is already responding
$gatewayUp = $false
try {
  $null = Invoke-WebRequest -Uri $BaseUrl -UseBasicParsing -TimeoutSec 1 -ErrorAction Stop
  $gatewayUp = $true
} catch {}

if ($gatewayUp) {
  Write-Host "Gateway already running. Open in browser: $BaseUrl"
  exit 0
}

Write-Host "Starting AntiBot gateway on port 18889..."
Write-Host "Dashboard: $BaseUrl"
Write-Host "Press Ctrl+C to stop."
Set-Location $AntibotRoot
& node antibot.mjs gateway --port 18889
