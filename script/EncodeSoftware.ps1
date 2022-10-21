function Encode {
    param(
        [string] $InputFile,
        [string] $OutputFile        
    )
    . $PSScriptRoot/EncoderSettings-Software.ps1;
    $EncoderSettings = GetEncoderSettings-Software;
    $Encoder = $EncoderSettings["Encoder"];
    $CommonParam = $EncoderSettings["CommonParam"];
    Write-Host "Bitrate: ${VideoBitrate}kbps (video) + ${AudioBitrate}kbps (audio)";
    Write-Host "Cài đặt encoder: $CommonParam`n";

    if ($EncoderSettings["2Pass"])
    {
        $Pass1Param = $EncoderSettings["2PassParam"][0];
        $Pass2Param = $EncoderSettings["2PassParam"][1];
        Write-Host "Pass 1:";
        & "$FFmpeg" -y -i "$InputFile" `
            -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
            -c:v $Encoder -b:v "${VideoBitrate}k"                 `
            @CommonParam @Pass1Param                              `
            -an -f null ($IsWindows ? "NUL" : "/dev/null")
        Write-Host;

        Write-Host "Pass 2:"
        & "$FFmpeg" -y -i "$InputFile" `
            -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
            -c:v $Encoder -b:v "${VideoBitrate}k"                 `
            @CommonParam @Pass2Param                              `
            -movflags +faststart                                  `
            "$OutputFile"
        Write-Host;
        Remove-Item "*2pass*";
    }
}