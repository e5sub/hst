#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2024年5月27日                          "*
echo -e "#                                                      "*
echo -e "# *脚本支持CentOS/Ubuntu/Debian                        "*
echo -e "#                                                      "*
echo -e "# *可按Ctrl+Z取消安装                                  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
# 获取内网IP地址
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
interface=$(ip route show | grep -i 'default via' | awk '{print $5; exit}')
#--------------------------------------------------------------------------------------
# MySQL/Redis密码相关
root_password=admin@yaohst.com
read -ep "请输入要设置的MySQL的root密码（默认为：$root_password）：" input
root_password=${input:-$root_password}
new_password=$root_password
master_user=admin
read -ep "创建同步用的MySQL用户名（主从请保持一致，留空默认为：$master_user）：" input
master_user=${input:-$master_user}
master_password=admin@yaohst.com
read -ep "创建同步用的MySQL用户密码（主从请保持一致，留空默认为：$master_password）：" input
master_password=${input:-$master_password}
redis_password=admin@yaohst.com
read -ep "请输入要设置的Redis密码（留空默认为：$redis_password）：" input
redis_password=${input:-$redis_password}
master_host=127.0.0.1
read -ep "请输入要设置的MySQL主服务器地址（留空默认为：$master_host）：" input
master_host=${input:-$master_host}
mysql_port=3306
read -ep "请输入要设置的MySQL的端口（默认为3306）：" input
mysql_port=${input:-$mysql_port}
mysql_id=1
read -ep "请输入要设置的MySQL的ID（输入数字，注意不能重复，留空默认1为主服务器）：" input
mysql_id=${input:-$mysql_id}
#--------------------------------------------------------------------------------------
#------------------------------keepalived虚拟IP设置部分---------------------------------
# 提取IP地址的前三段
ip_prefix=$(echo "$IP" | cut -d '.' -f 1-3)
# 指定最后一段
last_octet="88"  # 这里指定为88，你可以根据需要修改
# 组装成完整的虚拟IP地址
virtual_ip="$ip_prefix.$last_octet"
read -ep "请输入要设置的 keepalived 虚拟IP地址（默认为：$virtual_ip）：" input
virtual_ip=${input:-$virtual_ip}
#--------------------------------------------------------------------------------------
# MySQL/Redis下载地址
CentOS_MySQL=https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-8.4.0-1.el7.aarch64.rpm-bundle.tar
Ubuntu_MySQL=https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-server_8.4.0-1ubuntu24.04_amd64.deb-bundle.tar
Debian_MySQL=https://dev.mysql.com/get/Downloads/MySQL-8.4/mysql-server_8.4.0-1debian12_amd64.deb-bundle.tar
CentOS_Redis=https://rpms.remirepo.net/enterprise/7/remi/x86_64/redis-7.2.4-1.el7.remi.x86_64.rpm
if grep -q "net.ipv4.ip_forward = 1" /etc/sysctl.conf; then
    :
else
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
fi
sysctl -p
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
# docker安装
    if ! type curl >/dev/null 2>&1; then
        echo 'curl 未安装 正在安装中';
        apt install curl -y || yum install curl -y
    else
        echo 'curl 已安装，继续操作'
    fi
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        curl -sSL https://get.docker.com/ | sh 
		systemctl enable docker		
    else 
        echo 'docker 已安装，继续操作'
    fi
# 限制docker日志大小
cat >/etc/docker/daemon.json<<EOF
{
"log-driver": "json-file",
"log-opts": {"max-size":"20m", "max-file":"2"}
}
EOF
systemctl daemon-reload
systemctl start docker
# 检测系统类型
if [[ -f /etc/redhat-release ]]; then
    # CentOS
    echo -e "# 检测到系统为CentOS，仅支持MySQL8.x"
    # 开放防火墙端口
    firewall-cmd --add-masquerade --permanent
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --zone=public --add-port=443/tcp --permanent
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
    firewall-cmd --zone=public --add-port=6379/tcp --permanent
    firewall-cmd --zone=public --add-port=26379/tcp --permanent
    firewall-cmd --reload
    # 禁用SELinux
    setenforce 0
    sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config
    # 检测MySQL、Redis安装包
while true; do
    if ! command -v mysql &> /dev/null; then
        # 移除任何已经安装的 MySQL 或者 MariaDB
        rpm -e `rpm -qa | grep -i mysql`
        rpm -e --nodeps `rpm -qa | grep -i mariadb`
        curl -LO -k https://dev.mysql.com/get/mysql84-community-release-el7-1.noarch.rpm && rpm -ivh mysql84-community-release-el7-1.noarch.rpm
        yum -y install mysql-community-server wget unzip libappindicator-gtk3 libXScrnSaver-devel perl net-tools libaio* keepalived    
        break
    else
        echo "检测到已有 MySQL 环境，跳过安装。"
        break
    fi
done
while true; do
    if ! command -v redis-server &> /dev/null; then
        if ls redis*.rpm 1> /dev/null 2>&1; then
            echo "检测到 Redis 安装包已存在，跳过下载。"
        else
            echo "未检测到 Redis 安装包，正在下载..."
            wget -N --no-check-certificate $CentOS_Redis
        fi
        # 安装 Redis
        rpm -ivh redis*.rpm
        break
    else
        echo "检测到已有 Redis 环境，跳过安装。"
        break
    fi
done
cat  >> /etc/my.cnf <<EOF
port = $mysql_port
server-id = $mysql_id
log-bin = mysql-bin
max_binlog_size=512M
replica_skip_errors=1032,1146,1007,1008,1050,1051
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema
binlog-ignore-db=sys
innodb_log_file_size=1G
slow_query_log = ON
slow_query_log_file=/var/lib/mysql/instance-slow.log
long_query_time = 10
max_connections=3000
lower_case_table_names=1
character_set_server=utf8mb4
symbolic-links=0
max_connect_errors=100
explicit_defaults_for_timestamp=true
EOF
    echo "请稍候，正在初始化数据库。。。"
    # 初始化数据库
    rm -rf /var/lib/mysql/*
    mysqld --defaults-file=/etc/my.cnf --initialize --user=mysql --lower_case_table_names=1 > /var/log/mysqld.log 2>&1
    # 重启MySQL
    systemctl restart mysqld
    # 提取临时密码
    temp_password=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
    # 备份Redis配置文件
    cp /etc/redis/redis.conf /etc/redis/redis_bak.conf
    cp /etc/redis/sentinel.conf /etc/redis/sentinel_bak.conf
    # Redis配置文件路径
    sentinel_config="/etc/redis/sentinel.conf"
    REDIS_CONF="/etc/redis/redis.conf"
    sed -i "s/^# requirepass .*/requirepass $redis_password/" $REDIS_CONF
    sed -i "s/^# masterauth .*/masterauth $redis_password/" $REDIS_CONF
    sed -i "s/^protected-mode .*$/protected-mode no/" $REDIS_CONF
    sed -i 's/^bind.*/bind 0.0.0.0/' $REDIS_CONF
    chown -R redis /etc/redis
    echo "Redis密码已修改为${redis_password}"
    # 设置开机自启
    systemctl enable redis
    systemctl enable redis-sentinel
    systemctl restart redis
    # 使用临时密码登录并修改MYSQL密码
    mysql -uroot --password="${temp_password}" --connect-expired-password -P $mysql_port -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}'; CREATE USER 'root'@'%' IDENTIFIED BY '${root_password}'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null
    echo "Mysql密码已修改为${new_password}"  
    # 重启MySQL
    systemctl restart mysqld
elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu
    echo -e "# 检测到系统为Ubuntu，仅支持MySQL8.x"
    # 开放防火墙端口
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 3306/tcp
    sudo ufw allow 6379/tcp
    sudo ufw allow 26379/tcp
    # 检测 MySQL 安装包
while true; do
    if ! command -v mysql &> /dev/null; then
        # 安装 MySQL
        apt update && apt install -y libaio1 libtinfo5 libmecab2 curl gnupg2 ca-certificates net-tools lsb-release debian-archive-keyring psmisc libnuma1 mecab-ipadic-utf8 keepalived mysql-server
        break
    else
        echo "检测到已有 MySQL 环境，跳过安装。"
        break
    fi
done
    # 安装Redis
    apt install -y redis redis-sentinel
    # 备份Redis配置文件
    cp /etc/redis/redis.conf /etc/redis/redis_bak.conf
    cp /etc/redis/sentinel.conf /etc/redis/sentinel_bak.conf
    # Redis配置文件路径
    sentinel_config="/etc/redis/sentinel.conf"
    REDIS_CONF="/etc/redis/redis.conf"
    sed -i "s/^# requirepass .*/requirepass $redis_password/" $REDIS_CONF
    sed -i "s/^# masterauth .*/masterauth $redis_password/" $REDIS_CONF
    sed -i "s/^protected-mode .*$/protected-mode no/" $REDIS_CONF
    sed -i 's/^bind.*/bind 0.0.0.0/' $REDIS_CONF
    chown -R redis /etc/redis
    echo "Redis密码已修改为${redis_password}"
    # 重启Redis
    systemctl restart redis
cat  >> /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF
port = $mysql_port
server-id = $mysql_id
log-bin = mysql-bin
max_binlog_size=512M
replica_skip_errors=1032,1146,1007,1008,1050,1051
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema
binlog-ignore-db=sys
innodb_log_file_size=1G
slow_query_log = ON
slow_query_log_file=/var/lib/mysql/instance-slow.log
long_query_time = 10
max_connections=3000
lower_case_table_names=1
character_set_server=utf8mb4
symbolic-links=0
max_connect_errors=100
explicit_defaults_for_timestamp=true
EOF
sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i 's/^mysqlx-bind-address\s*=\s*127.0.0.1/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
echo "请稍候，正在初始化数据库。。。"
# 初始化数据库
rm -rf /var/lib/mysql/*
mysqld --defaults-file=/etc/mysql/mysql.conf.d --initialize --user=mysql --lower_case_table_names=1 > /var/log/mysqld.log 2>&1
# 重启MySQL
systemctl restart mysql.service
temp_password=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
# 使用临时密码登录并修改MYSQL密码
mysql -uroot --password="${temp_password}" --connect-expired-password -P $mysql_port -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}'; CREATE USER 'root'@'%' IDENTIFIED BY '${root_password}'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null
elif [[ -f /etc/debian_version ]]; then
    # Debian
    echo -e "# 检测到系统为Debian，仅支持MySQL8.x"
    # 检测 MySQL 安装包
while true; do
    if ! command -v mysql &> /dev/null; then
        # 安装 MySQL
        curl -LO -k https://dev.mysql.com/get/mysql-apt-config_0.8.30-1_all.deb && dpkg -i ./mysql-apt-config_0.8.30-1_all.deb
        apt update && apt install -y libaio1 libtinfo5 libmecab2 curl gnupg2 ca-certificates net-tools lsb-release debian-archive-keyring psmisc libnuma1 mecab-ipadic-utf8 keepalived mysql-server
        break
    else
        echo "检测到已有 MySQL 环境，跳过安装。"
        break
    fi
done
    # 安装Redis
    apt install -y redis redis-sentinel
    # 备份Redis配置文件
    cp /etc/redis/redis.conf /etc/redis/redis_bak.conf
    cp /etc/redis/sentinel.conf /etc/redis/sentinel_bak.conf
    # Redis配置文件路径
    sentinel_config="/etc/redis/sentinel.conf"
    REDIS_CONF="/etc/redis/redis.conf"
    sed -i "s/^# requirepass .*/requirepass $redis_password/" $REDIS_CONF
    sed -i "s/^# masterauth .*/masterauth $redis_password/" $REDIS_CONF
    sed -i "s/^protected-mode .*$/protected-mode no/" $REDIS_CONF
    sed -i 's/^bind.*/bind 0.0.0.0/' $REDIS_CONF
    chown -R redis /etc/redis
    echo "Redis密码已修改为${redis_password}"
    # 重启Redis
    systemctl restart redis
cat  >> /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF
port = $mysql_port
server-id = $mysql_id
log-bin = mysql-bin
max_binlog_size=512M
replica_skip_errors=1032,1146,1007,1008,1050,1051
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema
binlog-ignore-db=sys
innodb_log_file_size=1G
slow_query_log = ON
slow_query_log_file=/var/lib/mysql/instance-slow.log
long_query_time = 10
max_connections=3000
lower_case_table_names=1
character_set_server=utf8mb4
symbolic-links=0
max_connect_errors=100
explicit_defaults_for_timestamp=true
EOF
sed -i 's/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i 's/^mysqlx-bind-address\s*=\s*127.0.0.1/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
echo "请稍候，正在初始化数据库。。。"
# 初始化数据库
rm -rf /var/lib/mysql/*
mysqld --defaults-file=/etc/mysql/mysql.conf.d --initialize --user=mysql --lower_case_table_names=1 > /var/log/mysqld.log 2>&1
# 重启MySQL
systemctl restart mysql.service
temp_password=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
# 使用临时密码登录并修改MYSQL密码
mysql -uroot --password="${temp_password}" --connect-expired-password -P $mysql_port -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}'; CREATE USER 'root'@'%' IDENTIFIED BY '${root_password}'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null
else
    echo "不支持的操作系统"
fi
# 设置本机hosts解析
sed -i "/^127\.0\.0\.1\s*$(hostname)$/d" /etc/hosts
echo "127.0.0.1   $(hostname)" | sudo tee -a /etc/hosts
# 检查 /etc/my.cnf 文件是否存在
if [[ -f /etc/my.cnf ]]; then
    my_cnf="/etc/my.cnf"
# 检查 /etc/mysql/mysql.conf.d/mysqld.cnf 文件是否存在
elif [[ -f /etc/mysql/mysql.conf.d/mysqld.cnf ]]; then
    my_cnf="/etc/mysql/mysql.conf.d/mysqld.cnf"
else
    echo "未找到MySQL配置文件"
    exit 1
fi
# 主从脚本执行
if [ "$mysql_id" -eq 1 ]; then
    # 主服务器
    echo "这是主服务器，执行主服务器脚本"  
    hostnamectl set-hostname master0$mysql_id  
    #echo "master_info_repository=TABLE" | tee -a $my_cnf
    # 重启 MySQL 数据库
    if systemctl status mysqld.service >/dev/null 2>&1; then
    systemctl restart mysqld.service
    elif systemctl status mysql.service >/dev/null 2>&1; then
    systemctl restart mysql.service
    else
    echo "MySQL 服务未找到"
    fi
    # 执行主服务器脚本
    mysql -uroot -p"$new_password" -e "CREATE USER '${master_user}'@'%' IDENTIFIED BY '${master_password}'; GRANT ALL PRIVILEGES ON *.* TO '${master_user}'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>/dev/null
    redis-cli -h 127.0.0.1 -p 6379 -a $redis_password SLAVEOF NO ONE 2>/dev/null
    # 清除哨兵配置文件
    > $sentinel_config
    # 添加主节点监控选项
    echo "sentinel monitor mymaster ${master_host} 6379 1" >> $sentinel_config
    # 添加密码选项
    echo "sentinel auth-pass mymaster $redis_password" >> $sentinel_config
    # 设置超时时间
    echo "sentinel down-after-milliseconds mymaster 5000" >> $sentinel_config
    # 创建keepalived配置文件
    cat <<EOF > /etc/keepalived/keepalived.conf
vrrp_script chk_mysql {
    script "/usr/bin/mysqladmin -uroot -p'${root_password} -P $mysql_port' ping"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    state MASTER
    interface $interface
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        $virtual_ip
    }
    track_script {
        chk_mysql
    }
}
EOF
    # 启动keepalived服务
    systemctl enable keepalived && systemctl start keepalived
else
    # 从服务器
    echo "这是从服务器，执行从服务器脚本"  
    hostnamectl set-hostname slave0$mysql_id 
    # 修改my.cnf文件
    echo "read_only = 1" | tee -a $my_cnf
    echo "relay_log_info_repository=TABLE" | tee -a $my_cnf
    # 重启 MySQL 数据库
    if systemctl status mysqld.service >/dev/null 2>&1; then
    systemctl restart mysqld.service
    elif systemctl status mysql.service >/dev/null 2>&1; then
    systemctl restart mysql.service
    else
    echo "MySQL 服务未找到"
    fi
    # 获取主服务器的二进制日志文件名和位置
    result=$(mysql -h "$master_host" -uroot -p"$root_password" -e "SHOW MASTER STATUS\G")
    master_log_file=$(echo "$result" | awk '/File:/ {print $2}')
    master_log_pos=$(echo "$result" | awk '/Position:/ {print $2}')            
    echo "主服务器的二进制日志文件名为: $master_log_file"
    echo "主服务器的日志大小为: $master_log_pos"            
    # 在从服务器上执行初始化
    mysql -uroot -p"$new_password" -e "STOP SLAVE;" 2>/dev/null
    mysql -uroot -p"$new_password" -e "CHANGE MASTER TO MASTER_HOST='$master_host', MASTER_USER='$master_user', MASTER_PASSWORD='$master_password', MASTER_LOG_FILE='$master_log_file', MASTER_LOG_POS=$master_log_pos, get_master_public_key=1;" 2>/dev/null
    mysql -uroot -p"$new_password" -e "START SLAVE;" 2>/dev/null
    redis-cli -h 127.0.0.1 -p 6379 -a $redis_password SLAVEOF "${master_host}" 6379 2>/dev/null
    # 清除哨兵配置文件
    > $sentinel_config
    # 添加主节点监控选项
    echo "sentinel monitor mymaster ${master_host} 6379 1" >> $sentinel_config
    # 添加密码选项
    echo "sentinel auth-pass mymaster $redis_password" >> $sentinel_config
    # 设置超时时间
    echo "sentinel down-after-milliseconds mymaster 5000" >> $sentinel_config
    # 检查从服务器的复制状态
    status=$(mysql -uroot -p"$new_password" -e "SHOW SLAVE STATUS\G")  
    # 创建keepalived配置文件
    cat <<EOF > /etc/keepalived/keepalived.conf
vrrp_script chk_mysql {
    script "/usr/bin/mysqladmin -uroot -p'${root_password} -P $mysql_port' ping"
    interval 2
    weight 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface $interface
    virtual_router_id 51
    priority 50
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        $virtual_ip
    }
    track_script {
        chk_mysql
    }
}
EOF
    # 启动keepalived服务
    systemctl enable keepalived && systemctl start keepalived       
    # 检查复制状态是否正常
    if [[ $status == *"Slave_IO_Running: Yes"* && $status == *"Slave_SQL_Running: Yes"* ]]; then
        echo "MySQL主从复制已成功配置。"
    else
        echo "MySQL主从复制配置失败，请检查配置和日志。"
    fi
fi

cat > /home/mysql_slave_monitor.sh <<'EOF'
#!/bin/bash  
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
if ! dpkg -s mailx &> /dev/null || ! rpm -q sendmail &> /dev/null; then
    # 检查包管理器并相应地安装
    if command -v yum &> /dev/null; then
        yum install -y mailx sendmail
    elif command -v apt &> /dev/null; then
        apt update && apt install -y bsd-mailx sendmail
    else
        echo "未找到包管理器。无法安装mailx和sendmail。"
    fi
else
    echo "mailx和sendmail已经安装。"
fi

# 邮件通知配置
from=xxx@qq.com                        # 发件人邮箱
smtp=smtp.qq.com:465                   # SMTP服务器地址
smtp_auth_user=xxx@qq.com              # SMTP用户名
smtp_auth_password=xxxxx               # SMTP密码
smtp_auth=login                        # SMTP认证方式，一般为login或者plain
mail=xxx@qq.com                        # 告警信息收件人邮箱  
PASSWD=$root_password                  # MySQL root密码

# 配置sendmail
if ! setting_exists from || [ "$(grep "^set from=" /etc/mail.rc | awk -F= '{print $2}' | tr -d '[:space:]')" != "$from" ]; then
    sed -i "/^set from=/d" /etc/mail.rc
    echo "set from=$from" >> /etc/mail.rc
fi
if ! setting_exists smtp || [ "$(grep "^set smtp=" /etc/mail.rc | awk -F= '{print $2}' | tr -d '[:space:]')" != "$smtp" ]; then
    sed -i "/^set smtp=/d" /etc/mail.rc
    echo "set smtp=$smtp" >> /etc/mail.rc
fi
if ! setting_exists smtp-auth-user || [ "$(grep "^set smtp-auth-user=" /etc/mail.rc | awk -F= '{print $2}' | tr -d '[:space:]')" != "$smtp_auth_user" ]; then
    sed -i "/^set smtp-auth-user=/d" /etc/mail.rc
    echo "set smtp-auth-user=$smtp_auth_user" >> /etc/mail.rc
fi
if ! setting_exists smtp-auth-password || [ "$(grep "^set smtp-auth-password=" /etc/mail.rc | awk -F= '{print $2}' | tr -d '[:space:]')" != "$smtp_auth_password" ]; then
    sed -i "/^set smtp-auth-password=/d" /etc/mail.rc
    echo "set smtp-auth-password=$smtp_auth_password" >> /etc/mail.rc
fi
if ! setting_exists smtp-auth || [ "$(grep "^set smtp-auth=" /etc/mail.rc | awk -F= '{print $2}' | tr -d '[:space:]')" != "$smtp_auth" ]; then
    sed -i "/^set smtp-auth=/d" /etc/mail.rc
    echo "set smtp-auth=$smtp_auth" >> /etc/mail.rc
fi
if ! setting_exists ssl-verify || [ "$(grep "^set ssl-verify=" /etc/mail.rc | awk -F= '{print $2}' | tr -d '[:space:]')" != "ignore" ]; then
    sed -i "/^set ssl-verify=/d" /etc/mail.rc
    echo "set ssl-verify=ignore" >> /etc/mail.rc
fi
systemctl enable sendmail && systemctl restart sendmail  

# 使用mysql命令查询从服务器的状态，并通过awk提取出IO线程和SQL线程的运行状态  
IO_SQL_STATUS=$(mysql -uroot -p$PASSWD -P $mysql_port -e 'show slave status\G' 2>/dev/null | awk '/Slave_.*_Running:/{print $1$2}')  
# 遍历查询结果，分别检查IO线程和SQL线程的状态  
for i in $IO_SQL_STATUS; do  
    # 提取线程状态名称（如"Slave_IO_Running"或"Slave_SQL_Running"）  
    THREAD_STATUS_NAME=${i%:*}  
    # 提取线程状态值（"Yes"表示正常运行，"No"表示异常）  
    THREAD_STATUS=${i#*:}  
    # 判断线程状态是否为"Yes"，如果不是，则发送警报邮件  
    if [ "$THREAD_STATUS" != "Yes" ]; then  
        echo "错误：MySQL（$IP）主从 $THREAD_STATUS_NAME 状态为 $THREAD_STATUS！" | mail -s "（$IP）主从状态警报" $mail
    fi  
    (crontab -l ; echo "0 3 * * 1 /home/mysql_slave_monitor.sh" ) | crontab -   #执行完本脚本后，请删除这一行，避免重复执行
done
EOF