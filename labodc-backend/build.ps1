# Build LabODC Backend
# Compile và đóng gói Spring Boot application

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Building LabODC Backend..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Java\jdk-22"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Change to project directory
Set-Location "C:\xampp\htdocs\LabODC_UTH\labodc-backend"

# Clean old build
if (Test-Path "target") {
    Write-Host "Cleaning old build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force target -ErrorAction SilentlyContinue
}

# Build using Maven Wrapper
Write-Host "Compiling and packaging application..." -ForegroundColor Yellow
Write-Host ""

& ".\mvnw.cmd" clean package -DskipTests

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  BUILD SUCCESSFUL!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "JAR file: target\labodc-backend-1.0.0.jar" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  BUILD FAILED!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
}
