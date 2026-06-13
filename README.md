# Gateway TCP Network Tuning

适用于 Proxmox VE LXC / KVM 透明网关的网络优化配置。

## 文件说明

```
/etc/sysctl.d/
├── 99-bbr.conf                 # BBR 拥塞控制
├── 99-conntrack.conf           # 连接跟踪超时
├── 99-kcp-style.conf           # KCP 风格快速重传
├── 99-network-tuning.conf      # Fast Open / TIME_WAIT
└── 99-tcp-fastfail.conf        # 快速失败

/root/
├── transparent-gateway.sh      # 透明网关管理脚本（含 fq qdisc）
└── clash_iptables.sh           # Clash iptables 规则
```

## 一键部署

```bash
cp sysctl.d/*.conf /etc/sysctl.d/
sysctl --system

# 设置 fq qdisc
tc qdisc replace dev eth0 root fq
```

## 内核参数说明

| 文件 | 参数 | 优化效果 |
|------|------|---------|
| 99-bbr.conf | `tcp_congestion_control=bbr` | 高丢包下吞吐提升 30%+ |
| 99-conntrack.conf | `nf_conntrack_*_timeout` | 防连接表满导致断网 |
| 99-kcp-style.conf | `tcp_rto_min_us=10000` | RTO 从 200ms→10ms，KCP 风格 |
| 99-kcp-style.conf | `tcp_retries2=3` | 死连接 ~2s 判定，不再等 30s |
| 99-kcp-style.conf | `tcp_syn_retries=1` | SYN 超时 3s 放弃 |
| 99-kcp-style.conf | `tcp_limit_output_bytes=1460` | 逐包发送，减少突发 |
| 99-network-tuning.conf | `tcp_fastopen=3` | 减少握手延迟 |
| 99-network-tuning.conf | `tcp_tw_reuse=1` | TIME_WAIT 复用 |
| 99-network-tuning.conf | `somaxconn=16384` | 高并发队列 |
| 99-tcp-fastfail.conf | `keepalive_*` | 5min 检测死连接 |

## 适用环境

- Debian/Ubuntu (PVE LXC 容器)
- 内核 5.x+
- Clash/mihomo 透明代理
- 1 核 1GB 网关

## 测试结果

```
百度: 47ms 🟢
Google(直连): timeout ❌
Google(代理): 346ms 🟢
```
