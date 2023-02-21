function Preview-Video {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    if (-not $mpv) { return; }
    & "$mpv" "$Path";
}