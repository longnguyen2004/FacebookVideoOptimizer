param(
    [switch] $Debug,
    [string] $Language = "vi"
)

. $PSScriptRoot/Localization.ps1
if (-not $Translation.ContainsKey($Language))
{
    throw "Unrecognized language: $Language";
}
$Strings = $Translation[$Language];

$RootDir = Resolve-Path (Join-Path "$PSScriptRoot" "..");

. $PSScriptRoot/Utilities/Get-UserInput.ps1;
. $PSScriptRoot/Utilities/Parse-PathString.ps1
. $PSScriptRoot/Version.ps1
. $PSScriptRoot/Dependencies/Dependencies.ps1

Clear-Host;

if ($Debug)
{
    Write-Host $Strings["DebugMode"];
}

$LogLevel = $Debug ? "verbose" : "error";

. $PSScriptRoot/Encode/Encode.ps1
. $PSScriptRoot/Encode/EncoderSettings.ps1
. $PSScriptRoot/Trim/Trim.ps1

while ($true)
{
    $InputString = Read-Host $Strings["VideoPathPrompt"];
    if (-not $InputString)
    {
        return;
    }
    $InputFiles = Parse-PathString $InputString;
    Write-Host;
    
    Write-Host $Strings["VideoList"];
    $InputFiles | ForEach-Object { Write-Host "- $_" }
    Write-Host $Strings["EnterToContinue"];
    Read-Host;

    $EncodeJobs = $null;
    foreach ($InputFile in $InputFiles)
    {
        Clear-Host;
        Write-Host ($Strings["SettingsForFile"] -f $InputFile);
        $OutputFile = Join-Path (Split-Path -Parent $InputFile) ((Split-Path -LeafBase $InputFile) + " (transcode).mp4");
        if ((Split-Path -Extension "$InputFile") -ne ".avs")
        {
            $TrimTime = Trim-Video "$InputFile";
        }

        $FileInfo = & "$FFprobe" -v quiet -print_format json -show_streams "$InputFile";
        Write-Debug "Stream info:";
        Write-Debug ("`n" + (($FileInfo | ForEach-Object { $_ + "`n" }) -join ""));
        $FileInfo = $FileInfo | ConvertFrom-Json;

        Write-Host $Strings["ProcessingMode"];
        $ProcessingMode = Get-UserInput -Choices 1, 2;

        switch ($ProcessingMode)
        {
            1 { 
                $EncodeJob = [PSCustomObject]@{
                    "Input" = $InputFile;
                    "Output" = $OutputFile;
                    "Mode" = "FileSize";
                    "Trim" = $TrimTime;
                    "Encoder" = Get-EncoderSettings $FileInfo -Mode FileSize;
                }
            }
            2 {
                $EncodeJob = [PSCustomObject]@{
                    "Input" = $InputFile;
                    "Output" = $OutputFile;
                    "Mode" = "Quality";
                    "Trim" = $TrimTime;
                    "Encoder" = Get-EncoderSettings $FileInfo -Mode Quality;
                }
            }
        }
        
        $EncodeJobs += ,$EncodeJob;
    }

    Clear-Host;
    foreach ($Job in $EncodeJobs)
    {
        Write-Host ($Strings["ProcessingFile"] -f $Job.Input);
        $Success = Encode $Job;
        Write-Host ($Success ? ($Strings["Finished"] -f $Job.Output) : $Strings["Failed"]);
        Write-Host;
    }
    Write-Host $Strings["EnterToContinue"];
    Read-Host;
    Clear-Host;
}
