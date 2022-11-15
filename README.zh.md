# Facebook Video Optimizer

## 高质量录音的技巧

切勿使用 CBR 或 VBR 进行录制。 这些模式不会使比特率适应视频，这会浪费简单内容的比特率（osu！，...），而浪费比特率来处理复杂的内容（几何冲刺，...）

针对不同编码器的一些推荐设置：

- x264: CRF 20-23
- NVIDIA NVENC: CQP 20, 预设： Quality, 使能够 Look-ahead 和 Psycho Visual Tuning
- Intel QuickSync: LA-ICQ 20-23
- AMD AMF: CQP, 质量预设： Quality, I-frame QP: 20, P-frame QP: 25

此脚本不会增加帧速率 (30 -> 60)，因此源视频必须为 60fps。

## 如何下载

点击右上角的代码 -> 下载 ZIP

## 要求

- (Windows) Visual C++ 可再发行组件 ([AIO][vc++-aio])
- PowerShell ([Windows][pwsh-win], [macOS][pwsh-macos], [Linux][pwsh-linux])
- 笔记：
  - Windows 7: 最后支持的版本是 7.2.7 (WYSI!)。 在这里下载 ([32][pwsh-7.2.7-32], [64][pwsh-7.2.7-64])

[vc++-aio]: https://github.com/abbodi1406/vcredist/releases
[pwsh-win]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows#msi
[pwsh-macos]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos
[pwsh-linux]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
[pwsh-7.2.7-32]: https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/PowerShell-7.2.7-win-x86.msi
[pwsh-7.2.7-64]: https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/PowerShell-7.2.7-win-x64.msi

## 如何运行

- Windows: 运行 `run.zh.bat` 并按照说明进行操作
- macOS (很快) & Linux: 运行 `run.zh.sh` 并按照说明进行操作

## 为什么？

由于硬件编码器的性质，屏幕录制通常具有高比特率。 因此，它们将被 Facebook 处理（严重），这将降低质量和帧速率。 如果源视频的比特率低于 2000kbps，Facebook 将提供“源”质量选项，这将保留视频的原始质量（理论上）。

## 如何？

通过在 2-pass VBR 模式下使用 x264，视频将被转码为 1800kbps（视频）+128kbps（音频），这将在 Facebook 的限制范围内保持尽可能高的质量。

## 笔记

并非所有视频都可以同等压缩。 “简单”视频（运动很少）比“复杂”视频（运动很多）更容易压缩。 在上传之前检查输出的质量。
