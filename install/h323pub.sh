#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年9月2日                          "*
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
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# Pre-installation settings
pre_install_H323(){
    # Set h323gw_devid
    read -ep "(请输入下沉网关的网关号，BOSS后台获取):" h323gw_devid
    [ -z "${h323gw_devid}" ]
    echo
    echo "---------------------------"
    echo "下沉网关的网关号 = ${h323gw_devid}"
    echo "---------------------------"
    echo
    # Set verify_code
    read -ep "(请输入下沉网关的验证码，BOSS后台获取):" verify_code
    [ -z "${verify_code}" ] 
    echo
    echo "---------------------------"
    echo "下沉网关的验证码 = ${verify_code}"
    echo "---------------------------"
    echo
	# Set company_id
    read -ep "(请输入企业ID，BOSS后台获取):" company_id
    [ -z "${company_id}" ] 
    echo
    echo "---------------------------"
    echo "企业ID = ${company_id}"
    echo "---------------------------"
    echo
	# Set local_ip
    read -ep "(请输入gc本机地址，留空默认获取网卡IP):" local_ip
    [ -z "${local_ip}" ] && local_ip=${IP}
    echo
    echo "---------------------------"
    echo "gc本机地址 = ${local_ip}"
    echo "---------------------------"
    echo
    # Set domain
    read -ep "(请输入企业所在域，没特别需求此项请留空):" domain
    [ -z "${domain}" ] && domain=fsp2
    echo
    echo "---------------------------"
    echo "企业所在域 = ${domain}"
    echo "---------------------------"
    echo
	# Set app_id
    read -ep "(请输入网关的应用ID，没特别需求此项请留空):" app_id
    [ -z "${app_id}" ] && app_id=2688c8f746ebc1b28d968d2f1823d704
    echo
    echo "---------------------------"
    echo "网关的应用id = ${app_id}"
    echo "---------------------------"
    echo
	# Set access_addr
    read -ep "(请输入fsp access地址，没特别需求此项请留空):" access_addr
    [ -z "${access_addr}" ] && access_addr=https://mt.hst.com/paas/server/address
    echo
    echo "---------------------------"
    echo "fsp access地址 = ${access_addr}"
    echo "---------------------------"
    echo
	# Set app_key
    read -ep "(请输入访问配置中心需要的key，没特别需求此项请留空):" app_key
    [ -z "${app_key}" ] && app_key=a4483b4aa16578ef714c8162717bd0aa
    echo
    echo "---------------------------"
    echo "配置中心需要的key = ${app_key}"
    echo "---------------------------"
    echo
	# Set GateWebSocketUrl
    read -ep "(请输入运维网关的web地址,没特别需求此项请留空):" GateWebSocketUrl
    [ -z "${GateWebSocketUrl}" ] && GateWebSocketUrl=wss://omc-gw.hst.com/websocket
    echo
    echo "---------------------------"
    echo "运维网关的web地址 = ${GateWebSocketUrl}"
    echo "---------------------------"
    echo
}
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# Config H323
config_H323(){
    echo "正在写入H323服务器配置文件"
    sed -i "s|<h323gw_devid>.*|<h323gw_devid>${h323gw_devid}</h323gw_devid>|"  /fsmeeting/h323gw_xd/gc/gc.xml
    sed -i "s|<verify_code>.*|<verify_code>${verify_code}</verify_code>|"  /fsmeeting/h323gw_xd/gc/gc.xml
    sed -i "s|<domain>.*|<domain>${domain}</domain>|" /fsmeeting/h323gw_xd/gc/gc.xml
    sed -i "s|<app_id>.*|<app_id>${app_id}</app_id>|"  /fsmeeting/h323gw_xd/gc/gc.xml
	sed -i "s|<company_id>.*|<company_id>${company_id}</company_id>|"  /fsmeeting/h323gw_xd/gc/gc.xml
	sed -i "s|<access_addr>.*|<access_addr>${access_addr}</access_addr>|"  /fsmeeting/h323gw_xd/gc/gc.xml
	sed -i "s|<local_ip>.*|<local_ip>${local_ip}</local_ip>|"    /fsmeeting/h323gw_xd/gc/gc.xml
	sed -i "s|<front>.*|<front>TCP:a.hst.com:1089;TCP:t.hst.com:1089;</front>|"  /fsmeeting/h323gw_xd/gc/gc.xml
    sed -i "s|<app_key>.*|<app_key>${app_key}</app_key>|"  /fsmeeting/h323gw_xd/gc/gc.xml
#    sed -i "s|<h323gw_devid>.*|<h323gw_devid>${h323gw_devid}</h323gw_devid>|"  /fsmeeting/h323gw_xd/gm/gm.xml
#    sed -i "s|<verify_code>.*|<verify_code>${verify_code}</verify_code>|"  /fsmeeting/h323gw_xd/gm/gm.xml
	sed -i "s|<local_ip>.*|<local_ip>${local_ip}</local_ip>|"    /fsmeeting/h323gw_xd/gm/gm.xml
	sed -i "s|<dev_id>.*|<dev_id>${h323gw_devid}</dev_id>|"    /fsmeeting/h323gw_xd/gm/gm.xml
    sed -i "s|<tcp>.*|<tcp>tcp:${local_ip}:1088</tcp>|"    /fsmeeting/h323gw_xd/gm/gm.xml
    sed -i "s|<GateWebSocketUrl>.*|<GateWebSocketUrl>${GateWebSocketUrl}</GateWebSocketUrl>|"    /fsmeeting/ma323/ma323_config.xml
    sed -i "s|Ice.Default.Locator.*|Ice.Default.Locator = FMServiceIceGrid/Locator:tcp -h boss-ice1.hst.com -p 10001:tcp -h boss-ice2.hst.com -p 10001|"  /fsmeeting/h323gw_xd/gc/ice.property.cfg
	echo "写入成功，正在重启H323服务器，请耐心等待"
}

pre_install_H323
config_H323

#重启H323服务器
supervisorctl restart all