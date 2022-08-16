#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年4月20日                         "*
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
# Pre-installation settings
pre_install_webapp(){
    # Set Main_ip
    read -ep "(请输入服务器IP地址或者域名):" main_ip
    [ -z "${Main_ip}" ]
    echo
    echo "---------------------------"
    echo "CES服务器IP = ${main_ip}"
    echo "---------------------------"
    echo
	# Set WSPort
    read -ep "(请输入WS的端口，不填则默认4432):" WSPort
    [ -z "${WSPort}" ] && WSPort=4432
    echo
    echo "---------------------------"
    echo "WS端口 = ${WSPort}"
    echo "---------------------------"
    echo
    # Set IsUseWss
    read -ep "(是否启用ws协议 1：启用 不填则默认不启用):" UseWss
    [ -z "${UseWss}" ] && UseWss=0
    echo
    echo "---------------------------"
    echo "ws协议 = ${UseWss}"
    echo "---------------------------"
    echo
    # Set IsUseFspWbSrv
    read -ep "(是否启用fsp白板 1：启用 不填则默认不启用):" UseFspWbSrv
    [ -z "${UseFspWbSrv}" ] && UseFspWbSrv=0
    echo
    echo "---------------------------"
    echo "FSP白板 = ${UseFspWbSrv}"
    echo "---------------------------"
    echo
	# Set FspAccessAddr
    read -ep "(请输入FSP服务器IP地址):" AccessAddr
    [ -z "${AccessAddr}" ] 
    echo
    echo "---------------------------"
    echo "FSP服务器IP = ${AccessAddr}"
    echo "---------------------------"
    echo
	# Set FspPort
    read -ep "(请输入FSP服务器端口，不填则默认21000):" FspPort
    [ -z "${FspPort}" ] && FspPort=21000
    echo
    echo "---------------------------"
    echo "FSP服务器端口 = ${FspPort}"
    echo "---------------------------"
    echo
	# Set Domain
    read -ep "(请输入fsp域，不填则默认pri):" Domain
    [ -z "${Domain}" ] && Domain=pri
    echo
    echo "---------------------------"
    echo "FSP域 = ${Domain}"
    echo "---------------------------"
    echo
}

# Config webapp
config_webapp(){
    echo "正在写入webapp配置文件"	
    sed -i "s|<IsUseWss>.*|<IsUseWss>${UseWss}</IsUseWss>|"  /usr/local/hst/FMWebProxy/service_config.xml
    sed -i "s|<LocalAddr>.*|<LocalAddr>wss://${main_ip}:${WSPort}</LocalAddr>|"  /usr/local/hst/FMWebProxy/service_config.xml
    sed -i "s|<IsUseFspWbSrv>.*|<IsUseFspWbSrv>${UseFspWbSrv}</IsUseFspWbSrv>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<FspAccessAddr>.*|<FspAccessAddr>${AccessAddr}:${FspPort}</FspAccessAddr>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<FspDomain>.*|<FspDomain>${Domain}</FspDomain>|" /usr/local/hst/FMServer/ServiceConfig.xml    
	echo "写入成功，正在重启FMservice服务，请耐心等待"
}

pre_install_webapp
config_webapp

#重启FMservice服务
service fmservice restart