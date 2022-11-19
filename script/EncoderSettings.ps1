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
    $VideoFilters = (
        "scale=-2:'min(ih,$($EncoderSettings.MaxRes))'",
        "fps='min(source_fps,$($EncoderSettings.MaxFps))'"
    )
    $EncoderSettings `
        | Add-Member -MemberType NoteProperty -Name VideoFilters -Value $VideoFilters

    return $EncoderSettings
}