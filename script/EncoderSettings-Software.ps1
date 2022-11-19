. $PSScriptRoot/Get-Choice.ps1;

function Get-EncoderSettings-Software
{
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
    Write-Host $Strings["x264Presets"];
    $Preset = Get-Choice -Choices $ValidPresets -Default "medium";

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