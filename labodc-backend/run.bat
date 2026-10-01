@echo off
REM Script chay nhanh Spring Boot - LabODC Backend
REM Tac gia: Huyen

echo ========================================
echo  Dang khoi dong LabODC Backend...
echo ========================================

REM Set JAVA_HOME neu chua co
set JAVA_HOME=C:\Program Files\Java\jdk-22
set PATH=%JAVA_HOME%\bin;%PATH%

REM Di chuyen vao thu muc project
cd /d C:\xampp\htdocs\LabODC_UTH\labodc-backend

REM Kiem tra JAR file co ton tai khong
if not exist "target\labodc-backend-1.0.0.jar" (
    echo.
    echo ========================================
    echo  CHUA BUILD PROJECT!
    echo ========================================
    echo Chay build.bat truoc de build project
    echo.
    pause
    exit /b 1
)

REM Chay ung dung Spring Boot
echo.
echo Starting application on http://localhost:8080...
echo Press Ctrl+C to stop
echo.
java -jar target\labodc-backend-1.0.0.jar

REM Giu cua so mo neu co loi
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo  CO LOI XAY RA!
    echo ========================================
    pause
)