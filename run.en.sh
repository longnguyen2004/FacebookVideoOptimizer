#!/bin/sh
if ! command -v pwsh >/dev/null 2>&1; then
    echo "PowerShell not found. This script requires PowerShell 7+"
    uname="$(uname -s)"
    case "${uname}" in
        Linux*)  OS=linux;;
        Darwin*) OS=macos;;
    esac
    echo "Please visit https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-$OS"
    echo "Press Enter to exit"
    read _
    exit
fi
BASE_DIR="$(cd "$(dirname "$0")"; pwd)"
pwsh -File "$BASE_DIR/script/Main.ps1" -Language en "$@"