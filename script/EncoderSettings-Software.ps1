function GetEncoderSettings-Software
{
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
"@;

    return @{
        "Encoder"     = "libx264";
        "2Pass"       = $true;
        "2PassParam"  = ("-pass", "1"), ("-pass", "2");
        "CommonParam" = (
            "-aq-mode"     , "3",
            "-aq-strength" , "0.7",
            "-psy-rd"      , "1.2:0.5",
            "-rc-lookahead", "100",
            "-direct-pred" , "3",
            "-x264-params" , "trellis=2",
            "-preset"      , $Preset
        )
    }
}