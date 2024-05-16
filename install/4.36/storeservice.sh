#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年6月1日                          "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
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
getIpAddress=$(curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress)
echo -e "当前服务器的内网IP：\033[44;37m ${IP} \033[0m"
echo -e " "
echo -e "当前服务器的外网IP：\033[44;37m ${getIpAddress} \033[0m"
echo -e ""
echo -e "以上信息仅供参考，如果获取的不正确，请手动指定IP地址。下方的IP信息默认填写服务器内网IP。"
echo -e ""
# Pre-installation settings
pre_install_storeservice(){
# Set ces_ip
    read -ep "(请输入CES服务器IP):" ces_ip
    [ -z "${ces_ip}" ]
    echo 
    echo "---------------------------"
    echo "CES服务器IP = ${ces_ip}"
    echo "---------------------------"
    echo
# Set record_ip
    read -ep "(请输入录制服务器IP，空自动获取网卡IP):" record_ip
    [ -z "${record_ip}" ] && record_ip=${IP}
    echo 
    echo "---------------------------"
    echo "录制服务器IP = ${record_ip}"
    echo "---------------------------"
    echo
# Set fsp_ip
    read -ep "(请输入FSP服务器IP，若与CES地址一致留空即可):" fsp_ip
    [ -z "${fsp_ip}" ] && fsp_ip=${ces_ip}
    echo
    echo "---------------------------"
    echo "FSP服务器IP = ${fsp_ip}"
    echo "---------------------------"
    echo 
}

# Config storeservice
config_storeservice(){
    echo "正在写入storeservice配置文件"	
    sed -i "s|hosts.*|hosts=${ces_ip}|"  /fsmeeting/fsp_record/storeservice/store.conf
    sed -i "s|inner_addr.*|inner_addr=http://${record_ip}:8080|"  /fsmeeting/fsp_record/storeservice/store.conf
    sed -i "s|nginx_https.*|nginx_https=https://${record_ip}:21000|"  /fsmeeting/fsp_record/storeservice/store.conf
    sed -i "s|service_ip.*|service_ip = ${record_ip}|"  /fsmeeting/fsp_record/storeservice/store.conf
    sed -i "s|service_play_proxy.*|service_play_proxy = https://${record_ip}:8384/hls/%s/index.m3u8|"  /fsmeeting/fsp_record/storeservice/store.conf
    sed -i "s|service_proxy.*|service_proxy = https://${record_ip}:21000|" /fsmeeting/fsp_record/storeservice/store.conf
    sed -i "s|mq_brokers.*|mq_brokers=${fsp_ip}:24000:root:root@/|" /fsmeeting/fsp_record/storeservice/store.conf 
    echo "写入成功"
}

pre_install_storeservice
config_storeservice

#配置FSP服务器地址（仅首次安装使用）
echo "配置FSP服务器地址仅首次安装使用，非首次使用报错属于正常情况"
cd /fsmeeting/fsp_record
sh config_addr.sh ${fsp_ip} fsp2