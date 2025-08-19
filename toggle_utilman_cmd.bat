@echo off
REM ============================================
REM Setup and toggle utilman.exe <-> cmd.exe
REM Adapted for Recovery Console (WinRE)
REM Targets C:\Windows\System32
REM ============================================

REM ================================
REM Step 1: Determine System32 path in Recovery Console
REM ================================
set "SYSTEM_DRIVE="
for %%d in (C D E F G H I J K L) do (
    if exist "%%d:\Windows\System32\utilman.exe" (
        set "SYSTEM_DRIVE=%%d"
        goto FOUND_DRIVE
    )
)
echo [ERROR] Could not find Windows\System32 directory.
pause
goto END

:FOUND_DRIVE
set "BASE=%SYSTEM_DRIVE%:\Windows\System32\"

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
    goto END
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
    echo [DONE] Restoration complete.
    goto END
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
    echo [DONE] Replacement done.
) else (
    color %COLOR_ERROR%
    echo [ERROR] No utilman.exe found to replace or restore.
    color %COLOR_DEFAULT%
)

:END
echo.
pause