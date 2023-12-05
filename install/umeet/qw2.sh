#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年11月30日                         "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *安装前请确保环境干净,脚本不支持覆盖安装!            "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "

# 获取本地IP地址
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

# 安装centos依赖
yum -y install rsync ntpdate curl net-tools psmisc sysstat unzip wget ntp screen bind-utils libaio* 

# 移除任何已经安装的 MySQL 或者 MariaDB
rpm -e `rpm -qa | grep -i mysql`
rpm -e --nodeps `rpm -qa | grep -i mariadb`

# 检测企微私有化部署安装包
while true; do
    if [ ! -f wwlocal-*.zip ]; then
        echo "需要的wwlocal-*.zip文件不存在，无法进行安装"
        read -p "请将wwlocal-*.zip文件放置到当前目录下，然后按回车键继续..."
    else
        break
    fi
done

# 检测localglobal.conf配置文件
while true; do
    if [ ! -f localglobal.conf ]; then
        echo "需要的localglobal.conf文件不存在，无法进行安装"
        read -p "请将localglobal.conf文件放置到当前目录下，然后按回车键继续..."
    else
        break
    fi
done

# 检测ip.lst配置文件
while true; do
    if [ ! -f ip.lst ]; then
        echo "需要的ip.lst文件不存在，无法进行安装"
        read -p "请将ip.lst文件放置到当前目录下，然后按回车键继续..."
    else
        break
    fi
done

# 检测unzip环境
while ! command -v unzip &> /dev/null; do
    echo "unzip命令不可用，无法进行离线安装,5秒钟之后自动检测安装包"
    if [ -f unzip*.rpm ]; then
        rpm -ivh unzip*.rpm
        if [ $? -eq 0 ]; then
            echo "unzip安装成功！"
            break
        else
            echo "unzip安装失败，请检查安装包名称或手动安装。"
        fi
    else
        echo "未找到unzip.rpm安装包，请将安装包放置到当前目录下。"  
        sleep 5  # 等待5秒后继续检测		
    fi
done

# 使用通配符解压安装包
unzip -P 5np?M#b% wwlocal-*.zip
tar -zxf wwlocal-*.tar.gz -C /home/

# 复制localglobal.conf配置文件
cp localglobal.conf /home/wwlocal/conf/global/localglobal.conf

# 复制wwlsocks5proxy_cli.conf.template模板并改名wwlsocks5proxy_cli.conf
cp /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf.template /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf

# 复制ip.lst配置文件
cp ip.lst /home/wwlocal/conf/global/ip.lst

# 设置wwlocal权限
chmod -R 777 /home/wwlocal

# 安装企微私有化依赖
rpm -ivh --nodeps /home/wwlocal/wwlops/PRECHECK/unixbench.suite/packages/*.rpm 

# 这是主要安装脚本
ip_file="ip.lst"
if [ -f "$ip_file" ]; then
  while IFS="=" read -r key value; do
    key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # 检查是否匹配本地IP地址
    if [ "$local_ip" == "$value" ]; then
      case "$key" in
        LIP*)
          echo "根据ip.lst信息识别到这台是逻辑服务器，开始安装逻辑服务器"
          # 提取ip.lst信息并自动修改配置文件
          ips=($(grep -E 'PIP[0-9]*' /home/wwlocal/conf/global/ip.lst | cut -d'=' -f2))
          count=$(grep -E 'PIP[0-9]*' /home/wwlocal/conf/global/ip.lst | wc -l)
          sed -i "s/UseProxy=0/UseProxy=1/" /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          sed -i "s/ServerCount=[0-9]*/ServerCount=$count/" /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          # 删除现有的 [Server0] 部分
          sed -i '/\[Server0\]/,/^\[/d' /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          # 循环生成配置文件，从 [Server0] 开始递增
          for ((i=0; i<${#ips[@]}; i++)); do
          echo "[Server$i]" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "SVR_IP=${ips[i]}" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "SVR_Port=8081" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Sect_Begin=-1" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Sect_End=-1" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Scale=1000" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          done
          # 执行安装脚本
          bash /home/wwlocal/wwlops/SETUP.sh
          # 初始化企业数据
          bash /home/wwlocal/wwlops/INIT.sh
          ;;
        PIP*)
          echo "根据ip.lst信息识别到这台是接入服务器，开始安装接入服务器"
          # 提取ip.lst信息并自动修改配置文件
          ips=($(grep -E 'PIP[0-9]*' /home/wwlocal/conf/global/ip.lst | cut -d'=' -f2))
          count=$(grep -E 'PIP[0-9]*' /home/wwlocal/conf/global/ip.lst | wc -l)
          sed -i "s/UseProxy=0/UseProxy=1/" /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          sed -i "s/ServerCount=[0-9]*/ServerCount=$count/" /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          # 删除现有的 [Server0] 部分
          sed -i '/\[Server0\]/,/^\[/d' /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          # 循环生成配置文件，从 [Server0] 开始递增
          for ((i=0; i<${#ips[@]}; i++)); do
          echo "[Server$i]" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "SVR_IP=${ips[i]}" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "SVR_Port=8081" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Sect_Begin=-1" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Sect_End=-1" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Scale=1000" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          done
          # 执行安装脚本
          bash /home/wwlocal/wwlops/SETUP.sh
          # 修改wwlsocks5proxy.conf中的IP地址
          sed -i "s/IP=.*/IP=$local_ip/g" /home/wwlocal/wwlsocks5proxy/conf/wwlsocks5proxy.conf
          # 保存后重启wwlsocks5proxy
          /home/wwlocal/wwlsocks5proxy/bin/wwlsocks5proxyTool restart
          ;;
        SIP*)
          echo "根据ip.lst信息识别到这台是存储服务器，开始安装存储服务器"
          # 提取ip.lst信息并自动修改配置文件
          ips=($(grep -E 'PIP[0-9]*' /home/wwlocal/conf/global/ip.lst | cut -d'=' -f2))
          count=$(grep -E 'PIP[0-9]*' /home/wwlocal/conf/global/ip.lst | wc -l)
          sed -i "s/UseProxy=0/UseProxy=1/" /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          sed -i "s/ServerCount=[0-9]*/ServerCount=$count/" /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          # 删除现有的 [Server0] 部分
          sed -i '/\[Server0\]/,/^\[/d' /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          # 循环生成配置文件，从 [Server0] 开始递增
          for ((i=0; i<${#ips[@]}; i++)); do
          echo "[Server$i]" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "SVR_IP=${ips[i]}" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "SVR_Port=8081" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Sect_Begin=-1" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Sect_End=-1" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo "Scale=1000" >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          echo >> /home/wwlocal/conf/global/wwlsocks5proxy_cli.conf
          done
          # 执行安装脚本
          bash /home/wwlocal/wwlops/SETUP.sh
          # 初始化企业数据
          bash /home/wwlocal/wwlops/INIT.sh
          ;;
        *)
          echo "根据ip.lst信息识未能识别出服务器，不执行安装"
          ;;
      esac
      # 如果匹配到了IP地址，就不需要再继续循环
      break
    fi
  done < "$ip_file"
else
  echo "ip.lst 文件不存在"
fi