. $PSScriptRoot/Preview.ps1;
function Trim-Video {
    param (
        [Parameter(Mandatory = $true)]
        [string] $InputFile
    )
    $Process = Preview-Video $InputFile;

    $Duration = (& "$FFprobe" -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $InputFile)

    $TimeStart = Get-UserInput -Prompt $Strings["TrimStart"] -Predicate {
        param([string] $Time)
        if (-not $Time) { return $true; }
        try {
            $Seconds = ([timespan]$Time).TotalSeconds;
            return $Seconds -ge 0 -and $Seconds -le $Duration;
        }
        catch {
            return $false;
        }
    }

    $TimeEnd = Get-UserInput -Prompt $Strings["TrimEnd"] -Predicate {
        param([string] $Time)
        if (-not $Time) { return $true; }
        try {
            $Parsed = ([timespan]$Time);
            $Seconds = $Parsed.TotalSeconds;
            return $Seconds -ge 0         -and
                   $Seconds -le $Duration -and
                   ($TimeStart ? [timespan]$TimeStart -lt $Parsed : $true);
        }
        catch {
            return $false;
        }
    }
    Write-Host;
    [void]$Process.CloseMainWindow();
    return ($TimeStart, $TimeEnd);
}