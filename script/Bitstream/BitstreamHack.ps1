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

    $Patches = @();

    Write-Debug "[BitrateHack] Getting all atoms...";
    $Atoms = Get-Mp4Atoms $Stream;

    $Mvhd = $Atoms | Where-Object -Property "Name" -EQ "mvhd";
    if (-not $Mvhd)
    {
        throw "mvhd atom not found. Your file is corrupt";
    }

    $Tkhd = $Atoms | Where-Object -Property "Name" -EQ "tkhd";
    if (-not $Tkhd)
    {
        throw "tkhd atom not found. Your file is corrupt";
    }

    $Patches += $Mvhd | ForEach-Object {
        [PSCustomObject]@{
            Offset = $_.Offset + 32;
            Data = $DurationAsBytes;
            Skip = 4;
        }
    }
    $Patches += $Tkhd | ForEach-Object {
        [PSCustomObject]@{
            Offset = $_.Offset + 28;
            Data = $DurationAsBytes;
            Skip = 4;
        }
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