#!/bin/sh
if ! command -v pwsh >/dev/null 2>&1; then
	echo "找不到 PowerShell。 此脚本需要 PowerShell 7+"
	uname="$(uname -s)"
	case "${uname}" in
		Linux*)  OS=linux;;
		Darwin*) OS=macos;;
	esac
	echo "请访问 https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-$OS"
	echo "按 Enter 退出"
	read _
	exit
fi
BASE_DIR="$(cd "$(dirname "$0")"; pwd)"
pwsh -File "$BASE_DIR/script/Main.ps1" -Language zh "$@"