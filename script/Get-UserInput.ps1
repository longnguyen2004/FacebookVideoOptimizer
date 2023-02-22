function Get-UserInput {
    param(
        [string]   $Prompt,

        [Parameter(Mandatory = $true, ParameterSetName = "Choices")]
        [CmdletBinding(PositionalBinding=$false)]
        [string[]] $Choices,

        [Parameter(ParameterSetName = "Choices")]
        [CmdletBinding(PositionalBinding=$false)]
        [string]   $Default,

        [Parameter(Mandatory = $true, ParameterSetName = "Pattern")]
        [CmdletBinding(PositionalBinding=$false)]
        [string]   $Pattern
    )
    if ($Choices)
    {
        if (-not $Prompt)
        {
            $Prompt = $Strings["Choice"];
        }
        $Prompt += " ($($Choices -join ", "))";
        if ($Default)
        {
            if ($Default -notin $Choices)
            {
                throw "Default choice not in valid choices";
            }
            $Prompt += " ($($Strings["Default"]): $Default)";
        }
        do
        {
            $Choice = Read-Host -Prompt $Prompt;
            if ($Default -and (-not $Choice))
            {
                return $Default;
            }
        }
        while ($Choice -notin $Choices);
        return $Choice;
    }
    if ($Pattern)
    {
        do
        {
            $Answer = Read-Host -Prompt $Prompt;
        }
        while ($Answer -notmatch $Pattern);
        return $Answer;
    }
}