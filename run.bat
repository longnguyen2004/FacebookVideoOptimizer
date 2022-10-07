@echo off
chcp 65001 >nul
where /q pwsh
if not ERRORLEVEL 0 (
    @echo Không tìm thấy PowerShell. Script này yêu cầu PowerShell 7 trở lên
    @echo Vui lòng truy cập https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows#msi
    pause && exit
)
pwsh -ExecutionPolicy Bypass -File Main.ps1
