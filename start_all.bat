@echo off
title Sanctum XI - Start All
cd /d "%~dp0"

start "Connect Supervisor" "%~dp0start_connect.bat"
timeout /t 2 /nobreak >nul

start "Search Supervisor" "%~dp0start_search.bat"
timeout /t 2 /nobreak >nul

start "World Supervisor" "%~dp0start_world.bat"
timeout /t 2 /nobreak >nul

start "Map Supervisor" "%~dp0start_map.bat"