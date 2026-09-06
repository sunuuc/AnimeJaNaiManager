$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$translator = Join-Path $root 'AnimeJaNaiConfEditor/ChineseLocalization.cs'

# Build-time localization for the personal zh-CN build.
# Unlike the old runtime visual-tree overlay, this rewrites user-visible source text
# before compilation, so the first rendered frame is already Chinese.

function Unescape-CSharpString([string]$s) {
    $s = $s.Replace('\"', '"')
    $s = $s.Replace('\\', "`0")
    $s = $s.Replace('\r', "`r").Replace('\n', "`n").Replace('\t', "`t")
    $s = $s.Replace("`0", '\')
    return $s
}

$map = [ordered]@{}
if (Test-Path $translator) {
    $src = Get-Content $translator -Raw

    # Reuse the translation table that was previously applied at runtime.
    $rxExact = [regex]'\[\"((?:\\.|[^\"])*)\"\]\s*=\s*\"((?:\\.|[^\"])*)\",'
    foreach ($m in $rxExact.Matches($src)) {
        $en = Unescape-CSharpString $m.Groups[1].Value
        $zh = Unescape-CSharpString $m.Groups[2].Value
        if ($en -and -not $map.Contains($en)) { $map[$en] = $zh }
    }

    $rxPhrase = [regex]'\(\"((?:\\.|[^\"])*)\",\s*\"((?:\\.|[^\"])*)\"\),'
    foreach ($m in $rxPhrase.Matches($src)) {
        $en = Unescape-CSharpString $m.Groups[1].Value
        $zh = Unescape-CSharpString $m.Groups[2].Value
        if ($en -and -not $map.Contains($en)) { $map[$en] = $zh }
    }
}

# Text split by XAML inline tags or generated dynamically cannot always be matched by
# the runtime table as a whole sentence. Add source-level fragments explicitly.
$manual = [ordered]@{
    'AnimeJaNai Manager' = 'AnimeJaNai 管理器'
    ' (Default)' = '（默认）'
    'Global Settings' = '全局设置'
    'Default Profiles (Read-only)' = '默认配置（只读）'
    'Custom Profiles' = '自定义配置'
    'Tools' = '工具'
    'Run Benchmarks' = '运行性能测试'
    'Submit to Catalog' = '提交到性能目录'
    'Enable Logging' = '启用日志'
    'Upscaling Backend' = '超分后端'
    'TensorRT Engine Settings' = 'TensorRT 引擎设置'
    'Engine Type' = '引擎类型'
    'Static ONNX' = '静态 ONNX'
    'Static' = '静态'
    'Dynamic' = '动态'
    'Min Resolution' = '最低分辨率'
    'Opt Resolution' = '最佳分辨率'
    'Max Resolution' = '最高分辨率'
    'Builder Optimization Level' = '引擎构建优化等级'
    'GPU Subtitle Rendering (Experimental)' = 'GPU 字幕渲染（实验性）'
    'Import Full Config From File' = '从文件导入完整配置'
    'Export Full Config To File' = '将完整配置导出到文件'
    'Profile Name' = '配置名称'
    'Model Preset' = '模型预设'
    'Standard' = '标准'
    'Sharp' = '锐化'
    'Set as Default Profile in mpv' = '设为 mpv 默认配置'
    'Activation Condition' = '启用条件'
    'Resolution Range' = '分辨率范围'
    'FPS Range' = '帧率范围'
    'Upscale Settings' = '超分设置'
    'Resize Height Before Upscale' = '超分前缩放高度'
    'Resize Factor Before Upscale' = '超分前缩放比例'
    'Open Models Directory' = '打开模型目录'
    'Enable RIFE Interpolation' = '启用 RIFE 补帧'
    'Interpolation Factor' = '补帧倍数'
    'Ensemble' = '集成模式'
    'Scene Detection Threshold' = '转场检测阈值'
    'Interpolate before upscaling' = '先补帧，再超分'
    'Add Chain' = '添加处理链'
    'Add Model' = '添加模型'
    'Components' = '组件'
    'recommended for this PC' = '推荐用于此电脑'
    'Apply changes' = '应用更改'
    'Refresh' = '刷新'
    'installed' = '已安装'
    'optional' = '可选'
    'Remove Chain' = '移除处理链'
    'Remove Model' = '移除模型'
    'Copy Selected Profile To Current Profile' = '将选中配置复制到当前配置'
    'Import Profile Config From File' = '从文件导入配置'
    'Export Profile Config To File' = '将配置导出到文件'

    'The log file is created at' = '日志文件会创建在'
    'in the same directory as this config editor.' = '，位于与本管理器相同的目录。'
    'Fastest option but NVIDIA only.' = '速度最快，但仅支持 NVIDIA。'
    'Supports fp16 and fp32 ONNX models.' = '支持 fp16 和 fp32 ONNX 模型。'
    'fp16 models are recommended for faster performance and reduced VRAM usage without any loss in quality.' = '推荐使用 fp16，可在不损失画质的情况下提升速度并减少显存占用。'
    'The initial engine generation may require several minutes but only needs to be done once.' = '首次生成引擎可能需要几分钟，但只需进行一次。'
    'Compatible with NVIDIA, AMD, and Intel GPUs but slower than TensorRT.' = '兼容 NVIDIA、AMD 和 Intel GPU，但速度慢于 TensorRT。'
    'sharper subtitles.' = '字幕更清晰。'
    'Rendered at your display resolution instead of being baked into the video, so text stays crisp and isn''t distorted by upscaling.' = '字幕会按显示器分辨率单独渲染，而不是先压进视频画面，因此文字更清晰，也不会被超分拉伸变形。'
    'Experimental: may cost some performance or have bugs.' = '实验性功能：可能会损失一些性能，或存在兼容性问题。'
    '(default): fastest and most stable.' = '（默认）：速度最快且最稳定。'
    'Subtitles are baked into the video.' = '字幕会直接合成到视频画面中。'
    'Best for most users.' = '适合大多数用户。'
    'Switching the backend takes effect after you restart the player.' = '切换后端后，需要重启播放器才能生效。'
    'Subtitle rendering changes take effect after you restart the player.' = '字幕渲染设置更改后，需要重启播放器才能生效。'
    'Use this profile by default when launching mpv.' = '启动 mpv 时默认使用此配置。'
    'Profile edits apply when you switch profiles in the player, or after you restart it.' = '修改配置后，在播放器中切换配置或重启播放器即可生效。'
    'Whether or not to run RIFE video frame interpolation.' = '是否启用 RIFE 视频补帧。'
    'Measure your real playback fps (the speed you will actually get) at several resolutions.' = '测试多个分辨率下的实际播放帧率（也就是你真正能获得的速度）。'
    'mpv windows will open and close on their own during the test; leave them alone or the results will be invalid.' = '测试期间 mpv 窗口会自动打开和关闭，请不要操作，否则结果会失效。'
    'Can take 10+ minutes depending on your hardware.' = '根据硬件不同，测试可能需要 10 分钟以上。'
    'Share your latest benchmark results with the community catalog.' = '把最新性能测试结果分享到社区目录。'
    'You''ll see exactly what is sent before anything leaves your machine.' = '发送前会明确显示上传内容。'
    'No account required.' = '不需要账号。'
    'Higher levels (0-5) take longer to build the engine but can produce a faster engine.' = '等级越高（0–5），引擎构建时间越长，但生成的引擎可能更快。'
    'Default is 5.' = '默认值为 5。'
    'Switches this profile between the standard and sharper V3.1 models.' = '在标准 V3.1 模型与更锐利的 V3.1 模型之间切换此配置。'
}
foreach ($k in $manual.Keys) { $map[$k] = $manual[$k] }

# Longest first avoids a short phrase partially consuming a longer sentence.
$entries = $map.GetEnumerator() | Sort-Object { $_.Key.Length } -Descending
$targets = @(
    'AnimeJaNaiConfEditor/Views/MainWindow.axaml',
    'AnimeJaNaiConfEditor/Views/MainWindow.axaml.cs',
    'AnimeJaNaiConfEditor/ViewModels/MainWindowViewModel.cs',
    'AnimeJaNaiConfEditor/ViewModels/ComponentManagerViewModel.cs',
    'AnimeJaNaiConfEditor/Services/BenchmarkSubmission.cs'
)

foreach ($rel in $targets) {
    $path = Join-Path $root $rel
    if (-not (Test-Path $path)) { continue }
    $text = Get-Content $path -Raw
    foreach ($e in $entries) {
        $text = $text.Replace([string]$e.Key, [string]$e.Value)
    }

    # Dynamic StringFormat labels in XAML.
    $text = $text.Replace('StringFormat=Chain {0}', 'StringFormat=处理链 {0}')
    $text = $text.Replace('StringFormat=Model {0}', 'StringFormat=模型 {0}')
    Set-Content -Path $path -Value $text -Encoding utf8
}

Write-Host 'Native zh-CN source localization applied.'

# Diagnostic only: surface likely remaining user-visible English in MainWindow XAML.
$xaml = Join-Path $root 'AnimeJaNaiConfEditor/Views/MainWindow.axaml'
if (Test-Path $xaml) {
    Write-Host '--- Likely remaining English UI lines (technical names may be legitimate) ---'
    $lineNo = 0
    Get-Content $xaml | ForEach-Object {
        $lineNo++
        $line = $_
        if ($line -match '(>[^<]*[A-Za-z]{3,}[^<]*<|\b(Content|Header|Title|Watermark|Text)=\"[^\"]*[A-Za-z]{3,})') {
            if ($line -notmatch '^\s*<!--' -and $line -notmatch 'Binding|Command|ItemsSource|IsVisible|FontFamily') {
                Write-Host ("{0}: {1}" -f $lineNo, $line.Trim())
            }
        }
    }
}
