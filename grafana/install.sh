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

#检测依赖
sys_install(){
    if ! type wget >/dev/null 2>&1; then
        echo 'wget 未安装 正在安装中';
        sudo apt install wget -y || yum install wget -y
    else
        echo 'wget 已安装，继续操作'
    fi
    if ! type curl >/dev/null 2>&1; then
        echo 'curl 未安装 正在安装中';
        sudo apt install curl -y || yum install curl -y
    else
        echo 'curl 已安装，继续操作'
    fi
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        sudo curl -sSL https://get.docker.com/ | sh | systemctl enable docker && systemctl start docker
    else 
        echo 'docker 已安装，继续操作'
    fi
}
sys_install
# 获取网卡IP
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

# 下载prometheus配置文件
mkdir -p /home/grafana/prometheus
wget -N --no-check-certificate -P /home/grafana/prometheus https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/prometheus.yml

# 设置grafana文件夹权限
mkdir -p /home/grafana/grafana
chmod 777 /home/grafana/grafana

# 检测系统类型
if [[ -f /etc/redhat-release ]]; then
# CentOS 系统安装consul
    yum install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    yum -y install consul-1.14.5-1
    pip3 install -upgrade pip
    pip3 install docker-compose
elif [[ -f /etc/lsb-release ]]; then
# Ubuntu/Debian 系统安装consul
    wget -N --no-check-certificate https://releases.hashicorp.com/consul/1.14.5/consul_1.14.5_linux_amd64.zip
	sudo unzip consul_1.14.5_linux_amd64.zip -d /usr/bin
    sudo apt install python3-pip -y
	sudo pip3 install docker-compose
	wget -N --no-check-certificate -P /usr/lib/systemd/system https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/consul.service
	wget -N --no-check-certificate -P /etc/consul.d https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/consul.env
	wget -N --no-check-certificate -P /etc/consul.d https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/consul.hcl
	mkdir -p /opt/consul
	sudo groupadd consul && useradd -r -s /sbin/nologin -g consul consul
else
    echo "不支持的操作系统"
    exit 1
fi
mkdir -p /home/grafana/consul
cd /home/grafana/consul
# 修改consul配置文件
config_file="/etc/consul.d/consul.hcl"
echo "log_level = \"ERROR\"" > "$config_file"
echo "advertise_addr = \"$local_ip\"" >> "$config_file"
echo "data_dir = \"/opt/consul\"" >> "$config_file"
echo "client_addr = \"0.0.0.0\"" >> "$config_file"
echo "ui_config {" >> "$config_file"
echo "  enabled = true" >> "$config_file"
echo "}" >> "$config_file"
echo "server = true" >> "$config_file"
echo "bootstrap = true" >> "$config_file"
echo "acl {" >> "$config_file"
echo "  enabled = true" >> "$config_file"
echo "  default_policy = \"deny\"" >> "$config_file"
echo "  enable_token_persistence = true" >> "$config_file"
echo "}" >> "$config_file"
echo "配置已写入 $config_file 文件。"
chown -R consul:consul /opt/consul
systemctl enable consul.service
systemctl start consul.service
wget -N --no-check-certificate -P /home/grafana/consul https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/grafana/docker-compose.yml

# 获取 Consul ACL Token
consul_acl_token=$(consul acl bootstrap | grep SecretID | awk '{print $2}')

# 更新 docker-compose.yml 和 prometheus.yml 配置文件
sed -i "s/consul_token:.*/consul_token: $consul_acl_token/" /home/grafana/consul/docker-compose.yml
sed -i "s/consul_url:.*/consul_url: http:\/\/$local_ip:8500\/v1/" /home/grafana/consul/docker-compose.yml
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