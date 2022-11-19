function Get-EncoderSettings
{
    param(
        [string] $InputFile
    )
    . $PSScriptRoot/EncoderSettings-Software.ps1;
    . $PSScriptRoot/EncoderSettings-Hardware.ps1;

    Write-Host $Strings["EncoderType"];
    $EncoderType = [int](Get-Choice -Choices 1, 2 -Default 1);
    Write-Host;

    switch ($EncoderType)
    {
        1 {
            $EncoderSettings = Get-EncoderSettings-Software;
        }
        2 {
            $EncoderSettings = Get-EncoderSettings-Hardware;
        }
    }
    $MaxRes = $EncoderSettings.MaxRes;
    $MaxFps = $EncoderSettings.MaxFps;

    if ((Split-Path -Extension "$InputFile") -eq ".avs")
    {
        $VideoFilters = (
            "scale=-2:'min(ih,$MaxRes)'",
            "fps='min(source_fps, $MaxFps)'"
        )
    }
    else
    {
        $VideoInfo = & "$FFprobe" -v quiet -print_format json -show_format -show_streams "$InputFile" | ConvertFrom-Json;
        $VideoFilters = (,
            "scale=-2:'min(ih,$MaxRes)'"
        )
        if ($VideoInfo.format.tags.artist -eq "Microsoft Game DVR")
        {
            Write-Host $Strings["GameDVR"];
            $VideoFilters += "fps=60"
        }
        else
        {
            $VideoFilters += "fps='min(source_fps, $MaxFps)'"
        }
    }

    $EncoderSettings `
        | Add-Member -MemberType NoteProperty -Name VideoFilters -Value $VideoFilters

    return $EncoderSettings
}