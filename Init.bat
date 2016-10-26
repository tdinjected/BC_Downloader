@Echo Off
CLS
set loc=%~DP0
set script="%loc%BC_Down.ps1"
PowerShell.exe -ExecutionPolicy Bypass -File %script%