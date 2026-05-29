@echo off
title Sanctum XI - Map Supervisor
cd /d "%~dp0"

set EXE=xi_map.exe

:loop
cls
echo ========================================
echo   Sanctum XI - Map Supervisor
echo ========================================
echo Starting %EXE% at %date% %time%
echo.

if not exist "%EXE%" (
    echo ERROR: %EXE% was not found in:
    echo %~dp0
    echo.
    pause
    exit /b
)

"%~dp0%EXE%"
echo.
echo %EXE% exited with code %errorlevel%.
echo Restarting in 5 seconds...
timeout /t 5 /nobreak >nul
goto loop