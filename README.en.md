# Facebook Video Optimizer

## Tips for high quality recordings

Never use CBR or VBR for recording. These modes don't adapt the bitrate to the video, which will waste bitrate for simple content (osu!,...) and starve bitrate for complex content (Geometry Dash,...)

Some recommended settings for different encoders:

- x264: CRF 20-23
- NVIDIA NVENC: CQP 20, Preset: Quality, enable Look-ahead and Psycho Visual Tuning
- Intel QuickSync: LA-ICQ 20-23
- AMD AMF: CQP, Quality Preset: Quality, I-frame QP: 20, P-frame QP: 25

This script do NOT increase frame rate (30 -> 60), so the source video must be in 60fps.

## How to download

Click Code -> Download ZIP on the upper right corner

## Prerequisites

- (Windows) Visual C++ Redistributable ([AIO][vc++-aio])
- PowerShell ([Windows][pwsh-win], [macOS][pwsh-macos], [Linux][pwsh-linux])
- Note:
  - Windows 7: The last supported version is 7.2.7 (WYSI!). Download it here ([32][pwsh-7.2.7-32], [64][pwsh-7.2.7-64])

[vc++-aio]: https://github.com/abbodi1406/vcredist/releases
[pwsh-win]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows#msi
[pwsh-macos]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos
[pwsh-linux]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
[pwsh-7.2.7-32]: https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/PowerShell-7.2.7-win-x86.msi
[pwsh-7.2.7-64]: https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/PowerShell-7.2.7-win-x64.msi

## How to run

- Windows: Run `run.en.bat` and follow the instructions
- macOS (soon) & Linux: Run `run.en.sh` and follow the instructions

## Note about console font

If you see this

![Console font warning](/docs/change_console_font/warning.png?raw=true)

You are using Windows 7/8/8.1, and need to change the console font before continuing. Please follow these steps

1. Right click the title bar, and select Properties

![Changing font, figure 1](/docs/change_console_font/1.png?raw=true)

2. Select Consolas or Lucida Console, and click OK

![Changing font, figure 2](/docs/change_console_font/2.png?raw=true)

## Why?

Screen recordings usually have high bitrate, due to the nature of hardware encoders. As such, they'll get processed (badly) by Facebook, which will reduce the quality and frame rate. If the source video's bitrate is below 2000kbps, Facebook will offer a "Source" quality option, which will preserve the original quality of the video (theoretically).

## How?

By using x264 in 2-pass VBR mode, the video will be transcoded to 1800kbps (video) + 128kbps (audio), which will keep the highest quality possible, within the constraints of Facebook.

## Notes

Not all videos can be compressed equally. "Simple" videos (with little motion) is easier to compress than "complex" videos (with lots of motion). Inspect the quality of the output before uploading.
