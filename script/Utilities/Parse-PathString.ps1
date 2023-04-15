function Parse-PathString
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $String
    )
    function Generate-Regex
    {
        if ($IsWindows)
        {
            $Separator = '[\\/]';
            $Quote = '"';
            $NamePattern = '[^<>:"\\/|?* ]+';
            $NamePatternQuoted = '[^<>:"\\/|?*]+';
            $RootGroup = "(?:[A-Za-z]:$Separator*)?";
        }
        else
        {
            $Separator = '\/';
            $Quote = "'";
            $NamePattern = '[^/ ]+';
            $NamePatternQuoted = '[^/]+';
            $RootGroup = "${Separator}?";
        }
        $ExtensionPattern = "\.[A-Za-z0-9]+";
        $FolderGroup = "(?:$NamePattern$Separator+)*";
        $FileGroup = "(?:$NamePattern$ExtensionPattern)";
        $FolderGroupQuoted = "(?:$NamePatternQuoted$Separator+)*";
        $FileGroupQuoted = "(?:$NamePatternQuoted$ExtensionPattern)";

        $PathPattern = $RootGroup + $FolderGroup + $FileGroup;
        $PathPatternQuoted = $Quote + $RootGroup + $FolderGroupQuoted + $FileGroupQuoted + $Quote;
        return [regex]"($PathPattern|$PathPatternQuoted)(?=\s+|$)";
    }

    # VS Code pattern
    if ($String -match "^& '(.+)'$")
    {
        $PathMatches = (,$Matches[1] -replace "''","'")
    }
    else
    {
        $PathMatches = (Generate-Regex).Matches($String);
    }
    return $PathMatches |
        ForEach-Object {
            if ($IsWindows -and $_.Value -match '^"(.+)"$')
            {
                return $Matches[1];
            }
            elseif ($_.Value -match "^'(.+)'$")
            {
                return $Matches[1] -replace "'\''", "'"
            }
            else
            {
                return $_;    
            }
        } |
        Where-Object {
            if (-not (Test-Path $_ -PathType Leaf))
            {
                Write-Host ($Strings["InvalidPath"] -f $_)
                return $false;
            }
            return $true;
        }
}
