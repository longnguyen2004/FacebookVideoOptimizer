function Get-EncoderSettings
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $InputFile
    )

    function Get-EncoderSettings-Video
    {
        param($VideoStreamInfo)

        . $PSScriptRoot/EncoderSettings-Software.ps1;
        . $PSScriptRoot/EncoderSettings-Hardware.ps1;

        Write-Host $Strings["EncoderType"];
        $EncoderType = [int](Get-UserInput -Choices 1, 2 -Default 1);
        Write-Host;
        switch ($EncoderType)
        {
            1 {
                $EncoderSettings = Get-EncoderSettings-Software $VideoStreamInfo;
            }
            2 {
                $EncoderSettings = Get-EncoderSettings-Hardware $VideoStreamInfo;
            }
        }
        $MaxRes = $EncoderSettings.MaxRes;
        $MaxFps = $EncoderSettings.MaxFps;

        # Trust the user if they're using AviSynth
        if ((Split-Path -Extension "$InputFile") -ne ".avs")
        {
            $Filters = (
                "scale=-2:'min(ih,$MaxRes)'",
                "fps='min(source_fps, $MaxFps)'"
            )
        }
        $EncoderSettings.CommonParam += ("-g", (5*(Invoke-Expression $VideoStreamInfo.r_frame_rate)))
        $EncoderSettings |
            Add-Member -NotePropertyMembers @{
                "Filters" = $Filters;
                "Bitrate" = 1800;
            }
        return $EncoderSettings;
    }
    function Get-EncoderSettings-Audio
    {
        return [PSCustomObject]@{
            "Encoder" = "aac";
            "Bitrate" = 128;
        };
    }

    $FileInfo = & "$FFprobe" -v quiet -print_format json -show_streams "$InputFile";
    Write-Debug "Stream info:";
    Write-Debug ("`n" + (($FileInfo | ForEach-Object { $_ + "`n" }) -join ""));
    $FileInfo = $FileInfo | ConvertFrom-Json;

    return [PSCustomObject]@{
        "Video" = Get-EncoderSettings-Video $FileInfo.streams[0];
        "Audio" = Get-EncoderSettings-Audio
    };
}