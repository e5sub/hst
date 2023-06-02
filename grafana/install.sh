#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年6月2日                          "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *安装前请确保环境干净,本脚本不支持覆盖安装!          "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
# 安装docker和docker-compose
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun | systemctl enable docker && systemctl start docker
pip3 install -upgrade pip && pip3 install docker-compose
# 使用docker部署node-exporter
docker run -d -p 9100:9100 -v /home/grafana/node-exporter/proc:/host/proc:ro -v /home/grafana/node-exporter/sys:/host/sys:ro -v /home/grafana/node-exporter/:/homefs:ro --name node-exporter --restart=always prom/node-exporter
# 使用docker部署prometheus
mkdir /home/grafana/prometheus
wget -N --no-check-certificate -P /home/grafana/prometheus https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/prometheus.yml
docker run  -d -p 9090:9090 -v /home/grafana/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml --name prometheus --restart=always prom/prometheus
# 使用docker部署grafana
mkdir /home/grafana/grafana
chmod 777 /home/grafana/grafana
docker run -d -p 3000:3000 --name=grafana -v /home/grafana/grafana:/var/lib/grafana --name grafana --restart=always grafana/grafana
# 使用yum部署consul
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install consul-1.14.5-1
mkdir /home/grafana/consul
cd /home/grafana/consul
wget -N --no-check-certificate -P /home/grafana/consul https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/consul_config.sh && bash consul_config.sh 
chown -R consul:consul /opt/consul
systemctl enable consul.service
systemctl start consul.service
wget -N --no-check-certificate -P /home/grafana/consul https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/docker-compose.yml
docker-compose up -d
# 获取 Consul ACL Token
consul_acl_token=$(consul acl bootstrap | grep SecretID | awk '{print $2}')
# 获取 local IP address
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# 更新 docker-compose.yml 和 prometheus.yml
sed -i "s/consul_token:.*/consul_token: $consul_acl_token/" docker-compose.yml
sed -i "s/consul_url:.*/consul_url: http:\/\/$local_ip:8500\/v1/" docker-compose.yml
sed -i "s/token:.*/token: '$consul_acl_token'/" /home/grafana/prometheus/prometheus.yml
sed -i "s/server: 'xxx:8500'/server: '$local_ip:8500'/" /home/grafana/prometheus/prometheus.yml
# 重启服务
docker restart node-exporter && docker restart prometheus && docker restart grafana
cd /home/grafana/consul
docker-compose pull && docker-compose restart
echo -e "                                                                                "
echo -e "#*******************************************************************************"
echo -e "#                                                                               "
echo -e "# *登陆信息                                                                     "
echo -e "#                                                                               "
echo -e "# *node-exporter: http://$local_ip:9100/metrics                                 "
echo -e "#                                                                               "
echo -e "# *prometheus：http://$local_ip:9090/targets                                    "
echo -e "#                                                                               "
echo -e "# *grafana: http://$local_ip:3000/   (默认帐号密码admin)                        "
echo -e "#                                                                               "
echo -e "# *consul: http://$local_ip:1026/    (默认密码jigehenniubi)                     "
echo -e "#                                                                               "
echo -e "# *consul配置文件路径:/home/grafana/consul/docker-compose.yml 可更新token和登陆密码"
echo -e "#                                                                               "
echo -e "# *模板下载地址 https://grafana.com/api/dashboards/8919/revisions/25/download   "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "