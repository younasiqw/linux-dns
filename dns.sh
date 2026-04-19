cat << 'EOF' > dns.sh
#!/bin/bash

# 根据选择的选项设置DNS配置
set_dns_configuration() {
  case $1 in
    1)
      dns1='1.1.1.1'
      dns2='1.0.0.1'
      dns3='2606:4700:4700::1111'
      ;;
    2)
      dns1='8.8.8.8'
      dns2='8.8.4.4'
      dns3='2001:4860:4860::8888'
      ;;
    3)
      dns1='1.1.1.1'
      dns2='8.8.8.8'
      dns3='2606:4700:4700::1111'
      ;;
    *)
      echo "无效选项"
      exit 1
      ;;
  esac

  echo "正在设置DNS配置..."
  sudo chattr -i /etc/resolv.conf >/dev/null 2>&1 || true
  sudo sed -i '/^nameserver/d' /etc/resolv.conf
  echo "nameserver $dns1" | sudo tee -a /etc/resolv.conf
  echo "nameserver $dns2" | sudo tee -a /etc/resolv.conf
  echo "nameserver $dns3" | sudo tee -a /etc/resolv.conf
  sudo chattr +i /etc/resolv.conf
  echo

  echo "DNS配置已修改."
  restart_network_service
}

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
echo "1. Cloudflare DNS"
echo "2. Google DNS"
echo "3. 混合DNS（Cloudflare + Google）"
echo

read -p "请输入您的选择: " choice
set_dns_configuration $choice

echo "DNS配置已更新."
EOF

chmod +x dns.sh
./dns.sh
