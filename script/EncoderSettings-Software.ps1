. $PSScriptRoot/Get-Choice.ps1;

function GetEncoderSettings-Software
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
    Write-Host @"
Cách chọn preset:
    - Máy yếu: veryfast hoặc faster
    - Máy mạnh: medium hoặc slow
"@
    $Preset = Get-Choice -Prompt "Vui lòng chọn preset" -Choices $ValidPresets -Default "medium";

    Write-Host @"

Sử dụng libx264 để encode
Preset: $Preset
Rate control: 2-pass VBR
"@;

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
            "-bufsize"     , "5M"
        )
    }
}