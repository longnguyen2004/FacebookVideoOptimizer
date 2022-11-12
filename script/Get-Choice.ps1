function Get-Choice {
    param(
        [string]   $Prompt = $Strings["Choice"],
        [object[]] $Choices,
        [object]   $Default
    )
    if ($Choices -and $Default -and $Default -notin $Choices)
    {
        throw "Default choice not in valid choices";
    }
    if ($Choices)
    {
        $Prompt += " ($($Choices -join ", "))";
    }
    if ($Default)
    {
        $Prompt += " ($($Strings["Default"]): $Default)";
    }
    do
    {
        $Choice = Read-Host -Prompt $Prompt;
        if ($Default -and (-not $Choice))
        {
            $Choice = $Default;
            break;
        }
    }
    while ($Choices ? $Choice -notin $Choices : $false);
    return $Choice;
}