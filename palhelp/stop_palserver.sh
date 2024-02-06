#!/bin/bash

# 路径到run_pal_script.sh脚本
RUN_PAL_SCRIPT="/home/steam/palhelp/run_pal_script.sh"

"$RUN_PAL_SCRIPT" broadcast "InitialAutoRebootScript."

# 广播初始化自动重启消息并保存游戏进度
"$RUN_PAL_SCRIPT" broadcast "PrepareToSaveGameProgress."

# 保存游戏进度
"$RUN_PAL_SCRIPT" save

# 广播保存游戏进度成功消息
"$RUN_PAL_SCRIPT" broadcast "SaveGameProgressSuccess."

# 执行关闭服务器命令（不阻塞），传递两个参数：等待时间和广播信息
"$RUN_PAL_SCRIPT" shutdown "60" "WARNING!!ServerIsShuttingDownNow."

# 广播保存游戏进度成功消息
"$RUN_PAL_SCRIPT" broadcast "WARNING!!PleaseExitGameNow."

# 总倒计时时间（秒）
TOTAL_SHUTDOWN_TIME=60
# 每次广播间隔（秒）
BROADCAST_INTERVAL=5

# 等待一小段时间再开始倒计时，确保关闭指令已发送
sleep $BROADCAST_INTERVAL

# 倒计时广播
for (( i=$TOTAL_SHUTDOWN_TIME-$BROADCAST_INTERVAL; i>0; i-=$BROADCAST_INTERVAL ))
do
  # 广播倒计时消息
  remaining=$((i))
  remaining=$((remaining > 0 ? remaining : 0)) # 确保倒计时不会出现负数
  "$RUN_PAL_SCRIPT" broadcast "!!WARNING!!${remaining}secUntilServerShutdown."
  sleep $BROADCAST_INTERVAL
done