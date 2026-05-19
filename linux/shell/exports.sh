#!/bin/bash
# Linux 通用环境变量

# 如果使用 systemd
export SYSTEMD_PAGER=''

# XDG 基础目录
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
