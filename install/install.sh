#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年9月9日                          "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
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
#FSP Docker仓库地址
FSP141="ccr.ccs.tencentyun.com/1040155/fsp:1.4.1.17"
FSP175="ccr.ccs.tencentyun.com/1040155/fsp:1.7.5.1"
FSP183="ccr.ccs.tencentyun.com/1040155/fsp:1.8.3.10"
#录制服务器和H323安装包下载地址
record="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/录制服务器软部署/fsp-record-3.2.6.17.tar.gz"
H323="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/H323网关MCU/h323gw_xd_pkg_2.4.2.2.tar.gz"
H323MCU="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/H323网关MCU/centos7.installer_MCU20220712_2.4.1.13.tar.gz"
if [ $1 = '-141fsp' ]
then
echo -e "\033[33m 【你选择的是安装FSP v1.4.1.17服务器】 \033[0m"
echo -e "\n"
sleep 5s
if ! type docker >/dev/null 2>&1; then
echo 'docker 未安装 正在安装中';
curl -sSL https://get.docker.com/ | sh && systemctl enable docker && systemctl start docker
else 
echo 'docker 已安装，继续操作'
fi
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
if ! type docker >/dev/null 2>&1; then
echo 'docker 未安装 正在安装中';
curl -sSL https://get.docker.com/ | sh && systemctl enable docker && systemctl start docker
else 
echo 'docker 已安装，继续操作'
fi
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.7.5.1/set_extra_ip.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.7.5.1/set_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.7.5.1/set_store_proxy.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.7.5.1/set_wb_app_id.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.7.5.1/add_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.7.5.1/fsmeeting.conf
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
#开放FSP服务器防火墙端口
firewall-cmd --zone=public --add-port=21000/tcp --permanent
firewall-cmd --zone=public --add-port=21100/tcp --permanent
firewall-cmd --zone=public --add-port=21001/tcp --permanent
firewall-cmd --zone=public --add-port=21002/tcp --permanent
firewall-cmd --zone=public --add-port=24000/tcp --permanent
firewall-cmd --zone=public --add-port=25000/tcp --permanent
firewall-cmd --zone=public --add-port=26000/tcp --permanent
firewall-cmd --zone=public --add-port=27000/tcp --permanent
firewall-cmd --zone=public --add-port=28000/tcp --permanent
firewall-cmd --zone=public --add-port=28001/tcp --permanent
firewall-cmd --zone=public --add-port=28002/tcp --permanent
firewall-cmd --zone=public --add-port=28900/tcp --permanent
firewall-cmd --zone=public --add-port=29000/tcp --permanent
firewall-cmd --zone=public --add-port=29100/tcp --permanent
firewall-cmd --zone=public --add-port=29200/tcp --permanent
firewall-cmd --zone=public --add-port=29400/tcp --permanent
firewall-cmd --zone=public --add-port=29400/udp --permanent
firewall-cmd --zone=public --add-port=29700/tcp --permanent
firewall-cmd --zone=public --add-port=29700/udp --permanent
firewall-cmd --zone=public --add-port=29710/tcp --permanent
firewall-cmd --zone=public --add-port=29710/udp --permanent
firewall-cmd --zone=public --add-port=29800/tcp --permanent
firewall-cmd --zone=public --add-port=20020/tcp --permanent
firewall-cmd --zone=public --add-port=20010/tcp --permanent
firewall-cmd --zone=public --add-port=20000/tcp --permanent
firewall-cmd --zone=public --add-port=20014/tcp --permanent
firewall-cmd --zone=public --add-port=23100/tcp --permanent
firewall-cmd --zone=public --add-port=30504/tcp --permanent
firewall-cmd --zone=public --add-port=30510/tcp --permanent
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
echo -e "\033[33m 【你选择的是安装FSP v1.8.3.10服务器】 \033[0m"
echo -e "\n"
sleep 5s
if ! type docker >/dev/null 2>&1; then
echo 'docker 未安装 正在安装中';
curl -sSL https://get.docker.com/ | sh && systemctl enable docker && systemctl start docker
else 
echo 'docker 已安装，继续操作'
fi
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.8.3.10/set_extra_ip.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.8.3.10/set_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.8.3.10/set_store_proxy.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.8.3.10/set_wb_app_id.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.8.3.10/add_protocol_addr.sh
wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/1.8.3.10/fsmeeting.conf
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
#开放FSP服务器防火墙端口
firewall-cmd --zone=public --add-port=21000/tcp --permanent
firewall-cmd --zone=public --add-port=21100/tcp --permanent
firewall-cmd --zone=public --add-port=21001/tcp --permanent
firewall-cmd --zone=public --add-port=21002/tcp --permanent
firewall-cmd --zone=public --add-port=24000/tcp --permanent
firewall-cmd --zone=public --add-port=25000/tcp --permanent
firewall-cmd --zone=public --add-port=26000/tcp --permanent
firewall-cmd --zone=public --add-port=27000/tcp --permanent
firewall-cmd --zone=public --add-port=28000/tcp --permanent
firewall-cmd --zone=public --add-port=28001/tcp --permanent
firewall-cmd --zone=public --add-port=28002/tcp --permanent
firewall-cmd --zone=public --add-port=28900/tcp --permanent
firewall-cmd --zone=public --add-port=29000/tcp --permanent
firewall-cmd --zone=public --add-port=29100/tcp --permanent
firewall-cmd --zone=public --add-port=29200/tcp --permanent
firewall-cmd --zone=public --add-port=29400/tcp --permanent
firewall-cmd --zone=public --add-port=29400/udp --permanent
firewall-cmd --zone=public --add-port=29700/tcp --permanent
firewall-cmd --zone=public --add-port=29700/udp --permanent
firewall-cmd --zone=public --add-port=29710/tcp --permanent
firewall-cmd --zone=public --add-port=29710/udp --permanent
firewall-cmd --zone=public --add-port=29800/tcp --permanent
firewall-cmd --zone=public --add-port=20020/tcp --permanent
firewall-cmd --zone=public --add-port=20010/tcp --permanent
firewall-cmd --zone=public --add-port=20000/tcp --permanent
firewall-cmd --zone=public --add-port=20014/tcp --permanent
firewall-cmd --zone=public --add-port=23100/tcp --permanent
firewall-cmd --zone=public --add-port=30504/tcp --permanent
firewall-cmd --zone=public --add-port=30510/tcp --permanent
echo -e "恭喜，安装完成，首次启动FSP速度较慢，请耐心等待"
fi
if [ $1 = '-h323pri' ]
then
	echo -e "\033[33m 【你选择的是安装H323网关服务器v2.4.2.2（私有云）】 \033[0m"
	echo -e "\n"
	sleep 5s	
	${H323}
	tar -zxvf h323gw_xd_pkg_2.4.2.2.tar.gz
	chmod -R 777 ./h323gw_xd_pkg_2.4.2.2 
	cd ./h323gw_xd_pkg_2.4.2.2
    echo -e "\n"
	echo -e "\033[33m 正在安装H323网关，请耐心等待 \033[0m"
	echo -e "\n"
	bash install.sh pri gc 
	bash install.sh pri gm 
	sleep 10s	
	echo -e "\033[33m 正在安装H323MCU，请耐心等待 \033[0m"
	echo -e "\n"	
	${H323MCU}
	tar -zxvf centos7.installer_MCU20220712_2.4.1.13.tar.gz
	chmod -R 777 ./centos7.installer
	cd ./centos7.installer	
	bash install.sh  
fi
if [ $1 = '-h323pub' ]
then
	echo -e "\033[33m 【你选择的是安装H323网关服务器v2.4.2.2（云会议）】 \033[0m"
	echo -e "\n"
	sleep 5s	
	${H323}
	tar -zxvf h323gw_xd_pkg_2.4.2.2.tar.gz
	chmod -R 777 ./h323gw_xd_pkg_2.4.2.2
	cd ./h323gw_xd_pkg_2.4.2.2
    echo -e "\n"
	echo -e "\033[33m 正在安装H323网关，请耐心等待 \033[0m"
	echo -e "\n"
	bash install.sh pub gc 
	bash install.sh pub gm 
	bash install.sh pub ma 
	sleep 10s
    echo -e "\n"	
	echo -e "\033[33m 正在安装H323MCU，请耐心等待 \033[0m"
	echo -e "\n"	
	${H323MCU}
	tar -zxvf centos7.installer_MCU20220712_2.4.1.13.tar.gz
	chmod -R 777 ./centos7.installer
	cd ./centos7.installer	
	bash install.sh 
fi
if [ $1 = '-record' ]
then
	echo -e "\033[33m 【你选择的是安装录制服务器v3.2.6.17】 \033[0m"
	echo -e "\n"
	sleep 5s	
	${record}
	tar -zxvf fsp-record-3.2.6.17.tar.gz
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
	wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/frp/frps.ini
	docker run --restart=always --network host -d -v /frp:/etc/frp --name frps snowdreamtech/frps
fi
if [ $1 = '-frpc' ]
then
	echo -e "\033[33m 【你选择的是安装Frp内网穿透客户端】 \033[0m"
	echo -e "\n"
	sleep 5s
	mkdir -p /frp
	cd /frp
	wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/frp/frpc.ini
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
if [ $1 = '-nginx' ]
then
	echo -e "\033[33m 【你选择的是Nginx转发8443端口，隐藏公网8443后台页面（转发端口号18443）】 \033[0m"
	echo -e "\n"
	sleep 5s	
	cd /usr/local/hst
    wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/4.36/nginx.tar.gz	
	tar zxvf nginx.tar.gz
	service fmservice restart
fi
if [ $1 = '-proxy' ]
then
	echo -e "\033[33m 【你选择的是Nginx反代1089/8443端口,需手动修改/usr/local/nginx/nginx.conf里的地址】 \033[0m"
	echo -e "\n"
	sleep 5s
    if ! type docker >/dev/null 2>&1; then
    echo 'docker 未安装 正在安装中';
    curl -sSL https://get.docker.com/ | sh && systemctl enable docker && systemctl start docker
    else 
    echo 'docker 已安装，继续操作'
    fi
    docker run -d --name nginx_proxy --net=host --hostname nginx_proxy --restart=always nginx
    docker cp $(docker ps|grep nginx_proxy|awk '{print $1}'):/etc/nginx /usr/local/nginx
    mkdir -p /usr/local/nginx/ssl
    wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/4.36/proxy.tar.gz
    tar -zxvf proxy.tar.gz -C /usr/local/nginx
    wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/4.36/ssl.tar.gz
    tar -zxvf ssl.tar.gz -C /usr/local/nginx/ssl
	sleep 10s
    docker stop $(docker ps|grep nginx_proxy|awk '{print $1}')
    sleep 10s
    docker rm $(docker ps -qf status=exited)
    sleep 5s
    docker run -d --name nginx_proxy -v /usr/local/nginx/html:/usr/share/nginx/html -v /usr/local/nginx:/etc/nginx -v /usr/local/nginx/logs:/var/log/nginx -v /usr/local/nginx/ssl:/etc/nginx/ssl -e TZ=Asia/Shanghai --net=host --hostname nginx_proxy --restart=always nginx
fi
if [ $1 = '-resetadmin' ]
then
	echo -e "\033[33m 【你选择的是重置后台admin密码】 \033[0m"
	echo -e "\n"
	sleep 5s	
	wget -N --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/install/resetadmin.sql
	mysql -u admin -pFsEntMeeting.com -P3308<"resetadmin.sql"
fi
## 是否关闭系统防火墙
#    if [[ -z "${fw}" ]]; then    
#        read -e -r -p "是否需要关闭防火墙？留空默认不关闭[y/n] " input
#        case $input in
#        [yY][eE][sS] | [yY])            
#            fw=true
#            ;;
#        [nN][oO] | [nN])            
#            ;;
#        *)                            
#            ;;
#            esac        
#    fi
#    if [[ -z "${fw}" ]]; then
#          echo "不关闭系统防火墙" 
#    else
#         systemctl stop firewalld.service && systemctl disable firewalld.service 
#         echo "系统防火墙已关闭"
#		  echo "如需打开请输入systemctl start firewalld.service && systemctl enable firewalld.service"
#    fi
#删除安装脚本
rm -rf install.sh
rm -rf ces.sh
rm -rf zxces.sh
rm -rf resetadmin.sql
rm -rf old.sh
rm -rf cesinstall.sh

echo -e "                                                                                "
echo -e "#*******************************************************************************"*
echo -e "#                                                                               "
echo -e "# *脚本执行完成                                                                 "
echo -e "#                                                                               "
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！                                     "
echo -e "#                                                                               "
echo -e "# *FSP外网映射端口：28000、20020、21000、29100、29400、29710                    "
echo -e "#                                                                               "
echo -e "# *CES默认端口：1089、8443                                                      "
echo -e "#                                                                               "
echo -e "# *如需外网使用请在路由器中映射上述端口                                         "
echo -e "#                                                                               "
echo -e "# *后台默认用户名密码均为admin（4.35之后版本默认密码为HSTadmin123，用户名不变） "
echo -e "#                                                                               "
echo -e "# *使用过程中如有问题，请拨打400-1199-666转1号键                                "
echo -e "#                                                                               "
echo -e "# *本脚本作者：Sugar                                                            "
echo -e "#                                                                               "
echo -e "# *博客地址：https://www.yaohst.com                                             "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "
