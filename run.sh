#!/bin/sh
if ! command -v pwsh &> /dev/null
    echo Không tìm thấy PowerShell. Script này yêu cầu PowerShell 7 trở lên
    uname="$(uname -s)"
    case "${uname}" in
        Linux*)  OS=linux
        Darwin*) OS=macos
    echo Vui lòng truy cập https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-$OS
    read -p "Press any key to continue... " -n1 -s
    exit
fi
pwsh -File Main.ps1 "$@"