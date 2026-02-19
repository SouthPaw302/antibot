# AntiBot build for Windows.
# If pnpm build fails with "memory allocation of 2048 bytes failed" (tsdown/rolldown crash),
# this script retries with increased Node heap. If it still fails, build in WSL (see RUNBOOK.md).

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AntibotRoot = Split-Path -Parent $ScriptDir

# Give Node more heap in case the crash is triggered under memory pressure
$env:NODE_OPTIONS = "--max-old-space-size=8192"

Set-Location $AntibotRoot
Write-Host "Running pnpm build (NODE_OPTIONS=$env:NODE_OPTIONS)..."
& pnpm build
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "Build failed. If you saw 'memory allocation of 2048 bytes failed', try building in WSL:"
  Write-Host "  wsl -e bash -c 'cd /mnt/c/Projects/antibot && pnpm build'"
  exit $LASTEXITCODE
}
