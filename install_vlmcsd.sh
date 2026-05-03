#!/bin/bash
# Debian 13 vlmcsd 一键安装脚本（使用 ini 配置版）

set -e

echo "=== Debian 13 vlmcsd 一键安装脚本（ini 配置版） ==="

# 1. 更新系统 + 安装依赖
apt update
apt install -y git build-essential

# 2. 创建用户
if ! id vlmcsd >/dev/null 2>&1; then
    useradd -r -s /usr/sbin/nologin -M vlmcsd
fi

# 3. 下载编译安装
cd /usr/local/src
rm -rf vlmcsd
git clone https://github.com/Wind4/vlmcsd.git
cd vlmcsd
make

install -m 755 bin/vlmcsd /usr/local/bin/vlmcsd
install -m 755 bin/vlmcs /usr/local/bin/vlmcs

# 4. 创建配置文件目录和主配置文件
mkdir -p /etc/vlmcsd
cat > /etc/vlmcsd/vlmcsd.ini << 'EOF'
# ==================== vlmcsd 主配置文件 ====================

# 监听地址和端口（可改成特定IP）
Listen = 0.0.0.0:1688

# 日志设置
LogFile = /var/log/vlmcsd/vlmcsd.log
LogDateAndTime = yes
# LogVerbose = yes

# 其他常用选项（按需取消注释）
# MaxClients = 1000
# RandomizationLevel = 1
# ProtectLevel = 0

EOF

# 5. 日志目录权限
mkdir -p /var/log/vlmcsd
touch /var/log/vlmcsd.log
chown -R vlmcsd:vlmcsd /var/log/vlmcsd /etc/vlmcsd
chmod 640 /var/log/vlmcsd.log

# 6. systemd 服务（调用 ini 文件）
cat > /etc/systemd/system/vlmcsd.service << 'EOF'
[Unit]
Description=vlmcsd KMS Emulator Service
After=network.target

[Service]
Type=simple
User=vlmcsd
Group=vlmcsd
ExecStart=/usr/local/bin/vlmcsd -i /etc/vlmcsd/vlmcsd.ini -D
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 7. 启动
systemctl daemon-reload
systemctl enable --now vlmcsd

# 8. 显示结果
echo "=== 安装完成 ==="
systemctl status vlmcsd --no-pager -l
echo -e "\n端口监听状态："
ss -ltnp | grep 1688

echo -e "\n✅ 安装成功！配置文件位于：/etc/vlmcsd/vlmcsd.ini"
echo "修改配置后请执行：sudo systemctl restart vlmcsd"
