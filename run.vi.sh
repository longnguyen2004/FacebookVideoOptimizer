#!/bin/sh
if ! command -v pwsh >/dev/null 2>&1; then
    echo "Không tìm thấy PowerShell. Script này yêu cầu PowerShell 7 trở lên"
    uname="$(uname -s)"
    case "${uname}" in
        Linux*)  OS=linux;;
        Darwin*) OS=macos;;
    esac
    echo "Vui lòng truy cập https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-$OS"
    echo "Bấm Enter để thoát"
    read _
    exit
fi
BASE_DIR="$(cd "$(dirname "$0")"; pwd)"
pwsh -File "$BASE_DIR/script/Main.ps1" -Language vi "$@"