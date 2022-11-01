. $PSScriptRoot/Get-Choice.ps1;

function Encode {
    param(
        [string] $InputFile,
        [string] $OutputFile
    )
    . $PSScriptRoot/EncoderSettings-Software.ps1;
    . $PSScriptRoot/EncoderSettings-Hardware.ps1;

    Write-Host @"
Chọn loại encoder:
1. CPU (chậm hơn, chất lượng cao hơn)
2. GPU (nhanh hơn, chất lượng thấp hơn, video sẽ bị scale xuống 720p)
"@
    $EncoderType = [int](Get-Choice -Choices 1, 2 -Default 1);
    Write-Host;
    switch ($EncoderType)
    {
        1 {
            $EncoderSettings = GetEncoderSettings-Software;
        }
        2 {
            $EncoderSettings = GetEncoderSettings-Hardware;
        }
    }

    $Encoder = $EncoderSettings.Encoder;
    $CommonParam = $EncoderSettings.CommonParam;
    Write-Host "Bitrate: ${VideoBitrate}kbps (video) + ${AudioBitrate}kbps (audio)";
    Write-Host "Cài đặt encoder: $CommonParam`n";

    if ($EncoderSettings."2PassParam")
    {
        $Pass1Param, $Pass2Param = $EncoderSettings."2PassParam";
        Write-Host "Pass 1:";
        & "$FFmpeg" -y -i "$InputFile" `
            -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
            -c:v $Encoder -b:v "${VideoBitrate}k"                 `
            @CommonParam @Pass1Param                              `
            -an -f null ($IsWindows ? "NUL" : "/dev/null")
        Write-Host;
        ($LASTEXITCODE -ne 0) -and (return $false);

        Write-Host "Pass 2:"
        & "$FFmpeg" -y -i "$InputFile" `
            -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
            -c:v $Encoder -b:v "${VideoBitrate}k"                 `
            @CommonParam @Pass2Param                              `
            -movflags +faststart                                  `
            "$OutputFile"
        Write-Host;
        Remove-Item "*2pass*";
        ($LASTEXITCODE -ne 0) -and (return $false);
    }
    else
    {
        & "$FFmpeg" -y -i "$InputFile" `
            -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
            -c:v $Encoder -b:v "${VideoBitrate}k"                 `
            @CommonParam                                          `
            -movflags +faststart                                  `
            "$OutputFile"
        Write-Host;
        ($LASTEXITCODE -ne 0) -and (return $false);
    }
    return $true;
}