#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年8月31日                         "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *请按照提示填写相应的参数                            "* 
echo -e "#                                                      "*
echo -e "# *如输入错误，可按Ctrl+Z重新填写                      "*
echo -e "#                                                      "*
echo -e "# *如有不明白选项可以保持默认                          "*
echo -e "#                                                      "*
echo -e "# *如有问题或者遗漏的参数信息，请及时反馈              "*
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "                                                       "
LOCAL_IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# Pre-installation settings
pre_install_H323(){
    # Set ces_ip
    read -ep "(请输入CES服务器IP地址或者域名):" ces_ip
    [ -z "${ces_ip}" ]
    echo
    echo "---------------------------"
    echo "CES服务器IP = ${ces_ip}"
    echo "---------------------------"
    echo
    # Set h323gw_gcdevid
    read -ep "(请输入H323 gc网关设备ID):" h323gw_gcdevid
    [ -z "${h323gw_gcdevid}" ] && h323gw_gcdevid=h323gw_gc
    echo
    echo "---------------------------"
    echo "H323 gc网关设备ID = ${h323gw_gcdevid}"
    echo "---------------------------"
    echo
    # Set verify_gccode
    read -ep "(请输入H323 gc网关设备验证码):" verify_gccode
    [ -z "${verify_gccode}" ] && verify_gccode=1114
    echo
    echo "---------------------------"
    echo "H323 gc网关设备验证码 = ${verify_gccode}"
    echo "---------------------------"
    echo
	# Set h323gw_gcdevid
    read -ep "(请输入H323 gm网关设备ID):" h323gw_gmdevid
    [ -z "${h323gw_gmdevid}" ] && h323gw_gmdevid=h323gw_gm1
    echo
    echo "---------------------------"
    echo "H323 gm网关设备ID = ${h323gw_gmdevid}"
    echo "---------------------------"
    echo
    # Set verify_gccode
    read -ep "(请输入H323 gm网关设备验证码):" verify_gmcode
    [ -z "${verify_gmcode}" ] && verify_gmcode=1114
    echo
    echo "---------------------------"
    echo "H323 gm网关设备验证码 = ${verify_gmcode}"
    echo "---------------------------"
    echo
	# Set verify_gccode
    read -ep "(请输入H323 gc服务器IP，留空默认获取网卡地址):" gc_ip
    [ -z "${gc_ip}" ] && gc_ip=${LOCAL_IP}
    echo
    echo "---------------------------"
    echo "H323 gc服务器IP = ${gc_ip}"
    echo "---------------------------"
    echo
	# Set old_ces
    read -ep "(是否为4.30以下CES服务器，1：是，留空默认不是):" old_ces
    [ -z "${old_ces}" ] && old_ces=0
    echo
    echo "---------------------------"
    echo "是否为4.30以下CES服务器 = ${old_ces}"
    echo "---------------------------"
    echo
	# Set port
    read -ep "(请输入服务器配置中心端口，不填则默认8443):" port
    [ -z "${port}" ] && port=8443
    echo
    echo "---------------------------"
    echo "CES配置中心端口 = ${port}"
    echo "---------------------------"
    echo
	# Set front
    read -ep "(请输入服务器会议业务端口，不填则默认1089):" front
    [ -z "${front}" ] && front=1089
    echo
    echo "---------------------------"
    echo "会议业务端口 = ${front}"
    echo "---------------------------"
    echo
}
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# Config H323
config_H323(){
    echo "正在写入H323服务器配置文件"
# H323 GC设备验证码	
    sed -i "s|<verify_code>.*|<verify_code>${verify_gccode}</verify_code>|"  /fsmeeting/h323gw_xd/gc/gc.xml
# H323 GC设备ID	
    sed -i "s|<h323gw_devid>.*|<h323gw_devid>${h323gw_gcdevid}</h323gw_devid>|"  /fsmeeting/h323gw_xd/gc/gc.xml
# CES数据库IP
    sed -i "s|<dbip>.*|<dbip>${ces_ip}</dbip>|" /fsmeeting/h323gw_xd/gc/gc.xml
# 是否为4.30以下CES
    sed -i "s|<old_ces.*|<old_ces type="'"private"'">${old_ces}</old_ces>|"  /fsmeeting/h323gw_xd/gc/gc.xml
# CES配置中心地址
	sed -i "s|<register_url>.*|<register_url>https://${ces_ip}:${port}</register_url>|"  /fsmeeting/h323gw_xd/gc/gc.xml
# CES前置地址
	sed -i "s|<front>.*|<front>TCP:${ces_ip}:${front};</front>|"  /fsmeeting/h323gw_xd/gc/gc.xml
# H323 GC本地IP	
	sed -i "s|<local_ip>.*|<local_ip>${LOCAL_IP}</local_ip>|"    /fsmeeting/h323gw_xd/gc/gc.xml
# H323 GM设备验证码
	sed -i "s|<verify_code>.*|<verify_code>${verify_gmcode}</verify_code>|"  /fsmeeting/h323gw_xd/gm/gm.xml
# H323 GM设备ID
    sed -i "s|<h323gw_devid>.*|<h323gw_devid>${h323gw_gmdevid}</h323gw_devid>|"  /fsmeeting/h323gw_xd/gm/gm.xml
# H323 GC设备ID
    sed -i "s|<dev_id>.*|<dev_id>${h323gw_gcdevid}</dev_id>|" /fsmeeting/h323gw_xd/gm/gm.xml
# H323 GC服务器IP
	sed -i "s|<tcp>.*|<tcp>tcp:${gc_ip}:1088</tcp>|"  /fsmeeting/h323gw_xd/gm/gm.xml
# H323 GM本地IP
	sed -i "s|<local_ip>.*|<local_ip>${LOCAL_IP}</local_ip>|"    /fsmeeting/h323gw_xd/gm/gm.xml
	echo "写入成功，正在重启H323服务器，请耐心等待"
}

pre_install_H323
config_H323

#重启H323服务器
supervisorctl restart all