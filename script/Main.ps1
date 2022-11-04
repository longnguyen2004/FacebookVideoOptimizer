param(
    [switch] $Debug
)

. $PSScriptRoot/FFmpegCheck.ps1
. $PSScriptRoot/Encode.ps1

if ($Debug)
{
    Write-Host "Đã kích hoạt chế độ debug. FFmpeg sẽ hiển thị thêm thông tin về video."
}

$LogLevel = $Debug ? "verbose" : "error";

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

    if (-not (Test-Path $InputFile -PathType Leaf))
    {
        Write-Error "Đường dẫn không hợp lệ!";
        continue;
    }
    Write-Host;

    $VideoBitrate = 1800;
    $AudioBitrate = 128;

    $OutputFile = Join-Path (Split-Path -Parent $InputFile) ((Split-Path -LeafBase $InputFile) + " (transcode).mp4");

    $Success = Encode "$InputFile" "$OutputFile";
    if ($Success)
    {
        Write-Host @"
Đã hoàn tất
File output: $OutputFile

"@;
    }
    else
    {
        Write-Host "Xử lý thất bại!`n";
    }
    Write-Host "Bấm Enter để tiếp tục...";
    Read-Host;
    Clear-Host;
}
