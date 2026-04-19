#!/bin/bash

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 权限运行此脚本 (例如: sudo bash $0)"
  exit 1
fi

echo "=========================================="
echo "       Linux DNS 持久化修改脚本       "
echo "      (适配 Ubuntu / Debian 系列)     "
echo "=========================================="
echo "1. Cloudflare DNS"
echo "2. Google DNS"
echo "3. 混合DNS（Cloudflare + Google）"
echo "0. 退出"
echo "=========================================="
read -p "请输入选项 [0-3]: " choice

# 定义 IPv4 和 IPv6 DNS 地址
CF_V4_1="1.1.1.1"
CF_V4_2="1.0.0.1"
CF_V6_1="2606:4700:4700::1111"
CF_V6_2="2606:4700:4700::1001"

GG_V4_1="8.8.8.8"
GG_V4_2="8.8.4.4"
GG_V6_1="2001:4860:4860::8888"
GG_V6_2="2001:4860:4860::8844"

case $choice in
  1)
    DNS_LIST="nameserver $CF_V4_1\nnameserver $CF_V4_2\nnameserver $CF_V6_1\nnameserver $CF_V6_2"
    MSG="Cloudflare DNS"
    ;;
  2)
    DNS_LIST="nameserver $GG_V4_1\nnameserver $GG_V4_2\nnameserver $GG_V6_1\nnameserver $GG_V6_2"
    MSG="Google DNS"
    ;;
  3)
    DNS_LIST="nameserver $CF_V4_1\nnameserver $GG_V4_1\nnameserver $CF_V6_1\nnameserver $GG_V6_1"
    MSG="混合DNS (Cloudflare + Google)"
    ;;
  0)
    echo "退出脚本。"
    exit 0
    ;;
  *)
    echo "❌ 无效选项，请输入 0-3。"
    exit 1
    ;;
esac

echo "正在将 DNS 修改为 $MSG ..."

# 1. 解除 /etc/resolv.conf 的文件锁定（防止之前已经锁定导致无法修改）
chattr -i /etc/resolv.conf 2>/dev/null

# 2. 删除可能存在的系统软链接（非常重要：如果是软链接，chattr 锁定的会是内存盘中的源文件，重启会失效）
if [ -L /etc/resolv.conf ] || [ -f /etc/resolv.conf ]; then
    rm -f /etc/resolv.conf
fi

# 3. 创建实体文件并写入新的 DNS 记录
echo -e "# 自定义 DNS 配置文件\n# 已被 chattr 锁定，防止 DHCP 或云服务商覆盖" > /etc/resolv.conf
echo -e "$DNS_LIST" >> /etc/resolv.conf

# 4. 彻底锁定文件，禁止任何进程（包括 root 和 systemd）修改、删除或覆盖
chattr +i /etc/resolv.conf

echo "=========================================="
echo "✅ DNS 修改成功，并已开启终极防篡改锁定！"
echo "当前的 /etc/resolv.conf 内容为："
echo "------------------------------------------"
cat /etc/resolv.conf
echo "------------------------------------------"
echo "⚠️ 提示：文件已被 chattr +i 锁定。"
echo "未来如果你或某些 VPN 软件需要修改 DNS，请先执行："
echo "chattr -i /etc/resolv.conf 解除锁定。"
echo "=========================================="
