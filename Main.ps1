$FFmpegInternalPath = Join-Path "$PSScriptRoot" "ffmpeg" ("ffmpeg" + ($IsWindows ? ".exe" : ""));
if ($FFmpegSystem = Get-Command ffmpeg -ErrorAction SilentlyContinue)
{
    Write-Host "Dùng FFmpeg của hệ thống tại $($FFmpegSystem.Source)";
    $FFmpeg = $FFmpegSystem.Source;
}
elseif (Get-Command "$FFmpegInternalPath" -ErrorAction SilentlyContinue)
{
    Write-Host "Dùng FFmpeg đã được tải trước";
    $FFmpeg = $FFmpegInternalPath;
}
else
{
    Write-Host "Không tìm thấy FFmpeg";
    New-Item -ItemType Directory (Split-Path -Parent $FFmpegInternalPath) -ErrorAction SilentlyContinue | Out-Null;
    $GitHubAPIRes = ConvertFrom-JSON (Invoke-WebRequest "https://api.github.com/repos/eugeneware/ffmpeg-static/releases/latest");
    $LatestVersion = $GitHubAPIRes.tag_name;
    $OS = $IsWindows ? "win32" : $IsMacOS ? "darwin" : "linux";
    $Architecture = [Environment]::Is64BitOperatingSystem ? "x64" : "ia32";
    $DownloadLink = "https://github.com/eugeneware/ffmpeg-static/releases/download/$LatestVersion/$OS-$Architecture";
    Write-Host "Tải FFmpeg $LatestVersion từ $DownloadLink";
    Invoke-WebRequest $DownloadLink -OutFile $FFmpegInternalPath -ErrorAction Stop;
    if (-not $IsWindows)
    {
        chmod a+x "$FFmpegInternalPath";
    }
    $FFmpeg = $FFmpegInternalPath;
}

while ($true)
{
    $InputFile = Read-Host "Đường dẫn đến file video cần xử lý";
    if (-not $InputFile)
    {
        Write-Host;
        return;
    }

	# PowerShell drag-and-drop paths
    if ($InputFile -match "^& '(.+)'$")
    {
        $InputFile = $Matches[1] -replace "''","'"
    }
	# Windows Terminal drag-and-drop paths
	elseif ($InputFile -match '^"(.+)"$')
	{
		$InputFile = $Matches[1]
	}

    if (-not (Test-Path $InputFile))
    {
        Write-Error "Đường dẫn không hợp lệ!";
        continue;
    }
    Write-Host;

    <#
        Chỉnh sửa preset ở đây nếu encode quá lâu
        Danh sách các preset: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
        Khuyến khích dùng veryfast trở xuống, không dùng ultrafast và superfast
    #>
    $Preset = "medium"

    Write-Host "Thực hiện 2-pass VBR với x264, preset $Preset";
    Write-Host "(có thể edit file để chỉnh sửa preset)"
    Write-Host "Bitrate: 1800kbps (video) + 128kbps (audio)`n";

    $OutputFile = Join-Path (Split-Path -Parent $InputFile) ((Split-Path -LeafBase $InputFile) + " (transcode).mp4");
    Write-Host "File output: $OutputFile`n"

    Write-Host "Pass 1:"
    & "$FFmpeg" -y -i "$InputFile" `
        -hide_banner -loglevel warning -stats -vsync cfr `
        -c:v libx264 -b:v 1800k -pass 1                  `
        -an -f null ($IsWindows ? "NUL" : "/dev/null")
    Write-Host;

    Write-Host "Pass 2:"
    & "$FFmpeg" -y -i "$InputFile" `
        -hide_banner -loglevel warning -stats -vsync cfr `
        -c:v libx264 -b:v 1800k -pass 2                  `
        "$OutputFile"
    Write-Host;
    Remove-Item "ffmpeg2pass*";
}
