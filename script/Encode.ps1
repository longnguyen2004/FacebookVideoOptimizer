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
2. GPU (nhanh hơn, chất lượng thấp hơn)
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
        if ($LASTEXITCODE -ne 0) 
        {
            return $false;
        }

        Write-Host "Pass 2:"
        & "$FFmpeg" -y -i "$InputFile" `
            -hide_banner -loglevel $LogLevel -stats -fps_mode cfr `
            -c:v $Encoder -b:v "${VideoBitrate}k"                 `
            @CommonParam @Pass2Param                              `
            -movflags +faststart                                  `
            "$OutputFile"
        Write-Host;
        Remove-Item "*2pass*";
        if ($LASTEXITCODE -ne 0) 
        {
            return $false;
        }
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
        if ($LASTEXITCODE -ne 0) 
        {
            return $false;
        }
    }
    return $true;
}