param(
    [switch] $Debug,
    [string] $Language = "vi"
)

. $PSScriptRoot/Localization.ps1
if (-not $Translation.ContainsKey($Language))
{
    throw "Unrecognized language: $Language";
}
$Strings = $Translation[$Language];

$RootDir = Resolve-Path (Join-Path "$PSScriptRoot" "..");

. $PSScriptRoot/Utilities/Get-UserInput.ps1
. $PSScriptRoot/Utilities/Parse-PathString.ps1
. $PSScriptRoot/Utilities/Get-VideoInfo.ps1
. $PSScriptRoot/Version.ps1
. $PSScriptRoot/Dependencies/Dependencies.ps1

Clear-Host;

if ($Debug)
{
    Write-Host $Strings["DebugMode"];
}

$LogLevel = $Debug ? "verbose" : "error";

. $PSScriptRoot/Encode/Encode.ps1
. $PSScriptRoot/Encode/EncoderSettings.ps1
. $PSScriptRoot/Trim/Trim.ps1
. $PSScriptRoot/Bitstream/BitstreamHack.ps1

while ($true)
{
    $InputString = Read-Host $Strings["VideoPathPrompt"];
    if (-not $InputString)
    {
        return;
    }
    $InputFiles = Parse-PathString $InputString;
    Write-Host;
    
    Write-Host $Strings["VideoList"];
    $InputFiles | ForEach-Object { Write-Host "- $_" }
    Write-Host $Strings["EnterToContinue"];
    Read-Host;

    $EncodeJobs = $null;
    foreach ($InputFile in $InputFiles)
    {
        Clear-Host;
        Write-Host ($Strings["SettingsForFile"] -f $InputFile);
        $OutputFile = Join-Path (Split-Path -Parent $InputFile) ((Split-Path -LeafBase $InputFile) + " (processed).mp4");
        if ((Split-Path -Extension "$InputFile") -ne ".avs")
        {
            $TrimTime = Trim-Video "$InputFile";
        }
		else
		{
			$TrimTime = ($null, $null);
		}

        $FileInfo = Get-VideoInfo $InputFile

        Write-Host $Strings["ProcessingMode"];
        $ProcessingMode = Get-UserInput -Choices 1, 2;
        Write-Host;

        switch ($ProcessingMode)
        {
            1 { 
                $EncodeJob = [PSCustomObject]@{
                    "Input" = $InputFile;
                    "Output" = $OutputFile;
                    "Mode" = "FileSize";
                    "Trim" = $TrimTime;
                    "Encoder" = [PSCustomObject]@{
                        Video = Get-EncoderSettings-Video -Mode FileSize $FileInfo.streams[0];
                        Audio = Get-EncoderSettings-Audio -Mode FileSize;
                    }
                }
            }
            2 {
                $NoTrim = -not $TrimTime[0] -and -not $TrimTime[1];
                $SkipVideo =
                    $NoTrim                                    -and
                    $FileInfo.streams[0].codec_name -eq "h264" -and
                    (Invoke-Expression $FileInfo.streams[0].r_frame_rate) -le 120;
                $SkipAudio = $NoTrim -and $FileInfo.streams[1].codec_name -eq "aac";
                $EncodeJob = [PSCustomObject]@{
                    "Input" = $InputFile;
                    "Output" = $OutputFile;
                    "Mode" = "Quality";
                    "Trim" = $TrimTime;
                    "Encoder" = [PSCustomObject]@{
                        Video = $SkipVideo ? $null
                            : (Get-EncoderSettings-Video -Mode Quality $FileInfo.streams[0])
                        Audio = $SkipAudio ? $null
                            : (Get-EncoderSettings-Audio -Mode Quality)
                    }
                }
            }
        }
        $EncodeJobs += ,$EncodeJob;
    }

    Clear-Host;
    foreach ($Job in $EncodeJobs)
    {
        Write-Host ($Strings["ProcessingFile"] -f $Job.Input);
        $Success = Encode $Job;
        if (-not $Success)
        {
            Write-Host $Strings["Failed"];
            continue;
        }
        if ($Job.Mode -eq "Quality")
        {
            Apply-BitstreamHack $Job.Output $Job.Output;
        }
        Write-Host ($Strings["Finished"] -f $Job.Output);
        Write-Host;
    }
    Write-Host $Strings["EnterToContinue"];
    Read-Host;
    Clear-Host;
}
