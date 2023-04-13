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
. $PSScriptRoot/Version.ps1
. $PSScriptRoot/Dependencies/Dependencies.ps1

if ($Debug)
{
    Write-Host $Strings["DebugMode"];
}

$LogLevel = $Debug ? "verbose" : "error";

. $PSScriptRoot/Encode/Encode.ps1
. $PSScriptRoot/Trim/Trim.ps1

while ($true)
{
    $InputFile = Read-Host $Strings["VideoPathPrompt"];
    if (-not $InputFile)
    {
        Write-Host;
        return;
    }

    # PowerShell drag-and-drop paths
    if ($InputFile -match "^& '(.+)'$")
    {
        $InputFile = $Matches[1] -replace "''","'"
    }
    # Windows Terminal drag-and-drop paths
    elseif ($InputFile -match '^"(.+)"$')
    {
    	$InputFile = $Matches[1]
    }

    if (-not (Test-Path $InputFile -PathType Leaf))
    {
        Write-Error $Strings["InvalidPath"];
        continue;
    }
    Write-Host;

    if ((Split-Path -Extension "$InputFile") -ne ".avs")
    {
        $TimeStart, $TimeEnd = Trim-Video "$InputFile";
    }

    $VideoBitrate = 1800;
    $AudioBitrate = 128;

    $OutputFile = Join-Path (Split-Path -Parent $InputFile) ((Split-Path -LeafBase $InputFile) + " (transcode).mp4");

    $Success = Encode "$InputFile" "$OutputFile" -TimeStart $TimeStart -TimeEnd $TimeEnd;
    Write-Host ($Success ? ($Strings["Finished"] -f $OutputFile) : $Strings["Failed"]);
    Write-Host;
    Write-Host $Strings["EnterToContinue"];
    Read-Host;
    Clear-Host;
}
