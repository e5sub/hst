#安装依赖
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
}
#脚本启动
sys_install

wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/install.sh -O install.sh
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
echo "# * 脚本更新时间：2022年4月17日，如有遇到安装问题请及时反馈            "#
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
echo -e " \033[32m 16. \033[0m CES v4.36.5.1单机版"
echo -e " \033[32m 17. \033[0m CES v4.36.5.1集群主服务器"
echo -e " \033[32m 18. \033[0m CES v4.36.5.1集群节点服务器"
echo -e " \033[32m 19. \033[0m CES v4.36.5.1人脸识别服务器"
echo -e " \033[31m=====*4.35版本*=====\033[0m"
echo -e " \033[32m 20. \033[0m CES v4.35.4.5单机版"
echo -e " \033[32m 21. \033[0m CES v4.35.4.5集群主服务器"
echo -e " \033[32m 22. \033[0m CES v4.35.4.5集群节点服务器"
echo -e " \033[32m 23. \033[0m CES v4.35.4.5人脸识别服务器"
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 24. \033[0m CES v4.34.5.1单机版"
echo -e " \033[32m 25. \033[0m CES v4.34.5.1集群主服务器"
echo -e " \033[32m 26. \033[0m CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 27. \033[0m CES v4.34.5.1人脸识别服务器"
echo -e " \033[44;37m 国产化CES服务端 For ARM \033[0m"
echo -e " \033[32m 40. \033[0m 国产化CES v4.35.1.30单机版服务器"
echo -e " \033[32m 41. \033[0m 国产化CES v4.35.1.30集群主服务器"
echo -e " \033[32m 42. \033[0m 国产化CES v4.35.1.30集群节点服务器"
echo -e " \033[32m 43. \033[0m 国产化CES v4.35.1.30人脸识别服务器"
echo -e " \033[32m 44. \033[0m 国产化CES v4.34.5.1单机版服务器"
echo -e " \033[32m 45. \033[0m 国产化CES v4.34.5.1集群主服务器"
echo -e " \033[32m 46. \033[0m 国产化CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 47. \033[0m 国产化CES v4.34.5.1人脸识别服务器"
echo -e " \033[44;37m 国产化CES服务端 For MIPS \033[0m"
echo -e " \033[32m 60. \033[0m 国产化CES v4.35.1.30单机版服务器"
echo -e " \033[32m 61. \033[0m 国产化CES v4.35.1.30集群主服务器"
echo -e " \033[32m 62. \033[0m 国产化CES v4.35.1.30集群节点服务器"
echo -e " \033[32m 63. \033[0m 国产化CES v4.35.1.30人脸识别服务器"
echo -e " \033[44;37m 只安装FSP服务器 \033[0m"
echo -e " \033[32m 70. \033[0m 安装FSP v1.4.1.17服务器（配套4.31以下服务器）"
echo -e " \033[32m 71. \033[0m 安装FSP v1.7.4.2服务器（配套4.34以上服务器）"
echo -e " \033[32m 72. \033[0m 安装FSP v1.8.3.3服务器（配套4.36以上服务器）"
echo -e " \033[44;37m 安装H323服务器 \033[0m"
echo -e " \033[32m 79. \033[0m 安装H323网关服务器v2.3.1.12"
echo -e " \033[44;37m 其他（非好视通产品） \033[0m"
echo -e " \033[32m 80. \033[0m 安装RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器（1935/1985/1990/8000/8080/8088端口）"
echo -e " \033[32m 81. \033[0m 安装iperf3网络性能测试工具(服务端)（5201端口）"
echo -e " \033[32m 82. \033[0m 安装HTML5网络速度测试工具(服务端)（6688端口）"
echo -e " \033[32m 83. \033[0m 修改时间为中国时区"
echo -e ""
echo -e " \033[32m 88. \033[0m 卸载CES服务器"
echo -e " \033[32m 89. \033[0m 重启FSP服务器"
echo -e " \033[32m 90. \033[0m 卸载FSP服务器"
echo -e ""
echo -e " \033[32m 92. \033[0m 一键修改H323服务器配置信息（适用于2.3.1.12版本，单机版本选这个）"
echo -e " \033[32m 93. \033[0m 一键修改H323 GM服务器配置信息（适用于2.3.1.12版本，集群选这个）"
echo -e " \033[32m 94. \033[0m 一键修改录制服务器配置信息（适用于1.0.7.16版本的录制服务器）"
echo -e " \033[32m 95. \033[0m 一键修改CES webapp配置信息（适用于4.35以上版本）"
echo -e " \033[32m 96. \033[0m 一键修改节点服务器配置信息（适用于4.35以上版本，主服务器勿用）"
echo -e " \033[32m 97. \033[0m 自动添加FSP公网地址（1.7.4.2以上才需要执行）"
echo -e " \033[32m 98. \033[0m 重置后台admin密码"
echo -e " \033[32m 99. \033[0m 安装CES历史版本"
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
  60) bash install.sh -m435dj;;
  61) bash install.sh -m435jq;;
  62) bash install.sh -m435node;;
  63) bash install.sh -m435face;;
  70) bash install.sh -141fsp ;;
  71) bash install.sh -174fsp ;;
  72) bash install.sh -183fsp ;;
  79) bash install.sh -h323 ;;
  80) bash install.sh -rtmp ;;
  81) bash install.sh -iperf ;;  
  82) bash install.sh -html5 ;; 
  83) rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime ;; 
  88) bash install.sh -xiezai ;;
  89) bash install.sh -restartfsp ;;
  90) bash install.sh -unfsp ;;
  92) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/h323.sh -O h323.sh && chmod +x h323.sh && bash h323.sh ;;
  93) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/h323gm.sh -O h323gm.sh && chmod +x h323gm.sh && bash h323gm.sh ;;
  94) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/luzhi.sh -O luzhi.sh && chmod +x luzhi.sh && bash luzhi.sh ;;
  95) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/webapp.sh -O webapp.sh && chmod +x webapp.sh && bash webapp.sh ;;
  96) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/node.sh -O node.sh && chmod +x node.sh && bash node.sh ;;
  97) bash install.sh -setip ;;
  98) bash install.sh -resetadmin ;;
  99) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/old.sh -O old.sh && chmod +x old.sh && bash old.sh ;;
  00) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/zxces.sh -O zxces.sh && chmod +x zxces.sh && bash zxces.sh ;;
  *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac
