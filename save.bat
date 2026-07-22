@echo off
setlocal enabledelayedexpansion
cd /d Z:\labs\soc-home-lab
set "SDIR=Z:\labs\soc-home-lab\evidence\screenshots"

if "%~1"=="" goto usage

set "MSG=%~1"
shift
if "%~1"=="" goto commit

set /a n=0
for /f "delims=" %%f in ('dir /b /o:d "%SDIR%\*.png" 2^>nul') do (
  set "nm=%%f"
  set "keep="
  if /i "!nm:~0,10!"=="VirtualBox" set keep=1
  if /i "!nm:~0,10!"=="Screenshot" set keep=1
  if defined keep (
    set /a n+=1
    set "F!n!=%%f"
  )
)

set /a i=0
:ren
if "%~1"=="" goto commit
set /a i+=1
if !i! gtr %n% goto commit
ren "%SDIR%\!F%i%!" "%~1.png"
echo Renamed: %~1.png
shift
goto ren

:commit
git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo Nothing to commit.
  exit /b 0
)
git commit -m "%MSG%" || exit /b 1
git push
echo Pushed: %MSG%
exit /b 0

:usage
echo Usage: save "message" ["shot1" "shot2" ...]
echo.
echo Pending screenshots in order:
for /f "delims=" %%f in ('dir /b /o:d "%SDIR%\*.png" 2^>nul') do (
  set "nm=%%f"
  if /i "!nm:~0,10!"=="VirtualBox" echo    %%f
  if /i "!nm:~0,10!"=="Screenshot" echo    %%f
)
exit /b 1