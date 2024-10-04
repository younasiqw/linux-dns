#!/bin/sh

# 根据选择的选项设置DNS配置
set_dns_configuration() {
    case $1 in
        1)
            # Ali DNS
            dns1='223.5.5.5'
            dns2='223.6.6.6'
            dns3='2400:3200::1'
            ;;
        2)
            # Tencent DNS
            dns1='119.29.29.29'
            dns2='2402:4e00::'
            ;;
        3)
            # 混合DNS（Ali + Tencent）
            dns1='223.5.5.5'
            dns2='2400:3200::1'
            dns3='2402:4e00::'
            ;;
        *)
            echo "无效选项"
            exit 1
            ;;
    esac

    # 设置DNS配置
    echo "正在设置DNS配置..."
    sudo sed -i '/^nameserver/d' /etc/resolv.conf
    echo "nameserver $dns1" | sudo tee -a /etc/resolv.conf
    echo "nameserver $dns2" | sudo tee -a /etc/resolv.conf
    echo "nameserver $dns3" | sudo tee -a /etc/resolv.conf
    echo

    echo "DNS配置已修改."

    # 重启网络服务
    restart_network_service
}

# 重启网络服务的函数
restart_network_service() {
    if [[ -f /etc/init.d/network || -f /etc/init.d/networking ]]; then
        sudo /etc/init.d/network restart || sudo /etc/init.d/networking restart
    else
        sudo systemctl restart NetworkManager || sudo systemctl restart networking
    fi
    echo "网络服务已重启."
}

clear
echo "请选择DNS配置:"
echo "1. Ali DNS"
echo "2. Tencent DNS"
echo "3. 混合DNS（Ali + Tencent）"
echo

read -p "请输入您的选择: " choice
set_dns_configuration $choice

echo "DNS配置已更新."
