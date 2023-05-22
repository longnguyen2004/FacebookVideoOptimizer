function Get-EncoderSettings-Hardware {
    param(
        [Parameter(Mandatory=$true)]
        $VideoInfo,

        [Parameter(Mandatory=$true)]
        [CmdletBinding(PositionalBinding=$false)]
        [string]$Mode
    )
    function Find-GPU-Windows
    {
        $WmiOutput = Get-CimInstance win32_VideoController `
            | Where-Object Status -eq "OK"                 `
            | Select-Object -ExpandProperty Name;          `
        $GPUSupported = @();
        foreach ($GPUName in $WmiOutput)
        {
            if ($GPUName -like "NVIDIA*" -and "NVIDIA" -notin $GPUSupported)
            {
                $GPUSupported += "NVIDIA";
            }
            elseif ($GPUName -like "AMD*" -and "AMD" -notin $GPUSupported)
            {
                $GPUSupported += "AMD";
            }
            elseif ($GPUName -like "Intel*" -and "Intel" -notin $GPUSupported)
            {
                $GPUSupported += "Intel";
            }
        }
        return $GPUSupported;
    }

    if ($IsWindows)
    {
        $GPUSupported = @(Find-GPU-Windows);
    }
    if ($GPUSupported.Length -eq 1)
    {
        $GPU = $GPUSupported[0];
    }
    else
    {
        Write-Host $Strings["GPUSelect"];
        $GPUSupported | ForEach-Object { $i = 1 } { Write-Host "${i}: $_"; $i++ }
        $GPU = $GPUSupported[[int](Get-UserInput -Choices $(1..($GPUSupported.Length))) - 1];   
    }
    Write-Host;
    switch ($GPU) {
        "NVIDIA" {
            $CommonParams = (
                "-multipass"   , "2",
                "-rc-lookahead", "200",
                "-spatial_aq"  , "1",
                "-temporal_aq" , "1",
                "-nonref_p"    , "1",
                "-coder"       , "cabac",
                "-b_ref_mode"  , "1",
                "-preset"      , "p7",
                "-rc"          , "vbr"
            );
            switch ($Mode)
            {
                "Quality" {
                    Write-Host ($Strings["EncoderInfo"] -f "NVIDIA NVENC","Constant Quality");
                    return [PSCustomObject]@{
                        "Encoder"     = "h264_nvenc";
                        "CommonParam" = $CommonParams + (
                            "-cq" , "19",
                            "-b:v", "0"
                        );
                        "MaxRes" = $null;
                        "MaxFps" = "120";
                    }
                }
                "FileSize" {
                    Write-Host ($Strings["EncoderInfo"] -f "NVIDIA NVENC","VBR High Quality");
                    return [PSCustomObject]@{
                        "Encoder"     = "h264_nvenc";
                        "CommonParam" = $CommonParams + (
                            "-maxrate:v", "5M",
                            "-bufsize:v", "10M"
                        );
                        "MaxRes" = "720";
                        "MaxFps" = "60";
                    }
                }
            }
        }
        "AMD" {
            $CommonParams = (
                "-quality"    , "quality",
                "-vbaq"       , "1",
                "-preanalysis", "1",
                "-coder"      , "cabac"
            )
            switch ($Mode)
            {
                "Quality" {
                    Write-Host ($Strings["EncoderInfo"] -f "AMD AMF","CQP + Pre-Analysis")
                    return [PSCustomObject]@{
                        "Encoder"     = "h264_amf";
                        "CommonParam" = $CommonParams + (
                            "-rc"  , "cqp",
                            "-qp_i", "15",
                            "-qp_p", "19",
                            "-qp_b", "23"
                        );
                        "MaxRes" = $null;
                        "MaxFps" = "120";
                    }
                }
                "FileSize" {
                    Write-Host ($Strings["EncoderInfo"] -f "AMD AMF","VBR + Pre-Analysis")
                    return [PSCustomObject]@{
                        "Encoder"     = "h264_amf";
                        "CommonParam" = $CommonParams + (
                            "-rc"       , "vbr_peak",
                            "-maxrate:v", "5M",
                            "-bufsize:v", "10M"
                        );
                        "MaxRes" = "720";
                        "MaxFps" = "60";
                    }
                }
            }
        }
        "Intel" {
            $CommonParams = (
                "-preset"          , "veryslow",
                "-rdo"             , "1",
                "-b_strategy"      , "1",
                "-look_ahead"      , "1",
                "-look_ahead_depth", "100"
            );
            switch ($Mode) {
                "Quality" { 
                    Write-Host ($Strings["EncoderInfo"] -f "Intel QuickSync","LA-ICQ");
                    return [PSCustomObject]@{
                        "Encoder"     = "h264_qsv";
                        "CommonParam" = $CommonParams + (
                            "-global_quality", "19"
                        )
                        "MaxRes" = $null;
                        "MaxFps" = "120";
                    }
                }
                "FileSize" {
                    Write-Host ($Strings["EncoderInfo"] -f "Intel QuickSync","LA-VBR");
                    return [PSCustomObject]@{
                        "Encoder"     = "h264_qsv";
                        "CommonParam" = $CommonParams
                        "MaxRes" = "720";
                        "MaxFps" = "60";
                    }
                }
            }
        }
    }
}