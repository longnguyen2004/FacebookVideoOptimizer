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
        "Pass1" = "Pass 1:";
        "Pass2" = "Pass 2:";

# Get-Choice strings
        "Choice" = "Choice";
        "Default" = "Default";

# FFmpeg checks
        "FFmpegSystem" = "Using system FFmpeg at {0}";
        "FFmpegLocal" = "Using local FFmpeg";
        "FFmpegNotFound" = "FFmpeg not found";
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
        "Pass1" = "Pass 1:";
        "Pass2" = "Pass 2:";

# Get-Choice strings
        "Choice" = "Lựa chọn";
        "Default" = "Mặc định";

# FFmpeg checks
        "FFmpegSystem" = "Dùng FFmpeg của hệ thống tại {0}";
        "FFmpegLocal" = "Dùng FFmpeg đã được tải trước";
        "FFmpegNotFound" = "Không tìm thấy FFmpeg";
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
    };
}