@echo off
setlocal
REM Windows version detection
for /f "tokens=4-7 delims=[.] " %%i in ('ver') do (if %%i==Version (set v=%%j.%%k) else (set v=%%i.%%j))
if "%v%" NEQ "10.0" (
    @echo You're not using Windows 10/11. You need to change the font to prevent crashes
    @echo See the README for more info
    @echo Please change the font before continuing
    pause
)
chcp 65001 >nul
where /q pwsh
if %ERRORLEVEL% NEQ 0 (
    @echo Không tìm thấy PowerShell. Script này yêu cầu PowerShell 7 trở lên
    @echo Vui lòng truy cập https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows#msi
    pause && exit
)
pwsh -ExecutionPolicy Bypass -File "%~dp0\script\Main.ps1" %*
pause
endlocal
