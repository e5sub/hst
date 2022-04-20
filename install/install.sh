echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2022年4月20日                         "*
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
            read -e -r -p "是否选用国内下载地址? [Y/n] " input
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
        CES436="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/标准版/ces_linux_hst4.36.5.1.tar.gz -O ces_linux_hst4.36.5.1.tar.gz"
        CES435="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/标准版/ces_linux_hst4.35.4.5.tar.gz -O ces_linux_hst4.35.4.5.tar.gz"
        CES434="wget --no-check-certificate https://yaohst.com/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.34.5.1.tar.gz -O ces_linux_hst4.34.5.1.tar.gz"
        CES432="wget --no-check-certificate https://yaohst.com/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.32.8.5.tar.gz -O ces_linux_hst4.32.8.5.tar.gz"
        CES431="wget --no-check-certificate https://yaohst.com/HST/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.31.3.5.tar.gz -O ces_linux_hst4.31.3.5.tar.gz"
        ARMCES435="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/ARM/标准版/ces_linux_arm4.35.1.30.tar.gz -O ces_linux_arm4.35.1.30.tar.gz"
        ARMCES434="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/ARM/标准版/ces_linux_arm4.34.5.1.tar.gz -O ces_linux_arm4.34.5.1.tar.gz"
        ARMCES431="wget --no-check-certificate https://yaohst.com/HST/02好视通视频会议企业版服务器/linux服务端/ARM/ces_linux_arm4.31.2.16.tar.gz -O ces_linux_arm4.31.2.16.tar.gz"
        MIPSCES435="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/mips/标准版/ces_linux_mips4.35.1.30.tar.gz -O ces_linux_mips4.35.1.30.tar.gz"
		#CES中性版安装包下载地址
	    ZXCES436="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/中性版/ces_linux_zx4.36.5.1.tar.gz -O ces_linux_zx4.36.5.1.tar.gz"
        ZXCES435="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/中性版/ces_linux_zx4.35.4.5.tar.gz -O ces_linux_zx4.35.4.5.tar.gz"
	    ZXCES434="wget --no-check-certificate https://yaohst.com/HST/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.34.5.1.tar.gz -O ces_linux_zx4.34.5.1.tar.gz"
        ZXCES432="wget --no-check-certificate https://yaohst.com/HST/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.32.8.5.tar.gz -O ces_linux_zx4.32.8.5.tar.gz"
        ZXCES431="wget --no-check-certificate https://yaohst.com/HST/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.31.3.5.tar.gz -O ces_linux_zx4.31.3.5.tar.gz"
        ARMZXCES435="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/ARM/中性版/ces_linux_arm_zx4.35.1.30.tar.gz -O ces_linux_arm_zx4.35.1.30.tar.gz"
        ARMZXCES434="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/ARM/中性版/ces_linux_arm_zx4.34.5.1.tar.gz -O ces_linux_arm_zx4.34.5.1.tar.gz"
        MIPSZXCES435="wget --no-check-certificate https://yaohst.com/OS/好视通linux服务器安装包/mips/中性版/ces_linux_mips_zx4.35.1.30.tar.gz -O ces_linux_mips_zx4.35.1.30.tar.gz"
		#FSP服务器
		FSP141="1040155/fsp:1.4.1.17"
		FSP174="1040155/fsp:1.7.4.2"
		FSP183="1040155/fsp:1.8.3.3"
    else
        #CES标准版安装包下载地址
        CES436="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.36.5.1.tar.gz -O ces_linux_hst4.36.5.1.tar.gz"
        CES435="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.35.4.5.tar.gz -O ces_linux_hst4.35.4.5.tar.gz"
        CES434="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.34.5.1.tar.gz -O ces_linux_hst4.34.5.1.tar.gz"
        CES432="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.32.8.5.tar.gz -O ces_linux_hst4.32.8.5.tar.gz"
        CES431="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/标准版/ces_linux_hst4.31.3.5.tar.gz -O ces_linux_hst4.31.3.5.tar.gz"
        ARMCES435="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.35.1.30.tar.gz -O ces_linux_arm4.35.1.30.tar.gz"
        ARMCES434="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.34.5.1.tar.gz -O ces_linux_arm4.34.5.1.tar.gz"
        ARMCES431="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/标准版/ces_linux_arm4.31.2.16.tar.gz -O ces_linux_arm4.31.2.16.tar.gz"
        MIPSCES435="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/mips/标准版/ces_linux_mips4.35.1.30.tar.gz -O ces_linux_mips4.35.1.30.tar.gz"
        #CES中性版安装包下载地址
        ZXCES436="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.36.5.1.tar.gz -O ces_linux_zx4.36.5.1.tar.gz"
        ZXCES435="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.35.4.5.tar.gz -O ces_linux_zx4.35.4.5.tar.gz"
        ZXCES434="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.34.5.1.tar.gz -O ces_linux_zx4.34.5.1.tar.gz"
        ZXCES432="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.32.8.5.tar.gz -O ces_linux_zx4.32.8.5.tar.gz"
        ZXCES431="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/中性版/ces_linux_zx4.31.3.5.tar.gz -O ces_linux_zx4.31.3.5.tar.gz"
        ARMZXCES435="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/中性版/ces_linux_arm_zx4.35.1.30.tar.gz -O ces_linux_arm_zx4.35.1.30.tar.gz"
        ARMZXCES434="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/ARM/中性版/ces_linux_arm_zx4.34.5.1.tar.gz -O ces_linux_arm_zx4.34.5.1.tar.gz"
        MIPSZXCES435="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/linux服务端/mips/中性版/ces_linux_mips_zx4.35.1.30.tar.gz -O ces_linux_mips_zx4.35.1.30.tar.gz"
		#FSP服务器
		FSP141="ccr.ccs.tencentyun.com/1040155/fsp:1.4.1.17"
		FSP174="ccr.ccs.tencentyun.com/1040155/fsp:1.7.4.2"
		FSP183="ccr.ccs.tencentyun.com/1040155/fsp:1.8.3.3"
    fi
#录制服务器和H323安装包下载地址
LUZHI="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/录制服务器软部署/mc-1.0.7.16.tar -O mc-1.0.7.16.tar"
H323MCU="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/H323网关MCU/h323gw_xd_pkg_2.3.1.12.tar.gz -O h323gw_xd_pkg_2.3.1.12.tar.gz"
H323="wget --no-check-certificate https://yaohst.com/Aliyun/好视通/02好视通视频会议企业版服务器/H323网关MCU/centos7.installer_MCU20211231_2.3.1.12.tar -O centos7.installer_MCU20211231_2.3.1.12.tar"
if [ $1 = '-436dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.36.5.1单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES436}
	tar zxvf ces_linux_hst4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh single	
fi
if [ $1 = '-436jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.36.5.1集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES436}
	tar zxvf ces_linux_hst4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh cluster main	
fi
if [ $1 = '-436node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.5.1集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES436}
	tar zxvf ces_linux_hst4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh cluster node
fi
if [ $1 = '-436face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.5.1人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES436}
	tar zxvf ces_linux_hst4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh cluster face
fi
if [ $1 = '-435dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.35.4.5单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES435}
	tar zxvf ces_linux_hst4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh single	
fi
if [ $1 = '-435jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.35.4.5集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES435}
	tar zxvf ces_linux_hst4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh cluster main	
fi
if [ $1 = '-435node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES435}
	tar zxvf ces_linux_hst4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh cluster node
fi
if [ $1 = '-435face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES435}
	tar zxvf ces_linux_hst4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh cluster face
fi
if [ $1 = '-434dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.34.5.1单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES434}
	tar zxvf ces_linux_hst4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh single
fi
if [ $1 = '-434jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.34.5.1集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES434}
	tar zxvf ces_linux_hst4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster main
fi
if [ $1 = '-434node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES434}
	tar zxvf ces_linux_hst4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster node
fi
if [ $1 = '-434face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES434}
	tar zxvf ces_linux_hst4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster face
fi
if [ $1 = '-431node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.31.3.6集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES431}
	tar zxvf ces_linux_hst4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh cluster node
fi
if [ $1 = '-431dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.31.3.6单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES431}
	tar zxvf ces_linux_hst4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh single
fi
if [ $1 = '-431jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.31.3.6集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES431}
	tar zxvf ces_linux_hst4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh cluster main
fi
if [ $1 = '-432node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES432}
	tar zxvf ces_linux_hst4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh cluster node
fi
if [ $1 = '-432face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES432}
	tar zxvf ces_linux_hst4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh cluster face
fi
if [ $1 = '-432dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.32.8.5单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES432}
	tar zxvf ces_linux_hst4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh single
fi
if [ $1 = '-432jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.32.8.5集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${CES432}
	tar zxvf ces_linux_hst4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh cluster main
fi
if [ $1 = '-m435dj' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30单机版服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSCES435}
	tar zxvf ces_linux_mips4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh single
fi
if [ $1 = '-m435jq' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSCES435}
	tar zxvf ces_linux_mips4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster main
fi
if [ $1 = '-m435node' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSCES435}
	tar zxvf ces_linux_mips4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster node
fi
if [ $1 = '-m435face' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSCES435}
	tar zxvf ces_linux_mips4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster face
fi
if [ $1 = '-gc435dj' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30单机版服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES435}
	tar zxvf ces_linux_arm4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh single
fi
if [ $1 = '-gc435jq' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES435}
	tar zxvf ces_linux_arm4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster main
fi
if [ $1 = '-gc435node' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES435}
	tar zxvf ces_linux_arm4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster node
fi
if [ $1 = '-gc435face' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES435}
	tar zxvf ces_linux_arm4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster face
fi
if [ $1 = '-gc434dj' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1单机版服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES434}
	tar zxvf ces_linux_arm4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh single
fi
if [ $1 = '-gc434jq' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES434}
	tar zxvf ces_linux_arm4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster main
fi
if [ $1 = '-gc434node' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES434}
	tar zxvf ces_linux_arm4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster node
fi
if [ $1 = '-gc434face' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES434}
	tar zxvf ces_linux_arm4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster face
fi
if [ $1 = '-gc431jq' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.31.2.16集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES431}
	tar zxvf ces_linux_arm4.31.2.16.tar.gz
	cd ./ces_linux4.31.2.16
	bash server_install.sh cluster main
fi
if [ $1 = '-gc431dj' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.31.2.16单机版服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES431}
	tar zxvf ces_linux_arm4.31.2.16.tar.gz
	cd ./ces_linux4.31.2.16
	bash server_install.sh single
fi
if [ $1 = '-gc431node' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.31.2.16集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMCES431}
	tar zxvf ces_linux_arm4.31.2.16.tar.gz
	cd ./ces_linux4.31.2.16
	bash server_install.sh cluster node
fi

##########################################################################################以下是中性版本##########################################################################################

if [ $1 = '-zx436dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.36.5.1单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES436}
	tar zxvf ces_linux_zx4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh single
fi
if [ $1 = '-zx436jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.36.5.1集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES436}
	tar zxvf ces_linux_zx4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh cluster main
fi
if [ $1 = '-zx436node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.5.1集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES436}
	tar zxvf ces_linux_zx4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh cluster node
fi
if [ $1 = '-zx436face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.36.5.1人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES436}
	tar zxvf ces_linux_zx4.36.5.1.tar.gz
	cd ./ces_linux4.36.5.1
	bash server_install.sh cluster face
fi
if [ $1 = '-zx435dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.35.4.5单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES435}
	tar zxvf ces_linux_zx4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh single
fi
if [ $1 = '-zx435jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.35.4.5集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES435}
	tar zxvf ces_linux_zx4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh cluster main
fi
if [ $1 = '-zx435node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES435}
	tar zxvf ces_linux_zx4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh cluster node
fi
if [ $1 = '-zx435face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.35.4.5人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES435}
	tar zxvf ces_linux_zx4.35.4.5.tar.gz
	cd ./ces_linux4.35.4.5
	bash server_install.sh cluster face
fi
if [ $1 = '-zx434dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.34.5.1单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES434}
	tar zxvf ces_linux_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh single
fi
if [ $1 = '-zx434jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.34.5.1集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES434}
	tar zxvf ces_linux_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster main
fi
if [ $1 = '-zx434node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES434}
	tar zxvf ces_linux_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster node
fi
if [ $1 = '-zx434face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.34.5.1人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES434}
	tar zxvf ces_linux_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster face
fi
if [ $1 = '-zx431node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.31.3.6集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES431}
	tar zxvf ces_linux_zx4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh cluster node
fi
if [ $1 = '-zx431dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.31.3.6单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES431}
	tar zxvf ces_linux_zx4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh single
fi
if [ $1 = '-zx431jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.31.3.6集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES431}
	tar zxvf ces_linux_zx4.31.3.5.tar.gz
	cd ./ces_linux4.31.3.5
	bash server_install.sh cluster main
fi
if [ $1 = '-zx432node' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES432}
	tar zxvf ces_linux_zx4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh cluster node
fi
if [ $1 = '-zx432face' ]
then
	echo -e "\033[33m 【你选择的是安装CES v4.32.8.5人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES432}
	tar zxvf ces_linux_zx4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh cluster face
fi
if [ $1 = '-zx432dj' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.32.8.5单机版】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES432}
	tar zxvf ces_linux_zx4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh single
fi
if [ $1 = '-zx432jq' ]
then
	echo -e "\033[33m 【你选择的是只安装CES v4.32.8.5集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ZXCES432}
	tar zxvf ces_linux_zx4.32.8.5.tar.gz
	cd ./ces_linux4.32.8.5
	bash server_install.sh cluster main
fi
if [ $1 = '-mzx435dj' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30单机版服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSZXCES435}
	tar zxvf ces_linux_mips_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh single
fi
if [ $1 = '-mzx435jq' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSZXCES435}
	tar zxvf ces_linux_mips_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster main
fi
if [ $1 = '-mzx435node' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSZXCES435}
	tar zxvf ces_linux_mips_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster node
fi
if [ $1 = '-mzx435face' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${MIPSZXCES435}
	tar zxvf ces_linux_mips_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster face
fi
if [ $1 = '-gczx435dj' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30单机版服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES435}
	tar zxvf ces_linux_arm_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh single
fi
if [ $1 = '-gczx435jq' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES435}
	tar zxvf ces_linux_arm_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster main
fi
if [ $1 = '-gczx435node' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES435}
	tar zxvf ces_linux_arm_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster node
fi
if [ $1 = '-gczx435face' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.35.1.30人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES435}
	tar zxvf ces_linux_arm_zx4.35.1.30.tar.gz
	cd ./ces_linux4.35.1.30
	bash server_install.sh cluster face
fi
if [ $1 = '-gczx434dj' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1单机版服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES434}
	tar zxvf ces_linux_arm_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh single
fi
if [ $1 = '-gczx434jq' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1集群主服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES434}
	tar zxvf ces_linux_arm_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster main
fi
if [ $1 = '-gczx434node' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1集群节点服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES434}
	tar zxvf ces_linux_arm_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster node
fi
if [ $1 = '-gczx434face' ]
then
	echo -e "\033[33m 【你选择的是只安装国产化CES v4.34.5.1人脸识别服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	${ARMZXCES434}
	tar zxvf ces_linux_arm_zx4.34.5.1.tar.gz
	cd ./ces_linux4.34.5.1
	bash server_install.sh cluster face
fi
if [ $1 = '-141fsp' ]
then
	echo -e "\033[33m 【你选择的是安装FSP v1.4.1.17服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	curl -sSL https://get.docker.com/ | sh
	systemctl enable docker
	systemctl start docker
	docker run -d --restart=unless-stopped -p 29100:29100 -p 28000:28000 --name fsp_pri ${FSP141}
fi
if [ $1 = '-174fsp' ]
then
	echo -e "\033[33m 【你选择的是安装FSP v1.7.4.2服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.4.2/set_extra_ip.sh -O set_extra_ip.sh
	wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.4.2/set_protocol_addr.sh -O set_protocol_addr.sh
    wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.4.2/set_store_proxy.sh -O set_store_proxy.sh
    wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.4.2/set_wb_app_id.sh -O set_wb_app_id.sh
	wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.7.4.2/add_protocol_addr.sh -O add_protocol_addr.sh
	curl -sSL https://get.docker.com/ | sh
	systemctl enable docker
	systemctl start docker
	docker run -d --name=fsp_pri ${FSP174}
	mkdir -p /usr/local/hst/fsp
	docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/fsmeeting /usr/local/hst/fsp
	docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/middleware /usr/local/hst/fsp
	docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/boss /usr/local/hst/fsp
	echo -e "正在停止FSP服务器"
	docker stop $(docker ps|grep fsp_pri|awk '{print $1}')
	sleep 5s
	echo -e "正在卸载FSP服务器"
	docker rm $(docker ps -qf status=exited)
	sleep 5s
	echo -e "正在启动FSP服务器"
	docker run -d -v /usr/local/hst/fsp/fsmeeting:/fsmeeting -v /usr/local/hst/fsp/middleware:/middleware -v /usr/local/hst/fsp/boss:/boss --name=fsp_pri -e addr="${LOCAL_IP}" -e service=wb2.web.ep --privileged --hostname fsp_server --net=host --restart=always ${FSP174}
fi
if [ $1 = '-183fsp' ]
then
	echo -e "\033[33m 【你选择的是安装FSP v1.8.3.3服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.3/set_extra_ip.sh -O set_extra_ip.sh
	wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.3/set_protocol_addr.sh -O set_protocol_addr.sh
    wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.3/set_store_proxy.sh -O set_store_proxy.sh
    wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.3/set_wb_app_id.sh -O set_wb_app_id.sh
	wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/1.8.3.3/add_protocol_addr.sh -O add_protocol_addr.sh
	curl -sSL https://get.docker.com/ | sh
	systemctl enable docker
	systemctl start docker
	docker run -d --name=fsp_pri ${FSP183}
	mkdir -p /usr/local/hst/fsp
	docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/fsmeeting /usr/local/hst/fsp
	docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/middleware /usr/local/hst/fsp
	docker cp $(docker ps|grep fsp_pri|awk '{print $1}'):/boss /usr/local/hst/fsp
	echo -e "正在停止FSP服务器"
	docker stop $(docker ps|grep fsp_pri|awk '{print $1}')
	sleep 5s
	echo -e "正在卸载FSP服务器"
	docker rm $(docker ps -qf status=exited)
	sleep 5s
	echo -e "正在启动FSP服务器"
	docker run -d -v /usr/local/hst/fsp/fsmeeting:/fsmeeting -v /usr/local/hst/fsp/middleware:/middleware -v /usr/local/hst/fsp/boss:/boss --name=fsp_pri -e addr="${LOCAL_IP}" -e service=wb2.web.ep.mds -e use_default_app=true --privileged --hostname fsp_server --net=host --restart=always ${FSP183}
fi
if [ $1 = '-luzhi' ]
then
	echo -e "\033[33m 【你选择的是安装录制服务器v1.0.7.16】 \033[0m"
	echo -e "\n"
	sleep 5s
	cd /opt
	${LUZHI}
	tar xvf mc-1.0.7.16.tar
	chmod +x setup.sh
	bash setup.sh
fi
if [ $1 = '-h323' ]
then
	echo -e "\033[33m 【你选择的是安装H323网关服务器v2.3.1.12】 \033[0m"
	echo -e "\n"
	sleep 5s	
	${H323}
	tar xvf h323gw_xd_pkg_2.3.1.12.tar.gz
	cd ./h323gw_xd_pkg_2.3.1.12
	echo -e "\033[33m 正在安装GC，请等待30秒 \033[0m"
	echo -e "\n"
	bash install.sh pri gc
	sleep 30s
	echo -e "\033[33m 正在安装GM，请等待30秒 \033[0m"
	echo -e "\n"
	bash install.sh pri gm
	echo -e "\033[33m 正在安装H323MCU，请等待30秒 \033[0m"
	echo -e "\n"
	sleep 30s
	${H323MCU}
	tar xvf centos7.installer_MCU20211231_2.3.1.12.tar
	cd ./centos7.installer
	bash install.sh
fi

##########################################################################################服务器安装脚本到此结束##########################################################################################

if [ $1 = '-rtmp' ]
then
	echo -e "\033[33m 【你选择的是安装RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	curl -sSL https://get.docker.com/ | sh
	systemctl enable docker
	systemctl start docker
	docker run -d --restart=unless-stopped -p 1935:1935 -p 1985:1985 -p 8080:8080 -p 1990:1990 -p 8088:8088 --env CANDIDATE="${LOCAL_IP}" -p 8000:8000/udp --name srs4 ccr.ccs.tencentyun.com/1040155/srs4 ./objs/srs -c conf/https.docker.conf
fi
if [ $1 = '-iperf' ]
then
	echo -e "\033[33m 【你选择的是安装iperf3局域网性能测试工具(服务端)】 \033[0m"
	echo -e "\n"
	sleep 5s
	curl -sSL https://get.docker.com/ | sh
	systemctl enable docker
	systemctl start docker
	docker run -d --restart=unless-stopped -p 5201:5201 -p 5201:5201/udp --name iperf3 ccr.ccs.tencentyun.com/1040155/iperf3 -s
fi
if [ $1 = '-html5' ]
then
	echo -e "\033[33m 【你选择的是安装HTML5网络速度测试工具(服务端)】 \033[0m"
	echo -e "\n"
	sleep 5s
	curl -sSL https://get.docker.com/ | sh
	systemctl enable docker
	systemctl start docker
	docker run -d --restart=unless-stopped -p 6688:80 --name hst-speedtest 1040155/hst-speedtest
fi
if [ $1 = '-xiezai' ]
then
	echo -e "\033[33m 【你选择的是卸载CES服务器】 \033[0m"
	echo -e "\n"
	sleep 5s
	cd /usr/local/hst
	bash server_uninstall.sh
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
	rm -rf /fsmeeting /usr/local/hst/fsp/
fi
if [ $1 = '-resetadmin' ]
then
	echo -e "\033[33m 【你选择的是重置后台admin密码】 \033[0m"
	echo -e "\n"
	sleep 5s	
	wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/install/resetadmin.sql -O resetadmin.sql
	mysql -u admin -pFsEntMeeting.com -P3308<"resetadmin.sql"
fi
if [ $1 = '-setip' ]
then
	echo -e "\033[33m 【你选择的是自动添加FSP公网地址（1.7.1.19以上才需要执行）】 \033[0m"
	echo -e "\n"
	sleep 5s	
	bash set_extra_ip.sh ${getIpAddress}
fi

#关闭并禁用防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service

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
echo -e "# *CES默认端口：1089、8080、8443                                                "
echo -e "#                                                                               "
echo -e "# *内网后台地址（仅限单机版和集群主服务器）：https://${LOCAL_IP}:8443           "
echo -e "#                                                                               "
echo -e "# *外网后台地址（仅限单机版和集群主服务器）：https://${getIpAddress}:8443       "
echo -e "#                                                                               "
echo -e "# *如需外网使用请在路由器中映射上述端口                                         "
echo -e "#                                                                               "
echo -e "# *后台默认用户名密码均为admin（4.35之后版本默认密码为HSTadmin123，用户名不变） "
echo -e "#                                                                               "
echo -e "# *使用过程中如有问题，请拨打400-1699-666转1号键联系我们                        "
echo -e "#                                                                               "
echo -e "# *本脚本作者：Sugar                                                            "
echo -e "#                                                                               "
echo -e "# *博客地址：https://www.yaohst.com                                             "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "
