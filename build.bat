@echo off
rem build.bat - install GCC if missing, build, then run the demo
rem usage: build.bat [install dir]   (default C:\vsm-tools\gcc)
chcp 65001 > nul
cd /d "%~dp0"

rem PowerShell 7 module path breaks Windows PowerShell 5.1 cmdlets - reset it
set "PSModulePath="

if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -InstallDir "%~1"
)
if errorlevel 1 exit /b 1

call "%~dp0local.cmd"

mingw32-make clean
mingw32-make
if errorlevel 1 exit /b 1

"%~dp0vsm_demo.exe"
exit /b %errorlevel%
