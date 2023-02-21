. $PSScriptRoot/CheckDependency.ps1;

function Download-FFmpeg {
    param(
        [Parameter(Mandatory=$true)]
        [string] $FFmpegDir
    )
    $TempPath = [System.IO.Path]::GetTempPath();
    New-Item -ItemType Directory $FFmpegDir -ErrorAction SilentlyContinue | Out-Null;
    if ($IsWindows)
    {
        if ([Environment]::Is64BitOperatingSystem)
        {
            $Link = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip";
            $FolderName = "ffmpeg-master-latest-win64-gpl-shared";
        }
        else
        {
            $Link = "https://github.com/sudo-nautilus/FFmpeg-Builds-Win32/releases/download/latest/ffmpeg-master-latest-win32-gpl-shared.zip";
            $FolderName = "ffmpeg-master-latest-win32-gpl-shared";
        }
        $ArchivePath = Join-Path "$TempPath" "ffmpeg.zip";
        Write-Host ($Strings["FileDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host ($Strings["FileExtracting"] -f $ArchivePath);
        Expand-Archive "$ArchivePath" -DestinationPath "$TempPath" -Force;
        Move-Item (Join-Path "$TempPath" "$FolderName" "bin" "*") "$FFmpegDir";
        Remove-Item (Join-Path "$TempPath" "$FolderName") -Recurse -Force;
    }
    elseif ($IsMacOS)
    {

    }
    elseif ($IsLinux)
    {
        $Architecture = uname -m;
        $DownloadArch = ($Architecture -match '^(arm|aarch)64$') ? "arm64" : "64";
        $Link = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux$DownloadArch-gpl.tar.xz";
        $ArchivePath = "/tmp/ffmpeg.tar.xz";
        Write-Host ($Strings["FileDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host ($Strings["FileExtracting"] -f $ArchivePath);
        tar -xf $ArchivePath -C "$TempPath";
        Move-Item (Join-Path "$TempPath" "ffmpeg-master-latest-linux64-gpl" "bin" "ff*") "$FFmpegDir";
        Remove-Item (Join-Path "$TempPath" "ffmpeg-master-latest-linux64-gpl") -Recurse -Force;
    }
    Write-Host ($Strings["FileFinished"] -f "FFmpeg");
    Write-Host;
}

$FFmpeg, $FFprobe = Check-Dependency -Name "FFmpeg" -Executables "ffmpeg","ffprobe" -DownloadFunction Download-FFmpeg
