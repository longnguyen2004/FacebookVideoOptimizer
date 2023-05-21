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
        [System.IO.FileStream]$InputStream,

        [Parameter(Mandatory=$true)]
        [System.IO.FileStream]$OutputStream,

        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$Patches
    )
    # Sort the patches by offset
    $Patches = $Patches | Sort-Object -Property Offset;

    # Seek to beginning
    $InputStream.Seek(0, [System.IO.SeekOrigin]::Begin);

    $BufferSize = 81920; # Taken from C# CopyTo buffer size
    $Buffer = [byte[]]::new($BufferSize);
    foreach ($Patch in $Patches)
    {
        # Copy bytes from before the patch point
        $Count = $Patch.Offset - $InputStream.Position;
        while ($Count -gt 0)
        {
            $NumBytes = [System.Math]::Min($Count, $BufferSize);
            $InputStream.Read($Buffer, 0, $NumBytes);
            $OutputStream.Write($Buffer, 0, $NumBytes);
            $Count -= $NumBytes;
        }

        # Write the new bytes in
        $OutputStream.Write($Patch.Data);

        # Advance the input by the number of skip bytes
        $InputStream.Seek($Patch.Skip, [System.IO.SeekOrigin]::Current);
    }

    # Copy the rest of the data
    $InputStream.CopyTo($OutputStream);
}