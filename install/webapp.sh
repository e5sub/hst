#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Pre-installation settings
pre_install_webapp(){
    # Set Main_ip
    read -p "(请输入服务器IP地址或者域名):" main_ip
    [ -z "${Main_ip}" ]
    echo
    echo "---------------------------"
    echo "CES服务器IP = ${main_ip}"
    echo "---------------------------"
    echo
	# Set WSPort
    read -p "(请输入WS的端口，不填则默认4432):" WSPort
    [ -z "${WSPort}" ] && WSPort=4432
    echo
    echo "---------------------------"
    echo "WS端口 = ${WSPort}"
    echo "---------------------------"
    echo
    # Set IsUseWss
    read -p "(是否启用ws协议 1：启用 不填则默认不启用):" IsUseWss
    [ -z "${IsUseWss}" ] && IsUseWss=0
    echo
    echo "---------------------------"
    echo "IsUseWss = ${IsUseWss}"
    echo "---------------------------"
    echo
    # Set IsUseFspWbSrv
    read -p "(是否启用fsp白板 1：启用 不填则默认不启用):" IsUseFspWbSrv
    [ -z "${IsUseFspWbSrv}" ] && IsUseFspWbSrv=0
    echo
    echo "---------------------------"
    echo "IsUseFspWbSrv = ${IsUseFspWbSrv}"
    echo "---------------------------"
    echo
	# Set FspAccessAddr
    read -p "(请输入FSP服务器IP地址):" FspAccessAddr
    [ -z "${FspAccessAddr}" ] 
    echo
    echo "---------------------------"
    echo "FSP服务器IP = ${FspAccessAddr}"
    echo "---------------------------"
    echo
	# Set FspPort
    read -p "(请输入FSP服务器端口，不填则默认21000):" FspPort
    [ -z "${FspPort}" ] && FspPort=21000
    echo
    echo "---------------------------"
    echo "FSP服务器端口 = ${FspPort}"
    echo "---------------------------"
    echo
	# Set FspPort
    read -p "(请输入fsp域，不填则默认pri):" FspDomain
    [ -z "${FspDomain}" ] && FspDomain=pri
    echo
    echo "---------------------------"
    echo "FspDomain = ${FspDomain}"
    echo "---------------------------"
    echo
}

# Config webapp
config_webapp(){
    echo "正在写入节点配置文件"	
    sed -i "s|<IsUseWss>.*|<IsUseWss>${IsUseWss}</IsUseWss>|"  /usr/local/hst/FMWebProxy/service_config.xml
    sed -i "s|<LocalAddr>.*|<LocalAddr>wss://${main_ip}:${WSPort}</LocalAddr>|"  /usr/local/hst/FMWebProxy/service_config.xml
    sed -i "s|<IsUseFspWbSrv>.*|<IsUseFspWbSrv>$IsUseFspWbSrv</IsUseFspWbSrv>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<FspAccessAddr>.*|<FspAccessAddr>${FspAccessAddr}:${FspPort}</FspAccessAddr>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<FspDomain>.*|<FspDomain>${FspDomain}</FspDomain>|" /usr/local/hst/FMServer/ServiceConfig.xml    
	echo "写入成功"
}

pre_install_webapp
config_webapp

#重启FMservice服务
service fmservice restart