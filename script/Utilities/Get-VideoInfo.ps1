function Get-VideoInfo {
    param (
        [Parameter(Mandatory=$true)]
        [string]$File
    )
    $FileInfo = & "$FFprobe" -v quiet -print_format json -show_streams -show_format "$File";
    Write-Debug "File info of ${File}:";
    Write-Debug ("`n" + (($FileInfo | ForEach-Object { $_ + "`n" }) -join ""));
    return $FileInfo | ConvertFrom-Json;
}
