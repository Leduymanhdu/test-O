Write-Host "Starting LabODC Backend Server..." -ForegroundColor Cyan
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.4.7-hotspot"
java -jar target\labodc-backend-1.0.0.jar
