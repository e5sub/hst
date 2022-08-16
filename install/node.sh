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
pre_install_node(){
    # Set Main_ip
    read -ep "(请输入主服务器IP地址或者域名):" main_ip
    [ -z "${Main_ip}" ]
    echo
    echo "---------------------------"
    echo "CES主服务器IP = ${main_ip}"
    echo "---------------------------"
    echo
    # Set main DevID
    read -ep "(请输入节点ID):" main_DevID
    [ -z "${Main_DevID}" ]
    echo
    echo "---------------------------"
    echo "节点ID = ${main_DevID}"
    echo "---------------------------"
    echo
    # Set Main_VerifyCode
    read -ep "(请输入节点验证码):" Main_VerifyCode
    [ -z "${Main_VerifyCode}" ] 
    echo
    echo "---------------------------"
    echo "节点验证码 = ${Main_VerifyCode}"
    echo "---------------------------"
    echo
	# Set Main_port
    read -ep "(请输入主服务器HTTPS端口，不填则默认8443):" Main_port
    [ -z "${Main_port}" ] && Main_port=8443
    echo
    echo "---------------------------"
    echo "CES主服务器端口 = ${Main_port}"
    echo "---------------------------"
    echo
}

# Config node
config_node(){
    echo "正在写入节点配置文件"	
    sed -i "s|<LicenseMgrService>.*|<LicenseMgrService>${main_ip}:1091</LicenseMgrService>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<DevID>.*|<DevID>${main_DevID}</DevID>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<VerifyCode>.*|<VerifyCode>${Main_VerifyCode}</VerifyCode>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<UserAuthAddr>.*|<UserAuthAddr>${main_ip}:${Main_port}</UserAuthAddr>|"  /usr/local/hst/FMServer/ServiceConfig.xml
    sed -i "s|<ConfigCenter>.*|<ConfigCenter>${main_ip}:${Main_port}</ConfigCenter>|"  /usr/local/hst/FMServer/ServiceConfig.xml    
	sed -i "s|CommonService.*|CommonService=commonService:tcp -h ${main_ip} -p 33001|"  /usr/local/hst/FMServer/config.client
	sed -i "s|Ice.Default.Locator.*|Ice.Default.Locator=dbProxyIceGrid/Locator:default -h ${main_ip} -p 10001|"  /usr/local/hst/FMServer/config.client
	echo "写入成功，正在重启FMservice服务，请耐心等待"
}

pre_install_node
config_node

#重启FMservice服务
service fmservice restart