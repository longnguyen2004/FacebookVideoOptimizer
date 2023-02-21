function Expand-Archive-Enhanced {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Path,

        [Parameter(Position = 1)]
        [string] $DestinationPath = ""
    )
    if ("" -eq $DestinationPath)
    {
        $DestinationPath = Split-Path -Parent (Resolve-Path $Path);
    }
    New-Item -ItemType Directory $DestinationPath -Force | Out-Null;
    switch -wildcard (Split-Path -Leaf $Path)
    {
        "*.zip"
        {
            Expand-Archive $Path $DestinationPath -Force;
        }
        "*.7z"
        {
            & "$7zip" x -y "-o$DestinationPath" "$Path";
        }
        "*.tar.*"
        {
            tar -xf "$Path" -C "$DestinationPath"
        }
    }
}