. $PSScriptRoot/Helper.ps1

function Apply-BitrateHack
{
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileStream]$Stream
    )
    # Convert stream size to kilobits, then divide by 2000 (max Facebook bitrate)
    Write-Debug "[BitrateHack] Calculating new duration...";
    $Duration = [System.Math]::Ceiling($Stream.Length * 8 / 1000 / 2000) * 1000;
    $DurationAsBytes = [byte[]]::new(4);
    [System.Buffers.Binary.BinaryPrimitives]::WriteInt32BigEndian($DurationAsBytes, $Duration);

    $Patches = $null;

    # Find the offset of the mvhd atom
    Write-Debug "[BitrateHack] Finding mvhd atom...";
    $Mvhd = Find-FirstOccurence $Stream ([System.Text.Encoding]::ASCII).GetBytes("mvhd");
    if (-1 -eq $Mvhd)
    {
        throw "Cannot find mvhd atom. Your file is corrupt.";
    }
    $Patches += (,
        [PSCustomObject]@{
            Offset = $Mvhd + 20;
            Skip = 4;
            Data = $DurationAsBytes
        }
    )

    Write-Debug "[BitrateHack] Finding tkhd atoms...";
    $TkhdCount = 0;
    while (-1 -ne ($Tkhd = Find-FirstOccurence $Stream ([System.Text.Encoding]::ASCII).GetBytes("tkhd")))
    {
        $TkhdCount++;
        $Patches += (,
            [PSCustomObject]@{
                Offset = $Tkhd + 24;
                Skip = 4;
                Data = $DurationAsBytes
            }
        )
    }
    if (0 -eq $TkhdCount)
    {
        throw "Cannot find tkhd atom. Your file is corrupt.";
    }
    return $Patches;
}

function Apply-BitstreamHack
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$InputFile,

        [Parameter(Mandatory=$true)]
        [string]$OutputFile
    )
    $InputStream = [System.IO.FileStream]::new($InputFile, [System.IO.FileMode]::Open);

    if ($InputFile -eq $OutputFile)
    {
        $TempFile = Join-Path ([System.IO.Path]::GetTempPath()) "temp.mp4";
        $OutputStream = [System.IO.FileStream]::new($TempFile, [System.IO.FileMode]::Create);
    }
    else
    {
        $OutputStream = [System.IO.FileStream]::new($OutputFile, [System.IO.FileMode]::Create);
    }

    $Patches = $null;
    $Patches += Apply-BitrateHack $InputStream;

    Copy-StreamWithPatches $InputStream $OutputStream $Patches;
    $InputStream.Close();
    $OutputStream.Close();

    if ($InputFile -eq $OutputFile)
    {
        Move-Item $TempFile $OutputFile -Force;
    }
}