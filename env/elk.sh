#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2024年6月8日                         "*
echo -e "#                                                      "*
echo -e "# *脚本支持CentOS/Ubuntu/Debian                        "* 
echo -e "#                                                      "*
echo -e "# *可按Ctrl+Z取消安装                                  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
# 获取内网IP地址
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# 系统设置
if grep -q "vm.max_map_count=262144" /etc/sysctl.conf; then
    echo "vm.max_map_count=262144已存在于sysctl.conf中"
else
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    echo "vm.max_map_count=262144已添加到sysctl.conf中"
fi
if grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1已存在于sysctl.conf中"
else
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    echo "net.ipv4.ip_forward=1已添加到sysctl.conf中"
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
# 系统环境检测
sys_install(){
    if ! type curl >/dev/null 2>&1; then
        echo 'curl 未安装 正在安装中';
        yum -y install curl | apt -y install curl
    else 
        echo 'curl 已安装，继续操作'
    fi   
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        curl -fsSL https://fastly.jsdelivr.net/gh/e5sub/docker-install@master/install.sh | bash -s docker --mirror Aliyun
        systemctl enable docker 
    else 
        echo 'docker 已安装，继续操作'
    fi 
}
sys_install
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
systemctl daemon-reload
systemctl restart docker
# 检测系统类型
if [[ -f /etc/redhat-release ]]; then
# CentOS
# 放开防火墙
       firewall-cmd --zone=public --add-port=5044/tcp --permanent
       firewall-cmd --zone=public --add-port=9200/tcp --permanent
       firewall-cmd --zone=public --add-port=9300/tcp --permanent
       firewall-cmd --zone=public --add-port=5601/tcp --permanent
       yum -y install epel-release
       yum -y groupinstall "Development tools"
       yum -y install openssl-devel openssl11 openssl11-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel psmisc libffi-devel git wget python3-pip
       pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
       wget -N --no-check-certificate https://registry.npmmirror.com/-/binary/python/3.12.0/Python-3.12.0.tgz 
       tar -zxf Python-3.12.0.tgz && mkdir -p /usr/local/python3 
       export CFLAGS=$(pkg-config --cflags openssl11) 
       export LDFLAGS=$(pkg-config --libs openssl11) 
       cd Python-3.12.0 && ./configure --prefix=/usr/local/python3 --with-ssl && make && make install 
       cp /usr/bin/python3 /usr/bin/python3.bak && rm -rf /usr/bin/python3 
       ln -s /usr/local/python3/bin/python3 /usr/bin/python3
    if ! command -v docker-compose &> /dev/null; then
       echo "docker-compose not found, installing docker-compose"
       curl -SL https://gitee.com/kesion/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
       chmod +x /usr/bin/docker-compose
    else
       echo "docker-compose already installed"
    fi
elif [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
# Ubuntu/Debian
    apt install -y docker-compose git
# 放行防火墙端口
    sudo ufw allow 5044/tcp
    sudo ufw allow 9200/tcp
    sudo ufw allow 9300/tcp
    sudo ufw allow 5601/tcp
else
    echo "不支持的操作系统"
    exit 1
fi
# 克隆ELK代码
git clone https://gitee.com/kesion/docker-elk.git /home/elk
cd /home/elk
# 启动ELk
docker-compose up setup && docker-compose up -d
# 等待ELK启动
sleep 30s
# 重置所有密码
password=$(docker exec -it $(docker ps -aqf "name=elk-elasticsearch*") bin/elasticsearch-setup-passwords auto --batch)
echo 所有密码已保存到 /home/elk/password.txt 请妥善保管密码文件！
# 保存密码
echo "$password" > /home/elk/password.txt
# 提取密码
elastic_password=$(grep "PASSWORD elastic" /home/elk/password.txt | awk '{print $4}' | sed 's/[[:space:]]*$//g')
logstash_internal_password=$(grep "PASSWORD logstash_system" /home/elk/password.txt | awk '{print $4}' | sed 's/[[:space:]]*$//g')
kibana_system_password=$(grep "PASSWORD kibana_system" /home/elk/password.txt | awk '{print $4}' | sed 's/[[:space:]]*$//g')
beats_system_password=$(grep "PASSWORD beats_system" /home/elk/password.txt | awk '{print $4}' | sed 's/[[:space:]]*$//g')
# 修改配置文件
sed -i 's/xpack.license.self_generated.type: trial/xpack.license.self_generated.type: basic/g'  /home/elk/elasticsearch/config/elasticsearch.yml
sed -i "s/ELASTIC_PASSWORD.*/ELASTIC_PASSWORD='$elastic_password'/" /home/elk/.env
sed -i "s/LOGSTASH_INTERNAL_PASSWORD.*/LOGSTASH_INTERNAL_PASSWORD='$logstash_internal_password'/" /home/elk/.env
sed -i "s/BEATS_SYSTEM_PASSWORD.*/BEATS_SYSTEM_PASSWORD='$beats_system_password'/" /home/elk/.env
sed -i "s/KIBANA_SYSTEM_PASSWORD.*/KIBANA_SYSTEM_PASSWORD='$kibana_system_password'/" /home/elk/.env
sed -i "s/elasticsearch.password:.*/elasticsearch.password: $kibana_system_password/g" /home/elk/kibana/config/kibana.yml
sed -i "s/password => .*/password => \"$logstash_internal_password\"/"  /home/elk/logstash/pipeline/logstash.conf
# 添加中文
if grep -q "i18n.locale: \"zh-CN\"" /home/elk/kibana/config/kibana.yml; then
    echo "已设置成中文"
else
    echo "i18n.locale: \"zh-CN\"" >> /home/elk/kibana/config/kibana.yml
    echo "已添加中文配置"
fi
# 重启ELK
docker-compose restart

