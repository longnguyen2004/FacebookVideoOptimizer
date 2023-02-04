. $PSScriptRoot/Get-Choice.ps1;

function Get-EncoderSettings-Software
{
    param(
        $VideoInfo
    );
    $ValidPresets = @(
        "ultrafast",
        "superfast",
        "veryfast",
        "faster",
        "fast",
        "medium",
        "slow",
        "slower",
        "veryslow"
    );

    $FrameRate = Invoke-Expression $VideoInfo.r_frame_rate;
    if ($FrameRate -le 60)
    {
        $DefaultPreset = "medium";
    }
    elseif ($FrameRate -le 75)
    {
        $DefaultPreset = "slow";
    }
    elseif ($FrameRate -le 90)
    {
        $DefaultPreset = "slower";
    }
    else
    {
        $DefaultPreset = "veryslow";
    }

    Write-Host $Strings["x264Presets"];
    $Preset = Get-Choice -Choices $ValidPresets -Default $DefaultPreset;

    Write-Host;
    Write-Host ($Strings["x264Info"] -f $Preset)

    return [PSCustomObject]@{
        "Encoder"     = "libx264";
        "2PassParam"  = ("-pass", "1"), ("-pass", "2");
        "CommonParam" = (
            "-aq-mode"     , "3",
            "-aq-strength" , "0.7",
            "-psy-rd"      , "1.2:0.5",
            "-rc-lookahead", "100",
            "-direct-pred" , "3",
            "-x264-params" , "trellis=2",
            "-preset"      , $Preset,
            "-bufsize"     , "5M",
            "-maxrate"     , "10M"
        );
        "MaxRes" = "1080";
        "MaxFps" = "120"
    }
}