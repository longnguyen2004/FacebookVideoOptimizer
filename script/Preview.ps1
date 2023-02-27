function Preview-Video {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    if (-not $mpv) { return; }
    Write-Host $Strings["OpeningPreview"];
    Start-Sleep -Seconds 1;

    $MpvParams = (
        "--keep-open",
        "--geometry=800x600",
        "--hwdec=auto-safe",
        "--vo=gpu",
        "--scropt-opts=osc-visibility=always",
        $Path
    );

    return Start-Process "$mpv" -ArgumentList $MpvParams -PassThru;
}