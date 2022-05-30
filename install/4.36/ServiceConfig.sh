#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年5月30日                         "*
echo -e "#                                                      "*
echo -e "# *请按照提示填写相应的参数                            "* 
echo -e "#                                                      "*
echo -e "# *如有不明白选项可以保持默认                          "*
echo -e "#                                                      "*
echo -e "# *如有问题或者遗漏的参数信息，请及时反馈              "*
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "                                                       "
# Pre-installation settings
pre_install_ServiceConfig(){
# Set ces_ip
    read -ep "(请输入CES服务器IP):" ces_ip
    [ -z "${ces_ip}" ]
    echo
    echo "---------------------------"
    echo "CES服务器IP = ${ces_ip}"
    echo "---------------------------"
    echo
# Set fsp_ip
    read -ep "(请输入FSP服务器IP):" fsp_ip
    [ -z "${fsp_ip}" ] 
    echo
    echo "---------------------------"
    echo "FSP服务器IP = ${fsp_ip}"
    echo "---------------------------"
    echo
# Set live-fb_ip
    read -ep "(请输入live-fb服务器IP，如没有请留空):" live_ip
    [ -z "${live_ip}" ] && live_ip=127.0.0.1
    echo
    echo "---------------------------"
    echo "live-fb服务器IP = ${live_ip}"
    echo "---------------------------"
    echo
# Set UserId
    read -ep "(请输入开发者账号id):" UserId
    [ -z "${UserId}" ] 
    echo
    echo "---------------------------"
    echo "开发者账号id = ${UserId}"
    echo "---------------------------"
    echo
 # Set SecretKey
    read -ep "(请输入开发者密钥):" SecretKey
    [ -z "${SecretKey}" ] 
    echo
    echo "---------------------------"
    echo "开发者密钥 = ${SecretKey}"
    echo "---------------------------"
    echo
# Set AppId
    read -ep "(请输入开发者创建的应用id):" AppId
    [ -z "${AppId}" ] 
    echo
    echo "---------------------------"
    echo "开发者创建的应用id = ${AppId}"
    echo "---------------------------"
    echo
# Set IsUseFspWbSrv
    read -ep "(是否使用fsp白板服务:0不使用):" IsUseFspWbSrv
    [ -z "${IsUseFspWbSrv}" ] && IsUseFspWbSrv=1
    echo
    echo "---------------------------"
    echo "使用fsp白板服务 = ${IsUseFspWbSrv}"
    echo "---------------------------"
    echo
# Set FspDomain
    read -ep "(请输入fsp域，不填则默认pri):" FspDomain
    [ -z "${FspDomain}" ] && FspDomain=pri
    echo
    echo "---------------------------"
    echo "FSP域 = ${FspDomain}"
    echo "---------------------------"
    echo
}

# Config ServiceConfig
config_ServiceConfig(){
    echo "正在写入FMserver配置文件"	
    sed -i "s|<RabbitMQBroker>.*|<RabbitMQBroker>${fsp_ip}:24000:root:root@/</RabbitMQBroker>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<UserId>.*|<UserId>${UserId}</UserId>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<SecretKey>.*|<SecretKey>${SecretKey}</SecretKey>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<AppId>.*|<AppId>${AppId}</AppId>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<FspAccessAddr>.*|<FspAccessAddr>http://${fsp_ip}:20020</FspAccessAddr>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<FspDomain>.*|<FspDomain>${FspDomain}</FspDomain>|" /usr/local/hst/FMServer/ServiceConfig.xml    
    #sed -i "s|<IsUseFspWbSrv>.*|<IsUseFspWbSrv>${IsUseFspWbSrv}</IsUseFspWbSrv>|" /usr/local/hst/FMServer/ServiceConfig.xml    
    #sed -i "s|<LocalAddr>.*|<LocalAddr>ws://${fsp_ip}:4432</IsUseFspWbSrv>|" /usr/local/hst/FMWebProxy/service_config.xml
	#sed -i "s|<IsUseWss>.*|<IsUseWss>0</IsUseWss>|" /usr/local/hst/FMWebProxy/service_config.xml
    #sed -i "s|Ice.Default.Locator.*|Ice.Default.Locator = LiveServiceIceGrid/Locator:ssl -h ${live_ip} -p 10000|" /usr/local/hst/FMServer/live_ice.cfg
    echo "写入成功，正在重启，请耐心等待"
}

pre_install_ServiceConfig
config_ServiceConfig

#重启FMservice服务
service fmservice restart