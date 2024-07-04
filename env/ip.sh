#!/bin/bash
echo -e "# ******************************************************"
echo -e "#                                                      "
echo -e "# *脚本更新时间：2024年7月4日       脚本作者：萌萌哒菜芽  "
echo -e "#                                                      "
echo -e "# *脚本支持CentOS/Ubuntu/Debian系统"
echo -e "#                                                      "
echo -e "# *可按Ctrl+Z取消安装"
echo -e "#                                                      "
echo -e "# ******************************************************"
echo -e "                                                       "
    # 获取网卡名称和检测网络连接
    interface=$(ip route show | grep -i 'default via' | awk '{print $5; exit}')
    if [ -z "$interface" ]; then
        echo "没有检测到网络，等待网线/WiFi连接..."
        while true; do
            if [ -n "$interface" ]; then
                echo "网线/WiFi已连接，继续执行"
                break
            fi
            sleep 1
        done
    else
        echo "设备已经接入网络，继续执行"
    fi    
    #dns_servers=$(nmcli dev show $interface | grep 'IP4.DNS' | awk '{print $2}')
    # 设置IP地址、子网掩码、网关和DNS服务器
    ip_address=$(ip addr show $interface | grep -oP 'inet \K[\d.]+')
    read -ep "请输入要设置的IP地址（留空自动填写DHCP分配的IP地址）: " input
    ip_address=${input:-$ip_address}
    echo "当前要设置的IP地址是: $ip_address"
    netmask=$(ip addr show $interface | grep -oP 'inet [\d.]+/\K[\d]+')
    read -ep "请输入要设置的子网掩码（留空自动填写DHCP分配的子网掩码）: " input
    netmask=${input:-$netmask}
    echo "当前要设置的子网掩码是: $netmask"
    gateway=$(ip route show dev $interface | grep -i 'default via' | awk '{print $3; exit}')
    read -ep "请输入要设置的网关地址（留空自动填写DHCP分配的网关地址）: " input
    echo "当前要设置的网关地址是: $gateway"    
    #dns1=$(echo $dns_servers | cut -d' ' -f1)
    dns1=114.114.114.114
    read -ep "请输入要设置的DNS1地址（留空自动设置114.114.114.114）: " input
    dns1=${input:-$dns1}
    echo "当前要设置的DNS1地址是: $dns1"
    #dns2=$(echo $dns_servers | cut -d' ' -f2)
    dns2=8.8.8.8
    read -ep "请输入要设置的DNS2地址（留空自动设置8.8.8.8）: " input
    dns2=${input:-$dns2}
    echo "当前要设置的DNS2地址是: $dns2"

if [ -f /etc/redhat-release ]; then
    echo "检测到系统为RedHat/CentOS"
    # 提取无线SSID
    link=$(iw $interface link)
    if echo "$link" | grep -q "SSID"; then
        SSID=$(echo "$link" | grep "SSID" | awk '{print $2}')
        echo "SSID: $SSID"
        # 备份原始网络配置文件
        if [ ! -f "/etc/sysconfig/network-scripts/ifcfg-$SSID.bak" ]; then
            cp /etc/sysconfig/network-scripts/ifcfg-$SSID /etc/sysconfig/network-scripts/ifcfg-$SSID.bak
        fi
        # 修改网络配置文件，将自动获取改为固定IP
        if grep -q "BOOTPROTO=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/BOOTPROTO=.*/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        if grep -q "ONBOOT=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/ONBOOT=.*/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        if grep -q "IPADDR=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/IPADDR=.*/IPADDR=$ip_address/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "IPADDR=$ip_address" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        if grep -q "PREFIX=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/PREFIX=.*/PREFIX=$netmask/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "PREFIX=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        if grep -q "GATEWAY=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/GATEWAY=.*/GATEWAY=$gateway/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "GATEWAY=$gateway" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        if grep -q "DNS1=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/DNS1=.*/DNS1=$dns1/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "DNS1=$dns1" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        if grep -q "DNS2=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/DNS2=.*/DNS2=$dns2/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "DNS2=$dns2" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        echo "固定IP地址设置完成"
    else
        # 不存在SSID时的操作
        echo "没有检测到WiFi网络连接，执行有线网卡修改"
        # 备份原始网络配置文件
        if [ ! -f "/etc/sysconfig/network-scripts/ifcfg-$interface.bak" ]; then
            cp /etc/sysconfig/network-scripts/ifcfg-$interface /etc/sysconfig/network-scripts/ifcfg-$interface.bak
        fi
        # 修改网络配置文件，将自动获取改为固定IP
        if grep -q "BOOTPROTO=" /etc/sysconfig/network-scripts/ifcfg-$interface; then
            sed -i "s/BOOTPROTO=.*/BOOTPROTO=static/" /etc/sysconfig/network-scripts/ifcfg-$interface
        else
            echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-$interface
        fi
        if grep -q "ONBOOT=" /etc/sysconfig/network-scripts/ifcfg-$interface; then
            sed -i "s/ONBOOT=.*/ONBOOT=yes/" /etc/sysconfig/network-scripts/ifcfg-$interface
        else
            echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-$interface
        fi
        if grep -q "IPADDR=" /etc/sysconfig/network-scripts/ifcfg-$interface; then
            sed -i "s/IPADDR=.*/IPADDR=$ip_address/" /etc/sysconfig/network-scripts/ifcfg-$interface
        else
            echo "IPADDR=$ip_address" >> /etc/sysconfig/network-scripts/ifcfg-$interface
        fi
        if grep -q "PREFIX=" /etc/sysconfig/network-scripts/ifcfg-$interface; then
            sed -i "s/PREFIX=.*/PREFIX=$netmask/" /etc/sysconfig/network-scripts/ifcfg-$interface
        else
            echo "PREFIX=$netmask" >> /etc/sysconfig/network-scripts/ifcfg-$interface
        fi
        if grep -q "GATEWAY=" /etc/sysconfig/network-scripts/ifcfg-$interface; then
            sed -i "s/GATEWAY=.*/GATEWAY=$gateway/" /etc/sysconfig/network-scripts/ifcfg-$interface
        else
            echo "GATEWAY=$gateway" >> /etc/sysconfig/network-scripts/ifcfg-$interface
        fi
        if grep -q "DNS1=" /etc/sysconfig/network-scripts/ifcfg-$interface; then
            sed -i "s/DNS1=.*/DNS1=$dns1/" /etc/sysconfig/network-scripts/ifcfg-$interface
        else
            echo "DNS1=$dns1" >> /etc/sysconfig/network-scripts/ifcfg-$interface
        fi
        if grep -q "DNS2=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
            sed -i "s/DNS2=.*/DNS2=$dns2/" /etc/sysconfig/network-scripts/ifcfg-$SSID
        else
            echo "DNS2=$dns2" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
        fi
        echo "固定IP地址设置完成"
    fi

elif [ -f /etc/lsb-release ]; then
    echo "检测到系统为Ubuntu"
if command -v nmcli &> /dev/null; then  
    connection_name=$(nmcli -t -f UUID con show --active | head -n 1)
    backup=$(nmcli -t -f NAME con show --active | head -n 1)
    # 备份原始网络配置文件
    if [ ! -f "/etc/NetworkManager/system-connections/$backup.nmconnection.bak" ]; then
        cp "/etc/NetworkManager/system-connections/$backup.nmconnection" "/etc/NetworkManager/system-connections/$backup.nmconnection.bak"
    fi
    # 设置静态IP地址、网关和DNS服务器    
    nmcli connection modify "$connection_name" ipv4.addresses $ip_address/$netmask
    nmcli connection modify "$connection_name" ipv4.gateway $gateway
    nmcli connection modify "$connection_name" ipv4.dns "$dns1 $dns2"
    nmcli connection modify "$connection_name" ipv4.method manual
    # 重新加载网络连接
    #nmcli con down "$connection_name" && nmcli con up "$connection_name" && systemctl restart NetworkManager
    echo "固定IP地址设置完成"
else
    # 备份原始网络配置文件
    if [ ! -f "/etc/netplan/00-installer-config.yaml.bak" ]; then
    cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
    fi
    sed -i "s/dhcp4: true/dhcp4: false\n      addresses:\n        - $ip_address\/$netmask\n      nameservers:\n        addresses:  \[$dns1, $dns2\]\n      routes:\n        - to: default\n          via: $gateway/g" /etc/netplan/00-installer-config.yaml
    chmod 600 /etc/netplan/00-installer-config.yaml
    #netplan apply
    echo "固定IP地址设置完成"
fi

elif [ -f /etc/debian_version ]; then
    echo "检测到系统为Debian"
if command -v nmcli &> /dev/null; then    
    connection_name=$(nmcli -t -f UUID con show --active | head -n 1)
    backup=$(nmcli -t -f NAME con show --active | head -n 1)
    # 备份原始网络配置文件
    if [ ! -f "/etc/NetworkManager/system-connections/$backup.bak" ]; then
        cp "/etc/NetworkManager/system-connections/$backup" "/etc/NetworkManager/system-connections/$backup.bak"
    fi
    # 设置静态IP地址、网关和DNS服务器
    nmcli connection modify "$connection_name" ipv4.addresses $ip_address/$netmask
    nmcli connection modify "$connection_name" ipv4.gateway $gateway
    nmcli connection modify "$connection_name" ipv4.dns "$dns1 $dns2"
    nmcli connection modify "$connection_name" ipv4.method manual
    # 重新加载网络连接
    #nmcli con down "$connection_name" && nmcli con up "$connection_name" && systemctl restart NetworkManager
    echo "固定IP地址设置完成"
else
    # 备份原始网络配置文件
    if [ ! -f "/etc/network/interfaces.bak" ]; then
    cp /etc/network/interfaces /etc/network/interfaces.bak
    fi  
    if grep -q "^iface $interface inet dhcp" /etc/network/interfaces; then
    sed -i "s/^iface $interface inet dhcp$/iface $interface inet static/" /etc/network/interfaces
    echo -e "    address $ip_address\n    netmask $netmask\n    gateway $gateway" >> /etc/network/interfaces
    else    
    sed -i -e "/^iface $interface inet static/{n;s/address .*/address $ip_address/}" \
           -e "/^iface $interface inet static/{n;s/netmask .*/netmask $netmask/}" \
           -e "/^iface $interface inet static/{n;s/gateway .*/gateway $gateway/}" /etc/network/interfaces
    fi
    #systemctl restart networking
    echo "固定IP地址设置完成"
fi

else
    echo "不支持的操作系统"
fi