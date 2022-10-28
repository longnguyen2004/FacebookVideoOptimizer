. $PSScriptRoot/Get-Choice.ps1;

function GetEncoderSettings-Hardware {
    Write-Host @"
Chọn GPU bạn có
1. NVIDIA
2. AMD
3. Intel
"@;
    $GPU = [int](Get-Choice -Choices 1, 2, 3);
    Write-Host;
    switch ($GPU) {
        1 {
            Write-Host @"
Sử dụng NVIDIA NVENC để encode
Rate control: CQ + Bitrate Limit
"@;
            return @{
                "Encoder"     = "h264_nvenc";
                "2Pass"       = $false;
                "CommonParam" = (
                    "-vf"          , "scale=-1:'min(720,ih)'",
                    "-multipass"   , "2",
                    "-rc-lookahead", "200",
                    "-spatial_aq"  , "1",
                    "-temporal_aq" , "1",
                    "-nonref_p"    , "1",
                    "-coder"       , "cabac",
                    "-b_ref_mode"  , "1",
                    "-preset"      , "p7",
                    "-maxrate:v"   , "${VideoBitrate}k",
                    "-bufsize:v"   , "5M"
                )
            }
        }
        2 {
            Write-Host @"
Sử dụng AMD AMF để encode
Rate control: VBR + Pre-Analysis
"@;
            return @{
                "Encoder"     = "h264_amf";
                "2Pass"       = $false;
                "CommonParam" = (
                    "-vf"         , "scale=-1:'min(720,ih)'",
                    "-quality"    , "quality",
                    "-rc"         , "vbr_peak",
                    "-vbaq"       , "1",
                    "-preanalysis", "1",
                    "-coder"      , "cabac",
                    "-maxrate:v"  , "5M",
                    "-bufsize:v"  , "10M"
                )
            }
        }
        3 {
            Write-Host @"
Sử dụng Intel QuickSync để encode
Rate control: LA_VBR
"@;
            return @{
                "Encoder"     = "h264_qsv";
                "2Pass"       = $false;
                "CommonParam" = (
                    "-vf"              , "scale=-1:'min(720,ih)'",
                    "-preset"          , "veryslow",
                    "-rdo"             , "1",
                    "-b_strategy"      , "1",
                    "-look_ahead"      , "1",
                    "-look_ahead_depth", "100"
                )
            }
        }
    }
}