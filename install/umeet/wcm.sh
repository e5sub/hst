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

# 判断网络环境,默认使用mysql安装包下载地址检测
function check_internet() {
	if ! type wget >/dev/null 2>&1; then
        echo 'wget 未安装 正在安装中';
        timeout 60 yum -y install wget
    else 
        echo 'wget 已安装，继续操作'
    fi
    wget --no-check-certificate -q -T 10 --spider https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.44-1.el7.x86_64.rpm-bundle.tar
    if [ $? -eq 0 ]; then      
        return 0
    else
        return 1
    fi
}
check_internet
if [ $? -eq 0 ]; then
    echo "检测到外网环境,本次将使用在线安装方式"
# 检测依赖
sys_install(){
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
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

# 下载所需的安装包
wget -N --no-check-certificate https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.44-1.el7.x86_64.rpm-bundle.tar
wget -N --no-check-certificate https://rpms.remirepo.net/enterprise/7/remi/x86_64/redis-7.2.3-1.el7.remi.x86_64.rpm
wget -N --no-check-certificate https://pan.yaohst.com/d/OS/umeet/wcm.zip
wget -N --no-check-certificate https://pan.yaohst.com/d/OS/umeet/init.sql
else
echo "未检测到外网环境,本次将使用离线安装方式"
# 检测安装环境
while true; do
    if [ ! -f docker*.tgz ]; then
        echo "需要的docker.tgz文件不存在，无法进行离线安装"
        read -p "请将docker.tgz文件放置到当前目录下，然后按回车键继续..."
    else
        break
    fi
done

while true; do
    if [ ! -f mysql-5.7*.tar ]; then
        echo "需要的mysql-5.7.tar文件不存在，无法进行离线安装"
        read -p "请将mysql-5.7.tar文件放置到当前目录下，然后按回车键继续..."
    else
        break
    fi
done

while true; do
    if [ ! -f redis*.rpm ]; then
        echo "需要的redis.rpm文件不存在，无法进行离线安装"
        read -p "请将redis.rpm文件放置到当前目录下，然后按回车键继续..."
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

# 安装docker
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

# 限制docker日志大小
mkdir /etc/docker
cat >/etc/docker/daemon.json<<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "20m",
    "max-file": "2"
  },
  "registry-mirrors": [
    "https://docker.071717.xyz"
  ]
}
EOF

# 重新加载systemd并启用新的Docker服务
systemctl daemon-reload
systemctl enable docker.service

# 使用新的服务启动Docker
systemctl start docker.service


# 移除任何已经安装的 MySQL 或者 MariaDB
rpm -e `rpm -qa | grep -i mysql`
rpm -e --nodeps `rpm -qa | grep -i mariadb`

# 解压Mysql5.7安装包
tar -xvf mysql-5.7*.tar
 
# 安装Mysql5.7
rpm -ivh mysql-community-common-5.7*.rpm
rpm -ivh mysql-community-libs-5.7*.rpm
rpm -ivh mysql-community-client-5.7*.rpm
rpm -ivh --nodeps mysql-community-server-5.7*.rpm

# 启动Mysql5.7
systemctl start mysqld

# 提取临时密码
temp_password=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# 设置mysql和redis新密码
new_password="wecom,123!"
read -p "请输入mysql和redis的新密码（默认为：$new_password）：" input
new_password=${input:-$new_password}

# 使用临时密码登录并修改密码
mysql -uroot --password="${temp_password}" --connect-expired-password -e "set global validate_password_policy=0; set global validate_password_mixed_case_count=0; ALTER USER 'root'@'localhost' IDENTIFIED BY '${new_password}'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${new_password}'; FLUSH PRIVILEGES;"
echo "Mysql密码已修改为${new_password}"

# 导入init.sql文件到MySQL
mysql -uroot --password="${new_password}"<"init.sql"

# 备份并更新my.cnf配置文件
cp /etc/my.cnf /etc/my_bak.cnf
echo "" > /etc/my.cnf
cat << EOF > /etc/my.cnf
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html
# *** DO NOT EDIT THIS FILE. It's a template which will be copied to the
# *** default location during install, and will be replaced if you
# *** upgrade to a newer version of MySQL.

[client]
#port	= 3306
#socket	= /data/3306/mysql.sock
default-character-set=utf8mb4

[mysql]
default-character-set = utf8mb4

[mysqld]
#port	=3306
#socket = /data/3306/mysql.sock
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'
lower_case_table_names=1
max_connections=2000

slow_query_log=1
long_query_time=2

interactive_timeout = 600
wait_timeout = 600

# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
innodb_buffer_pool_size = 4G

# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin

# These are commonly set, remove the # and set as required.
#basedir = /usr/local/mysql/
#datadir = /usr/local/mysql/data/
# port = .....
# server_id = .....
# socket = .....

# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M 

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 
EOF

# 重启Mysql5.7
systemctl restart mysqld

# 安装Redis
rpm -ivh redis*.rpm

# 修改密码并允许所有IP访问
cp /etc/redis/redis.conf /etc/redis/redis_bak.conf
REDIS_CONF="/etc/redis/redis.conf"
sed -i "s/^# requirepass .*/requirepass $new_password/" $REDIS_CONF
sed -i "s/^# masterauth .*/masterauth $new_password/" $REDIS_CONF
sed -i 's/^bind.*/bind 0.0.0.0/' $REDIS_CONF
echo "Redis密码已修改为${new_password}"

# 设置开机自启
systemctl start redis
systemctl enable redis

# 输出 Redis 安装状态
echo "Redis 安装成功!"

# 选择是否安装会话存档应用
read -p "是否安装会话存档应用? (y/n，默认为n) " answer
answer=${answer:-n}
case $answer in
    [Yy]* ) 
        echo "你选择了安装会话存档应用"; 
        # 检测会话存档安装包
        while true; do
            if [ ! -f wcm*.zip ]; then
                echo "需要的wcm*.zip文件不存在，无法进行离线安装"
                read -p "请将wcm*.zip文件放置到当前目录下，然后按回车键继续..."
            else
                break
            fi
        done
        # 解压并安装wcm
        unzip wcm*.zip
        chmod +x wcm_install.run        
        bash wcm_install.run
        ;;
    [Nn]* | "" ) 
        echo "你选择了不安装会话存档应用"
        ;;
    * ) 
        echo "请输入 y 或 n"
        ;;
esac

# 系统环境设置
content="
net.core.somaxconn = 512
net.ipv4.ip_forward=1
"

# 检查是否已经存在这些内容，如果不存在则追加
if ! grep -Fxq "$content" /etc/sysctl.conf
then
    echo "$content" >> /etc/sysctl.conf
    echo "内容已添加到/etc/sysctl.conf。"
else
    echo "内容已存在于/etc/sysctl.conf，无需添加。"
fi

# 加载新的内核参数
sysctl -p

# 修改系统的打开文件数量限制
echo '* - nofile 20000' | sudo tee -a /etc/security/limits.conf

# 关闭selinux
sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config 

# 设置防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service

echo -e "                                                                                "
echo -e "#*******************************************************************************"*
echo -e "#                                                                               "
echo -e "# *恭喜！安装完成！                                              "
echo -e "#                                                                               "
echo -e "# *后台初始用户名密码均为admin                                                  "
echo -e "#                                                                               "
echo -e "# *本脚本作者：Sugar                                                            "
echo -e "#                                                                               "
echo -e "# *博客地址：https://www.yaohst.com                                             "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "
