#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年5月4日                          "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *正在执行所选择的项目，请耐心等待                    "* 
echo -e "#                                                      "*
echo -e "# *如选错安装的项目，可按Ctrl+Z取消安装                "*
echo -e "#                                                      "*
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
        CES436="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/标准版/ces_linux_hst4.36.6.2.tar.gz"
        CES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/标准版/ces_linux_hst4.35.4.5.tar.gz"
        CES434="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.34.5.1.tar.gz"
        CES432="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.32.8.5.tar.gz"
        CES431="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.31.3.5.tar.gz"
        ARMCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/ARM/标准版/ces_linux_arm4.35.1.30.tar.gz"
        ARMCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/ARM/标准版/ces_linux_arm4.34.5.1.tar.gz"
        ARMCES431="wget -N --no-check-certificate https://pan.yaohst.com/d/HST/02好视通视频会议企业版服务器/linux服务端/ARM/ces_linux_arm4.31.2.16.tar.gz"
        MIPSCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/mips/标准版/ces_linux_mips4.35.1.30.tar.gz"
        #CES中性版安装包下载地址
        ZXCES436="wget -N --no-check-certificate https://pan.yaohst.com/d/OS/好视通linux服务器安装包/中性版/ces_linux_zx4.36.6.2.tar.gz"
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
        FSP183="1040155/fsp:1.8.3.5"
    else
        #CES标准版安装包下载地址
        CES436="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.36.6.2.tar.gz"
        CES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.35.4.5.tar.gz"
        CES434="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.34.5.1.tar.gz"
        CES432="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.32.8.5.tar.gz"
        CES431="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.31.3.5.tar.gz"
        ARMCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.35.1.30.tar.gz"
        ARMCES434="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.34.5.1.tar.gz"
        ARMCES431="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.31.2.16.tar.gz"
        MIPSCES435="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/mips/标准版/ces_linux_mips4.35.1.30.tar.gz"
        #CES中性版安装包下载地址
        ZXCES436="wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.36.6.2.tar.gz"
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
        FSP183="ccr.ccs.tencentyun.com/1040155/fsp:1.8.3.5"
    fi

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
if [ $1 = '-437' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.37.6.8服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通标准版自动化部署/hstdeploy-5.0.48.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通标准版自动化部署/fsp-base-1.0.4.9.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通标准版自动化部署/fsp-store-1.2.15.43.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通标准版自动化部署/fsp-record-3.2.9.5.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通标准版自动化部署/fsp-live-1.0.0.16.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通标准版自动化部署/meeting-4.37.6.8.tar.gz
    tar -zxvf hstdeploy-5.0.48.tar.gz
	cd ./hstdeploy
	bash install.sh
fi
if [ $1 = '-436' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.6.2服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES436}
	tar -zxvf ces_linux_hst4.36.6.2.tar.gz
	cd ./ces_linux4.36.6.2
	bash server_install.sh ${version}
fi
if [ $1 = '-435' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES435}
	tar -zxvf ces_linux_hst4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh ${version}
fi
if [ $1 = '-434' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES434}
	tar -zxvf ces_linux_hst4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
fi
if [ $1 = '-431' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.31.3.6服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES431}
	tar -zxvf ces_linux_hst4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh ${version}
fi
if [ $1 = '-432' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES432}
	tar -zxvf ces_linux_hst4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh ${version}
fi
if [ $1 = '-m435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSCES435}
	tar -zxvf ces_linux_mips4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gc435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES435}
	tar -zxvf ces_linux_arm4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gc434' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES434}
	tar -zxvf ces_linux_arm4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
fi
if [ $1 = '-gc431' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.31.2.16服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES431}
	tar -zxvf ces_linux_arm4.31.2.16.tar.gz
	cd ./ces_linux4.31.2.16
	bash server_install.sh ${version}
fi

##########################################################################################以下是中性版本##########################################################################################

if [ $1 = '-zx437' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.37.6.8服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通中性版自动化部署/hstdeploy-5.0.48.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通中性版自动化部署/fsp-base-1.0.4.9.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通中性版自动化部署/fsp-store-1.2.15.43.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通中性版自动化部署/fsp-record-3.2.9.5.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通中性版自动化部署/fsp-live-1.0.0.16.tar.gz
    wget -N --no-check-certificate https://pan.yaohst.com/d/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/好视通中性版自动化部署/meeting-4.37.6.8.tar.gz
    tar -zxvf hstdeploy-5.0.48.tar.gz
	cd ./hstdeploy
	bash install.sh
fi
if [ $1 = '-zx436' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.6.2服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES436}
	tar -zxvf ces_linux_zx4.36.6.2.tar.gz
	cd ./ces_linux4.36.6.2
	bash server_install.sh ${version}
fi
if [ $1 = '-zx435' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES435}
	tar -zxvf ces_linux_zx4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh ${version}
fi
if [ $1 = '-zx434' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES434}
	tar -zxvf ces_linux_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
fi
if [ $1 = '-zx431' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.31.3.6服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES431}
	tar -zxvf ces_linux_zx4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh ${version}
fi
if [ $1 = '-zx432' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES432}
	tar -zxvf ces_linux_zx4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh ${version}
fi
if [ $1 = '-mzx435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSZXCES435}
	tar -zxvf ces_linux_mips_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gczx435' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.35.1.30服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES435}
	tar -zxvf ces_linux_arm_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh ${version}
fi
if [ $1 = '-gczx434' ]
then
	echo -e "\033[33m 【你选择的是安装国产化CES v4.34.5.1服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES434}
	tar -zxvf ces_linux_arm_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh ${version}
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
rm -f install.sh
rm -f ces.sh
rm -f zxces.sh
rm -f resetadmin.sql
rm -f old.sh
rm -f cesinstall.sh

echo -e "                                                                                "
echo -e "#*******************************************************************************"*
echo -e "#                                                                               "
echo -e "# *恭喜！服务器安装完成！                                                       "
echo -e "#                                                                               "
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！                                     "
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
echo -e "# *使用过程中如有问题，请拨打400-1199-666转1号键                                "
echo -e "#                                                                               "
echo -e "# *本脚本作者：Sugar                                                            "
echo -e "#                                                                               "
echo -e "# *博客地址：https://www.yaohst.com                                             "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "
