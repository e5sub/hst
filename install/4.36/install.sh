#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年8月17日                         "*
echo -e "#                                                      "*
echo -e "# *博客：https://www.yaohst.com                        "*
echo -e "#                                                      "*
echo -e "# *作者：Sugar                                         "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *使用此脚本前，请将脚本服务器安装包放在同一目录下    "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
#获取内外网IP地址
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
##########################################################################################以下是服务器安装脚本##########################################################################################
## 自动下载FSP
    if [[ -z "${ces}" ]]; then    
        read -e -r -p "安装CES和FSP服务器(y) or 修改配置文件(n)？留空安装服务器[y/n] " input
        case $input in
        [yY][eE][sS] | [yY])        
            ;;
        [nN][oO] | [nN])
            ces=true		
            ;;
        *)  		
            ;;
            esac        
    fi
    if [[ -z "${ces}" ]]; then
    echo "已选择安装服务器"
pre_install_config(){
# Set version
    echo ""
    echo -e "输入 cluster main 安装集群版，输入 cluster node 安装节点服务器"
    echo ""
    read -ep "(请输入要安装的版本，留空则安装单机版):" version
    [ -z "${version}" ] && version=single
    echo 
    echo "---------------------------"
    echo "安装版本 = ${version}"
    echo "---------------------------"
    echo
}
pre_install_config
#解压CES、FSP安装包
    tar -zxvf ces_linux*.tar.gz && tar -zxvf fsp_pack*.tar.gz
#安装CES服务器
    cd ces_linux*/ && bash server_install.sh ${version}
#安装FSP服务器
    cd .. && cd fsp_pack && bash docker_install.sh  
    else
	echo "已选择修改配置文件"
#修改服务器配置文件
    docker_id=`docker ps|grep fsp|awk '{print $1}'`		
pre_config(){
# Set ces_ip
    read -ep "(请输入CES服务器IP，留空自动获取网卡IP):" ces_ip
    [ -z "${ces_ip}" ] && ces_ip=${IP}
    echo 
    echo "---------------------------"
    echo "CES服务器IP = ${ces_ip}"
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
    read -ep "(请输入live-fb服务器IP，若没有请留空):" live_ip
    [ -z "${live_ip}" ] && live_ip=${ces_ip}
    echo
    echo "---------------------------"
    echo "live-fb服务器IP = ${live_ip}"
    echo "---------------------------"
    echo
# Set media
    read -ep "(请输入直播media地址，若没有请留空):" media
    [ -z "${media}" ] && media=${ces_ip}
    echo
    echo "---------------------------"
    echo "直播media地址 = ${media}"
    echo "---------------------------"
    echo
# Set liveurl
    read -ep "(请输入直播liveurl地址，若没有请留空):" liveurl
    [ -z "${liveurl}" ] && liveurl=${ces_ip}
    echo
    echo "---------------------------"
    echo "直播liveurl地址 = ${liveurl}"
    echo "---------------------------"
    echo
# Set APAAAS
    read -ep "(请输入apaas地址，若没有请留空):" APAAAS
    [ -z "${APAAAS}" ] && APAAAS=${ces_ip}
    echo
    echo "---------------------------"
    echo "APAAAS地址 = ${APAAAS}"
    echo "---------------------------"
    echo	
# Set UserId
    read -ep "(请输入开发者账号id，登陆FSP后台后获取):" UserId
    [ -z "${UserId}" ] 
    echo
    echo "---------------------------"
    echo "开发者账号id = ${UserId}"
    echo "---------------------------"
    echo
# Set SecretKey
    read -ep "(请输入开发者密钥，登陆FSP后台后获取):" SecretKey
    [ -z "${SecretKey}" ] 
    echo
    echo "---------------------------"
    echo "开发者密钥 = ${SecretKey}"
    echo "---------------------------"
    echo
# Set AppId
    read -ep "(请输入开发者创建的应用id，若没更改过请留空):" AppId
    [ -z "${AppId}" ] && AppId=3049291591cb6aed78e638c2aed53867
    echo
    echo "---------------------------"
    echo "开发者创建的应用id = ${AppId}"
    echo "---------------------------"
    echo
# Set AppSecretKey
    read -ep "(请输入开发者创建的应用密钥，若没更改过请留空):" AppSecretKey
    [ -z "${AppSecretKey}" ] && AppSecretKey=16753469423db000
    echo
    echo "---------------------------"
    echo "开发者创建的应用id = ${AppSecretKey}"
    echo "---------------------------"
    echo
# Set ces_prot
    read -ep "(请输入CES会议业务端口，默认1089端口):" ces_prot
    [ -z "${ces_prot}" ] && ces_prot=1089
    echo
    echo "---------------------------"
    echo "CES会议业务端口 = ${ces_prot}"
    echo "---------------------------"
    echo
# Set https_prot
    read -ep "(请输入CES配置中心端口，默认8443端口):" https_prot
    [ -z "${https_prot}" ] && https_prot=8443
    echo
    echo "---------------------------"
    echo "CES配置中心端口 = ${https_prot}"
    echo "---------------------------"
    echo
# Set IsUseFspWbSrv
    read -ep "(是否使用fsp白板服务，留空默认使用):" IsUseFspWbSrv
    [ -z "${IsUseFspWbSrv}" ] && IsUseFspWbSrv=1
    echo
    echo "---------------------------"
    echo "使用fsp白板服务 = ${IsUseFspWbSrv}"
    echo "---------------------------"
    echo
# Set FspDomain
    read -ep "(请输入fsp域，留空默认pri):" FspDomain
    [ -z "${FspDomain}" ] && FspDomain=pri
    echo
    echo "---------------------------"
    echo "FSP域 = ${FspDomain}"
    echo "---------------------------"
    echo
# Set ces_Domain
    read -ep "(请输入CES服务器域名，若没有请留空):" ces_Domain
    [ -z "${ces_Domain}" ] && ces_Domain=ces.haoshitong.com
    echo 
    echo "---------------------------"
    echo "CES服务器域名 = ${ces_Domain}"
    echo "---------------------------"
    echo
}
# Config apaas
config_apaas(){
    echo "正在写入fsp配置文件"		
    docker exec -ti $docker_id sed -i "104s|app-id.*|app-id: ${AppId}|"  /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "105s|secret.*|secret: ${AppSecretKey}|"  /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "s|videoDomain.*|videoDomain: http://${fsp_ip}:29000/child/live/media/player|"  /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "36s|url.*|url: http://${ces_Domain}:8080/fmapi/webservice/jaxws?wsdl|"  /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "39s|url.*|url: http://${ces_ip}:8080/|" /boss/boss-pri-cloud-apaas/conf/application.yml
    docker exec -ti $docker_id sed -i "13s|address.*|address: http://${fsp_ip}:28001|"  /boss/admin-web/conf/application.yml
    docker exec -ti $docker_id sed -i "s|roomAddr.*|roomAddr: ${fsp_ip}:25704|" /boss/boss-pri-cloud-gw/conf/application.yml
    docker exec -ti $docker_id sed -i "s|mcuAddr.*|mcuAddr: ${ces_ip}:${ces_prot}|" /boss/boss-pri-cloud-gw/conf/application.yml
    docker exec -ti $docker_id sed -i "59s|url.*|url: https://${ces_Domain}:${https_prot}/fmapi/webservice/jaxws?wsdl|" /boss/boss-pri-cloud-gw/conf/application.yml
    docker exec -ti $docker_id sed -i "106s|id.*|id: ${UserId}|" /boss/pri-bgw/conf/application.yml
    docker exec -ti $docker_id sed -i "107s|secret.*|secret: ${SecretKey}|" /boss/pri-bgw/conf/application.yml
    docker exec -ti $docker_id echo "127.0.0.1   ces.haoshitong.com">> /etc/hosts
	docker exec -ti $docker_id echo "127.0.0.1   interface.haoshitong.com">> /etc/hosts
    #docker exec -i $docker_id mysql -uroot -phst@2019.Paas -P27000 video_record<record.sql    
} 
config_env(){
    echo "正在写入env配置文件"	
    sed -i "s|DATABASE_IP.*|DATABASE_IP=\"${ces_ip}\"|"  /usr/local/hst/.env
    sed -i "s|FM_SERVER_IP.*|FM_SERVER_IP=\"${ces_ip}\"|"  /usr/local/hst/.env
    sed -i "s|FSP_ICE_IP.*|FSP_ICE_IP=\"${ces_ip}\"|"  /usr/local/hst/.env
    sed -i "s|FSP_DEV_ID.*|FSP_DEV_ID=\"${UserId}\"|"  /usr/local/hst/.env
    sed -i "s|FSP_DEV_SECRET.*|FSP_DEV_SECRET=\"${SecretKey}\"|"  /usr/local/hst/.env
    sed -i "s|LIVE_MEDIA.*|LIVE_MEDIA=\"https://${media}:9096\"|" /usr/local/hst/.env   
    sed -i "s|LIVE_URL.*|LIVE_URL=\"https://${liveurl}:9096\"|" /usr/local/hst/.env   
    sed -i "s|PAAS_URL.*|PAAS_URL=\"https://${APAAAS}:9096\"|" /usr/local/hst/.env
    sed -i "s|LIVE_APP_KEY.*|LIVE_APP_KEY=\"2c60f53dfd0c4dbb95640e45388e4d37\"|" /usr/local/hst/.env
    sed -i "s|LIVE_APP_SECRET.*|LIVE_APP_SECRET=\"18dacf578bc2fc56\"|" /usr/local/hst/.env	
}
config_ServiceConfig(){
    echo "正在写入FMserver配置文件"	
    sed -i "s|<RabbitMQBroker>.*|<RabbitMQBroker>${fsp_ip}:24000:root:root@/</RabbitMQBroker>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<UserAuthAddr>.*|<UserAuthAddr>https://127.0.0.1:${https_prot}</UserAuthAddr>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<ConfigCenter>.*|<ConfigCenter>https://127.0.0.1:${https_prot}</ConfigCenter>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<UserId>.*|<UserId>${UserId}</UserId>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<SecretKey>.*|<SecretKey>${SecretKey}</SecretKey>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<AppId>.*|<AppId>${AppId}</AppId>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "95s|<FspAccessAddr>.*|<FspAccessAddr>http://${fsp_ip}:20020/server/address</FspAccessAddr>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "239s|<FspAccessAddr>.*|<FspAccessAddr>http://${fsp_ip}:20020</FspAccessAddr>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<FspDomain>.*|<FspDomain>${FspDomain}</FspDomain>|" /usr/local/hst/FMServer/ServiceConfig.xml    
    sed -i "s|<IsUseFspWbSrv>.*|<IsUseFspWbSrv>${IsUseFspWbSrv}</IsUseFspWbSrv>|" /usr/local/hst/FMServer/ServiceConfig.xml    
    sed -i "s|<LocalAddr>.*|<LocalAddr>wss://${fsp_ip}:4432</LocalAddr>|" /usr/local/hst/FMWebProxy/service_config.xml
    sed -i "s|<IsUseWss>.*|<IsUseWss>1</IsUseWss>|" /usr/local/hst/FMWebProxy/service_config.xml
    sed -i "s|Ice.Default.Locator.*|Ice.Default.Locator = LiveServiceIceGrid/Locator:ssl -h ${live_ip} -p 10000|" /usr/local/hst/FMServer/live_ice.cfg
    echo "写入成功，正在重启服务器，稍后请重新登录服务器"
}
pre_config
config_apaas
config_env
config_ServiceConfig
#添加宿主机hosts解析，防止重启之后FSP端口启动不了
echo "127.0.0.1   ces.haoshitong.com">> /etc/hosts
echo "127.0.0.1   interface.haoshitong.com">> /etc/hosts
#重启服务器
sh set_wb_app_id.sh ${AppId} && sh set_extra_ip.sh ${IP} && sh set_protocol_addr.sh wss ${fsp_ip} && reboot
    fi

