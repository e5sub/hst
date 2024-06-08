#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
# 美化Bash
if ! grep -q "getmyip" /etc/profile; then
    echo "# 获取IP函数" >> /etc/profile
    echo "function getmyip {" >> /etc/profile
    echo "    ip addr | grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -vE '^127\.|^255\.|^0\.' | head -n 1" >> /etc/profile
    echo "}" >> /etc/profile
fi
if ! grep -q "export PS1" /etc/profile; then
    echo "# 输出美化" >> /etc/profile
    echo "export PS1='\[\e[31m\][$?]\[\e[m\]:\[\e[32m\][\u@\H]\[\e[m\]:\[\e[34m\][\t]\[\e[m\]:\[\e[31m\][\$(getmyip)]\[\e[m\]:\[\e[33m\][\w]\[\e[m\]\$> '" >> /etc/profile
fi
#检测依赖
sys_install(){
    if ! type wget >/dev/null 2>&1; then
        echo 'wget 未安装 正在安装中';
        apt install wget -y || yum install wget -y
    else
        echo 'wget 已安装，继续操作'
    fi
    if ! type curl >/dev/null 2>&1; then
        echo 'curl 未安装 正在安装中';
        apt install curl -y || yum install curl -y
    else
        echo 'curl 已安装，继续操作'
    fi
    if ! type bzip2 >/dev/null 2>&1; then
        echo 'bzip2 未安装 正在安装中';
        yum install bzip2 -y
    else
        echo 'bzip2 已安装，继续操作'
    fi
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        curl -sSL https://get.docker.com/ | sh 
		systemctl enable docker
		systemctl start docker
    else 
        echo 'docker 已安装，继续操作'
    fi
}
sys_install
mkdir /etc/docker
cat >/etc/docker/daemon.json<<EOF
{
"log-driver": "json-file",
"log-opts": {"max-size":"20m", "max-file":"2"}
"registry-mirrors": ["https://hlx1vn88.mirror.aliyuncs.com"]
}
EOF
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
sh_ver="2.0"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
#更新脚本
Update_Shell(){
	echo -e "当前版本为 [ ${sh_ver} ]，开始检测最新版本..."
	sh_new_ver=$(wget --no-check-certificate -qO- "https://${github}/ces.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1)
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} 检测最新版本失败 !" && start_menu
	if [[ ${sh_new_ver} != ${sh_ver} ]]; then
		echo -e "发现新版本[ ${sh_new_ver} ]，是否更新？[Y/n]"
		read -p "(默认: y):" yn
		[[ -z "${yn}" ]] && yn="y"
		if [[ ${yn} == [Yy] ]]; then
			wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/ces.sh && chmod +x ces.sh
			echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !"
			bash ces.sh
		else
			echo && echo "	已取消..." && echo
		fi
	else
		echo -e "当前已是最新版本[ ${sh_new_ver} ] !"
		sleep 5s
		bash <(curl -Ls https://cdn.jsdelivr.net/gh/e5sub/hst@master/ces.sh) 
	fi
}
wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/install.sh
wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/cesinstall.sh
get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}
calc_disk() {
    local total_size=0
    local array=$@
    for size in ${array[@]}
    do
        [ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
        [ "`echo ${size:(-1)}`" == "K" ] && size=0
        [ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
        [ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
        [ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
        total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
    done
    echo ${total_size}
}
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
tram=$( free -m | awk '/Mem/ {print $2}' )
uram=$( free -m | awk '/Mem/ {print $3}' )
swap=$( free -m | awk '/Swap/ {print $2}' )
uswap=$( free -m | awk '/Swap/ {print $3}' )
up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )
disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
disk_total_size=$( calc_disk ${disk_size1[@]} )
disk_used_size=$( calc_disk ${disk_size2[@]} )
LOCAL_IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
getIpAddress=$(curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress)
echo -e "# #####################################################################"#
echo -e "#                                                                      "
echo -e "# * 一键安装指定版本FSP服务器和CES服务器                               "
echo -e "#                                                                      "
echo -e "# * 脚本作者：Sugar    版本：${sh_ver}                                 "
echo -e "#                                                                      "
echo -e "# * 抖音、微信视频号：萌萌哒菜芽，欢迎关注！                           "
echo -e "#                                                                      "
echo -e "# * 部署CES和FSP,建议服务器内存16G以上，避免因内存不够导致安装失败     "
echo -e "#                                                                      "
echo -e "# * 博客地址：https://www.yaohst.com                                   "
echo -e "#                                                                      "
echo -e "#------------------------- 本机硬件配置信息 ---------------------------"#
echo -e "                                                                       "
echo -e "# * CPU 型号             : ${SKYBLUE}$cname${PLAIN}                 "
echo -e "# * CPU 核心数           : ${SKYBLUE}$cores${PLAIN}                 "
echo -e "# * CPU 频率             : ${SKYBLUE}$freq MHz${PLAIN}              "
echo -e "# * 总硬盘大小           : ${SKYBLUE}$disk_total_size GB ($disk_used_size GB 已使用)${PLAIN}"
echo -e "# * 总内存大小           : ${SKYBLUE}$tram MB ($uram MB 已使用)${PLAIN}"
echo -e "# * SWAP大小             : ${SKYBLUE}$swap MB ($uswap MB 已使用)${PLAIN}"
echo -e "# * 开机时长             : ${SKYBLUE}$up${PLAIN}                     "
echo -e "# * 系统负载             : ${SKYBLUE}$load${PLAIN}                   "
echo -e "# * 系统                 : ${SKYBLUE}$opsy${PLAIN}                   "
echo -e "# * 架构                 : ${SKYBLUE}$arch ($lbit 位)${PLAIN}       "
echo -e "# * 内核                 : ${SKYBLUE}$kern${PLAIN}"
echo -e "# * 本地IP               : ${LOCAL_IP}"
echo -e "# * 外网IP               : ${getIpAddress}"
echo "                                                                       "
echo -e "# #####################################################################"#
echo "                                                       "
start_menu(){
echo -e "*****使用该脚本前强烈建议更新脚本之后再使用*****"
echo ""
echo "请选择需要安装的版本【标准版】:"
echo ""
echo -e " \033[32m 0. \033[0m 更新安装脚本，当前正在使用的版本：[${sh_ver}]"
echo ""
echo -e " \033[31m=====*4.38版本*=====\033[0m"
echo -e " \033[32m 1. \033[0m CES v4.38.6.3服务器"
echo -e " \033[31m=====*4.37版本*=====\033[0m"
echo -e " \033[32m 2. \033[0m CES v4.37.6.8服务器"
echo -e " \033[31m=====*4.36版本*=====\033[0m"
echo -e " \033[32m 3. \033[0m CES v4.36.6.2服务器"
echo -e " \033[31m=====*4.35版本*=====\033[0m"
echo -e " \033[32m 4. \033[0m CES v4.35.4.5服务器"
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 5. \033[0m CES v4.34.5.1服务器"
echo -e " \033[44;37m 安装FSP服务器 \033[0m"
echo -e " \033[32m 6. \033[0m 安装FSP v1.7.5.1服务器（配套4.34、4.35服务器）"
echo -e " \033[32m 7. \033[0m 安装FSP v1.8.3.5服务器（配套4.36服务器）"
echo -e " \033[44;37m 安装H323服务器 \033[0m"
echo -e " \033[32m 8. \033[0m 安装H323网关服务器v2.4.3.2（私有云版本）"
echo -e " \033[32m 9. \033[0m 安装H323网关服务器v2.4.3.2（云会议版本）"
echo -e " \033[44;37m 安装录制服务器 \033[0m"
echo -e " \033[32m 10. \033[0m 安装录制服务器v3.2.6.17（适用于CES V4.36版本，不能与FSP安装在同一台）"
echo -e " \033[44;37m 其他（非好视通产品） \033[0m"
echo -e " \033[32m 11. \033[0m 安装RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器（2022/1935/1985/8080/8000/10080端口）"
echo -e " \033[32m 12. \033[0m 安装iperf3网络性能测试工具(服务端)（5201端口）"
echo -e " \033[32m 13. \033[0m 安装HTML5网络速度测试工具(服务端)（6688端口）"
echo -e " \033[32m 14. \033[0m 安装动态域名解析服务（浏览器打开主机IP:9876）"
echo -e " \033[32m 15. \033[0m 网络同步服务器时间（需要服务器能连接公网）"
echo -e " \033[32m 16. \033[0m 安装RustDesk远程桌面服务器（21115/21116/21117/21118/21119端口）"
echo -e " \033[32m 17. \033[0m 安装Frp内网穿透服务器（配置文件存放路径/home/frp/frps.ini）"
echo -e " \033[32m 18. \033[0m 安装Frp内网穿透客户端（配置文件存放路径/home/frp/frpc.ini）"
echo -e " \033[32m 19. \033[0m 安装Prometheus+Grafana+node-exporter+consul+alertmanager+blackbox-exporter"
echo -e " \033[32m 20. \033[0m 安装Prometheus-Node-Exporter"
echo -e " \033[32m 21. \033[0m 安装zabbix-server"
echo -e " \033[32m 22. \033[0m 安装zabbix-agent"
echo -e " \033[32m 23. \033[0m 安装Emby流媒体服务器（8096/8920端口）"
echo -e " \033[32m 24. \033[0m 安装Alist文件列表程序（5244端口）"
echo -e " \033[32m 25. \033[0m 设置每周一自动更新容器镜像"
echo -e ""
echo -e " \033[32m 88. \033[0m 卸载CES服务器"
echo -e " \033[32m 89. \033[0m 卸载FSP服务器"
echo -e ""
echo -e " \033[32m 90. \033[0m 修改H323服务器配置信息（适用于2.4.2.2私有云版本）"
echo -e " \033[32m 91. \033[0m 修改H323服务器配置信息（适用于2.4.2.2云会议版本）"
echo -e " \033[32m 92. \033[0m 修改CES V4.36 配置信息（需先安装FSP服务器）"
echo -e " \033[32m 93. \033[0m 修改节点服务器配置信息（主服务器勿用）"
echo -e " \033[32m 94. \033[0m Nginx转发8443端口，隐藏公网8443后台页面（转发端口号18443）"
echo -e " \033[32m 95. \033[0m Nginx反代1089/8443/20020端口（需手动修改/usr/local/nginx/nginx.conf里的地址）"
echo -e " \033[32m 96. \033[0m 放行服务器所有端口"
echo -e ""
echo -e " \033[32m 97. \033[0m 重置后台admin密码"
echo -e " \033[32m 98. \033[0m 安装CES历史版本以及国产化版本"
echo -e " \033[32m 00. \033[0m 安装中性版服务器"
echo -e ""
echo && read -ep "请输入数字选择: " N
echo ""
case $N in
  0) Update_Shell ;;
  1) bash install.sh -438 ;;
  2) bash install.sh -437 ;;
  3) bash install.sh -436 ;;
  4) bash install.sh -435 ;;
  5) bash install.sh -434 ;;
  6) bash install.sh -175fsp ;;
  7) bash install.sh -183fsp ;;
  8) bash install.sh -h323pri ;;
  9) bash install.sh -h323pub ;;
  10) bash install.sh -record ;;
  11) docker run -dit --restart=always -p 2022:2022 -p 2443:2443 -p 1935:1935 -p 8080:8080 -p 8000:8000/udp -p 10080:10080/udp -e REACT_APP_LOCALE=zh --name srs-stack -v /home/srs:/data ossrs/srs-stack:5 ;;
  12) docker run -dit --restart=always -p 5201:5201 -p 5201:5201/udp --name iperf3 ccr.ccs.tencentyun.com/1040155/iperf3 -s ;;  
  13) docker run -dit --restart=always -p 6688:80 --name hst-speedtest 1040155/hst-speedtest ;; 
  14) docker run -dit --name ddns-go --restart=always --net=host -v /home/ddns-go:/root jeessy/ddns-go ;;
  15) bash install.sh -time ;;
  16) docker run --name hbbs -p 21115:21115 -p 21116:21116 -p 21116:21116/udp -p 21118:21118 -v /home/rustdesk:/root -dit --restart=always rustdesk/rustdesk-server hbbs -r ${LOCAL_IP}
      docker run --name hbbr -p 21117:21117 -p 21119:21119 -v /home/rustdesk:/root -dit --restart=always rustdesk/rustdesk-server hbbr  ;;
  17) bash install.sh -frps ;;
  18) bash install.sh -frpc ;;
  19) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/grafana/prometheus.sh && bash prometheus.sh ;;
  20) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/grafana/node.sh && bash node.sh ;;
  21) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/zabbix/zabbix.sh && bash zabbix.sh ;;
  22) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/zabbix/agent.sh && bash agent.sh ;;
  23) docker run -dit -e PUID=0 -e PGID=0 -v /home/emby/movies:/data/movies -v /home/emby/config:/config -p 8096:8096 -p 8920:8920 --name=emby --restart=always xinjiawei1/emby_unlockd:latest ;;
  24) docker run -dit --restart=always -v /home/alist:/opt/alist/data -p 5244:5244 -e PUID=0 -e PGID=0 -e UMASK=022 --name="alist" xhofe/alist:latest ;;
  25) (crontab -l ; echo "0 3 * * 1 docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower -cR" ) | crontab - ;;
  88) bash install.sh -xiezai ;;
  89) bash install.sh -unfsp ;;
  90) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/h323pri.sh && bash h323pri.sh ;;
  91) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/h323pub.sh && bash h323pub.sh ;;
  92) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/4.36/config.sh && bash config.sh ;;
  93) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/node.sh && bash node.sh ;;
  94) bash install.sh -nginx ;;
  95) bash install.sh -proxy ;;
  96) systemctl stop firewalld.service
      systemctl disable firewalld.service ;;

  97) bash install.sh -resetadmin ;;
  98) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/old.sh && bash old.sh ;;
  00) wget -N --no-check-certificate https://cdn.jsdelivr.net/gh/e5sub/hst@master/install/zxces.sh && bash zxces.sh ;;
  *)
      clear
      echo -e "${Error}:请输入正确的数字"
      sleep 5s
      start_menu
	  ;;
esac
}
start_menu
