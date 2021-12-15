echo '尝试通过网络同步系统时间...'
echo ""
getBtTime=$(curl -sS --connect-timeout 3 -m 60 http://www.bt.cn/api/index/get_time)
date -s "$(date -d @$getBtTime +"%Y-%m-%d %H:%M:%S")"
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/install.sh -O install.sh
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/resetadmin.sql -O resetadmin.sql
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/set_extra_ip.sh -O set_extra_ip.sh
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/zxces.sh -O zxces.sh
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/old.sh -O old.sh
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/set_protocol_addr.sh -O set_protocol_addr.sh
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/set_store_proxy.sh -O set_store_proxy.sh
wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/set_wb_app_id.sh -O set_wb_app_id.sh
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
echo "# * 脚本更新时间：2021年12月10日，如有遇到安装问题请及时反馈           "#
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
echo -e "# * 网卡IP               : ${LOCAL_IP}"
echo -e "# * 外网IP               : ${getIpAddress}"
echo "                                                                       "
echo "# #####################################################################"#
echo "                                                       "
echo "请选择需要安装的版本【默认安装标准版】:"
echo ""
echo -e " \033[31m=====*4.36版本*=====\033[0m"
echo -e " \033[32m 16. \033[0m CES v4.36.1.11单机版"
echo -e " \033[32m 17. \033[0m CES v4.36.1.11集群主服务器"
echo -e " \033[32m 18. \033[0m CES v4.36.1.11集群节点服务器"
echo -e " \033[32m 19. \033[0m CES v4.36.1.11人脸识别服务器"
echo -e " \033[31m=====*4.35版本*=====\033[0m"
echo -e " \033[32m 20. \033[0m CES v4.35.2.21单机版"
echo -e " \033[32m 21. \033[0m CES v4.35.2.21集群主服务器"
echo -e " \033[32m 22. \033[0m CES v4.35.2.21集群节点服务器"
echo -e " \033[32m 23. \033[0m CES v4.35.2.21人脸识别服务器"
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 24. \033[0m CES v4.34.5.1单机版"
echo -e " \033[32m 25. \033[0m CES v4.34.5.1集群主服务器"
echo -e " \033[32m 26. \033[0m CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 27. \033[0m CES v4.34.5.1人脸识别服务器"
echo -e " \033[44;37m 国产化CES服务端 For ARM \033[0m"
echo -e " \033[32m 40. \033[0m 国产化CES v4.35.1.29单机版服务器"
echo -e " \033[32m 41. \033[0m 国产化CES v4.35.1.29集群主服务器"
echo -e " \033[32m 42. \033[0m 国产化CES v4.35.1.29集群节点服务器"
echo -e " \033[32m 43. \033[0m 国产化CES v4.35.1.29人脸识别服务器"
echo -e " \033[32m 44. \033[0m 国产化CES v4.34.5.1单机版服务器"
echo -e " \033[32m 45. \033[0m 国产化CES v4.34.5.1集群主服务器"
echo -e " \033[32m 46. \033[0m 国产化CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 47. \033[0m 国产化CES v4.34.5.1人脸识别服务器"
echo -e " \033[44;37m 只安装FSP服务器 \033[0m"
echo -e " \033[32m 70. \033[0m 安装FSP v1.4.1.17服务器（适用于4.31以下服务器）"
echo -e " \033[32m 71. \033[0m 安装FSP v1.6.4.4服务器（适用于4.32以上服务器）"
echo -e " \033[32m 72. \033[0m 安装FSP v1.7.1.19服务器"
echo -e " \033[32m 73. \033[0m 安装FSP v1.7.4.2服务器"
echo -e " \033[44;37m 其他（非好视通产品） \033[0m"
echo -e " \033[32m 80. \033[0m 安装RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器（1935/1985/8080/8000端口）"
echo -e " \033[32m 81. \033[0m 安装iperf3局域网性能测试工具(服务端)（5201端口）"
echo -e ""
echo -e " \033[32m 88. \033[0m 卸载CES服务器"
echo -e " \033[32m 89. \033[0m 重启FSP服务器"
echo -e " \033[32m 90. \033[0m 卸载FSP服务器"
echo -e ""
echo -e " \033[32m 97. \033[0m 安装CES历史版本"
echo -e " \033[32m 98. \033[0m 自动添加FSP公网地址（1.7.1.19以上才需要执行）"
echo -e " \033[32m 99. \033[0m 重置后台admin密码"
echo -e " \033[32m 00. \033[0m 安装中性版服务器"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N
echo ""
case $N in
  16) bash install.sh -436dj ;;
  17) bash install.sh -436jq ;;
  18) bash install.sh -436node ;;
  19) bash install.sh -436face ;;
  20) bash install.sh -435dj ;;
  21) bash install.sh -435jq ;;
  22) bash install.sh -435node ;;
  23) bash install.sh -435face ;;
  24) bash install.sh -434dj ;;
  25) bash install.sh -434jq ;;
  26) bash install.sh -434node ;;
  27) bash install.sh -434face ;;
  40) bash install.sh -gc435dj;;
  41) bash install.sh -gc435jq;;
  42) bash install.sh -gc435node;;
  43) bash install.sh -gc435face;;
  44) bash install.sh -gc434dj;;
  45) bash install.sh -gc434jq;;
  46) bash install.sh -gc434node;;
  47) bash install.sh -gc434face;;
  70) bash install.sh -141fsp ;;
  71) bash install.sh -164fsp ;;
  72) bash install.sh -171fsp ;;
  73) bash install.sh -174fsp ;;
  80) bash install.sh -rtmp ;;
  81) bash install.sh -iperf ;;  
  88) bash install.sh -xiezai ;;
  89) bash install.sh -restartfsp ;;
  90) bash install.sh -unfsp ;;
  97) bash old.sh ;;
  98) bash install.sh -setip ;;
  99) bash install.sh -resetadmin ;;
  00) bash zxces.sh ;;
  *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac
