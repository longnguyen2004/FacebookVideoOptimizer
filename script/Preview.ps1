function Preview-Video {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    if (-not $mpv) { return $null; }
    Write-Host $Strings["OpeningPreview"];
    Start-Sleep -Seconds 1;

    $MpvParams = (
        "--keep-open",
        "--geometry=1024x768",
        "--hwdec=auto-safe",
        "--vo=gpu",
        "--script-opts=osc-visibility=always,osc-timems=yes",
        "`"$Path`""
    );

    return Start-Process "$mpv" -ArgumentList $MpvParams -PassThru;
}