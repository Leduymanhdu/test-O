# Run Backend Server
# Khởi động Spring Boot application

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Starting LabODC Backend Server    " -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if built
if (-not (Test-Path "target")) {
    Write-Host "Project not built yet. Building..." -ForegroundColor Yellow
    .\build-backend.ps1
}

# Check Maven
$mavenCmd = Get-Command mvn -ErrorAction SilentlyContinue

if ($null -eq $mavenCmd -and (Test-Path "mvnw.cmd")) {
    $mavenCommand = ".\mvnw.cmd"
} elseif ($null -ne $mavenCmd) {
    $mavenCommand = "mvn"
} else {
    Write-Host "ERROR: Maven not found. Run build-backend.ps1 first" -ForegroundColor Red
    exit 1
}

Write-Host "Starting server on http://localhost:8080..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

& $mavenCommand spring-boot:run
