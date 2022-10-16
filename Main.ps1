param(
    [switch] $Debug,

    [ValidateSet("ultrafast", "superfast", "veryfast", "faster", "fast", "medium", "slow", "slower", "veryslow")]
    [string] $Preset = "medium",

    [ValidateSet("libx264", "libx265")]
    [string] $Encoder = "libx264"
)

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
    $GitHubAPIRes = Invoke-RestMethod "https://api.github.com/repos/eugeneware/ffmpeg-static/releases/latest";
    $LatestVersion = $GitHubAPIRes.tag_name;
    $OS = $IsWindows ? "win32" : $IsMacOS ? "darwin" : "linux";
    $Architecture = [Environment]::Is64BitOperatingSystem ? "x64" : "ia32";
    $DownloadLink = "https://github.com/eugeneware/ffmpeg-static/releases/download/$LatestVersion/$OS-$Architecture";
    Write-Host "Đang tải FFmpeg $LatestVersion từ $DownloadLink";
    Invoke-WebRequest $DownloadLink -OutFile $FFmpegInternalPath -ErrorAction Stop;
    if (-not $IsWindows)
    {
        chmod a+x "$FFmpegInternalPath";
    }
    $FFmpeg = $FFmpegInternalPath;
    Write-Host "Đã tải xong`n"
}

if ($Debug)
{
    Write-Host "Đã kích hoạt chế độ debug. FFmpeg sẽ hiển thị thêm thông tin về video."
}

$2PassParams = @{
    "libx264" = ("-pass", "1"), ("-pass", "2");
    "libx265" = ("-x265-params", "pass=1"), ("-x265-params", "pass=2")
}
$CommonParams = @{
    "libx264" = ("-x264-params", "direct=auto")
}

$LogLevel = $Debug ? "info" : "warning";
$Pass1Param = $2PassParams[$Encoder][0];
$Pass2Param = $2PassParams[$Encoder][1];
$CommonParam = $CommonParams[$Encoder];

while ($true)
{
    $InputFile = Read-Host "Đường dẫn đến file video cần xử lý (có thể kéo thả)";
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

    $VideoBitrate = 1800;
    $AudioBitrate = 128;

    Write-Host "Video codec: $Encoder, preset $Preset";
    Write-Host "(có thể đổi preset bằng switch -Preset)";
    Write-Host "Audio codec: aac";
    Write-Host "Bitrate: ${VideoBitrate}kbps (video) + ${AudioBitrate}kbps (audio)`n";

    $OutputFile = Join-Path (Split-Path -Parent $InputFile) ((Split-Path -LeafBase $InputFile) + " (transcode).mp4");
    Write-Host "File output: $OutputFile`n";

    Write-Host "Pass 1:";
    & "$FFmpeg" -y -i "$InputFile" `
        -hide_banner -loglevel $LogLevel -stats -vsync cfr `
        -preset $Preset                                    `
        -c:v $Encoder -b:v "${VideoBitrate}k"              `
        @CommonParam @Pass1Param                           `
        -an -f null ($IsWindows ? "NUL" : "/dev/null")
    Write-Host;

    Write-Host "Pass 2:"
    & "$FFmpeg" -y -i "$InputFile" `
        -hide_banner -loglevel $LogLevel -stats -vsync cfr `
        -preset $Preset                                    `
        -c:v $Encoder -b:v "${VideoBitrate}k"              `
        @CommonParam @Pass2Param                           `
        -c:a aac      -b:a "${AudioBitrate}k"              `
        -movflags +faststart                               `
        "$OutputFile"
    Write-Host;
    Remove-Item "*2pass*";
}
