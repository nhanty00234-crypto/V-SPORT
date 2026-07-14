@echo off
setlocal EnableDelayedExpansion
set "JAVA_HOME=C:\Users\nhan\.jdks\ms-17.0.19"
set "CATALINA_HOME=D:\BiKipVoCong\TaiNguyenIntelliji\apache-tomcat-10.1.54"
set "MAVEN_PATH=D:\CNTT\netbeans-28-bin\netbeans\java\maven\bin\mvn.cmd"
set "WAR_NAME=Backend_java-1.0-SNAPSHOT.war"
set "APP_NAME=Backend_java"
set "PORT=8080"

echo ============================================
echo [0/5] Loading environment variables...
echo ============================================
if exist .env (
    echo Loading variables from .env file...
    for /f "usebackq tokens=1* delims==" %%i in (".env") do (
        set "key=%%i"
        set "val=%%j"
        if defined key (
            if not "!key:~0,1!"=="#" (
                set "!key!=!val!"
            )
        )
    )
) else (
    echo WARNING: .env file not found. Make sure environment variables are set.
)

echo Checking database configuration...
set "DB_CONFIG_OK=1"

if defined DB_URL (
    echo   DB_URL: configured
) else (
    echo   DB_URL: missing
    set "DB_CONFIG_OK=0"
)

if defined DB_USERNAME (
    echo   DB_USERNAME: configured
) else (
    echo   DB_USERNAME: missing
    set "DB_CONFIG_OK=0"
)

if defined DB_PASSWORD (
    echo   DB_PASSWORD: configured
) else (
    echo   DB_PASSWORD: missing
    set "DB_CONFIG_OK=0"
)

if "!DB_CONFIG_OK!"=="0" (
    echo ERROR: Required database configuration is missing!
    echo Please make sure DB_URL, DB_USERNAME, and DB_PASSWORD are set.
    echo Refer to docs/setup/local-database-config.md for details.
    exit /b 1
)

echo ============================================
echo [1/5] Stopping old Tomcat...
echo ============================================
call "%CATALINA_HOME%\bin\catalina.bat" stop 10 -force >nul 2>&1
ping -n 4 127.0.0.1 > nul

echo ============================================
echo [2/5] Checking port %PORT%...
echo ============================================
set "RETRY=0"

:CHECK_PORT
set "FOUND_PID="
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":%PORT% " ^| findstr "LISTENING"') do (
    set "FOUND_PID=%%P"
)

if not defined FOUND_PID (
    echo Port %PORT% is free.
    goto PORT_FREE
)

echo Port %PORT% is currently held by PID !FOUND_PID!.

set "IMAGE_NAME="
for /f "tokens=1,2" %%I in ('tasklist /FI "PID eq !FOUND_PID!" /NH 2^>nul') do (
    set "IMAGE_NAME=%%I"
)

if not defined IMAGE_NAME (
    echo PID !FOUND_PID! already exited on its own. Re-checking port...
    ping -n 2 127.0.0.1 > nul
    goto CHECK_PORT
)

echo !IMAGE_NAME! | findstr /I "java.exe tomcat" >nul
if errorlevel 1 (
    echo ERROR: PID !FOUND_PID! holding port %PORT% is "!IMAGE_NAME!", NOT java.exe/Tomcat.
    echo Refusing to kill an unrelated process. Please close it manually and re-run this script.
    exit /b 1
)

echo Killing PID !FOUND_PID! ^(!IMAGE_NAME!^) which is holding port %PORT%...
taskkill /F /PID !FOUND_PID! >nul 2>&1

set /a RETRY+=1
if !RETRY! GEQ 5 (
    echo ERROR: Could not free port %PORT% after 5 attempts. Aborting.
    exit /b 1
)

ping -n 3 127.0.0.1 > nul
goto CHECK_PORT

:PORT_FREE

echo ============================================
echo [3/5] Building Maven project...
echo ============================================
call "%MAVEN_PATH%" clean package -DskipTests
if errorlevel 1 (
    echo ERROR: Maven build failed. Aborting.
    exit /b 1
)

echo ============================================
echo [4/5] Deploying WAR...
echo ============================================
if exist "%CATALINA_HOME%\webapps\%APP_NAME%" (
    echo Removing old exploded webapp directory to avoid stale classes...
    rmdir /S /Q "%CATALINA_HOME%\webapps\%APP_NAME%"
)
if exist "%CATALINA_HOME%\webapps\%APP_NAME%.war" (
    del /F /Q "%CATALINA_HOME%\webapps\%APP_NAME%.war"
)

copy /Y "target\%WAR_NAME%" "%CATALINA_HOME%\webapps\%APP_NAME%.war" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy WAR file to webapps. Aborting.
    exit /b 1
)
echo Deployed target\%WAR_NAME% as %APP_NAME%.war

echo ============================================
echo [5/5] Starting Tomcat...
echo ============================================
call "%CATALINA_HOME%\bin\catalina.bat" start

echo Waiting for Tomcat to start...
ping -n 7 127.0.0.1 > nul

echo Opening browser...
start http://localhost:%PORT%/%APP_NAME%/

echo Done.
endlocal
