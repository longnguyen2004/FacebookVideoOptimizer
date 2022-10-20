function Encode-Software {
    param(
        [string] $InputFile,
        [string] $OutputFile        
    )
    $ValidPresets = @{
        "ultrafast" = "";
        "superfast" = "";
        "veryfast"  = "";
        "faster"    = "";
        "fast"      = "";
        "medium"    = "";
        "slow"      = "";
        "slower"    = "";
        "veryslow"  = "";
    }
    Write-Host @"
Danh sách preset: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow
Cách chọn preset:
    - Máy yếu: veryfast hoặc faster
    - Máy mạnh: medium hoặc slow

"@
    do
    {
        $Preset = Read-Host -Prompt "Vui lòng chọn preset (bỏ trống để chọn medium)";
        if ($Preset -eq "")
        {
            $Preset = "medium";
        }
    }
    while (-not $ValidPresets.ContainsKey($Preset));

    Write-Host @"

Sử dụng libx264 để encode
Preset: $Preset
Rate control: 2-pass VBR
Bitrate: ${VideoBitrate}kbps (video) + ${AudioBitrate}kbps (audio)

"@
    $CommonParam = (
        "-aq-mode"     , "3",
        "-aq-strength" , "0.7",
        "-psy-rd"      , "1.2:0.5",
        "-rc-lookahead", "100",
        "-direct-pred" , "3",
        "-x264-params" , "trellis=2"
    )

    Write-Host "Pass 1:";
    & "$FFmpeg" -y -i "$InputFile" `
        -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
        -preset $Preset                                       `
        -c:v libx264 -b:v "${VideoBitrate}k"                  `
        @CommonParam -pass 1                                  `
        -an -f null ($IsWindows ? "NUL" : "/dev/null")
    Write-Host;

    Write-Host "Pass 2:"
    & "$FFmpeg" -y -i "$InputFile" `
        -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
        -preset $Preset                                       `
        -c:v libx264 -b:v "${VideoBitrate}k"                  `
        @CommonParam -pass 2                                  `
        -movflags +faststart                                  `
        "$OutputFile"
    Write-Host;
    Remove-Item "*2pass*";
}