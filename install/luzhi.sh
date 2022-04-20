#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年4月20日                         "*
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
pre_install_luzhi(){
    # Set Main_ip
    read -ep "(请输入CES服务器IP地址或者域名):" main_ip
    [ -z "${Main_ip}" ]
    echo
    echo "---------------------------"
    echo "CES服务器IP = ${main_ip}"
    echo "---------------------------"
    echo
    # Set ZY_DevID
    read -ep "(请输入资源平台设备ID，不填则默认12345):" ZY_DevID
    [ -z "${ZY_DevID}" ] && ZY_DevID=12345
    echo
    echo "---------------------------"
    echo "资源平台设备ID = ${ZY_DevID}"
    echo "---------------------------"
    echo
    # Set ZY_VerifyCode
    read -ep "(请输入资源平台设备验证码，不填则默认12345):" ZY_VerifyCode
    [ -z "${ZY_VerifyCode}" ] && ZY_VerifyCode=12345
    echo
    echo "---------------------------"
    echo "资源平台设备验证码 = ${ZY_VerifyCode}"
    echo "---------------------------"
    echo
	# Set MT_DevID
    read -ep "(请输入媒体服务设备ID，不填则默认54321):" MT_DevID
    [ -z "${MT_DevID}" ] && MT_DevID=54321
    echo
    echo "---------------------------"
    echo "媒体服务设备ID = ${MT_DevID}"
    echo "---------------------------"
    echo
	# Set MT_VerifyCode
    read -ep "(请输入媒体服务验证码，不填则默认54321):" MT_VerifyCode
    [ -z "${MT_VerifyCode}" ] && MT_VerifyCode=54321
    echo
    echo "---------------------------"
    echo "媒体服务验证码 = ${MT_VerifyCode}"
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
	# Set cloud
    read -ep "(是否部署在云端，0：是 不填则默认选择否):" cloud
    [ -z "${cloud}" ] && cloud=20
    echo
    echo "---------------------------"
    echo "是否部署在云端 = ${cloud}"
    echo "---------------------------"
    echo
}
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# Config luzhi
config_luzhi(){
    echo "正在写入录制服务器配置文件"	
    sed -i "s|fs.server.config.url.*|fs.server.config.url=https://${main_ip}:${port}|"  /opt/AIO/Service/webservice/webroot/ROOT/WEB-INF/classes/jdbc.properties
    sed -i "s|my.server.device.device.id.*|my.server.device.device.id=${ZY_DevID}|"  /opt/AIO/Service/webservice/webroot/ROOT/WEB-INF/classes/jdbc.properties
    sed -i "s|my.server.device.verify.code.*|my.server.device.verify.code=${ZY_VerifyCode}|"  /opt/AIO/Service/webservice/webroot/ROOT/WEB-INF/classes/jdbc.properties
    sed -i "s|<ConfigCenterAddr>.*|<ConfigCenterAddr>https://${main_ip}:${port}</ConfigCenterAddr>|"  /fsmeeting/fsp_record/httpservice/service_config.xml
    sed -i "s|<DeviceID>.*|<DeviceID>${MT_DevID}</DeviceID>|" /fsmeeting/fsp_record/httpservice/service_config.xml
    sed -i "s|<VerifyCode>.*|<VerifyCode>${MT_VerifyCode}</VerifyCode>|" /fsmeeting/fsp_record/httpservice/service_config.xml 
    sed -i "s|<ConfigCenterAddr>.*|<ConfigCenterAddr>https://${main_ip}:${port}</ConfigCenterAddr>|"  /fsmeeting/fsp_record/mediaservice/service_config.xml
	sed -i "s|<GPUCodeNum>.*|<GPUCodeNum>${cloud}</GPUCodeNum>|"  /fsmeeting/fsp_record/recordservice/service_config.xml
	sed -i "s|<addr>.*|<addr>${IP}</addr>|"  /fsmeeting/fsp_record/httpservice/service_config.xml
	sed -i "s|default.local.ip.*|default.local.ip=${IP}|"    /opt/AIO/Service/webservice/webroot/ROOT/WEB-INF/classes/jdbc.properties
	echo "写入成功，正在重启录制服务器，请耐心等待"
}

pre_install_luzhi
config_luzhi

#重启录制服务器
reboot