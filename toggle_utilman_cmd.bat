@echo off
title Utilman Replacement in Recovery Environment
echo Checking the operating environment...
echo.

REM ================================
REM Check for Recovery Environment
REM ================================
REM Check 1: Verify WINDIR path
if /i "%WINDIR:~0,1%"=="X" (
    echo [✓] Recovery environment detected - WINDIR starts with X
    goto :recovery_detected
)

REM Check 2: Verify if explorer.exe is running
tasklist /FI "IMAGENAME eq explorer.exe" 2>nul | find /i "explorer.exe" >nul
if errorlevel 1 (
    echo [✓] Recovery environment detected - explorer.exe is not running
    goto :recovery_detected
) else (
    echo [X] Active Windows detected - explorer.exe is running
    goto :windows_active
)

:recovery_detected
echo.
echo =====================================
echo    Recovery environment detected - proceeding...
echo =====================================
echo.

REM ================================
REM Step 1: Define System32 path as the drive where the script is located
REM ================================
set "BASE=%~d0\Windows\System32\"

REM Check if System32 directory exists on the script's drive
if not exist "%BASE%utilman.exe" (
    echo [ERROR] Windows\System32 directory or utilman.exe not found on drive %~d0.
    pause
    goto :END
)

REM ================================
REM Define colors (limited support in Recovery Console)
REM ================================
set "COLOR_DEFAULT=07"
set "COLOR_INFO=0A"
set "COLOR_WARNING=0E"
set "COLOR_ERROR=0C"

REM ================================
REM Step 2: Check if cmd.exe exists
REM ================================
if not exist "%BASE%cmd.exe" (
    color %COLOR_ERROR%
    echo [ERROR] cmd.exe not found in %BASE%.
    color %COLOR_DEFAULT%
    pause
    goto :END
) else (
    color %COLOR_INFO%
    echo [INFO] cmd.exe found in %BASE%.
)

REM ================================
REM Step 3: Check for backup and restore
REM ================================
if exist "%BASE%utilman_backup.exe" (
    color %COLOR_INFO%
    echo [INFO] Backup found, restoring original utilman.exe...
    copy /Y "%BASE%utilman_backup.exe" "%BASE%utilman.exe" >nul
    del "%BASE%utilman_backup.exe"
    color %COLOR_DEFAULT%
    echo [DONE] Restoration completed.
    goto :END
)

REM ================================
REM Step 4: Backup and replace utilman.exe with cmd.exe
REM ================================
if exist "%BASE%utilman.exe" (
    color %COLOR_WARNING%
    echo [WARNING] utilman.exe found, creating backup and replacing with cmd.exe...
    copy /Y "%BASE%utilman.exe" "%BASE%utilman_backup.exe" >nul
    copy /Y "%BASE%cmd.exe" "%BASE%utilman.exe" >nul
    color %COLOR_DEFAULT%
    echo [DONE] Replacement completed.
) else (
    color %COLOR_ERROR%
    echo [ERROR] utilman.exe not found for replacement or restoration.
    color %COLOR_DEFAULT%
)

:END
echo.
echo Script completed successfully!
pause
exit /b 0

:windows_active
echo.
echo =====================================
echo      WARNING: Active Windows detected!
echo =====================================
echo.
echo This script is intended to run only in the Recovery Environment.
echo Running it in an active Windows system may cause damage.
echo.
echo The script will now exit without performing any actions.
echo.
pause
exit /b 1