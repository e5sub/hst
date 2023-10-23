#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年10月23日                         "*
echo -e "#                                                      "*
echo -e "# *脚本支持CentOS/Ubuntu/Debian                        "* 
echo -e "#                                                      "*
echo -e "# *可按Ctrl+Z取消安装                                  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
# 获取内网IP地址
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# 检测系统类型
if [[ -f /etc/redhat-release ]]; then
# CentOS
echo -e "# 检测到系统为CentOS，仅支持MySQL5.7"
# 关闭并禁用防火墙
systemctl stop firewalld
systemctl disable firewalld
# 检测MySQL、Redis、Docker安装包
while true; do
    if ! command -v mysql &> /dev/null; then
        echo "未检测到MySQL环境，是否通过网络下载并安装？(Y/N)"
        read -r download_mysql
        if [ "$download_mysql" = "Y" ] || [ "$download_mysql" = "y" ]; then
            echo "正在下载 MySQL 安装包..."
            yum install -y wget && wget -c -N --no-check-certificate https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.43-1.el7.x86_64.rpm-bundle.tar
        else
            echo "请将 mysql.tar 文件放置到当前目录下，然后按回车键继续..."
            read  # 这里等待用户按回车键
            if ls mysql*.tar 1> /dev/null 2>&1; then
                echo "检测到MySQL安装包已存在。"                
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
                break  # 如果下载完成，退出循环
            fi
        fi
    else
        echo "检测到已有MySQL环境，跳过安装"
        break  # 如果MySQL已安装，退出循环
    fi
done
while true; do
    if ! command -v redis-server &> /dev/null; then
        echo "未检测到Redis环境，是否通过网络下载并安装？(Y/N)"
        read -r download_redis
        if [ "$download_redis" = "Y" ] || [ "$download_redis" = "y" ]; then
            echo "正在下载 Redis 安装包..."
            yum install -y wget && wget -c -N --no-check-certificate https://rpms.remirepo.net/enterprise/7/remi/x86_64/redis-7.2.2-1.el7.remi.x86_64.rpm
            break  # 如果下载完成，退出循环
        else
            echo "请将 redis.rpm 文件放置到当前目录下，然后按回车键继续..."
            read  # 这里等待用户按回车键
            if ls redis*.rpm 1> /dev/null 2>&1; then
                echo "检测到Redis安装包已存在。"
                # 安装Redis
                rpm -ivh redis*.rpm
                break  # 如果下载完成，退出循环
            fi
        fi       
    else
        echo "检测到已有Redis环境，跳过安装"
        break  # 如果Redis已安装，退出循环
    fi
done
while true; do
    if ! command -v docker &> /dev/null; then
        echo "未检测到Docker环境，是否通过网络下载并安装？(Y/N)"
        read -r download_docker
         if [ "$download_docker" = "Y" ] || [ "$download_docker" = "y" ]; then
            curl -sSL https://get.docker.com/ | sh 
            systemctl enable docker && systemctl start docker            
            break  # 如果下载完成，退出循环
        else
            echo "请将 docker.tgz 文件放置到当前目录下，然后按回车键继续..."
            read  # 这里等待用户按回车键
            if ls docker*.tgz 1> /dev/null 2>&1; then
                echo "检测到Docker安装包已存在。"
# 安装docker
tar -zxvf docker*.tgz
cp docker/* /usr/bin/

# 写入docker.service的内容
cat <<EOL > /etc/systemd/system/docker.service
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
EOF

# 重新加载systemd并启用新的Docker服务
systemctl daemon-reload
systemctl enable docker.service

# 使用新的服务启动Docker
systemctl start docker.service
                break  # 如果检测存在，退出循环
            fi
        fi
    else
        echo "检测到已有Docker环境，跳过安装"
        break  # 如果Docker已安装，退出循环
    fi
done

# 提取临时密码
temp_password=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# 设置mysql和redis新密码
new_password="wecom,123!"
read -p "请输入mysql和redis的新密码（默认为：$new_password）：" input
new_password=${input:-$new_password}

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

# 使用临时密码登录并修改MYSQL密码
mysql -uroot --password="${temp_password}" --connect-expired-password -e "set global validate_password_policy=0; set global validate_password_mixed_case_count=0; ALTER USER 'root'@'localhost' IDENTIFIED BY '${new_password}';GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${new_password}'; FLUSH PRIVILEGES;"
echo "Mysql密码已修改为${new_password}"

# 创建同步所需的MYSQL用户
read -ep "请输入MySQL主服务器的地址: " master_host
read -ep "请输入同步用的MySQL用户名（主从保持一致）: " master_user
read -ep "请输入同步用的MySQL密码（主从保持一致）: " master_password
read -ep "请输入MySQL服务器的ID（输入数字，注意不能重复，默认1为主服务器）: " mysql_id

cat  >> /etc/my.cnf <<EOF 
server-id = $mysql_id 
log-bin = mysql-bin 
# 用于排除自带的数据库。  
binlog-ignore-db = mysql 
binlog-ignore-db = information_schema
binlog-ignore-db = performance_schema
#二进制日志格式，建议使用ROW格式以获得更好的兼容性和可靠性。
binlog-format = ROW 
EOF

# 重启MySQL
systemctl restart mysqld

my_cnf="/etc/my.cnf"
# 检查my.cnf文件是否存在
if [ -f "$my_cnf" ]; then
    # 获取my.cnf中的server-id配置值
    server_id=$(grep -oP 'server-id\s*=\s*\K\d+' "$my_cnf")
    
    # 检查server-id是否为空
    if [ -n "$server_id" ]; then
        if [ "$server_id" -eq 1 ]; then
            # 主服务器
            echo "这是主服务器，执行主服务器脚本"
            
            # 执行主服务器脚本
            mysql -uroot -p"$new_password" -e "set global validate_password_policy=0; set global validate_password_mixed_case_count=0; CREATE USER '$master_user'@'%' IDENTIFIED BY '$master_password'; GRANT REPLICATION SLAVE ON *.* TO '$master_user'@'%'; FLUSH PRIVILEGES;"
        else
            # 从服务器
            echo "这是从服务器，执行从服务器脚本"
            
            # 获取主服务器的二进制日志文件名和位置
            read -ep "请输入主MySQL的root密码: " root_password
            result=$(mysql -h "$master_host" -uroot -p"$root_password" -e "SHOW MASTER STATUS\G")
            master_log_file=$(echo "$result" | awk '/File:/ {print $2}')
            master_log_pos=$(echo "$result" | awk '/Position:/ {print $2}')            
            echo "主服务器的二进制日志文件名为: $master_log_file"
            echo "主服务器的日志大小为: $master_log_pos"
            
            # 在从服务器上执行初始化
            mysql -uroot -p"$new_password" -e "STOP SLAVE;"
            mysql -uroot -p"$new_password" -e "CHANGE MASTER TO MASTER_HOST='$master_host', MASTER_USER='$master_user', MASTER_PASSWORD='$master_password', MASTER_LOG_FILE='$master_log_file', MASTER_LOG_POS=$master_log_pos;"
            mysql -uroot -p"$new_password" -e "START SLAVE;"
            
            # 检查从服务器的复制状态
            status=$(mysql uroot -p"$new_password" "SHOW SLAVE STATUS\G")
            
            # 检查复制状态是否正常
            if [[ $status == *"Slave_IO_Running: Yes"* && $status == *"Slave_SQL_Running: Yes"* ]]; then
                echo "MySQL主从复制已成功配置。"
            else
                echo "MySQL主从复制配置失败，请检查配置和日志。"
            fi
        fi
    else
        echo "无法确定服务器角色，因为my.cnf中没有server-id配置。"
    fi
else
    echo "my.cnf文件不存在或路径不正确。"
fi
elif [[ -f /etc/lsb-release ]]; then
# Ubuntu
echo -e "# 检测到系统为Ubuntu，仅支持MySQL5.7"
# 关闭防火墙
sudo ufw disable
# 检测MySQL安装包
while true; do
    if ! command -v mysql &> /dev/null; then
        echo "未检测到MySQL环境，是否通过网络下载并安装？(Y/N)"
        read -r download_mysql
        if [ "$download_mysql" = "Y" ] || [ "$download_mysql" = "y" ]; then
            echo "正在下载 MySQL 安装包..."
            yum install -y wget && wget -c -N --no-check-certificate https://downloads.mysql.com/archives/get/p/23/file/mysql-server_5.7.42-1ubuntu18.04_amd64.deb-bundle.tar
        else
            echo "请将 mysql.tar 文件放置到当前目录下，然后按回车键继续..."
            read  # 这里等待用户按回车键
            if ls mysql*.tar 1> /dev/null 2>&1; then
                echo "检测到MySQL安装包已存在。"
                # 解压MySQL安装包
                tar -xvf mysql*.tar
                # 安装MySQL
                apt install -y libaio1 libtinfo5 libmecab2
                dpkg -i mysql-common*.deb
                dpkg-preconfigure mysql-community-server*.deb 
                dpkg -i libmysqlclient20*.deb
                dpkg -i libmysqlclient-dev*.deb
                dpkg -i libmysqld-dev*.deb
                dpkg -i mysql-community-client*.deb
                dpkg -i mysql-client*.deb
                dpkg -i mysql-community-server*.deb
                dpkg -i mysql-server*.deb
                break  # 如果下载完成，退出循环
            fi
        fi
    else
        echo "检测到已有MySQL环境，跳过安装"
        break  # 如果MySQL已安装，退出循环
    fi
done
# 安装Redis
apt install -y redis
# 获取MySQL密码
read -ep "请输入主MySQL的root密码: " root_password
# 修改密码并允许所有IP访问
cp /etc/redis/redis.conf /etc/redis/redis_bak.conf
REDIS_CONF="/etc/redis/redis.conf"
sed -i "s/^# requirepass .*/requirepass $root_password/" $REDIS_CONF
sed -i "s/^# masterauth .*/masterauth $root_password/" $REDIS_CONF
sed -i 's/^bind.*/bind 0.0.0.0/' $REDIS_CONF
echo "Redis密码已修改为${root_password}"
# 设置MySQL访问权限
mysql -uroot -p"$root_password" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${root_password}'; FLUSH PRIVILEGES;"
# 创建同步所需的MYSQL用户
read -ep "请输入MySQL主服务器的地址: " master_host
read -ep "请输入同步用的MySQL用户名（主从保持一致）: " master_user
read -ep "请输入同步用的MySQL密码（主从保持一致）: " master_password
read -ep "请输入MySQL服务器的ID（输入数字，注意不能重复，默认1为主服务器）: " mysql_id
cat  >> /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF 
server-id = $mysql_id 
log-bin = mysql-bin 
# 用于排除自带的数据库。  
binlog-ignore-db = mysql 
binlog-ignore-db = information_schema
binlog-ignore-db = performance_schema
#二进制日志格式，建议使用ROW格式以获得更好的兼容性和可靠性。
binlog-format = ROW 
EOF
sed -i 's/^bind-address/# bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
# 重启MySQL
systemctl restart mysql.service
my_cnf="/etc/mysql/mysql.conf.d/mysqld.cnf"
# 检查my.cnf文件是否存在
if [ -f "$my_cnf" ]; then
    # 获取my.cnf中的server-id配置值
    server_id=$(grep -oP 'server-id\s*=\s*\K\d+' "$my_cnf")
    
    # 检查server-id是否为空
    if [ -n "$server_id" ]; then
        if [ "$server_id" -eq 1 ]; then
            # 主服务器
            echo "这是主服务器，执行主服务器脚本"
            
            # 执行主服务器脚本
            mysql -uroot -p"$root_password" -e "CREATE USER '$master_user'@'%' IDENTIFIED BY '$master_password'; GRANT REPLICATION SLAVE ON *.* TO '$master_user'@'%'; FLUSH PRIVILEGES;"
        else
            # 从服务器
            echo "这是从服务器，执行从服务器脚本"
            
            # 获取主服务器的二进制日志文件名和位置
            result=$(mysql -h "$master_host" -uroot -p"$root_password" -e "SHOW MASTER STATUS\G")
            master_log_file=$(echo "$result" | awk '/File:/ {print $2}')
            master_log_pos=$(echo "$result" | awk '/Position:/ {print $2}')            
            echo "主服务器的二进制日志文件名为: $master_log_file"
            echo "主服务器的日志大小为: $master_log_pos"
            
            # 在从服务器上执行初始化
            mysql -uroot -p"$root_password" -e "STOP SLAVE;"
            mysql -uroot -p"$root_password" -e "CHANGE MASTER TO MASTER_HOST='$master_host', MASTER_USER='$master_user', MASTER_PASSWORD='$master_password', MASTER_LOG_FILE='$master_log_file', MASTER_LOG_POS=$master_log_pos;"
            mysql -uroot -p"$root_password" -e "START SLAVE;"
            
            # 检查从服务器的复制状态
            status=$(mysql -uroot -p"$root_password" -e "SHOW SLAVE STATUS\G")
            
            # 检查复制状态是否正常
            if [[ $status == *"Slave_IO_Running: Yes"* && $status == *"Slave_SQL_Running: Yes"* ]]; then
                echo "MySQL主从复制已成功配置。"
            else
                echo "MySQL主从复制配置失败，请检查配置和日志。"
            fi
        fi
    else
        echo "无法确定服务器角色，因为my.cnf中没有server-id配置。"
    fi
else
    echo "my.cnf文件不存在或路径不正确。"
fi
elif [[ -f /etc/debian_version ]]; then
# Debian
echo -e "# 检测到系统为Debian，仅支持MySQL8.0"
# 检测MySQL安装包
while true; do
    if ! command -v mysql &> /dev/null; then
        echo "未检测到MySQL环境，是否通过网络下载并安装？(Y/N)"
        read -r download_mysql
        if [ "$download_mysql" = "Y" ] || [ "$download_mysql" = "y" ]; then
            echo "正在下载 MySQL 安装包..."
            yum install -y wget && wget -c -N --no-check-certificate https://downloads.mysql.com/archives/get/p/23/file/mysql-server_8.0.33-1debian11_amd64.deb-bundle.tar
        else
            echo "请将 mysql.tar 文件放置到当前目录下，然后按回车键继续..."
            read  # 这里等待用户按回车键
            if ls mysql*.tar 1> /dev/null 2>&1; then
                echo "检测到MySQL安装包已存在。"
                # 安装MySQL8.0依赖
                wget -c -N --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/debian/pool/main/o/openssl/libssl1.1_1.1.1w-0%2Bdeb11u1_amd64.deb 
                dpkg -i libssl1.1_1.1.1w-0+deb11u1_amd64.deb
                # 解压MySQL安装包
                tar -xvf mysql*.tar
                # 安装MySQL
                apt install -y psmisc libaio1 libnuma1 libatomic1 libmecab2
                dpkg -i mysql-common*.deb
                dpkg -i mysql-community-client-plugins*.deb
                dpkg -i mysql-community-client-core*.deb
                dpkg -i mysql-community-client*.deb
                dpkg -i mysql-client*.deb
                dpkg -i mysql-community-server-core*.deb
                dpkg -i mysql-community-server*.deb 
                dpkg -i mysql-server*.deb
                break  # 如果下载完成，退出循环
            fi
        fi
    else
        echo "检测到已有MySQL环境，跳过安装"
        break  # 如果MySQL已安装，退出循环
    fi
done
# 安装Redis
apt install -y redis
# 获取MySQL密码
read -ep "请输入主MySQL的root密码: " root_password
# 修改密码并允许所有IP访问
cp /etc/redis/redis.conf /etc/redis/redis_bak.conf
REDIS_CONF="/etc/redis/redis.conf"
sed -i "s/^# requirepass .*/requirepass $root_password/" $REDIS_CONF
sed -i "s/^# masterauth .*/masterauth $root_password/" $REDIS_CONF
sed -i 's/^bind.*/bind 0.0.0.0/' $REDIS_CONF
echo "Redis密码已修改为${root_password}"
# 设置MySQL访问权限
mysql -uroot -p"$root_password" -e "USE mysql; UPDATE user SET host='%' WHERE user='root'; FLUSH PRIVILEGES;"
# 创建同步所需的MYSQL用户
read -ep "请输入MySQL主服务器的地址: " master_host
read -ep "请输入同步用的MySQL用户名（主从保持一致）: " master_user
read -ep "请输入同步用的MySQL密码（主从保持一致）: " master_password
read -ep "请输入MySQL服务器的ID（输入数字，注意不能重复，默认1为主服务器）: " mysql_id
cat  >> /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF 
server-id = $mysql_id 
log-bin = mysql-bin 
# 用于排除自带的数据库。  
binlog-ignore-db = mysql 
binlog-ignore-db = information_schema
binlog-ignore-db = performance_schema
#二进制日志格式，建议使用ROW格式以获得更好的兼容性和可靠性。
binlog-format = ROW 
EOF
sed -i 's/^bind-address/# bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
# 重启MySQL
systemctl restart mysql.service
my_cnf="/etc/mysql/mysql.conf.d/mysqld.cnf"
# 检查my.cnf文件是否存在
if [ -f "$my_cnf" ]; then
    # 获取my.cnf中的server-id配置值
    server_id=$(grep -oP 'server-id\s*=\s*\K\d+' "$my_cnf")
    
    # 检查server-id是否为空
    if [ -n "$server_id" ]; then
        if [ "$server_id" -eq 1 ]; then
            # 主服务器
            echo "这是主服务器，执行主服务器脚本"            
            # 执行主服务器脚本
            mysql -uroot -p"$root_password" -e "CREATE USER '$master_user'@'%' IDENTIFIED BY '$master_password'; GRANT REPLICATION SLAVE ON *.* TO '$master_user'@'%'; FLUSH PRIVILEGES;"
        else
            # 从服务器
            echo "这是从服务器，执行从服务器脚本"            
            # 获取主服务器的二进制日志文件名和位置
            result=$(mysql -h "$master_host" -uroot -p"$root_password" -e "SHOW MASTER STATUS\G")
            master_log_file=$(echo "$result" | awk '/File:/ {print $2}')
            master_log_pos=$(echo "$result" | awk '/Position:/ {print $2}')            
            echo "主服务器的二进制日志文件名为: $master_log_file"
            echo "主服务器的日志大小为: $master_log_pos"
            
            # 在从服务器上执行初始化
            mysql -uroot -p"$root_password" -e "STOP SLAVE;"
            mysql -uroot -p"$root_password" -e "CHANGE MASTER TO MASTER_HOST='$master_host', MASTER_USER='$master_user', MASTER_PASSWORD='$master_password', MASTER_LOG_FILE='$master_log_file', MASTER_LOG_POS=$master_log_pos;"
            mysql -uroot -p"$root_password" -e "START SLAVE;"
            
            # 检查从服务器的复制状态
            status=$(mysql -uroot -p"$root_password" -e "SHOW SLAVE STATUS\G")
            
            # 检查复制状态是否正常
            if [[ $status == *"Slave_IO_Running: Yes"* && $status == *"Slave_SQL_Running: Yes"* ]]; then
                echo "MySQL主从复制已成功配置。"
            else
                echo "MySQL主从复制配置失败，请检查配置和日志。"
            fi
        fi
    else
        echo "无法确定服务器角色，因为my.cnf中没有server-id配置。"
    fi
else
    echo "my.cnf文件不存在或路径不正确。"
fi
else
    echo "不支持的操作系统"
    exit 1
fi