#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年4月13日                         "*
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
# Pre-installation settings
pre_install_H323 gm(){
    # Set h323gw_gcdevid
    read -p "(请输入H323 gm网关设备ID，):" h323gw_devid
    [ -z "${h323gw_devid}" ] 
    echo
    echo "---------------------------"
    echo "H323 gm网关设备设备ID = ${h323gw_devid}"
    echo "---------------------------"
    echo
    # Set verify_gccode
    read -p "(请输入H323 gm网关设备验证码):" verify_code
    [ -z "${verify_code}" ] 
    echo
    echo "---------------------------"
    echo "H323 gm网关设备验证码 = ${verify_code}"
    echo "---------------------------"
    echo
	# Set h323gw_gmdevid
    read -p "(请输入H323 gc网关设备ID):" h323gw_gcdevid
    [ -z "${h323gw_gcdevid}" ]
    echo
    echo "---------------------------"
    echo "H323 gc网关设备ID = ${h323gw_gcdevid}"
    echo "---------------------------"
    echo
	# Set verify_gccode
    read -p "(请输入H323 gc服务器IP):" gc_ip
    [ -z "${gc_ip}" ]
    echo
    echo "---------------------------"
    echo "H323 gc服务器IP = ${gc_ip}"
    echo "---------------------------"
    echo
}
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# Config H323
config_H323(){
    echo "正在写入H323 gm服务器配置文件"	
    sed -i "s|<verify_code>.*|<verify_code>${verify_code}</verify_code>|"  /fsmeeting/h323gw_xd/gm/gm.xml
    sed -i "s|<h323gw_devid>.*|<h323gw_devid>${h323gw_devid}</h323gw_devid>|"  /fsmeeting/h323gw_xd/gm/gm.xml
    sed -i "s|dev_id>.*|dev_id>${h323gw_gcdevid}</dev_id>|" /fsmeeting/h323gw_xd/gm/gm.xml
	sed -i "s|<tcp>.*|<tcp>tcp:${gc_ip};:1088</tcp>|"  /fsmeeting/h323gw_xd/gm/gm.xml
	sed -i "s|<local_ip>.*|<local_ip>=${IP}</local_ip>|"    /fsmeeting/h323gw_xd/gm/gm.xml
	echo "写入成功，正在重启H323 gm服务器，请耐心等待"
}

pre_install_H323
config_H323
#重启H323服务器
supervisorctl restart all