function Get-Mp4Atoms
{
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileStream]$Stream,

        [int]$End = $Stream.Length
    )
    $Atoms = $null;
    $SizeBytes = [byte[]]::new(4);
    $NameBytes = [byte[]]::new(4);
    while ($End -eq -1 -or $Stream.Position -lt $End)
    {
        # Read size, break the loop if can't read
        if (4 -ne ($BytesRead = $Stream.Read($SizeBytes)))
        {
            [void]$Stream.Seek(-$BytesRead, [System.IO.SeekOrigin]::Current);
            break;
        }
        $Size = [System.Buffers.Binary.BinaryPrimitives]::ReadInt32BigEndian($SizeBytes);

        # Check if size is sane
        if ($Size -lt 8 -or $Stream.Position + $Size - 4 -gt $End)
        {
            [void]$Stream.Seek(-4, [System.IO.SeekOrigin]::Current);
            break;
        }

        # Read name
        if (4 -ne ($BytesRead = $Stream.Read($NameBytes)))
        {
            [void]$Stream.Seek(-4 -$BytesRead, [System.IO.SeekOrigin]::Current);
            break;
        }
        $Name = [System.Text.Encoding]::ASCII.GetString($NameBytes, 0, 4);

        # Check if name is compliant
        if ($Name -notmatch "[a-z0-9]{4}")
        {
            [void]$Stream.Seek(-8, [System.IO.SeekOrigin]::Current);
            break;
        }
        
        $Offset = $Stream.Position - 8;
        $Atom = [PSCustomObject]@{
            Offset = $Offset;
            Size = $Size;
            Name = $Name;
        };
        Write-Debug "Found atom $Name, size $Size at $Offset";
        $Atoms += (,$Atom);

        # Attempt to read child atoms
        if ($ChildAtoms = Get-Mp4Atoms $Stream ($Offset + $Size))
        {
            # Found child atoms, add to the list
            $Atoms += $ChildAtoms;
        }
        else
        {
            # No child atoms, skip the data
            [void]$Stream.Seek($Offset + $Size, [System.IO.SeekOrigin]::Begin);
        }
    }
    return $Atoms;
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
    [void]$InputStream.Seek(0, [System.IO.SeekOrigin]::Begin);

    $BufferSize = 81920; # Taken from C# CopyTo buffer size
    $Buffer = [byte[]]::new($BufferSize);
    foreach ($Patch in $Patches)
    {
        # Copy bytes from before the patch point
        $Count = $Patch.Offset - $InputStream.Position;
        while ($Count -gt 0)
        {
            $NumBytes = [System.Math]::Min($Count, $BufferSize);
            [void]$InputStream.Read($Buffer, 0, $NumBytes);
            $OutputStream.Write($Buffer, 0, $NumBytes);
            $Count -= $NumBytes;
        }

        # Write the new bytes in
        $OutputStream.Write($Patch.Data);

        # Advance the input by the number of skip bytes
        [void]$InputStream.Seek($Patch.Skip, [System.IO.SeekOrigin]::Current);
    }

    # Copy the rest of the data
    $InputStream.CopyTo($OutputStream);
}