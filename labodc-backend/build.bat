@echo off
REM Script build LabODC Backend

echo ========================================
echo  Building LabODC Backend...
echo ========================================

REM Set JAVA_HOME
set JAVA_HOME=C:\Program Files\Java\jdk-22
set PATH=%JAVA_HOME%\bin;%PATH%

REM Change to project directory
cd /d C:\xampp\htdocs\LabODC_UTH\labodc-backend

REM Build using Maven Wrapper
echo.
echo Compiling and packaging application...
call mvnw.cmd clean package -DskipTests

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  BUILD SUCCESSFUL!
    echo ========================================
    echo JAR file: target\labodc-backend-1.0.0.jar
    echo.
) else (
    echo.
    echo ========================================
    echo  BUILD FAILED!
    echo ========================================
    pause
)
