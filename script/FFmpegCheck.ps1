$FFmpegDir = Join-Path "$PSScriptRoot" ".." "ffmpeg";

$FFmpegSystem = Get-Command "ffmpeg" -ErrorAction SilentlyContinue
$FFprobeSystem = Get-Command "ffprobe" -ErrorAction SilentlyContinue

$FFmpegLocal = Get-Command "$FFmpegDir/ffmpeg" -ErrorAction SilentlyContinue
$FFprobeLocal = Get-Command "$FFmpegDir/ffprobe" -ErrorAction SilentlyContinue

if ($FFmpegSystem -and $FFprobeSystem)
{
    Write-Host ($Strings["FFmpegSystem"] -f $FFmpegSystem.Source);
    $FFmpeg = $FFmpegSystem.Source;
    $FFprobe = $FFprobeSystem.Source;
}
elseif ($FFmpegLocal -and $FFprobeLocal)
{
    Write-Host $Strings["FFmpegLocal"];
    $FFmpeg = $FFmpegLocal.Source;
    $FFprobe = $FFprobeLocal.Source;
}
else
{
    $TempPath = [System.IO.Path]::GetTempPath();
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
        $ArchivePath = Join-Path "$TempPath" "ffmpeg.zip";
        Write-Host ($Strings["FFmpegDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host $Strings["FFmpegExtracting"];
        Expand-Archive "$ArchivePath" -DestinationPath "$TempPath" -Force;
        Move-Item (Join-Path "$TempPath" "$FolderName" "bin" "ff*") "$FFmpegDir";
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
        Write-Host ($Strings["FFmpegDownloading"] -f $Link);
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host $Strings["FFmpegExtracting"];
        tar -xf $ArchivePath -C "$TempPath";
        Move-Item (Join-Path "$TempPath" "ffmpeg-master-latest-linux64-gpl" "bin" "ff*") "$FFmpegDir";
        Remove-Item (Join-Path "$TempPath" "ffmpeg-master-latest-linux64-gpl") -Recurse -Force;
    }
    $FFmpeg = Join-Path "$FFmpegDir" "ffmpeg";
    $FFprobe = Join-Path "$FFmpegDir" "ffprobe";
    Write-Host $Strings["FFmpegFinished"];
    Write-Host;
}
