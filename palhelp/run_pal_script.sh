#!/bin/bash

# RCON工具路径
RCON_TOOL="/home/steam/download/rcon-0.10.3-amd64_linux/rcon"
# RCON服务器地址和端口
RCON_ADDRESS="127.0.0.1:25575"
# RCON密码
RCON_PASSWORD="8442562"

# 检查是否提供了命令参数
if [ -z "$1" ]; then
  echo "Usage: $0 <command> [options]"
  exit 1
fi

# 解析命令
COMMAND="$1"
shift # 移除第一个参数，后面的参数向前移动

case "$COMMAND" in
  broadcast)
    CONTENT="$*"
    RCON_COMMAND="broadcast $CONTENT"
    ;;
  shutdown)
    SECONDS="$1"
    INFO="$2"
    RCON_COMMAND="shutdown $SECONDS $INFO"
    ;;
  save)
    RCON_COMMAND="save"
    ;;
  *)
    echo "Unknown command: $COMMAND"
    exit 2
    ;;
esac

# 执行RCON命令
$RCON_TOOL -a $RCON_ADDRESS -p $RCON_PASSWORD "$RCON_COMMAND"