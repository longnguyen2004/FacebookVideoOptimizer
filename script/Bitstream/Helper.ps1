function Find-FirstOccurence
{
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileStream]$Stream,

        [Parameter(Mandatory=$true)]
        [byte[]]$Data,

        [switch]$SeekToBeginning
    )
    $i = 0;
    $Position = -1;
    while (-1 -ne ($Byte = $Stream.ReadByte()))
    {
        if ($Data[$i] -eq $Byte)
        {
            $i++;
            if ($i -eq $Data.Count)
            {
                $Position = $Stream.Position - $Data.Count;
                break;
            }
        }
        else
        {
            $i = 0;
        }
    }
    if ($SeekToBeginning)
    {
        $Stream.Seek(0, [System.IO.SeekOrigin]::Begin);
    }
    return $Position;
}

function Copy-StreamWithPatches
{
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileStream]$Input,

        [Parameter(Mandatory=$true)]
        [System.IO.FileStream]$Output,

        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$Patches
    )
    # Sort the patches by offset
    $Patches = $Patches | Sort-Object -Property Offset;

    # Seek to beginning
    $Input.Seek(0, [System.IO.SeekOrigin]::Begin);

    foreach ($Patch in $Patches)
    {
        # Copy bytes from before the patch point
        $Count = $Patch.Offset - $Input.Position;
        $Bytes = [byte[]]::new($Count);
        $Input.Read($Bytes);
        $Output.Write($Bytes);

        # Write the new bytes in
        $Output.Write($Patch.Data);

        # Advance the input by the number of skip bytes
        $Input.Seek($Patch.Skip, [System.IO.SeekOrigin]::Current);
    }

    # Copy the rest of the data
    $Input.CopyTo($Output);
}