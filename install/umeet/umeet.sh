#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2024年6月8日                         "*
echo -e "#                                                      "*
echo -e "# *建议使用CentOS7,其他版本暂未测试                    "* 
echo -e "#                                                      "*
echo -e "# *可按Ctrl+Z取消安装                                  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
# 获取内网IP地址
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# 美化Bash
if ! grep -q "getmyip" /etc/profile; then
    echo "# 获取IP函数" >> /etc/profile
    echo "function getmyip {" >> /etc/profile
    echo "    ip addr | grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -vE '^127\.|^255\.|^0\.' | head -n 1" >> /etc/profile
    echo "}" >> /etc/profile
fi
if ! grep -q "export PS1" /etc/profile; then
    echo "# 输出美化" >> /etc/profile
    echo "export PS1='\[\e[31m\][$?]\[\e[m\]:\[\e[32m\][\u@\H]\[\e[m\]:\[\e[34m\][\t]\[\e[m\]:\[\e[31m\][\$(getmyip)]\[\e[m\]:\[\e[33m\][\w]\[\e[m\]\$> '" >> /etc/profile
fi
# 调整root根目录大小
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
     #备份并修改/etc/fstab挂载路径
       sudo cp /etc/fstab /etc/fstab_bak
       sudo sed -i "\|^$home|d" /etc/fstab
     #查看是否成功扩容
       df -lh
    fi

# 判断网络环境,默认使用安装包下载地址检测
function check_internet() {
	if ! type wget >/dev/null 2>&1; then
        echo 'wget 未安装 正在安装中';
        timeout 60 yum -y install wget
    else 
        echo 'wget 已安装，继续操作'
    fi
    wget --no-check-certificate -q -T 10 --spider https://pan.yaohst.com/d/联通云盘/umeet-v4.10.2.zip
    if [ $? -eq 0 ]; then      
        return 0
    else
        return 1
    fi
}
check_internet
if [ $? -eq 0 ]; then
    echo "检测到外网环境,本次将使用在线安装方式,即将安装4.10.2版本的Umeet Pro"
#检测依赖
sys_install(){
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        curl -sSL https://get.docker.com/ | sh 
		systemctl enable docker
		systemctl start docker
    else 
        echo 'docker 已安装，继续操作'
    fi
	if ! type unzip >/dev/null 2>&1; then
        echo 'unzip 未安装 正在安装中';
        yum -y install unzip
    else 
        echo 'unzip 已安装，继续操作'
    fi
}
sys_install

#Umeet Pro下载并解压
wget -N --no-check-certificate https://pan.yaohst.com/d/联通云盘/umeet-v4.10.2.zip && unzip umeet*.zip -d /opt 
else
echo "未检测到外网环境,本次将使用离线安装方式"
#检测安装环境
while true; do
    if [ ! -f docker*.tgz ]; then
        echo "需要的docker.tgz文件不存在，无法进行离线安装"
        read -p "请将docker.tgz文件放置到当前目录下，然后按回车键继续..."
    else
        break
    fi
done

while true; do
    if [ ! -f umeet-*.zip ]; then
        echo "需要的umeet.zip文件不存在，无法进行离线安装"
        read -p "请将umeet.zip文件放置到当前目录下，然后按回车键继续..."
    else
        break
    fi
done

while ! command -v unzip &> /dev/null; do
    echo "unzip命令不可用，无法进行离线安装,5秒钟之后自动检测安装包"
    if [ -f unzip*.rpm ]; then
        rpm -ivh unzip*.rpm
        if [ $? -eq 0 ]; then
            echo "unzip安装成功！"
            break
        else
            echo "unzip安装失败，请检查安装包名称或手动安装。"
        fi
    else
        echo "未找到unzip.rpm安装包，请将安装包放置到当前目录下。"  
        sleep 5  # 等待5秒后继续检测		
    fi
done

#安装docker
tar -zxvf docker*.tgz
cp docker/* /usr/bin/

#解压umeet安装包
unzip umeet*.zip
mv systec /opt

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

# 限制docker日志大小
mkdir /etc/docker
cat >/etc/docker/daemon.json<<EOF
{
"log-driver": "json-file",
"log-opts": {"max-size":"20m", "max-file":"2"}
}
{
"registry-mirrors": ["https://hlx1vn88.mirror.aliyuncs.com"]
}
EOF

# 重新加载systemd并启用新的Docker服务
systemctl daemon-reload
systemctl enable docker.service

# 使用新的服务启动Docker
systemctl start docker.service
fi

#修改Umeet配置文件
systec_dir=/opt/systec/service/
services=(process proxy report device system task umeet gateway apphub migrate live imhub)
for i in ${services[*]};do
# fire config.properties/redisson.yml/redisson-sentinel.yml
        sed -i -r "/eureka/s#127.0.0.1#${IP}#" ${systec_dir}${i}/config.properties
	#mysql
	#sed -i -r "/spring.datasource.url=/s#127.0.0.1:3306#${IP}:3306#" ${systec_dir}${i}/config.properties
done

#系统环境设置
content="
net.core.somaxconn = 512
net.ipv4.ip_forward=1
"

#检查是否已经存在这些内容，如果不存在则追加
if ! grep -Fxq "$content" /etc/sysctl.conf
then
    echo "$content" >> /etc/sysctl.conf
    echo "内容已添加到/etc/sysctl.conf。"
else
    echo "内容已存在于/etc/sysctl.conf，无需添加。"
fi

#加载新的内核参数
sysctl -p

#修改系统的打开文件数量限制
echo '* - nofile 20000' | sudo tee -a /etc/security/limits.conf

#关闭selinux
sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config 

#安装umeet
ln -s /opt/systec/umeet /usr/bin/umeet
bash umeet create

#设置防火墙
#systemctl stop firewalld.service
#systemctl disable firewalld.service
firewall-cmd --permanent --add-port=80/tcp --add-port=443/tcp --add-port=6102/tcp --add-port=6100/tcp --add-port=6101/tcp --add-port=6199/tcp
firewall-cmd --reload

echo -e "                                                                                "
echo -e "#*******************************************************************************"*
echo -e "#                                                                               "
echo -e "# *恭喜！Umeet Pro服务器安装完成！                                              "
echo -e "#                                                                               "
echo -e "# *Umeet后台：https://${IP}:6102                                                "
echo -e "#                                                                               "
echo -e "# *Umeet前台：https://${IP}                                                     "
echo -e "#                                                                               "
echo -e "# *后台初始用户名密码均为admin                                                  "
echo -e "#                                                                               "
echo -e "# *本脚本作者：Sugar                                                            "
echo -e "#                                                                               "
echo -e "# *博客地址：https://www.yaohst.com                                             "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "
