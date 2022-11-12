# Facebook Video Optimizer

_Looking for English? Click [here](/README.en.md)!_

## Tip để record chất lượng cao

Không bao giờ sử dụng CBR hoặc VBR cho record. Những mode này không điều chỉnh bitrate tương ứng với video, nên sẽ gây thừa bitrate với video đơn giản (osu!,...) và thiếu bitrate với video phức tạp (Geometry Dash,...)

Một số cài đặt khuyên dùng với các loại encoder:

- x264: CRF 20-23
- NVIDIA NVENC: CQP 20, Preset: Quality, bật Look-ahead và Psycho Visual Tuning
- Intel QuickSync: LA-ICQ 20-23
- AMD AMF: CQP, Quality Preset: Quality, I-frame QP: 20, P-frame QP: 25

Script này không tăng frame rate (30 -> 60), vì thế video gốc của bạn phải được quay ở 60fps.

## Cách tải script

Bấm Code -> Download ZIP ở góc trên bên phải

## Yêu cầu

- (Windows) Visual C++ Redistributable ([AIO][vc++-aio])
- PowerShell ([Windows][pwsh-win], [macOS][pwsh-macos], [Linux][pwsh-linux])
- Note:
  - Windows 7: Bản hỗ trợ cuối cùng của PowerShell 7 là 7.2.7 (WYSI!). Tải bản này tại đây ([32][pwsh-7.2.7-32], [64][pwsh-7.2.7-64])

[vc++-aio]: https://github.com/abbodi1406/vcredist/releases
[pwsh-win]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows#msi
[pwsh-macos]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos
[pwsh-linux]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
[pwsh-7.2.7-32]: https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/PowerShell-7.2.7-win-x86.msi
[pwsh-7.2.7-64]: https://github.com/PowerShell/PowerShell/releases/download/v7.2.7/PowerShell-7.2.7-win-x64.msi

## Cách sử dụng

- Windows: Chạy `run.vi.bat` và làm theo hướng dẫn
- macOS (soon) & Linux: Chạy `run.vi.sh` và làm theo hướng dẫn

## Lưu ý về font của console

Nếu bạn thấy thông báo này

![Cảnh báo về font](/docs/change_console_font/warning.png?raw=true)

Bạn đang sử dụng Windows 7/8/8.1, và cần thay đổi font của console trước khi tiếp tục. Hãy thực hiện các bước dưới đây:

1. Nhấp phải vào thanh tiêu đề, chọn Properties

![Đổi font - hình 1](/docs/change_console_font/1.png?raw=true)

2. Chọn một trong 2 font Consolas hoặc Lucida Console, sau đó nhấn OK

![Đổi font - hình 2](/docs/change_console_font/2.png?raw=true)

## Why?

Những video quay màn hình thường sẽ có bitrate cao, do tính chất của hardware encoder. Vì thế, video upload lên Facebook sẽ được xử lý (khá tệ), làm cho chất lượng và frame rate bị giảm. Nếu bitrate của video dưới 2000kbps, Facebook sẽ có tùy chọn chất lượng "Source", giữ lại được chất lượng của video gốc (theo lý thuyết).

## How?

Bằng cách sử dụng x264 với chế độ 2-pass VBR, video sẽ được encode lại với bitrate 1800kbps (video) + 128kbps (audio), giữ được chất lượng cao nhất có thể trong giới hạn của Facebook.

Ngoài ra, bạn cũng có thể sử dụng hardware encoder, nhưng chất lượng sẽ không cao bằng x264.

## Lưu ý

Không phải video nào cũng cho kết quả giống nhau. Những video "đơn giản" (có ít chuyển động) sẽ dễ encode hơn và cho chất lượng cao hơn so với những video "phức tạp" (có nhiều chuyển động). Hãy kiểm tra video đã xử lý trước khi upload.
