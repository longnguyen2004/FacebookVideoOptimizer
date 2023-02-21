function Check-Dependency {
    param (
        [string]
        $Name,
        [string[]]
        $Executables,

        $DownloadFunction
    )

    $ExecSystem = @($Executables | ForEach-Object { Get-Command $_ -ErrorAction SilentlyContinue });
    if ($ExecSystem.Count -eq $Executables.Count) {
        $ExecSystem = $ExecSystem | ForEach-Object { $_.Source };
        Write-Host ($Strings["DependencySystem"] -f $Name, ($ExecSystem -join ", "));
        return $ExecSystem;
    }

    $ExecLocalDir = Join-Path "$PSScriptRoot" ".." "tools" $Name.ToLower();
    $ExecLocal = @($Executables | ForEach-Object { Get-Command (Join-Path $ExecLocalDir $_) -ErrorAction SilentlyContinue });
    if ($ExecLocal.Count -eq $Executables.Count) {
        $ExecLocal = $ExecLocal | ForEach-Object { $_.Source };
        Write-Host ($Strings["DependencyLocal"] -f $Name);
        return $ExecLocal;
    }

    Write-Host ($Strings["DependencyNotFound"] -f $Name);
    & $DownloadFunction $ExecLocalDir;
    return $Executables | ForEach-Object { Join-Path $ExecLocalDir $_ };
}
