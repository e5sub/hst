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

# 创建网络
docker network create zabbix-net

# 提示用户输入环境变量
read -p "请输入ZBX_HOSTNAME: " ZBX_HOSTNAME
read -p "请输入ZBX_SERVER_HOST: " ZBX_SERVER_HOST
read -p "请输入ZBX_SERVER_PORT (default is 10051): " ZBX_SERVER_PORT
ZBX_SERVER_PORT=${ZBX_SERVER_PORT:-10051}

# 启动agent容器
docker run -dit \
  --name zabbix-agent \
  --network zabbix-net \
  -e ZBX_HOSTNAME=$ZBX_HOSTNAME \
  -e ZBX_SERVER_HOST=$ZBX_SERVER_HOST \
  -e ZBX_SERVER_PORT=$ZBX_SERVER_PORT \
  -v /etc/localtime:/etc/localtime \
  -p 10050:10050 \
  zabbix/zabbix-agent:latest

# 显示脚本安装次数
counter=$(curl -s https://www.yaohst.com/counter.php)

echo -e "                                                                                "
echo -e "#*******************************************************************************"
echo -e "#                                                                               "
echo -e "# *$counter                                                                     "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "

