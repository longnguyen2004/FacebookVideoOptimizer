. $PSScriptRoot/Get-Choice.ps1;

function Get-EncoderSettings-Hardware {
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
        $GPUSupported | % { $i = 1 } { Write-Host "${i}: $_"; $i++ }
        $GPU = $GPUSupported[[int](Get-Choice -Choices $(1..($GPUSupported.Length))) - 1];   
    }
    Write-Host;
    switch ($GPU) {
        "NVIDIA" {
            Write-Host $Strings["NVENCInfo"]
            return [PSCustomObject]@{
                "Encoder"     = "h264_nvenc";
                "CommonParam" = (
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
                );
                "MaxRes" = "720";
                "MaxFps" = "60";
            }
        }
        "AMD" {
            Write-Host $Strings["AMFInfo"]
            return [PSCustomObject]@{
                "Encoder"     = "h264_amf";
                "CommonParam" = (
                    "-quality"    , "quality",
                    "-rc"         , "vbr_peak",
                    "-vbaq"       , "1",
                    "-preanalysis", "1",
                    "-coder"      , "cabac",
                    "-maxrate:v"  , "5M",
                    "-bufsize:v"  , "10M"
                );
                "MaxRes" = "720";
                "MaxFps" = "60";
            }
        }
        "Intel" {
            Write-Host $Strings["QSInfo"]
            return [PSCustomObject]@{
                "Encoder"     = "h264_qsv";
                "CommonParam" = (
                    "-preset"          , "veryslow",
                    "-rdo"             , "1",
                    "-b_strategy"      , "1",
                    "-look_ahead"      , "1",
                    "-look_ahead_depth", "100"
                );
                "MaxRes" = "720";
                "MaxFps" = "60";
            }
        }
    }
}