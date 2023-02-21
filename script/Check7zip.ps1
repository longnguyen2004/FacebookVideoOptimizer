. $PSScriptRoot/CheckDependency.ps1;
. $PSScriptRoot/ExpandArchive-Enhanced.ps1;

function Download-7zip
{
    param(
        [Parameter(Mandatory = $true)]
        [string] $7zipDir
    )
    New-Item -ItemType Directory $7zipDir -ErrorAction SilentlyContinue | Out-Null;
    if ($IsWindows)
    {
        $Link = "https://www.7-zip.org/a/7zr.exe";
        $OutFile = Join-Path $7zipDir "7z.exe";
        Write-Host ($Strings["FileDownloading"] -f $Link);
        Invoke-WebRequest "$Link" -OutFile $OutFile;
    }
    elseif ($IsMacOS)
    {

    }
    elseif ($IsLinux)
    {
        $Architecture = uname -m;
        switch -regex ($Architecture)
        {
            "(x86_64|amd64)"
            {
                $Link = "https://www.7-zip.org/a/7z2201-linux-x64.tar.xz";
                break;
            }
            "(i386|i686)"
            {
                $Link = "https://www.7-zip.org/a/7z2201-linux-x86.tar.xz";
                break;
            }
            "arm64"
            {
                $Link = "https://www.7-zip.org/a/7z2201-linux-arm64.tar.xz";
                break;
            }
            "arm"
            {
                $Link = "https://www.7-zip.org/a/7z2201-linux-arm.tar.xz";
                break;
            }
        }
        $ArchivePath = "/tmp/7z.tar.xz";
        $TempPath = Join-Path ([System.IO.Path]::GetTempPath()) "7zip";
        Write-Host ($Strings["FileDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile $ArchivePath;
        Write-Host ($Strings["FileExtracting"] -f $ArchivePath);
        Expand-Archive-Enhanced "$ArchivePath" "$TempPath";
        Move-Item "$TempPath/7zzs" "$7zipDir/7z";
        Remove-Item $TempPath;
    }
    Write-Host ($Strings["FileFinished"] -f "7zip");
    Write-Host;
}

$7zip = Check-Dependency -Name "7zip" -Executables "7z" -DownloadFunction Download-7zip
