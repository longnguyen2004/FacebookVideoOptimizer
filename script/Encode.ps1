. $PSScriptRoot/Get-UserInput.ps1;

$FFmpegOptions = (
    "-hide_banner",
    "-loglevel", $LogLevel,
    "-stats",
    "-y"
)

function Encode-Video {
    param(
        [Parameter(Mandatory=$true)]
        [string] $InputFile,
        [Parameter(Mandatory=$true)]
        [string] $OutputFile,

        [CmdletBinding(PositionalBinding = $false)]
        [string] $TimeStart,
        [CmdletBinding(PositionalBinding = $false)]
        [string] $TimeEnd
    )
    
    . $PSScriptRoot/EncoderSettings.ps1
    $EncoderSettings = Get-EncoderSettings "$InputFile";

    $Encoder = $EncoderSettings.Encoder;
    $CommonParam = $EncoderSettings.CommonParam;
    $VideoFilters = $EncoderSettings.VideoFilters;
    Write-Host;

    Write-Host $Strings["ProcessingVideo"];
    Write-Host ($Strings["Bitrate"] -f $VideoBitrate);
    Write-Host ($Strings["EncoderSettings"] -f ($CommonParam -join " "));
    Write-Host ($Strings["VideoFilters"] -f ($VideoFilters -join ", "));
    Write-Host;

    $InputParams = ("-i", $InputFile);
    if ($TimeStart)
    {
        $InputParams = ("-ss", $TimeStart) + $InputParams;
    }
    if ($TimeEnd)
    {
        $InputParams = ("-to", $TimeEnd) + $InputParams;
    }
    $InputParams += ("-fps_mode", "cfr");

    if ($EncoderSettings."2PassParam")
    {
        $Pass1Param, $Pass2Param = $EncoderSettings."2PassParam";
        Write-Host ($Strings["CurrentPass"] -f 1,2);
        & "$FFmpeg" @FFmpegOptions `
            @InputParams                          `
            -vf ($VideoFilters -join ",")         `
            -c:v $Encoder -b:v "${VideoBitrate}k" `
            @CommonParam @Pass1Param              `
            -an -f null ($IsWindows ? "NUL" : "/dev/null")
        Write-Host;
        if ($LASTEXITCODE -ne 0) 
        {
            return $false;
        }

        Write-Host ($Strings["CurrentPass"] -f 2,2);
        & "$FFmpeg" @FFmpegOptions `
            @InputParams                          `
            -vf ($VideoFilters -join ",")         `
            -c:v $Encoder -b:v "${VideoBitrate}k" `
            @CommonParam @Pass2Param              `
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
        & "$FFmpeg" @FFmpegOptions `
            @InputParams                          `
            -vf ($VideoFilters -join ",")         `
            -c:v $Encoder -b:v "${VideoBitrate}k" `
            @CommonParam                          `
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
        [Parameter(Mandatory=$true)]
        [string] $InputFile,
        [Parameter(Mandatory=$true)]
        [string] $OutputFile,

        [CmdletBinding(PositionalBinding = $false)]
        [string] $TimeStart,
        [CmdletBinding(PositionalBinding = $false)]
        [string] $TimeEnd
    )
    Write-Host $Strings["ProcessingAudio"];
    Write-Host ($Strings["Bitrate"] -f $AudioBitrate);

    $InputParams = ("-i", $InputFile);
    if ($TimeStart)
    {
        $InputParams = ("-ss", $TimeStart) + $InputParams;
    }
    if ($TimeEnd)
    {
        $InputParams = ("-to", $TimeEnd) + $InputParams;
    }

    & "$FFmpeg" @FFmpegOptions `
        @InputParams                           `
        -c:a aac -b:a "${AudioBitrate}k"       `
        -af "lowpass=f=16000:r=f64,dynaudnorm" `
        -vn "$OutputFile"
    Write-Host;
    return ($LASTEXITCODE -eq 0);
}
function Encode {
    param(
        [Parameter(Mandatory=$true)]
        [string] $InputFile,
        [Parameter(Mandatory=$true)]
        [string] $OutputFile,

        [CmdletBinding(PositionalBinding = $false)]
        [string] $TimeStart,
        [CmdletBinding(PositionalBinding = $false)]
        [string] $TimeEnd
    )
    $TempDir = $IsWindows ? $Env:Temp : "/tmp";
    $VideoFile = Join-Path "$TempDir" "video.mp4";
    $AudioFile = Join-Path "$TempDir" "audio.m4a";

    $VideoResult = Encode-Video $InputFile $VideoFile -TimeStart $TimeStart -TimeEnd $TimeEnd;
    if (-not $VideoResult) { return $false };

    $AudioResult = Encode-Audio $InputFile $AudioFile -TimeStart $TimeStart -TimeEnd $TimeEnd;
    if (-not $AudioResult) { return $false };

    Write-Host $Strings["Muxing"];
    & "$FFmpeg" @FFmpegOptions -i "$VideoFile" -i "$AudioFile" -c copy "$OutputFile"
    Write-Host;

    Remove-Item $VideoFile -Force;
    Remove-Item $AudioFile -Force;

    return $LASTEXITCODE -eq 0;
}