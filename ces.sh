#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#检测依赖
sys_install(){
    if ! type wget >/dev/null 2>&1; then
        echo 'wget 未安装 正在安装中';
	    apt-get install wget -y || yum install wget -y
    else
        echo 'wget 已安装，继续操作'
    fi
    if ! type curl >/dev/null 2>&1; then
        echo 'curl 未安装 正在安装中';
        apt-get install curl -y || yum install curl -y
    else
        echo 'curl 已安装，继续操作'
    fi
	if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        curl -sSL https://get.docker.com/ | sh && systemctl enable docker && systemctl start docker
    else 
        echo 'docker 已安装，继续操作'
    fi
}
#脚本启动
sys_install
#更新Centos7
yum -y update
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/install.sh
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
echo "# #####################################################################"#
echo "#                                                                      "#
echo "# * 一键安装指定版本FSP服务器和CES服务器                               "#
echo "#                                                                      "#
echo "# * 脚本作者：Sugar                                                    "#
echo "#                                                                      "#
echo "# * 脚本更新时间：2022年7月19日，如有遇到安装问题请及时反馈            "#
echo "#                                                                      "#
echo "# * 建议服务器内存16G以上，避免因内存不够导致安装失败                  "#
echo "#                                                                      "#
echo "# * 博客地址：https://www.yaohst.com                                   "#
echo "#                                                                      "#
echo "                                                                       "#
echo "#------------------------- 本机硬件配置信息 ---------------------------"#
echo "                                                                       "
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
echo "# #####################################################################"#
echo "                                                       "
echo "请选择需要安装的版本【标准版】:"
echo ""
echo -e " \033[31m=====*4.36版本*=====\033[0m"
echo -e " \033[32m 1. \033[0m CES v4.36.5.5服务器"
echo -e " \033[31m=====*4.35版本*=====\033[0m"
echo -e " \033[32m 2. \033[0m CES v4.35.4.5服务器"
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 3. \033[0m CES v4.34.5.1服务器"
echo -e " \033[44;37m 安装FSP服务器 \033[0m"
echo -e " \033[32m 60. \033[0m 安装FSP v1.4.1.17服务器（配套4.31以下服务器）"
echo -e " \033[32m 61. \033[0m 安装FSP v1.7.5.1服务器（配套4.34、4.35服务器）"
echo -e " \033[32m 62. \033[0m 安装FSP v1.8.3.9服务器（配套4.36服务器）"
echo -e " \033[44;37m 安装H323服务器 \033[0m"
echo -e " \033[32m 70. \033[0m 安装H323网关服务器v2.3.1.12"
echo -e " \033[44;37m 安装录制服务器 \033[0m"
echo -e " \033[32m 71. \033[0m 安装录制服务器v3.2.6.17（适用于CES V4.36版本，不能与FSP安装在同一台）"
echo -e " \033[44;37m 其他（非好视通产品） \033[0m"
echo -e " \033[32m 80. \033[0m 安装RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器（1935/1985/1990/8000/8081/8088端口）"
echo -e " \033[32m 81. \033[0m 安装iperf3网络性能测试工具(服务端)（5201端口）"
echo -e " \033[32m 82. \033[0m 安装HTML5网络速度测试工具(服务端)（6688端口）"
echo -e " \033[32m 83. \033[0m 安装Frp内网穿透服务器（配置文件存放路径/frp/frps.ini）"
echo -e " \033[32m 84. \033[0m 安装Frp内网穿透客户端（配置文件存放路径/frp/frpc.ini）"
echo -e " \033[32m 85. \033[0m 安装动态域名解析服务（浏览器打开主机IP:9876）"
echo -e " \033[32m 86. \033[0m 安装ansible（用于批量管理服务器）"
echo -e " \033[32m 87. \033[0m 网络同步服务器时间（需要服务器能连接公网）"
echo -e " \033[32m 88. \033[0m 放行服务器所有端口"
echo -e ""
echo -e " \033[32m 89. \033[0m 卸载CES服务器"
echo -e " \033[32m 90. \033[0m 卸载FSP服务器"
echo -e ""
echo -e " \033[32m 92. \033[0m 修改H323服务器配置信息（适用于2.3.1.12版本，单机版本选这个）"
echo -e " \033[32m 93. \033[0m 修改H323 GM服务器配置信息（适用于2.3.1.12版本，集群节点选这个）"
echo -e " \033[32m 94. \033[0m 修改录制服务器配置信息（适用于v3.2.6.17版本的录制服务器）"
echo -e " \033[32m 95. \033[0m 修改CES V4.36 配置信息（需先安装FSP服务器）"
echo -e " \033[32m 96. \033[0m 修改CES V4.35 配置信息（需先安装FSP服务器）"
echo -e " \033[32m 97. \033[0m 修改节点服务器配置信息（主服务器勿用）"
echo -e ""
echo -e " \033[32m 98. \033[0m 重置后台admin密码"
echo -e " \033[32m 99. \033[0m 安装CES历史版本以及国产化版本"
echo -e " \033[32m 00. \033[0m 安装中性版服务器"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N 
echo ""
case $N in
  1) bash install.sh -436 ;;
  2) bash install.sh -435 ;;
  3) bash install.sh -434 ;;
  60) bash install.sh -141fsp ;;
  61) bash install.sh -175fsp ;;
  62) bash install.sh -183fsp ;;
  70) bash install.sh -h323 ;;
  71) bash install.sh -record326 ;;
  80) docker run -d --restart=always -p 1935:1935 -p 1985:1985 -p 8081:8080 -p 1990:1990 -p 8088:8088 --env CANDIDATE="${LOCAL_IP}" -p 8000:8000/udp --name srs ossrs/srs:4 ./objs/srs -c conf/https.docker.conf ;;
  81) docker run -d --restart=always -p 5201:5201 -p 5201:5201/udp --name iperf3 ccr.ccs.tencentyun.com/1040155/iperf3 -s ;;  
  82) docker run -d --restart=always -p 6688:80 --name hst-speedtest 1040155/hst-speedtest ;; 
  83) bash install.sh -frps ;;
  84) bash install.sh -frpc ;;
  85) docker run -d --name ddns-go --restart=always --net=host -v /opt/ddns-go:/root jeessy/ddns-go ;;
  86) yum -y install epel-release.noarch && yum install -y ansible && yum install -y tree ;;
  87) bash install.sh -time ;;
  88) systemctl stop firewalld.service && systemctl disable firewalld.service ;;
  89) bash install.sh -xiezai ;;
  90) bash install.sh -unfsp ;;
  92) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/h323.sh && bash h323.sh ;;
  93) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/h323gm.sh && bash h323gm.sh ;;
  94) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/4.36/storeservice.sh && bash storeservice.sh ;;
  95) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/4.36/config.sh && bash config.sh ;;
  96) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/webapp.sh && bash webapp.sh ;;
  97) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/node.sh && bash node.sh ;;
  98) bash install.sh -resetadmin ;;
  99) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/old.sh && bash old.sh ;;
  00) wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/zxces.sh && bash zxces.sh ;;
  *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac