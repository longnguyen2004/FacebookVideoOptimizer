function Preview-Video {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    if (-not $mpv) { return; }
    Write-Host $Strings["OpeningPreview"];
    Start-Sleep -Seconds 1;
    $MpvScriptOptions = ("osc-visibility=always")
    & "$mpv" `
        --keep-open                `
        --geometry=800x600         `
        --hwdec=auto-safe --vo=gpu `
        --script-opts=$MpvScriptOptions `
        "$Path";
}