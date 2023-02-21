<#
    (en)
    Translation guide:
    Copy the "en" language and edit the strings appropriately
    Unknown strings must be left intact! There's no fallback system (I might add one in the future tho)

    (vi)
    Hướng dẫn dịch:
    Copy phần ngôn ngữ "en" và chỉnh sửa cho phù hợp
    Những phần không dịch được phải được giữ nguyên! Không có hệ thống fallback (Có thể sẽ có trong tương lai)
#>

$Translation = @{
    "en" = @{
# Encoder settings prompts
        "EncoderType" = @"
Select encoder type:
1. CPU (slower, higher quality, limit: 1080p120)
2. GPU (faster, lower quality, limit: 720p60)
"@;
        "EncoderSettings" = "Encoder settings: {0}";
        "GPUSelect" = "Select GPU you want to use:";
        "x264Presets" = @"
Select preset
Preset guide:
- Weak computer: veryfast or faster
- Strong computer: medium or slow
"@;

# Encoder info
        "x264Info" = @"
Using libx264 for encoding
Preset: {0}
Rate control: 2-pass VBR
"@;
        "NVENCInfo" = @"
Using NVIDIA NVENC for encoding
Rate control: VBR High Quality
"@;
        "AMFInfo" = @"
Using AMD AMF for encoding
Rate control: VBR + Pre-Analysis
"@;
        "QSInfo" = @"
Using Intel QuickSync for encoding
Rate control: LA_VBR
"@;

# Processing text
        "ProcessingAudio" = "Processing audio...";
        "ProcessingVideo" = "Processing video...";
        "Muxing" = "Muxing...";
        "Bitrate" = "Bitrate: {0}kbps";
        "VideoFilters" = "Video filters: {0}";
        "CurrentPass" = "Pass {0}/{1}:";

# Video special cases
        "GameDVR" = "Microsoft Game DVR detected, forcing 60fps output";

# Get-Choice strings
        "Choice" = "Choice";
        "Default" = "Default";

# FFmpeg checks
        "DependencySystem" = "Using system {0} at {1}";
        "DependencyLocal" = "Using local {0}";
        "DependencyNotFound" = "{0} not found";
        "FFmpegDownloading" = "Downloading {0}";
        "FFmpegExtracting" = "Extracting";
        "FFmpegFinished" = "Finished downloading";

# Main program
        "DebugMode" = "Debug mode activated. FFmpeg will output extra video information.";
        "VideoPathPrompt" = "Path to video (drag and drop allowed)";
        "InvalidPath" = "Invalid path!";
        "Finished" = @"
Processing finished!
Output file: {0}
"@;
        "Failed" = "Processing failed!";
        "EnterToContinue" = "Press Enter to continue...";

# Updater
        "UpdateAvailable" = "Update available: {0}. Do you want to update?";
        "UpdateFinished" = "Update finished, please re-run the script";
    };
    
    "vi" = @{
# Encoder settings prompts
        "EncoderType" = @"
Chọn loại encoder:
1. CPU (chậm hơn, chất lượng cao hơn, giới hạn: 1080p120)
2. GPU (nhanh hơn, chất lượng thấp hơn, giới hạn: 720p60)
"@;
        "EncoderSettings" = "Cài đặt encoder: {0}";
        "GPUSelect" = "Chọn GPU bạn muốn sử dụng:";
        "x264Presets" = @"
Vui lòng chọn preset
Cách chọn preset:
- Máy yếu: veryfast hoặc faster
- Máy mạnh: medium hoặc slow
"@;

# Encoder info
        "x264Info" = @"
Sử dụng libx264 để encode
Preset: {0}
Rate control: 2-pass VBR
"@;
        "NVENCInfo" = @"
Sử dụng NVIDIA NVENC để encode
Rate control: VBR High Quality
"@;
        "AMFInfo" = @"
Sử dụng AMD AMF để encode
Rate control: VBR + Pre-Analysis
"@;
        "QSInfo" = @"
Sử dụng Intel QuickSync để encode
Rate control: LA_VBR
"@;

# Processing text
        "ProcessingAudio" = "Đang xử lý audio...";
        "ProcessingVideo" = "Đang xử lý video...";
        "Muxing" = "Muxing...";
        "Bitrate" = "Bitrate: {0}kbps";
        "VideoFilters" = "Video filter: {0}";
        "CurrentPass" = "Pass {0}/{1}:";

# Video special cases
        "GameDVR" = "Video từ Microsoft Game DVR, bật force 60fps";

# Get-Choice strings
        "Choice" = "Lựa chọn";
        "Default" = "Mặc định";

# FFmpeg checks
        "DependencySystem" = "Dùng {0} của hệ thống tại {1}";
        "DependencyLocal" = "Dùng {0} đã được tải trước";
        "DependencyNotFound" = "Không tìm thấy {0}";
        "FFmpegDownloading" = "Đang tải {0}";
        "FFmpegExtracting" = "Đang giải nén";
        "FFmpegFinished" = "Đã tải xong";

# Main program
        "DebugMode" = "Đã kích hoạt chế độ debug. FFmpeg sẽ hiển thị thêm thông tin về video.";
        "VideoPathPrompt" = "Đường dẫn đến file video cần xử lý (có thể kéo thả)";
        "InvalidPath" = "Đường dẫn không hợp lệ!";
        "Finished" = @"
Xử lý hoàn tất!
File output: {0}
"@;
        "Failed" = "Xử lý thất bại!";
        "EnterToContinue" = "Bấm Enter để tiếp tục...";

# Updater
        "UpdateAvailable" = "Có phiên bản mới: {0}. Bạn có muốn nâng cấp?";
        "UpdateFinished" = "Nâng cấp hoàn tất, vui lòng chạy lại script";
    };

    "zh" = @{
# Encoder settings prompts
        "EncoderType" = @"
选择编码器类型:
1. CPU (速度慢，高质量，限制: 1080p120)
2. GPU (速度快，低质量，限制: 720p60)
"@;
        "EncoderSettings" = "编码器设置： {0}";
        "GPUSelect" = "选择您要使用的 GPU:";
        "x264Presets" = @"
请选择预设
指导:
- 弱电脑：使用 "veryfast" 或 "faster"
- 强大的电脑：使用 "medium" 或 "slow"
"@;

# Encoder info
        "x264Info" = @"
使用 libx264 进行编码
Preset: {0}
Rate control: 2-pass VBR
"@;
        "NVENCInfo" = @"
使用 NVIDIA NVENC 进行编码
Rate control: VBR High Quality
"@;
        "AMFInfo" = @"
使用 AMD AMF 进行编码
Rate control: VBR + Pre-Analysis
"@;
        "QSInfo" = @"
使用 Intel QuickSync 进行编码
Rate control: LA_VBR
"@;

# Processing text
        "ProcessingAudio" = "正在处理音频...";
        "ProcessingVideo" = "正在处理视频...";
        "Muxing" = "多路复用...";
        "Bitrate" = "Bitrate: {0}kbps";
        "VideoFilters" = "视频过滤器: {0}";
        "CurrentPass" = "Pass {0}/{1}:";

# Video special cases
        "GameDVR" = "检测到 Microsoft 游戏 DVR, 强制 60fps 输出";

# Get-Choice strings
        "Choice" = "选择";
        "Default" = "默认";

# FFmpeg checks
        "DependencySystem" = "在{1}处使用系统 {0}";
        "DependencyLocal" = "使用当地的{0}";
        "DependencyNotFound" = "未找到 {0}";
        "FFmpegDownloading" = "下载 FFmpeg {0}";
        "FFmpegExtracting" = "提取";
        "FFmpegFinished" = "下载完成";
        
# Main program
        "DebugMode" = "调试模式已激活. FFmpeg 将导出额外的视频信息.";
        "VideoPathPrompt" = "视频路径（允许拖放）";
        "InvalidPath" = "无效路径!";
        "Finished" = @"
处理完毕！
输出文件: {0}
"@;
        "Failed" = "处理失败!";
        "EnterToContinue" = "按 Enter 继续...";

# Updater
        "UpdateAvailable" = "新版本可用: {0}. 您要更新吗?";
        "UpdateFinished" = "更新完成，请重启脚本."
    };
}