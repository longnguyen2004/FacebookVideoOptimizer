$FFmpegOptions = (
    "-hide_banner",
    "-loglevel", $LogLevel,
    "-stats",
    "-y"
)

function Encode-Video {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputFile,
        [Parameter(Mandatory=$true)]
        [string]$OutputFile,
        [Parameter(Mandatory=$true)]
        [Nullable[PSCustomObject]]$EncoderSettings,
        [string[]]$Trim
    )

    Write-Host;
    Write-Host $Strings["ProcessingVideo"];
    if (-not $EncoderSettings)
    {
        & "$FFmpeg" @FFmpegOptions -i "$InputFile" -c:v copy -an "$OutputFile";
        Write-Host;
        return -not $LASTEXITCODE;
    }
    else
    {
        $Encoder = $EncoderSettings.Encoder;
        $CommonParam = $EncoderSettings.CommonParam;
        $Filters = $EncoderSettings.Filters;
        $Bitrate = $EncoderSettings.Bitrate;
        $TimeStart, $TimeEnd = $Trim;
        
        Write-Host ($Strings["Bitrate"] -f $Bitrate);
        Write-Host ($Strings["EncoderSettings"] -f ($CommonParam -join " "));
        Write-Host ($Strings["VideoFilters"] -f ($Filters -join ", "));
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

        if ($Filters)
        {
            $InputParams += ("-vf", ($Filters -join ","));
        }

        if ($EncoderSettings."2PassParam")
        {
            $Pass1Param, $Pass2Param = $EncoderSettings."2PassParam";
            Write-Host ($Strings["CurrentPass"] -f 1,2);
            & "$FFmpeg" @FFmpegOptions `
                @InputParams                     `
                -c:v $Encoder -b:v "${Bitrate}k" `
                @CommonParam @Pass1Param         `
                -an -f null ($IsWindows ? "NUL" : "/dev/null")
            Write-Host;
            if ($LASTEXITCODE -ne 0) 
            {
                return $false;
            }

            Write-Host ($Strings["CurrentPass"] -f 2,2);
            & "$FFmpeg" @FFmpegOptions `
                @InputParams                     `
                -c:v $Encoder -b:v "${Bitrate}k" `
                @CommonParam @Pass2Param         `
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
                @InputParams                     `
                -c:v $Encoder -b:v "${Bitrate}k" `
                @CommonParam                     `
                -an "$OutputFile"
            Write-Host;
            if ($LASTEXITCODE -ne 0) 
            {
                return $false;
            }
        }
        return $true;
    }
}

function Encode-Audio {
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputFile,
        [Parameter(Mandatory=$true)]
        [string]$OutputFile,
        [Parameter(Mandatory=$true)]
        [Nullable[PSCustomObject]]$EncoderSettings,
        [string[]]$Trim
    )
    Write-Host $Strings["ProcessingAudio"];

    if (-not $EncoderSettings)
    {
        & "$FFmpeg" @FFmpegOptions -i "$InputFile" -c:a copy -vn "$OutputFile";
        Write-Host;
        return -not $LASTEXITCODE;
    }
    else
    {
        $Encoder = $EncoderSettings.Encoder;
        $Bitrate = $EncoderSettings.Bitrate;
        $TimeStart, $TimeEnd = $Trim;
        Write-Host ($Strings["Bitrate"] -f $Bitrate);

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
            @InputParams                     `
            -c:a $Encoder -b:a "${Bitrate}k" `
            -af "lowpass=f=16000:r=f64"      `
            -vn "$OutputFile"
        Write-Host;
        return ($LASTEXITCODE -eq 0);
    }
}
function Encode {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Job
    )
    $InputFile = $Job.Input;
    $OutputFile = $Job.Output;

    $TempDir = $IsWindows ? $Env:Temp : "/tmp";
    $VideoFile = Join-Path "$TempDir" "video.mp4";
    $AudioFile = Join-Path "$TempDir" "audio.m4a";

    $VideoResult = Encode-Video $InputFile $VideoFile `
        -EncoderSettings $Job.Encoder.Video -Trim $Job.Trim
    if (-not $VideoResult) { return $false };

    $AudioResult = Encode-Audio $InputFile $AudioFile `
        -EncoderSettings $Job.Encoder.Audio -Trim $Job.Trim
    if (-not $AudioResult) { return $false };

    Write-Host $Strings["Muxing"];
    & "$FFmpeg" @FFmpegOptions `
        -i "$VideoFile" -i "$AudioFile" -c copy     `
        -metadata:g "encoding_tool=$Identification" `
        -movflags +faststart                        `
        "$OutputFile"
    Write-Host;

    Remove-Item $VideoFile -Force;
    Remove-Item $AudioFile -Force;

    return $LASTEXITCODE -eq 0;
}