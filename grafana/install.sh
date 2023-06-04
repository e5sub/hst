#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年6月4日                          "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *安装前请确保环境干净,脚本不支持覆盖安装!            "*
echo -e "#                                                      "*
echo -e "# *脚本支持Centos7/Ubuntu/Debian                       "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
sleep 5s
# 安装docker和docker-compose
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun | systemctl enable docker && systemctl start docker
pip3 install -upgrade pip && pip3 install docker-compose

# 下载prometheus配置文件
mkdir /home/grafana/prometheus
wget -N --no-check-certificate -P /home/grafana/prometheus https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/prometheus.yml

# 设置grafana文件夹权限
mkdir /home/grafana/grafana
chmod 777 /home/grafana/grafana

# 检测系统类型
if [[ -f /etc/redhat-release ]]; then
    # CentOS 系统安装consul
    yum install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    yum -y install consul-1.14.5-1
elif [[ -f /etc/lsb-release ]]; then
    # Ubuntu/Debian 系统安装consul
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install -y consul-1.14.5-1 
else
    echo "不支持的操作系统"
    exit 1
fi

mkdir /home/grafana/consul
cd /home/grafana/consul
wget -N --no-check-certificate -P /home/grafana/consul https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/consul_config.sh && bash consul_config.sh 
chown -R consul:consul /opt/consul
systemctl enable consul.service
systemctl start consul.service
wget -N --no-check-certificate -P /home/grafana/consul https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/docker-compose.yml
# 获取 Consul ACL Token
consul_acl_token=$(consul acl bootstrap | grep SecretID | awk '{print $2}')

# 获取 local IP address
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

# 更新 docker-compose.yml 和 prometheus.yml 配置文件
sed -i "s/consul_token:.*/consul_token: $consul_acl_token/" docker-compose.yml
sed -i "s/consul_url:.*/consul_url: http:\/\/$local_ip:8500\/v1/" docker-compose.yml
sed -i "s/token:.*/token: '$consul_acl_token'/" /home/grafana/prometheus/prometheus.yml
sed -i "s/server: 'xxx:8500'/server: '$local_ip:8500'/" /home/grafana/prometheus/prometheus.yml

# 启动服务
cd /home/grafana/consul
docker-compose pull && docker-compose up -d
echo -e "                                                                                "
echo -e "#*******************************************************************************"
echo -e "#                                                                               "
echo -e "# *登陆入口及账号密码信息                                                       "
echo -e "#                                                                               "
echo -e "# *Node-exporter: http://$local_ip:9100/metrics                                 "
echo -e "#                                                                               "
echo -e "# *Prometheus：http://$local_ip:9090/targets                                    "
echo -e "#                                                                               "
echo -e "# *Grafana: http://$local_ip:3000/   登录帐号密码admin                          "
echo -e "#                                                                               "
echo -e "# *Consul: http://$local_ip:8500/  登录密码$consul_acl_token                    "
echo -e "#                                                                               "
echo -e "# *ConsulManager: http://$local_ip:1026/    登录密码jigehenniubi                "
echo -e "#                                                                               "
echo -e "# *Consul配置文件路径:/home/grafana/consul/docker-compose.yml 可更新token和登陆密码"
echo -e "#                                                                               "
echo -e "# *模板下载地址 https://grafana.com/api/dashboards/8919/revisions/25/download   "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "