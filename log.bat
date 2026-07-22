@echo off
setlocal
cd /d Z:\labs\soc-home-lab
if "%~3"=="" (
  echo Usage: log "hours" "work done" "evidence"
  exit /b 1
)
for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "TODAY=%%d"
>>logbook\hours.md echo ^| %TODAY% ^| %~1 ^| %~2 ^| %~3 ^|
endlocal