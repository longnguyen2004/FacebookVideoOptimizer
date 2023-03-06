$Version = 20230306
$PatchLevel = 0
$FullVersion = "$Version.$PatchLevel"

. $PSScriptRoot/Get-UserInput.ps1;

Write-Host "Facebook Video Optimizer v$FullVersion"
Write-Host;

$ProgressPreference = "SilentlyContinue";

if ((Test-NetConnection))
{
    $LatestVersion = (Invoke-RestMethod "https://api.github.com/repos/longnguyen2004/FacebookVideoOptimizer/tags")[0];
    if ([System.Version]$LatestVersion.name -gt [System.Version]$FullVersion)
    {
        Write-Host ($Strings["UpdateAvailable"] -f $LatestVersion.name);
        if ((Get-UserInput -Choices "Y","N") -eq "Y")
        {
            $TempPath = [System.IO.Path]::GetTempPath();
            $ZipPath = Join-Path "$TempPath" "update.zip";
            Invoke-WebRequest $LatestVersion.zipball_url -OutFile "$ZipPath";
            Expand-Archive -LiteralPath "$ZipPath" -DestinationPath "$TempPath";
            $Folder = Join-Path "$TempPath" "longnguyen2004-FacebookVideoOptimizer-*";
            Get-ChildItem "$PSScriptRoot/../*" -Exclude "tools" | Remove-Item -Recurse -Force;
            Move-Item (Join-Path "$Folder" "*") -Destination "$PSScriptRoot/..";
            Remove-Item -Recurse -Force "$Folder";
            Remove-Item -Force "$ZipPath";
            Write-Host $Strings["UpdateFinished"];
            Read-Host;
            [Environment]::Exit(0);
        }
    }
}

$ProgressPreference = "Continue";
