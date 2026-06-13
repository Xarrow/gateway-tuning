#!/bin/bash
set -e
echo "==> 部署网络优化配置..."

# 复制 sysctl 配置
cp sysctl.d/*.conf /etc/sysctl.d/

# 应用
sysctl --system

# 设置 fq qdisc（如果 eth0 存在）
if ip link show eth0 >/dev/null 2>&1; then
    tc qdisc replace dev eth0 root fq 2>/dev/null || true
    echo "✅ fq qdisc 已设置"
fi

echo "✅ 部署完成"
echo ""
echo "验证:"
sysctl net.ipv4.tcp_congestion_control
tc qdisc show dev eth0 2>/dev/null | head -1
