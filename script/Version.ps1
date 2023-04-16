$Version = 20230329
$PatchLevel = 0
$FullVersion = "$Version.$PatchLevel"

Write-Host "Facebook Video Optimizer v$FullVersion"
Write-Host;

$ProgressPreference = "SilentlyContinue";

if ((Test-NetConnection))
{
    $LatestVersion = (Invoke-RestMethod "https://api.github.com/repos/longnguyen2004/FacebookVideoOptimizer/tags")[0].name;
    if ([System.Version]$LatestVersion -gt [System.Version]$FullVersion)
    {
        Write-Host ($Strings["UpdateAvailable"] -f $LatestVersion);
        if ((Get-UserInput -Choices "Y","N") -eq "Y")
        {
            $TempPath = [System.IO.Path]::GetTempPath();
            $ZipPath = Join-Path "$TempPath" "update.zip";
            Invoke-WebRequest "https://github.com/longnguyen2004/FacebookVideoOptimizer/archive/refs/tags/${LatestVersion}.zip" -OutFile "$ZipPath";
            Expand-Archive -LiteralPath "$ZipPath" -DestinationPath "$TempPath";
            $Folder = Join-Path "$TempPath" "FacebookVideoOptimizer-$LatestVersion";
            Get-ChildItem "$RootDir/*" -Exclude "tools" | Remove-Item -Recurse -Force;
            Move-Item (Join-Path "$Folder" "*") -Destination "$RootDir";
            Remove-Item -Recurse -Force "$Folder";
            Remove-Item -Force "$ZipPath";
            Write-Host $Strings["UpdateFinished"];
            Read-Host;
            [Environment]::Exit(0);
        }
    }
}

$ProgressPreference = "Continue";
