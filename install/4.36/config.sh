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
docker_id=`docker ps|grep fsp_pri|awk '{print $1}'`
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# Pre-installation settings
pre_install_config(){
# Set ces_ip
    read -ep "(请输入CES服务器IP):" ces_ip
    [ -z "${ces_ip}" ]
    echo 
    echo "---------------------------"
    echo "CES服务器IP = ${ces_ip}"
    echo "---------------------------"
    echo
# Set record_ip
    read -ep "(请输入录制服务器IP):" record_ip
    [ -z "${record_ip}" ] 
    echo 
    echo "---------------------------"
    echo "录制服务器IP = ${record_ip}"
    echo "---------------------------"
    echo
# Set fsp_ip
    read -ep "(请输入FSP服务器IP，若与CES地址一致直接回车即可):" fsp_ip
    [ -z "${fsp_ip}" ] && fsp_ip=${ces_ip}
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
# Set media
    read -ep "(请输入直播media地址，如没有请留空):" media
    [ -z "${media}" ] && media=127.0.0.1
    echo
    echo "---------------------------"
    echo "直播media地址 = ${media}"
    echo "---------------------------"
    echo
# Set liveurl
    read -ep "(请输入直播liveurl地址，如没有请留空):" liveurl
    [ -z "${liveurl}" ] && liveurl=127.0.0.1
    echo
    echo "---------------------------"
    echo "直播liveurl地址 = ${liveurl}"
    echo "---------------------------"
    echo
# Set APAAAS
    read -ep "(请输入apaas地址，如没有请留空):" APAAAS
    [ -z "${APAAAS}" ] && APAAAS=127.0.0.1
    echo
    echo "---------------------------"
    echo "APAAAS地址 = ${APAAAS}"
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
# AppSecretKey
    read -ep "(请输入开发者创建的应用密钥):" AppSecretKey
    [ -z "${AppSecretKey}" ] 
    echo
    echo "---------------------------"
    echo "开发者创建的应用id = ${AppSecretKey}"
    echo "---------------------------"
    echo
# Set IsUseFspWbSrv
    #read -ep "(是否使用fsp白板服务:0不使用):" IsUseFspWbSrv
    #[ -z "${IsUseFspWbSrv}" ] && IsUseFspWbSrv=1
    #echo
    #echo "---------------------------"
    #echo "使用fsp白板服务 = ${IsUseFspWbSrv}"
    #echo "---------------------------"
    #echo
# Set FspDomain
    read -ep "(请输入fsp域，不填则默认pri):" FspDomain
    [ -z "${FspDomain}" ] && FspDomain=pri
    echo
    echo "---------------------------"
    echo "FSP域 = ${FspDomain}"
    echo "---------------------------"
    echo
}

# Config apaas
config_apaas(){
    echo "正在写入fsp配置文件（由于本人技术有限，此项仅限于第一次安装FSP v1.8.3.5使用）"		
    docker exec -ti $docker_id sed -i "s|app-id: 9c45c27746abcaee27852e6279d15814|app-id: ${AppId}|"  /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "s|secret: 42dade007e0863e8|secret: ${AppSecretKey}|"  /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "s|videoDomain.*|videoDomain: http://${fsp_ip}:29000/child/live/media/player|"  /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "s|address: http://127.0.0.1:28001|address: http://${fsp_ip}:28001|"  /boss/admin-web/conf/application.yml
    docker exec -ti $docker_id sed -i "s|roomAddr.*|roomAddr: ${fsp_ip}:25704|" /boss/boss-pri-cloud-gw/conf/application.yml
    docker exec -ti $docker_id sed -i "s|mcuAddr.*|mcuAddr: ${ces_ip}:1089|" /boss/boss-pri-cloud-gw/conf/application.yml
    docker exec -ti $docker_id sed -i "s|url: http://47.107.67.240:8080/fmapi/webservice/jaxws?wsdl|url: http://${ces_ip}:8080/fmapi/webservice/jaxws?wsdl|" /boss/boss-pri-cloud-gw/conf/application.yml
    docker exec -ti $docker_id sed -i "s|id: 9f08cb39074bb831586ce998fd983206|id: ${UserId}|" /boss/pri-bgw/conf/application.yml
    docker exec -ti $docker_id sed -i "s|secret: c30878b783e17dcb|secret: ${SecretKey}|" /boss/pri-bgw/conf/application.yml    
}
config_env(){
    echo "正在写入env配置文件"	
    sed -i "s|DATABASE_IP.*|DATABASE_IP=\"${ces_ip}\"|"  /usr/local/hst/.env
    sed -i "s|FM_SERVER_IP.*|FM_SERVER_IP=\"${ces_ip}\"|"  /usr/local/hst/.env
    sed -i "s|FSP_ICE_IP.*|FSP_ICE_IP=\"${ces_ip}\"|"  /usr/local/hst/.env
    sed -i "s|FSP_DEV_ID.*|FSP_DEV_ID=\"${UserId}\"|"  /usr/local/hst/.env
    sed -i "s|FSP_DEV_SECRET.*|FSP_DEV_SECRET=\"${SecretKey}\"|"  /usr/local/hst/.env
    sed -i "s|LIVE_MEDIA.*|LIVE_MEDIA=\"http://${media}:9096\"|" /usr/local/hst/.env   
    sed -i "s|LIVE_URL.*|LIVE_URL=\"http://${liveurl}:9096\"|" /usr/local/hst/.env   
    sed -i "s|PAAS_URL.*|PAAS_URL=\"http://${APAAAS}:9096\"|" /usr/local/hst/.env
    sed -i "s|LIVE_APP_KEY.*|LIVE_APP_KEY=\"2c60f53dfd0c4dbb95640e45388e4d37\"|" /usr/local/hst/.env
    sed -i "s|LIVE_APP_SECRET.*|LIVE_APP_SECRET=\"18dacf578bc2fc56\"|" /usr/local/hst/.env	
}
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
    echo "写入成功，正在重启服务器，稍后请重新登录服务器"
}
pre_install_config
config_apaas
config_env
config_ServiceConfig
#重启服务器
sh set_wb_app_id.sh ${AppId} && sh set_extra_ip.sh ${IP} && sh set_protocol_addr.sh ws ${fsp_ip} && reboot