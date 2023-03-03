. $PSScriptRoot/Get-UserInput.ps1;
. $PSScriptRoot/Preview.ps1;
function Trim-Video {
    param (
        [Parameter(Mandatory = $true)]
        [string] $InputFile
    )
    $Process = Preview-Video $InputFile;

    $Duration = (& "$FFprobe" -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $InputFile)

    $TimeStart = Get-UserInput -Prompt $Strings["TrimStart"] -Predicate {
        param([string] $time)
        if ("" -eq $time) { return $true; }
        try {
            $seconds = ([timespan]$time).TotalSeconds;
            return $seconds -ge 0 -and $seconds -le $Duration;
        }
        catch {
            return $false;
        }
    }

    $TimeEnd = Get-UserInput -Prompt $Strings["TrimEnd"] -Predicate {
        param([string] $time)
        if ("" -eq $time) { return $true; }
        try {
            $parsed = ([timespan]$time);
            $seconds = $parsed.TotalSeconds;
            return $seconds -ge 0 -and $seconds -le $Duration -and [timespan]$TimeStart -lt $parsed;
        }
        catch {
            return $false;
        }
    }
    Write-Host;
    [void]$Process.CloseMainWindow();
    return ($TimeStart, $TimeEnd);
}