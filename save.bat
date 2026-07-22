@echo off
setlocal enabledelayedexpansion
cd /d Z:\labs\soc-home-lab
set "SDIR=evidence\screenshots"
set "LIST=%TEMP%\wz_untracked.txt"

git ls-files --others --exclude-standard evidence/screenshots > "%LIST%" 2>nul

if "%~1"=="" goto usage

set "MSG=%~1"
shift
if "%~1"=="" goto commit

set /a n=0
for /f "delims=" %%f in ('dir /b /o:d "%SDIR%\*.png" 2^>nul') do (
  findstr /i /x /c:"evidence/screenshots/%%f" "%LIST%" >nul 2>&1
  if not errorlevel 1 (
    set /a n+=1
    set "F!n!=%%f"
  )
)

set /a i=0
:ren
if "%~1"=="" goto commit
set /a i+=1
if !i! gtr !n! goto commit
ren "%SDIR%\!F%i%!" "%~1.png"
echo Renamed: %~1.png
shift
goto ren

:commit
git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo Nothing to commit.
  del "%LIST%" 2>nul
  exit /b 0
)
git commit -m "%MSG%" || exit /b 1
git push
echo Pushed: %MSG%
del "%LIST%" 2>nul
exit /b 0

:usage
echo Usage: save "message" ["shot1" "shot2" ...]
echo.
echo Unnamed screenshots in order:
for /f "delims=" %%f in ('dir /b /o:d "%SDIR%\*.png" 2^>nul') do (
  findstr /i /x /c:"evidence/screenshots/%%f" "%LIST%" >nul 2>&1
  if not errorlevel 1 echo    %%f
)
del "%LIST%" 2>nul
exit /b 1