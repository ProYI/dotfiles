#!/bin/bash
# Docker 环境变量

# DOCKER_HOST 支持（远程 Docker 连接）
# 取消注释并修改以连接远程 Docker daemon
# export DOCKER_HOST="ssh://user@host"

# DOCKER_BUILDKIT 启用构建优化
export DOCKER_BUILDKIT=1

# docker-compose 使用 v2 插件
export COMPOSE_DOCKER_CLI_BUILD=1
