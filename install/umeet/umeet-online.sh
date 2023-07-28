#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年7月31日                         "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *建议使用CentOS7,其他版本暂未测试                    "* 
echo -e "#                                                      "*
echo -e "# *可按Ctrl+Z取消安装                                  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
## 调整root根目录大小
    if [[ -z "${kr}" ]]; then    
        read -e -r -p "是否需要调整root根目录大小？留空默认不调整[y/n] " input
        case $input in
        [yY][eE][sS] | [yY])            
            kr=true
            ;;
        [nN][oO] | [nN])            
            ;;
        *)                            
            ;;
            esac        
    fi
    if [[ -z "${kr}" ]]; then
        echo "不调root整根目录大小" 
    else
        #查看root和home卷标
        df -lh
        #提取root和home卷标
        r=$(df -lh / | awk '$NF=="/" {print $1}')
        h=$(df -lh | awk '$NF=="/home" {print $1}')
        echo
        echo "默认会自动提取卷标,如果获取的不正确,请手动输入卷标"
        echo "请注意进行扩容之后会丢失home所有数据,请注意备份!!!"
        echo "请确保/root有少量剩余空间,否则有可能导致扩容失败!!!"
        echo
      pre_kuorong(){
       # Set root
        read -ep "(请输入上方的root目录卷标,按回车自动提取):" root
        [ -z "${root}" ] && root=${r}
        echo 
        echo "---------------------------"
        echo "root卷标 = ${root}"
        echo "---------------------------"
        echo
      # Set home
        read -ep "(请输入上方的home目录卷标,按回车自动提取):" home
        [ -z "${home}" ] && home=${h}
        echo
        echo "---------------------------"
        echo "home卷标 = ${home}"
        echo "---------------------------"
        echo
}
     # Config kuorong
       config_kuorong(){
       echo "正在调整根分区大小"       
       umount ${home} 
       lvremove ${home} -y
       lvextend -l +100%FREE ${root}
       xfs_growfs ${root}
} 
     #调用函数
       pre_kuorong
       config_kuorong
     #备份并删除/etc/fstab挂载路径
       sudo cp /etc/fstab /etc/fstab_bak
       sudo sed -i "\|^$home|d" /etc/fstab
     #查看是否成功扩容
       df -lh
    fi
#获取内网IP地址
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
#检测依赖
sys_install(){
    if ! type wget >/dev/null 2>&1; then
        echo 'wget 未安装 正在安装中';
        apt install wget -y || yum install wget -y
    else
        echo 'wget 已安装，继续操作'
    fi
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        curl -sSL https://get.docker.com/ | sh | systemctl enable docker && systemctl start docker
    else 
        echo 'docker 已安装，继续操作'
    fi
}
sys_install
#Umeet Pro安装包下载地址
wget -N --no-check-certificate -P /opt https://pan.yaohst.com/OS/umeet/umeet-v4.7.0.zip
#解压安装包
cd /opt
unzip umeet*.zip
#修改Umeet配置文件
systec_dir=/opt/systec/service/
services=(process proxy report device system task umeet gateway apphub migrate live imhub)
for i in ${services[*]};do
# fire config.properties/redisson.yml/redisson-sentinel.yml
        sed -i -r "/eureka/s#127.0.0.1#${IP}#" ${systec_dir}${i}/config.properties
	#mysql
	#sed -i -r "/spring.datasource.url=/s#127.0.0.1:3306#${IP}:3306#" ${systec_dir}${i}/config.properties
done
#安装umeet
cd /opt/systec
ln -s /opt/systec/umeet /usr/bin/umeet
umeet create
#设置防火墙
#systemctl stop firewalld.service
#systemctl disable firewalld.service
firewall-cmd --permanent --add-port=80/tcp --add-port=443/tcp --add-port=6102/tcp --add-port=6100/tcp --add-port=6101/tcp
firewall-cmd --reload

echo -e "                                                                                "
echo -e "#*******************************************************************************"*
echo -e "#                                                                               "
echo -e "# *恭喜！Umeet Pro服务器安装完成！                                              "
echo -e "#                                                                               "
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！                                     "
echo -e "#                                                                               "
echo -e "# *Umeet后台：https://${IP}:6102                                                "
echo -e "#                                                                               "
echo -e "# *Umeet前台：https://${IP}                                                     "
echo -e "#                                                                               "
echo -e "# *如需外网使用请在路由器中映射上述端口                                         "
echo -e "#                                                                               "
echo -e "# *后台初始用户名密码均为admin                                                  "
echo -e "#                                                                               "
echo -e "# *本脚本作者：Sugar                                                            "
echo -e "#                                                                               "
echo -e "# *博客地址：https://www.yaohst.com                                             "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "
