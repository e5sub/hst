#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年7月21日                         "*
echo -e "#                                                      "*
echo -e "# *正在执行所选择的项目，请耐心等待                    "* 
echo -e "#                                                      "*
echo -e "# *如选错安装的项目，可按Ctrl+Z取消安装                "*
echo -e "#                                                      "*
echo -e "# *如自动添加FSP公网地址失败，可手动添加               "*
echo -e "#                                                      "*
echo -e "# *手动添加格式：bash set_extra_ip.sh 公网IP           "*
echo -e "# ******************************************************"
echo -e "                                                       "
#获取内外网IP地址，端口
LOCAL_IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
getIpAddress=$(curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress)
##########################################################################################以下是服务器安装脚本##########################################################################################

## China_IP
    if [[ -z "${CN}" ]]; then
        if [[ $(curl -m 10 -s https://ipapi.co/json | grep 'China') != "" ]]; then
            echo "根据ipapi.co提供的信息，当前IP可能在国内"
            read -e -r -p "是否选用国内下载地址? 留空使用国内下载地址[Y/n] " input
            case $input in
            [yY][eE][sS] | [yY])
                echo "使用国内下载地址"
                CN=true
                ;;

            [nN][oO] | [nN])
                echo "不使用国内下载地址"
                ;;
            *)
                echo "使用国内下载地址"
                CN=true
                ;;
            esac
        fi
    fi
    if [[ -z "${CN}" ]]; then
        #CES标准版安装包下载地址
        CES436="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/标准版/ces_linux_hst4.36.5.5.tar.gz"
        CES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/标准版/ces_linux_hst4.35.4.5.tar.gz"
        CES434="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.34.5.1.tar.gz"
        CES432="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.32.8.5.tar.gz"
        CES431="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.31.3.5.tar.gz"
        ARMCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/ARM/标准版/ces_linux_arm4.35.1.30.tar.gz"
        ARMCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/ARM/标准版/ces_linux_arm4.34.5.1.tar.gz"
        ARMCES431="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/ARM/ces_linux_arm4.31.2.16.tar.gz"
        MIPSCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/mips/标准版/ces_linux_mips4.35.1.30.tar.gz"
        #CES中性版安装包下载地址
        ZXCES436="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/中性版/ces_linux_zx4.36.5.5.tar.gz"
        ZXCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/中性版/ces_linux_zx4.35.4.5.tar.gz"
        ZXCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.34.5.1.tar.gz"
        ZXCES432="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.32.8.5.tar.gz"
        ZXCES431="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.31.3.5.tar.gz"
        ARMZXCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/ARM/中性版/ces_linux_arm_zx4.35.1.30.tar.gz"
        ARMZXCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/ARM/中性版/ces_linux_arm_zx4.34.5.1.tar.gz"
        MIPSZXCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/mips/中性版/ces_linux_mips_zx4.35.1.30.tar.gz"
        #FSP服务器
        FSP141="1040155/fsp:1.4.1.17"
        FSP175="1040155/fsp:1.7.5.1"
        FSP183="1040155/fsp:1.8.3.9"
    else
        #CES标准版安装包下载地址
        CES436="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.36.5.5.tar.gz"
        CES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.35.4.5.tar.gz"
        CES434="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.34.5.1.tar.gz"
        CES432="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.32.8.5.tar.gz"
        CES431="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.31.3.5.tar.gz"
        ARMCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.35.1.30.tar.gz"
        ARMCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.34.5.1.tar.gz"
        ARMCES431="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.31.2.16.tar.gz"
        MIPSCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/mips/标准版/ces_linux_mips4.35.1.30.tar.gz"
        #CES中性版安装包下载地址
        ZXCES436="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.36.5.5.tar.gz"
        ZXCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.35.4.5.tar.gz"
        ZXCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.34.5.1.tar.gz"
        ZXCES432="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.32.8.5.tar.gz"
        ZXCES431="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.31.3.5.tar.gz"
        ARMZXCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/中性版/ces_linux_arm_zx4.35.1.30.tar.gz"
        ARMZXCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/中性版/ces_linux_arm_zx4.34.5.1.tar.gz"
        MIPSZXCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/mips/中性版/ces_linux_mips_zx4.35.1.30.tar.gz"
        #FSP服务器
        FSP141="ccr.ccs.tencentyun.com/1040155/fsp:1.4.1.17"
        FSP175="ccr.ccs.tencentyun.com/1040155/fsp:1.7.5.1"
        FSP183="ccr.ccs.tencentyun.com/1040155/fsp:1.8.3.9"
    fi

pre_install_config(){
# Set version
    echo -e "\033[44;37m 温馨提示：安装非CES服务器时不受此项影响，请直接留空该项 \033[0m"
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
#录制服务器和H323安装包下载地址
record326="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/录制服务器软部署/fsp-record-3.2.6.17.tar.gz"
H323="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/H323网关MCU/h323gw_xd_pkg_2.4.1.13.tar.gz"
H323MCU="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/H323网关MCU/centos7.installer_MCU20220712_2.4.1.13.tar.gz"
	
if [ $1 = '-436' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.5.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES436}
	tar zxvf ces_linux_hst4.36.5.5.tar.gz
	cd ./ces_linux4.36.5.5
	bash server_install.sh ${version}
fi
if [ $1 = '-435' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES435}
	tar zxvf ces_linux_hst4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh ${version}
fi
if [ $1 = '-434' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES434}
	tar zxvf ces_linux_hst4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
fi
if [ $1 = '-431' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.31.3.6服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES431}
	tar zxvf ces_linux_hst4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh ${version}
fi
if [ $1 = '-432' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES432}
	tar zxvf ces_linux_hst4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh ${version}
fi
if [ $1 = '-m435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSCES435}
	tar zxvf ces_linux_mips4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gc435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES435}
	tar zxvf ces_linux_arm4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gc434' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES434}
	tar zxvf ces_linux_arm4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
fi
if [ $1 = '-gc431' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.31.2.16服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES431}
	tar zxvf ces_linux_arm4.31.2.16.tar.gz
	cd ./ces_linux4.31.2.16
	bash server_install.sh ${version}
fi

##########################################################################################以下是中性版本##########################################################################################

if [ $1 = '-zx436' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.5.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES436}
	tar zxvf ces_linux_zx4.36.5.5.tar.gz
	cd ./ces_linux4.36.5.5
	bash server_install.sh ${version}
fi
if [ $1 = '-zx435' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES435}
	tar zxvf ces_linux_zx4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh ${version}
fi
if [ $1 = '-zx434' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES434}
	tar zxvf ces_linux_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
fi
if [ $1 = '-zx431' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.31.3.6服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES431}
	tar zxvf ces_linux_zx4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh ${version}
fi
if [ $1 = '-zx432' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES432}
	tar zxvf ces_linux_zx4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh ${version}
fi
if [ $1 = '-mzx435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSZXCES435}
	tar zxvf ces_linux_mips_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gczx435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES435}
	tar zxvf ces_linux_arm_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gczx434' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES434}
	tar zxvf ces_linux_arm_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
fi
if [ $1 = '-141fsp' ]
then
	echo -e "\033[33m 【你选择的是安装FSP v1.4.1.17服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	docker run -d --restart=unless-stopped -p 29100:29100 -p 28000:28000 --name fsp_pri ${FSP141}
fi
if [ $1 = '-175fsp' ]
then
## 调整docker镜像存储路径，防止磁盘空间不足
    if [[ -z "${docker_store}" ]]; then    
        read -e -r -p "是否需要修改docker存储路径? 留空默认不修改[y/n] " input
        case $input in
        [yY][eE][sS] | [yY])            
            docker_store=true
            ;;
        [nN][oO] | [nN])            
            ;;
        *)                            
            ;;
            esac        
    fi
    if [[ -z "${docker_store}" ]]; then
          echo "不修改docker存储路径，跳过" 
    else
          systemctl stop docker.service
          mkdir -p /fsmeeting/docker
          ln -s /fsmeeting/docker /var/lib/docker		  
          sed -i "s|ExecStart.*|ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --graph=/fsmeeting/docker|" /usr/lib/systemd/system/docker.service
          systemctl start docker
          echo "docker默认存储路径已经修改为/fsmeeting/docker，如有外接存储，可手动挂载到/fsmeeting目录"
    fi
echo -e "\033[33m 【你选择的是安装FSP v1.7.5.1服务器】 \033[0m"
echo -e "\n"
sleep 5s
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.5.1/set_extra_ip.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.5.1/set_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.5.1/set_store_proxy.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.5.1/set_wb_app_id.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.5.1/add_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.5.1/fsmeeting.conf
docker run -d --name=fsp_pri ${FSP175}
echo -e "请稍等，正在映射FSP至本地目录/fsmeeting/fsp"
mkdir -p /fsmeeting/fsp
docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/fsmeeting /fsmeeting/fsp
docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/middleware /fsmeeting/fsp
docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/boss /fsmeeting/fsp
sleep 60s	
docker stop $(docker ps|grep fsp_pri|awk '{print $1}')
sleep 15s
echo -e "正在停止FSP服务器"
docker rm $(docker ps -qf status=exited)
sleep 15s
echo -e "正在启动FSP服务器"
docker run -d -v /fsmeeting/fsp/fsmeeting:/fsmeeting -v /fsmeeting/fsp/middleware:/middleware -v /fsmeeting/fsp/boss:/boss --name=fsp_pri -e addr="${LOCAL_IP}" -e service=wb2.web.ep.mds -e use_default_app=true --privileged --hostname fsp_server --net=host --restart=always ${FSP175}
echo -e "恭喜，安装完成，首次启动FSP速度较慢，请耐心等待"
fi
if [ $1 = '-183fsp' ]
then
## 调整docker镜像存储路径，防止磁盘空间不足
    if [[ -z "${docker_store}" ]]; then    
        read -e -r -p "是否需要修改docker存储路径? 留空默认不修改[y/n] " input
        case $input in
        [yY][eE][sS] | [yY])            
            docker_store=true
            ;;
        [nN][oO] | [nN])            
            ;;
        *)                            
            ;;
            esac        
    fi
    if [[ -z "${docker_store}" ]]; then
          echo "不修改docker存储路径，跳过" 
    else
          systemctl stop docker.service
          mkdir -p /fsmeeting/docker
          ln -s /fsmeeting/docker /var/lib/docker		  
          sed -i "s|ExecStart.*|ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --graph=/fsmeeting/docker|" /usr/lib/systemd/system/docker.service
          systemctl start docker
          echo "docker默认存储路径已经修改为/fsmeeting/docker，如有外接存储，可手动挂载到/fsmeeting目录"
    fi
echo -e "\033[33m 【你选择的是安装FSP v1.8.3.9服务器】 \033[0m"
echo -e "\n"
sleep 5s
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.9/set_extra_ip.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.9/set_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.9/set_store_proxy.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.9/set_wb_app_id.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.9/add_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.9/fsmeeting.conf
docker run -d --name=fsp_pri ${FSP183}
echo -e "请稍等，正在映射FSP至本地目录/fsmeeting/fsp"
#mkdir -p /fsmeeting/fsp
mkdir -p /fsmeeting/fsp/nginx
docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/fsmeeting /fsmeeting/fsp
docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/middleware /fsmeeting/fsp
docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/boss /fsmeeting/fsp
docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/etc/nginx/conf.d /fsmeeting/fsp/nginx/conf.d
sleep 60s
docker stop $(docker ps|grep fsp_pri|awk '{print $1}')
sleep 15s
echo -e "正在停止FSP服务器"
docker rm $(docker ps -qf status=exited)
sleep 15s
echo -e "正在启动FSP服务器"
#docker run -d -v /fsmeeting/fsp/fsmeeting:/fsmeeting -v /fsmeeting/fsp/middleware:/middleware -v /fsmeeting/fsp/boss:/boss --add-host=ces.haoshitong.com:127.0.0.1 --name=fsp_pri -e addr="${LOCAL_IP}" -e service=wb2.web.ep.mds -e use_default_app=true --privileged --hostname fsp_server --net=host --restart=always ${FSP183}
docker run -d -v /fsmeeting/fsp/fsmeeting:/fsmeeting -v /fsmeeting/fsp/middleware:/middleware -v /fsmeeting/fsp/boss:/boss -v /fsmeeting/fsp/nginx/conf.d:/etc/nginx/conf.d --name=fsp_pri -e addr="${LOCAL_IP}" -e service=wb2.web.ep.mds -e use_default_app=true --privileged --hostname fsp_server --net=host --restart=always ${FSP183}
echo -e "恭喜，安装完成，首次启动FSP速度较慢，请耐心等待"
fi
if [ $1 = '-h323' ]
then
	echo -e "\033[33m 【你选择的是安装H323网关服务器v2.4.1.13】 \033[0m"
	echo -e "\n"
	sleep 5s	
	${H323}
	tar xvf h323gw_xd_pkg_2.4.1.13.tar.gz
	cd ./h323gw_xd_pkg_2.4.1.13
	echo -e "\033[33m 正在安装H323网关，请耐心等待 \033[0m"
	echo -e "\n"
	bash install.sh pri gc && bash install.sh pri gm 
	sleep 30s	
	echo -e "\033[33m 正在安装H323MCU，请耐心等待 \033[0m"
	echo -e "\n"	
	${H323MCU}
	tar xvf centos7.installer_MCU20220712_2.4.1.13.tar.gz
	cd ./centos7.installer
	bash install.sh
fi
if [ $1 = '-record326' ]
then
	echo -e "\033[33m 【你选择的是安装录制服务器v3.2.6.17】 \033[0m"
	echo -e "\n"
	sleep 5s	
	${record326}
	tar xvf fsp-record-3.2.6.17.tar.gz
	cd ./fsp-record-install-3.2.6.17
	bash install.sh pri
fi
##########################################################################################服务器安装脚本到此结束##########################################################################################

if [ $1 = '-frps' ]
then
	echo -e "\033[33m 【你选择的是安装Frp内网穿透服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	mkdir -p /frp
	cd /frp
	wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/frp/frps.ini
	docker run --restart=always --network host -d -v /frp:/etc/frp --name frps snowdreamtech/frps
fi
if [ $1 = '-frpc' ]
then
	echo -e "\033[33m 【你选择的是安装Frp内网穿透客户端】 \033[0m"
	echo -e "\n"
	sleep 5s
	mkdir -p /frp
	cd /frp
	wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/frp/frpc.ini
	docker run --restart=always --network host -d -v /frp:/etc/frp --name frpc snowdreamtech/frpc
fi
if [ $1 = '-time' ]
then
    echo -e "\033[33m 【你选择的是网络同步服务器时间】 \033[0m"
    echo -e "\n"
    sleep 5s
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    getTime=$(curl -sS --connect-timeout 10 -m 60 http://www.bt.cn/api/index/get_time)
    date -s "$(date -d @$getTime +"%Y-%m-%d %H:%M:%S")"
fi
if [ $1 = '-xiezai' ]
then
	echo -e "\033[33m 【你选择的是卸载CES服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	cd /usr/local/hst
	bash server_uninstall.sh
	yum remove -y docker-scan-plugin.x86_64
	yum remove -y containerd.io.x86_64
fi
if [ $1 = '-restartfsp' ]
then
	echo -e "\033[33m 【你选择的是重启FSP服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	docker restart $(docker ps|grep fsp_pri|awk '{print $1}')
fi
if [ $1 = '-unfsp' ]
then
	echo -e "\033[33m 【你选择的是卸载FSP服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	echo -e "正在停止FSP服务器"
	docker stop $(docker ps|grep fsp_pri|awk '{print $1}')
	sleep 5s
	echo -e "正在卸载FSP服务器"
	docker rm $(docker ps -qf status=exited)
	rm -rf /fsmeeting/fsp/
fi
if [ $1 = '-resetadmin' ]
then
	echo -e "\033[33m 【你选择的是重置后台admin密码】 \033[0m"
	echo -e "\n"
	sleep 5s	
	wget -N --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/resetadmin.sql
	mysql -u admin -pFsEntMeeting.com -P3308<"resetadmin.sql"
fi
if [ $1 = '-setip' ]
then
	echo -e "\033[33m 【你选择的是自动添加FSP公网地址（1.7.1.19以上才需要执行）】 \033[0m"
	echo -e "\n"
	sleep 5s	
	bash set_extra_ip.sh ${getIpAddress}
fi
#关闭系统防火墙
systemctl stop firewalld.service && systemctl disable firewalld.service
#删除安装脚本
rm -f install.sh
rm -f ces.sh
rm -f zxces.sh
rm -f resetadmin.sql
rm -f old.sh

echo -e "                                                                                "
echo -e "#*******************************************************************************"*
echo -e "#                                                                               "
echo -e "# *脚本执行完成                                                                 "
echo -e "#                                                                               "
echo -e "# *FSP外网映射端口：28000、20020、21000、29100、29400、29710                    "
echo -e "#                                                                               "
echo -e "# *CES默认端口：1089、8443                                                      "
echo -e "#                                                                               "
echo -e "# *内网后台（仅限安装单机版和集群版访问）：https://${LOCAL_IP}:8443             "
echo -e "#                                                                               "
echo -e "# *外网后台（仅限安装单机版和集群版访问）：https://${getIpAddress}:8443         "
echo -e "#                                                                               "
echo -e "# *如需外网使用请在路由器中映射上述端口                                         "
echo -e "#                                                                               "
echo -e "# *后台默认用户名密码均为admin（4.35之后版本默认密码为HSTadmin123，用户名不变） "
echo -e "#                                                                               "
echo -e "# *使用过程中如有问题，请拨打400-1199-666转1号键联系我们                        "
echo -e "#                                                                               "
echo -e "# *本脚本作者：Sugar                                                            "
echo -e "#                                                                               "
echo -e "# *博客地址：https://www.yaohst.com                                             "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "
