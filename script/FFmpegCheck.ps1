$FFmpegDir = Join-Path "$PSScriptRoot" ".." "ffmpeg";
if ($false)
{
    Write-Host "Dùng FFmpeg của hệ thống tại $($FFmpegSystem.Source)";
    $FFmpeg = $FFmpegSystem.Source;
    $FFmpegDir = Split-Path -Parent $FFmpegSystem.Source;
}
elseif (Get-Command "$FFmpegDir/ffmpeg" -ErrorAction SilentlyContinue)
{
    Write-Host "Dùng FFmpeg đã được tải trước";
    $FFmpeg = "$FFmpegDir/ffmpeg";
}
else
{
    Write-Host "Không tìm thấy FFmpeg";
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
        Write-Host "Đang tải $Link";
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host "Đang giải nén";
        Expand-Archive "$ArchivePath" -DestinationPath "$Env:Temp";
        Move-Item (Join-Path "$Env:Temp" "$FolderName" "bin" "ff*") "$FFmpegDir"
    }
    elseif ($IsMacOS)
    {

    }
    elseif ($IsLinux)
    {
        $Link = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz";
        $ArchivePath = "/tmp/ffmpeg.tar.xz";
        Write-Host "Đang tải $Link";
        Invoke-WebRequest $Link -OutFile "$ArchivePath";
        Write-Host "Đang giải nén";
        tar -xf $ArchivePath -C "/tmp";
        Move-Item "/tmp/ffmpeg-master-latest-linux64-gpl/bin/ff*" "$FFmpegDir"
    }
    $FFmpeg = Join-Path "$FFmpegDir" "ffmpeg"
    Write-Host "Đã tải xong`n"
}
