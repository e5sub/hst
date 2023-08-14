#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年8月14日                         "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *安装前请确保环境干净,脚本不支持覆盖安装!            "*
echo -e "#                                                      "*
echo -e "# *脚本支持Centos7/Ubuntu/Debian                       "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "

#检测依赖
sys_install(){
    if ! type wget >/dev/null 2>&1; then
        echo 'wget 未安装 正在安装中';
        apt install wget -y || yum install wget -y
    else
        echo 'wget 已安装，继续操作'
    fi
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
        systemctl start docker
    else 
        echo 'docker 已安装，继续操作'
    fi
}
sys_install
# 获取网卡IP
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

# 检测系统类型
if [[ -f /etc/redhat-release ]]; then
# CentOS
    yum -y install python3-pip
    pip3 install --upgrade pip
    pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    pip3 install docker-compose
elif [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
# Ubuntu/Debian
    apt install -y docker-compose
else
    echo "不支持的操作系统"
    exit 1
fi
wget -N --no-check-certificate -P /home/zabbix https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/zabbix/docker-compose.yml
wget -N --no-check-certificate -P /home/zabbix https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/zabbix/zabbix_server.conf


# 启动服务
cd /home/zabbix
docker-compose pull && docker-compose up -d 

echo '请稍后，zabbix容器正在启动，大约需要2-3分钟'
sleep 150s

# 修改zabbix-server的NodeAddress
sed -i "s/#\s*NodeAddress=localhost:10051/NodeAddress=$local_ip:10051/g" /home/zabbix/zabbix_server.conf
sleep 10s
docker restart zabbix-server

# 显示脚本安装次数
counter=$(curl -s https://www.yaohst.com/counter.php)

echo -e "                                                                                "
echo -e "#*******************************************************************************"
echo -e "#                                                                               "
echo -e "# *登陆入口及账号密码信息                                                       "
echo -e "#                                                                               "
echo -e "# *zabbix: http://$local_ip:8080 默认账号密码：Admin/zabbix                     "
echo -e "#                                                                               "
echo -e "# *$counter                                                                     "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "

