-- WezTerm 字体配置 (Lua)
-- 复制此片段到 WezTerm 配置中:
--   通常位于 ~/.config/wezterm/wezterm.lua

-- 字体配置
local config = {}

-- 主字体（英文 + 图标）
config.font = wezterm.font("JetBrains Mono Nerd Font")

-- 中文 CJK 回退
config.font_rules = {
    -- 可选: 为不同 Unicode 区块指定不同字体
}

-- 额外字体（自动回退到 CJK）
config.font_overrides = {
    "JetBrains Mono Nerd Font",
    "Noto Sans CJK SC",
}

-- 字体大小
config.font_size = 12.0

-- 如果已加载 wezterm 配置，合并字体设置
-- 实际使用时请将此配置合并到现有的 wezterm.lua 中
