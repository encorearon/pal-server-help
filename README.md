# PAL服务器架设（CentOS）


## 安装steamcmd

- 新增系统steam用户账号（非steam账号）
```
sudo useradd -m steam
sudo passwd steam
sudo -u steam -s
cd /home/steam
```
- centos下将steam账号加入sudo组
```
sudo usermod -aG wheel steam
```

- 切换为steam
```
su steam
```
- 安装gcc
sudo yum install glibc.i686 libstdc++.i686

- 创建Steam目录
```
mkdir ~/Steam && cd ~/Steam
```
- 下载并解压
```
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
```

- 执行SteamCMD
```
cd ~/Steam
./steamcmd.sh
```

## 安装PAL
内容源自https://tech.palworldgame.com/dedicated-server-guide

- 安装pal
```
steamcmd +login anonymous +app_update 2394010 validate +quit
```
- 启动
```
cd ~/Steam/steamapps/common/PalServer
./PalServer.sh
```

正常来说都会缺一个steamclient.so的文件：
```
.steam/sdk64/steamclient.so: cannot open shared object file: No such file or directory
```
执行一下这个命令

```mkdir -p ~/.steam/sdk64/
steamcmd +login anonymous +app_update 1007 +quit
cp ~/Steam/steamapps/common/Steamworks\ SDK\ Redist/linux64/steamclient.so ~/.steam/sdk64/
```

或者直接
```
mkdir -p ~/.steam/sdk64/
cp ~/Steam/steamapps/common/PalServer/steamclient.so ~/.steam/sdk64/
```

## 安装RCON工具
rcon是valve公司的一个游戏通讯协议，帕鲁通过PalWorldSettings.ini中的RCONEnabled来开启，RCONPort设定其通讯端口。

这里使用 [gorcon/rcon-cli](https://github.com/gorcon/rcon-cli)  提供的一个客户端实现。

```
wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz | tar zxvf -
```

使用方法
```
./rcon -a 127.0.0.1:25575 -p mypassword broadcast "hello_world"
```
其中
- 「127.0.0.1 」是服务器地址
- 「mypassword」是帕鲁的admin密码，在PalWorldSettings.ini中通过AdminPassword设定
- 「25575」是PalWorldSettings.ini中RCONPort设定端口，Pal默认配置文件里就是25575
- broadcast是帕鲁的admin命令，具体可以查帕鲁的admin命令表

## 配置PalWorldSetting.ini
直接用目录下提供的PalWorldSettings.ini 覆盖 
```
/home/steam/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer
```
下的文件，其中要修改一下
- RCONEnabled 设置为True，表示打开RCON
- RCONPort 25575
- ServerPassword 服务器密码，一定要设置
- PublicPort 服务器连接端口，协议是UDP，用云服务器的话一定要打开对应入口放洗那个对应端口的UDP流量（如使用阿里云，设定端口为8211，那就到阿里云的安全组中，放行入口流量-》8211-》UDP协议）
- AdminPassword admin密码，一定要设置用来RCON通讯

其他按需要设置（经验倍率等）

## 运维脚本
帕鲁的内存优化极差，一般一天3人游戏可以称爆16GB内存，最好定时重启一下。重启一定要注意不要直接ctrl+c来结束服务，这里提供几个screen+RCON的脚本来处理.

将palhelp复制到/home/steam下
- start_palserver.sh 用screen启动一个PalServer
- stop_palserver.sh 用rcon停止帕鲁。停止时候会广播一个停止消息和触发服务器存储，并在接下来的60秒倒计时结束后停止服务。
- update_palserver.sh 启动steam并更新帕鲁的服务器程序
- run_pal_script.sh包了一下帕鲁的RCON命令。

复制完毕（或者自己vi创建），需要对目录下所有脚本赋予可执行权限
```
chmod +x ~/palhelp/*
```

启动服务器时候，切换steam用户身份(下同)
```
su steam
```
并进入palhelp目录

```
cd ~/palhelp
./start_palserver.sh
```
或
```
/home/steam/palhelp/start_palserver.sh
```
同理，stop_palserver.sh

```
cd ~/palhelp
./stop_palserver.sh
```
或

```
/home/steam/palhelp/stop_palserver.sh
```

### 定期重启&存档备份
帕鲁服务器容易内存溢出，价值联机存档没有开启自动备份，很容易炸，这里给出一个简单的crontab任务来开启定时备份。在steam身份下，执行
```
crontab -e
```
在vi界面下输入
```
# 每天6:10 PM重新启动PalServer.sh
10 18 * * * /home/steam/palhelp/start_palserver.sh

# 每天6:00 PM终止PalServer.sh
0 18 * * * /home/steam/palhelp/stop_palserver.sh

# 每15分钟备份存档
*/15 * * * * /bin/bash -c 'rsync -av /home/steam/Steam/steamapps/common/PalServer/Pal/Saved/SaveGames/ /home/steam/pal-save-bk/$(date +\%Y-\%m-\%d-\%H\%M)/'
```

按需修改。备份出来的存档可以直接覆盖回原来的SaveGames并重启游戏来回档。


## 附录

| Command                | Description                                                                                                      |
|------------------------|------------------------------------------------------------------------------------------------------------------|
| `/Shutdown {Seconds} {MessageText}` | Gracefully shuts down server with an optional timer and/or message to notify players in your server.            |
| `/DoExit`              | Forcefully shuts down the server immediately. It is not recommended to use this option unless you've got a technical problem or are okay with potentially losing data. |
| `/Broadcast {MessageText}` | Broadcasts a message to all players in the server.                                                              |
| `/KickPlayer {PlayerUID or SteamID}` | Kicks player from the server. Useful for getting a player's attention with moderation.                          |
| `/BanPlayer {PlayerUID or SteamID}` | Bans player from the server. The Player will not be able to rejoin the server until they are unbanned.          |
| `/TeleportToPlayer {PlayerUID or SteamID}` | INGAME ONLY Immediately teleport to the target player                                                           |
| `/TeleportToMe {PlayerUID or SteamID}` | INGAME ONLY Immediately teleports target player to you.                                                         |
| `/ShowPlayers`         | Shows information on all connected players                                                                      |
| `/Info`                | Shows server information                                                                                        |
| `/Save`                | Save the world data to disk. Useful to ensure your Pal, player, and other data is saved before stopping the server or performing a risky gameplay option.             |
