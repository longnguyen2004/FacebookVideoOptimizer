function Get-EncoderSettings
{
    param(
        [string] $InputFile
    )
    . $PSScriptRoot/EncoderSettings-Software.ps1;
    . $PSScriptRoot/EncoderSettings-Hardware.ps1;

    $VideoInfo = & "$FFprobe" -v quiet -print_format json -show_format -show_streams "$InputFile";
    Write-Debug "ffprobe output:";
    Write-Debug ("`n" + (($VideoInfo | % { $_ + "`n" }) -join ""));
    $VideoInfo = $VideoInfo | ConvertFrom-Json;

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

    # Trust the user if they're using AviSynth
    if ((Split-Path -Extension "$InputFile") -ne ".avs")
    {
        $VideoFilters = (
            "scale=-2:'min(ih,$MaxRes)'",
            "fps='min(source_fps, $MaxFps)'"
        )
    }

    $EncoderSettings `
        | Add-Member -MemberType NoteProperty -Name VideoFilters -Value $VideoFilters

    return $EncoderSettings
}