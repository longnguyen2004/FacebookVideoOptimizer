function Get-EncoderSettings-Video
{
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$VideoStreamInfo,

        [Parameter(Mandatory=$true)]
        [CmdletBinding(PositionalBinding=$false)]
        [string]$Mode
    )

    . $PSScriptRoot/EncoderSettings-Software.ps1;
    . $PSScriptRoot/EncoderSettings-Hardware.ps1;

    Write-Host $Strings["EncoderType"];
    $EncoderType = [int](Get-UserInput -Choices 1, 2 -Default 1);
    Write-Host;
    switch ($EncoderType)
    {
        1 {
            $EncoderSettings = Get-EncoderSettings-Software -Mode $Mode $VideoStreamInfo;
        }
        2 {
            $EncoderSettings = Get-EncoderSettings-Hardware -Mode $Mode $VideoStreamInfo;
        }
    }
    $MaxRes = $EncoderSettings.MaxRes;
    $MaxFps = $EncoderSettings.MaxFps;

    $Filters = $null;
    # Trust the user if they're using AviSynth
    if ((Split-Path -Extension "$InputFile") -ne ".avs")
    {
        if ($MaxRes)
        {
            $Filters += ,"scale=-2:'min(ih,$MaxRes)'";
        }
        if ($MaxFps)
        {
            $Filters += ,"fps='min(source_fps, $MaxFps)'";
        }
    }
    $EncoderSettings |
        Add-Member -NotePropertyMembers @{
            "Filters" = $Filters;
            "Bitrate" = $Mode -eq "Quality" ? $null : 1800;
        }
    return $EncoderSettings;
}
function Get-EncoderSettings-Audio
{
    param(
        [Parameter(Mandatory=$true)]
        [CmdletBinding(PositionalBinding=$false)]
        [string]$Mode
    )
    switch ($Mode)
    {
        "FileSize" {
            return [PSCustomObject]@{
                "Encoder" = "aac";
                "Bitrate" = 128;
                "Filter"  = ("lowpass=f=16000:r=f64")
            };
        }
        "Quality" {
            return [PSCustomObject]@{
                "Encoder" = "aac";
                "Bitrate" = 320;
            };
        }
    }
}
