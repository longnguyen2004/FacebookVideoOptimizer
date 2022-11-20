$Version = 20221120
$PatchLevel = 1
$FullVersion = "$Version.$PatchLevel"

. $PSScriptRoot/Get-Choice.ps1;

Write-Host "Facebook Video Optimizer v$FullVersion"
Write-Host;

$ProgressPreference = "SilentlyContinue";

if ((Test-NetConnection))
{
    $LatestVersion = (Invoke-RestMethod "https://api.github.com/repos/longnguyen2004/FacebookVideoOptimizer/tags")[0];
    if ([System.Version]$LatestVersion.name -gt [System.Version]$FullVersion)
    {
        Write-Host ($Strings["UpdateAvailable"] -f $LatestVersion.name);
        if ((Get-Choice -Choices "Y","N") -eq "Y")
        {
            $TempPath = [System.IO.Path]::GetTempPath();
            $ZipPath = Join-Path "$TempPath" "update.zip";
            Invoke-WebRequest $LatestVersion.zipball_url -OutFile "$ZipPath";
            Expand-Archive -LiteralPath "$ZipPath" -DestinationPath "$TempPath";
            $Folder = Join-Path "$TempPath" "longnguyen2004-FacebookVideoOptimizer-*";
            Remove-Item -Recurse -Force "$PSScriptRoot/../*" -Exclude "ffmpeg";
            Move-Item (Join-Path "$Folder" "*") -Destination "$PSScriptRoot/..";
            Remove-Item -Recurse -Force "$Folder";
            Remove-Item -Force "$ZipPath";
            Write-Host $Strings["UpdateFinished"];
            Read-Host;
            exit;
        }
    }
}

$ProgressPreference = "Continue";
