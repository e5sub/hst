#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年11月9日                         "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *安装前请确保环境干净,脚本不支持覆盖安装!            "*
echo -e "#                                                      "*
echo -e "# *脚本支持Centos7/Ubuntu/Debian                       "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
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
#检测依赖
sys_install(){
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
mkdir /etc/docker
cat >/etc/docker/daemon.json<<EOF
{
"log-driver": "json-file",
"log-opts": {"max-size":"20m", "max-file":"2"}
}
EOF

# 提示用户输入环境变量
read -ep "请输入ZBX_HOSTNAME: " ZBX_HOSTNAME
read -ep "请输入ZBX_SERVER_HOST: " ZBX_SERVER_HOST
read -ep "请输入ZBX_SERVER_PORT (default is 10051): " ZBX_SERVER_PORT
ZBX_SERVER_PORT=${ZBX_SERVER_PORT:-10051}
# 显示用户输入的值供确认
echo "您输入的值为："
echo "ZBX_HOSTNAME: $ZBX_HOSTNAME"
echo "ZBX_SERVER_HOST: $ZBX_SERVER_HOST"
echo "ZBX_SERVER_PORT: $ZBX_SERVER_PORT"
# 启动agent容器
docker run -dit --name zabbix-agent -e ZBX_HOSTNAME="$ZBX_HOSTNAME" -e ZBX_SERVER_HOST="$ZBX_SERVER_HOST" -e ZBX_SERVER_PORT="$ZBX_SERVER_PORT" -v /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro -p 10050:10050 zabbix/zabbix-agent:latest

# 显示脚本安装次数
counter=$(curl -s https://www.yaohst.com/counter.php)

echo -e "                                                                                "
echo -e "#*******************************************************************************"
echo -e "#                                                                               "
echo -e "# *$counter                                                                     "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "

