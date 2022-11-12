$FFmpegDir = Join-Path "$PSScriptRoot" ".." "ffmpeg";
if ($FFmpegSystem = Get-Command "ffmpeg" -ErrorAction SilentlyContinue)
{
    Write-Host ($Strings["FFmpegSystem"] -f $FFmpegSystem.Source);
    $FFmpeg = $FFmpegSystem.Source;
    $FFmpegDir = Split-Path -Parent $FFmpegSystem.Source;
}
elseif (Get-Command "$FFmpegDir/ffmpeg" -ErrorAction SilentlyContinue)
{
    Write-Host $Strings["FFmpegLocal"];
    $FFmpeg = "$FFmpegDir/ffmpeg";
}
else
{
    Write-Host $Strings["FFmpegNotFound"];
    New-Item -ItemType Directory $FFmpegDir -ErrorAction SilentlyContinue | Out-Null;
    if ($IsWindows)
    {
        if ([Environment]::Is64BitOperatingSystem)
        {
            $Link = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip";
            $FolderName = "ffmpeg-master-latest-win64-gpl";
        }
        else
        {
            $Link = "https://github.com/sudo-nautilus/FFmpeg-Builds-Win32/releases/download/latest/ffmpeg-master-latest-win32-gpl.zip";
            $FolderName = "ffmpeg-master-latest-win32-gpl";
        }
        $ArchivePath = Join-Path "$Env:Temp" "ffmpeg.zip";
        Write-Host ($Strings["FFmpegDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host $Strings["FFmpegExtracting"];
        Expand-Archive "$ArchivePath" -DestinationPath "$Env:Temp" -Force;
        Move-Item (Join-Path "$Env:Temp" "$FolderName" "bin" "ff*") "$FFmpegDir";
        Remove-Item (Join-Path "$Env:Temp" "$FolderName") -Recurse -Force;
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
        Write-Host ($Strings["FFmpegDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host $Strings["FFmpegExtracting"];
        tar -xf $ArchivePath -C "/tmp";
        Move-Item "/tmp/ffmpeg-master-latest-linux64-gpl/bin/ff*" "$FFmpegDir";
        Remove-Item "/tmp/ffmpeg-master-latest-linux64-gpl" -Recurse -Force;
    }
    $FFmpeg = Join-Path "$FFmpegDir" "ffmpeg";
    Write-Host $Strings["FFmpegFinished"];
    Write-Host;
}
