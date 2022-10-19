@echo off
setlocal
REM Windows version detection
for /f "tokens=4-7 delims=[.] " %%i in ('ver') do (if %%i==Version (set v=%%j.%%k) else (set v=%%i.%%j))
if "%v%" == "10.0" (
    chcp 65001 >nul
) else (
    @echo You're not using Windows 10/11. Vietnamese text will be broken
    pause
)
where /q pwsh
if not %ERRORLEVEL% == 0 (
    @echo Không tìm thấy PowerShell. Script này yêu cầu PowerShell 7 trở lên
    @echo Vui lòng truy cập https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows#msi
    pause && exit
)
pwsh -ExecutionPolicy Bypass -File "%~dp0\script\Main.ps1" %*
pause
endlocal
