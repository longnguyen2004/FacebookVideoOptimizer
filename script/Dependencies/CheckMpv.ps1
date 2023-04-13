function Download-Mpv {
    param(
        [Parameter(Mandatory=$true)]
        [string] $MpvDir
    )
    $TempPath = Join-Path ([System.IO.Path]::GetTempPath()) "mpv";
    New-Item -ItemType Directory $TempPath -Force | Out-Null;
    New-Item -ItemType Directory $MpvDir -Force | Out-Null;
    if ($IsWindows)
    {
        if ([Environment]::Is64BitOperatingSystem)
        {
            $Link = "https://sourceforge.net/projects/mpv-player-windows/files/64bit/mpv-x86_64-20230212-git-a40958c.7z/download";
        }
        else
        {
            $Link = "https://sourceforge.net/projects/mpv-player-windows/files/32bit/mpv-i686-20230212-git-a40958c.7z/download";
        }
        $ArchivePath = Join-Path "$TempPath" "mpv.7z";
        Write-Host ($Strings["FileDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile "$ArchivePath" -UserAgent "Wget";
        Write-Host ($Strings["FileExtracting"] -f $ArchivePath);
        Expand-Archive-Enhanced "$ArchivePath" -DestinationPath "$TempPath";
        Move-Item (Join-Path "$TempPath" "mpv.exe") "$MpvDir";
        Remove-Item $TempPath -Recurse -Force;
    }
    elseif ($IsMacOS)
    {

    }
    elseif ($IsLinux)
    {
        Write-Host "Please install mpv through your package manager if you need preview functionality";
        return $false;
    }
    Write-Host ($Strings["FileFinished"] -f "mpv");
    Write-Host;
    return $true;
}

$mpv = Check-Dependency -Name "mpv" -Executables "mpv" -DownloadFunction Download-Mpv;
