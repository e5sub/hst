#!/bin/bash
echo -e "# ******************************************************"
echo -e "#                                                      "
echo -e "# *脚本更新时间：2024年3月20日"
echo -e "#                                                      "
echo -e "# *脚本暂时只支持CentOS"
echo -e "#                                                      "
echo -e "# *可按Ctrl+Z取消安装"
echo -e "#                                                      "
echo -e "# ******************************************************"
echo -e "                                                       "
if [ -f /etc/redhat-release ]; then
echo "检测到系统为RedHat/CentOS"
interface=$(ip route show | grep -i 'default via' | awk '{print $5; exit}')
dns_servers=$(nmcli dev show $interface | grep 'IP4.DNS' | awk '{print $2}')
   # 提取DNS1和DNS2
dns1=$(echo $dns_servers | cut -d' ' -f1)
dns2=$(echo $dns_servers | cut -d' ' -f2)
if [ -z "$interface" ]; then
    echo "没有检测到网络，等待网线/WiFi连接..."
    while true; do
        interface=$(ip route show | grep -i 'default via' | awk '{print $5; exit}')
        if [ -n "$interface" ]; then
            echo "网线/WiFi已连接，继续执行"
            break
        fi
        sleep 1
    done
else
    echo "设备已经接入网络，继续执行"
fi
   # 提取DHCP获取到的IP地址信息
ip_address=$(ip addr show $interface | grep -oP 'inet \K[\d.]+')
netmask=$(ip addr show $interface | grep -oP 'inet [\d.]+/\K[\d]+')
gateway=$(ip route show dev $interface | grep -i 'default via' | awk '{print $3; exit}')
   # 提取无线SSID
link=$(iw $interface link)
SSID=$(echo "$link" | grep "SSID" | awk '{print $2}')
if echo "$link" | grep -q "SSID"; then
   # 存在SSID时执行的操作
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
if [ -n "$dns2" ]; then
    if grep -q "DNS2=" /etc/sysconfig/network-scripts/ifcfg-$SSID; then
        sed -i "s/DNS2=.*/DNS2=$dns2/" /etc/sysconfig/network-scripts/ifcfg-$SSID
    else
        echo "DNS2=$dns2" >> /etc/sysconfig/network-scripts/ifcfg-$SSID
    fi
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
if [ -n "$dns2" ]; then
    if grep -q "DNS2=" /etc/sysconfig/network-scripts/ifcfg-$interface; then
        sed -i "s/DNS2=.*/DNS2=$dns2/" /etc/sysconfig/network-scripts/ifcfg-$interface
    else
        echo "DNS2=$dns2" >> /etc/sysconfig/network-scripts/ifcfg-$interface
    fi
fi

echo "固定IP地址设置完成"

elif [ -f /etc/debian_version ]; then
echo "检测到系统为Debian"

elif [[ -f /etc/lsb-release ]]; then
echo "检测到系统为Ubuntu"

else
echo "不支持的操作系统"
fi