#!/bin/sh
if ! command -v pwsh >/dev/null 2>&1; then
    echo "Không tìm thấy PowerShell. Script này yêu cầu PowerShell 7 trở lên"
    uname="$(uname -s)"
    case "${uname}" in
        Linux*)  OS=linux;;
        Darwin*) OS=macos;;
    esac
    echo "Vui lòng truy cập https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-$OS"
    echo "Press Enter to exit"
    read _
    exit
fi
pwsh -File Main.ps1 "$@"