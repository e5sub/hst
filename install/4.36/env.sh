#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年5月27日                         "*
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
pre_install_env(){
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
}

# Config ServiceConfig
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
	echo "写入成功，正在重启docker，请耐心等待"
}

pre_install_env
config_env

#重启docker
docker-compose down && docker-compose up -d
