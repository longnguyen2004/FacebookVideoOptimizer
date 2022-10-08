# Facebook Video Optimizer

## Tip để record chất lượng cao

Không bao giờ sử dụng CBR hoặc VBR cho record, luôn luôn sử dụng CRF/CQ/CQP để source có chất lượng cao nhất có thể.

Script này không tăng frame rate (30 -> 60), vì thế video gốc của bạn phải được quay ở 60fps.

## Cách tải script

Bấm Code -> Download ZIP ở góc trên bên phải

## Yêu cầu

- PowerShell ([Windows][1], [macOS][2], [Linux][3])

[1]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows#msi
[2]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos
[3]: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux

## Cách sử dụng

- Windows: Chạy `run.bat` và làm theo hướng dẫn
- macOS & Linux (soon): Chạy `run.sh` và làm theo hướng dẫn

## Why?

Những video quay màn hình thường sẽ có bitrate cao, do tính chất của hardware encoder. Vì thế, video upload lên Facebook sẽ được xử lý (khá tệ), làm cho chất lượng và frame rate bị giảm. Nếu bitrate của video dưới 2000kbps, Facebook sẽ có tùy chọn chất lượng "Source", giữ lại được chất lượng của video gốc (theo lý thuyết).

## How?

Bằng cách sử dụng x264 với chế độ 2-pass VBR, video sẽ được encode lại với bitrate 1800kbps (video) + 128kbps (audio), giữ được chất lượng cao nhất có thể trong giới hạn của Facebook.

## Lưu ý

Không phải video nào cũng cho kết quả giống nhau. Những video "đơn giản" (có ít chuyển động) sẽ dễ encode hơn và cho chất lượng cao hơn so với những video "phức tạp" (có nhiều chuyển động). Hãy kiểm tra video đã xử lý trước khi upload.
