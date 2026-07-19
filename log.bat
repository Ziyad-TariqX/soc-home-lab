@echo off
echo %date% ^| %~1 ^| %~2 ^| %~3 >> logbook\hours.md
echo Done: logged to hours.md