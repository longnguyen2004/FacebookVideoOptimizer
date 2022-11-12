. $PSScriptRoot/Get-Choice.ps1;

function Encode-Video {
    param(
        [string] $InputFile,
        [string] $OutputFile
    )
    . $PSScriptRoot/EncoderSettings-Software.ps1;
    . $PSScriptRoot/EncoderSettings-Hardware.ps1;

    Write-Host $Strings["EncoderType"];
    $EncoderType = [int](Get-Choice -Choices 1, 2 -Default 1);
    Write-Host;

    switch ($EncoderType)
    {
        1 {
            $EncoderSettings = GetEncoderSettings-Software;
            $VideoFilters = @("scale=-1:'min(1080, ih)'","fps='min(120, source_fps)'")
        }
        2 {
            $EncoderSettings = GetEncoderSettings-Hardware;
            $VideoFilters = @("scale=-1:'min(720, ih)'","fps='min(60, source_fps)'")
        }
    }

    $Encoder = $EncoderSettings.Encoder;
    $CommonParam = $EncoderSettings.CommonParam;
    Write-Host;

    Write-Host $Strings["ProcessingVideo"];
    Write-Host ($Strings["Bitrate"] -f $VideoBitrate);
    Write-Host ($Strings["EncoderSettings"] -f ($CommonParam -join " "));
    Write-Host ($Strings["VideoFilters"] -f $VideoFilters -join ", ");
    Write-Host;

    if ($EncoderSettings."2PassParam")
    {
        $Pass1Param, $Pass2Param = $EncoderSettings."2PassParam";
        Write-Host $Strings["Pass1"];
        & "$FFmpeg" `
            -hide_banner -loglevel $LogLevel -stats `
            -y -i "$InputFile" -fps_mode cfr        `
            -vf ($VideoFilters -join ",")           `
            -c:v $Encoder -b:v "${VideoBitrate}k"   `
            @CommonParam @Pass1Param                `
            -an -f null ($IsWindows ? "NUL" : "/dev/null")
        Write-Host;
        if ($LASTEXITCODE -ne 0) 
        {
            return $false;
        }

        Write-Host $Strings["Pass2"];
        & "$FFmpeg" `
            -hide_banner -loglevel $LogLevel -stats `
            -y -i "$InputFile" -fps_mode cfr        `
            -vf ($VideoFilters -join ",")           `
            -c:v $Encoder -b:v "${VideoBitrate}k"   `
            @CommonParam @Pass2Param                `
            -an "$OutputFile"
        Write-Host;
        Remove-Item "*2pass*";
        if ($LASTEXITCODE -ne 0) 
        {
            return $false;
        }
    }
    else
    {
        & "$FFmpeg" `
            -hide_banner -loglevel $LogLevel -stats `
            -y -i "$InputFile" -fps_mode cfr        `
            -vf ($VideoFilters -join ",")           `
            -c:v $Encoder -b:v "${VideoBitrate}k"   `
            @CommonParam                            `
            -an "$OutputFile"
        Write-Host;
        if ($LASTEXITCODE -ne 0) 
        {
            return $false;
        }
    }
    return $true;
}

function Encode-Audio {
    param(
        [string] $InputFile,
        [string] $OutputFile
    )
    Write-Host $Strings["ProcessingAudio"];
    Write-Host ($Strings["Bitrate"] -f $AudioBitrate);
    & "$FFmpeg" -y -i "$InputFile" `
        -hide_banner -loglevel $LogLevel -stats `
        -c:a aac -b:a "${AudioBitrate}k"        `
        -af "lowpass=f=16000:r=f64,dynaudnorm"  `
        -vn "$OutputFile"
    Write-Host;
    return ($LASTEXITCODE -eq 0);
}
function Encode {
    param(
        [string] $InputFile,
        [string] $OutputFile
    )
    $TempDir = $IsWindows ? $Env:Temp : "/tmp";
    $VideoFile = Join-Path "$TempDir" "video.mp4";
    $AudioFile = Join-Path "$TempDir" "audio.m4a";

    $VideoResult = Encode-Video $InputFile $VideoFile;
    if (-not $VideoResult) { return $false };

    $AudioResult = Encode-Audio $InputFile $AudioFile;
    if (-not $AudioResult) { return $false };

    Write-Host $Strings["Muxing"];
    & "$FFmpeg" `
        -y -hide_banner -loglevel $LogLevel -stats `
        -i "$VideoFile" -i "$AudioFile"            `
        -c copy "$OutputFile"
    Write-Host;

    Remove-Item $VideoFile -Force;
    Remove-Item $AudioFile -Force;

    return $LASTEXITCODE -eq 0;
}