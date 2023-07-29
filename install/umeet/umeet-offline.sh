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

#安装docker
tar -zxvf docker*.tgz
cp docker/* /usr/bin/

# 创建docker.service文件
DOCKER_SERVICE_FILE="/etc/systemd/system/docker.service"

# 写入docker.service的内容
cat <<EOL > "$DOCKER_SERVICE_FILE"
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
# 默认情况下不使用systemd管理cgroup，因为委托问题仍然存在
# 而且systemd目前不支持运行docker容器所需的cgroup特性集
ExecStart=/usr/bin/dockerd --selinux-enabled=false --insecure-registry=172.16.40.210
ExecReload=/bin/kill -s HUP \$MAINPID
# 非零的Limit*s会导致由于内核中的会计开销而出现性能问题
# 我们建议使用cgroups来进行容器的本地账户管理
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# 如果你的systemd版本支持，取消注释TasksMax
# 仅systemd 226及以上版本支持此选项
#TasksMax=infinity

TimeoutStartSec=0
# 设置委派为yes，以便systemd不会重置docker容器的cgroup
Delegate=yes
# 仅终止docker进程，而不终止cgroup中的所有进程
KillMode=process
# 如果docker进程异常退出，则重启docker进程
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOL

# 修改docker.service文件中的ExecStart行
sed -i "s|ExecStart=/usr/bin/dockerd.*|ExecStart=/usr/bin/dockerd --selinux-enabled=false --insecure-registry=$IP|" /etc/systemd/system/docker.service

# 重新加载systemd并启用新的Docker服务
systemctl daemon-reload
systemctl enable docker.service

# 使用新的服务启动Docker
systemctl start docker.service

#解压Umeet安装包
unzip umeet*.zip
mv systec /opt

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
