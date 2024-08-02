#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2024年8月1日                            "*
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
        curl -fsSL https://fastly.jsdelivr.net/gh/e5sub/docker-install@master/install.sh | bash -s docker --mirror Aliyun
        systemctl enable docker 
    else 
        echo 'docker 已安装，继续操作'
    fi
}
sys_install
# 获取网卡IP
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

# 下载alertmanager配置文件
mkdir -p /home/grafana/alertmanager
wget -N --no-check-certificate -P /home/grafana/alertmanager https://fastly.jsdelivr.net/gh/e5sub/hst@master/grafana/alertmanager.yml

# 下载blackbox_exporter配置文件
mkdir -p /home/grafana/blackbox_exporter
wget -N --no-check-certificate -P /home/grafana/blackbox_exporter https://fastly.jsdelivr.net/gh/e5sub/hst@master/grafana/blackbox.yml

# 下载prometheus配置文件
mkdir -p /home/grafana/prometheus
wget -N --no-check-certificate -P /home/grafana/prometheus https://fastly.jsdelivr.net/gh/e5sub/hst@master/grafana/prometheus.yml
wget -N --no-check-certificate -P /home/grafana/prometheus https://fastly.jsdelivr.net/gh/e5sub/hst@master/grafana/rules.yml

# 设置grafana文件夹权限
mkdir -p /home/grafana/grafana
chmod 777 /home/grafana/grafana

# 检测系统类型
if [[ -f /etc/redhat-release ]]; then
# CentOS
    yum -y install python3-pip
    pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
    pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    pip3 install docker-compose
elif [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
# Ubuntu/Debian
    apt install -y python3-pip uuid-runtime docker-compose
else
    echo "不支持的操作系统"
    exit 1
fi
mkdir -p /home/grafana/consul
tsspath="/home/grafana"
uuid=`uuidgen`
read -ep "请设置登录后羿运维平台的admin密码：" passwd
if [ -z $passwd ]; then
  passwd="yaohst"
  echo -e "\n未输入，使用默认密码：\033[31;1myaohst\033[0m\n"
fi
mkdir -p $tsspath/consul/config
cat <<EOF > $tsspath/consul/config/consul.hcl
log_level = "error"
data_dir = "/consul/data"
client_addr = "0.0.0.0"
ui_config{
  enabled = true
}
ports = {
  grpc = -1
  https = -1
  dns = -1
  grpc_tls = -1
  serf_wan = -1
}
peering {
  enabled = false
}
connect {
  enabled = false
}
server = true
bootstrap_expect=1
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    initial_management = "$uuid"
    agent = "$uuid"
  }
}
EOF
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
systemctl daemon-reload
systemctl start docker
chmod 777 -R $tsspath/consul/config
wget -N --no-check-certificate -P /home/grafana https://fastly.jsdelivr.net/gh/e5sub/hst@master/grafana/docker-compose.yml

# 更新 docker-compose.yml 和 prometheus.yml 配置文件
sed -i "s/- ip:9093/- $local_ip:9093/g" /home/grafana/prometheus/prometheus.yml
sed -i "s/token:.*/token: '$uuid'/" /home/grafana/prometheus/prometheus.yml
sed -i "s/consul_token: xxx/consul_token: $uuid/" /home/grafana/docker-compose.yml
sed -i "s/admin_passwd: xxx/admin_passwd: $passwd/" /home/grafana/docker-compose.yml
sed -i "s/server: 'xxx:8500'/server: '$local_ip:8500'/" /home/grafana/prometheus/prometheus.yml

# 启动服务
cd /home/grafana
docker-compose pull && docker-compose up -d 

# 显示脚本安装次数
counter=$(curl -s https://www.yaohst.com/counter.php)

echo -e "                                                                                "
echo -e "#*******************************************************************************"
echo -e "#                                                                               "
echo -e "# *登陆入口及账号密码信息,推荐使用后羿运维平台管理服务器!                       "
echo -e "#                                                                               "
echo -e "# *Node-exporter: http://$local_ip:9100/metrics                                 "
echo -e "#                                                                               "
echo -e "# *Blackbox_exporter：http://$local_ip:9115                                     "
echo -e "#                                                                               "
echo -e "# *Alertmanager：http://$local_ip:9093  报警规则路径/home/grafana/prometheus/rules.yml"
echo -e "#                                                                               "
echo -e "# *Prometheus：http://$local_ip:9090/targets                                    "
echo -e "#                                                                               "
echo -e "# *Grafana: http://$local_ip:3000/   登录帐号密码:admin                         "
echo -e "#                                                                               "
echo -e "# *后羿运维平台的admin密码是：\033[31;1m$passwd\033[0m                    "
echo -e "#                                                                               "
echo -e "# *修改密码请编辑 /home/grafana/docker-compose.yaml 查找并修改变量 admin_passwd 的值"
echo -e "#                                                                               "
echo -e "# *请使用浏览器访问 http://$local_ip:1026 并登录使用                            "
echo -e "#                                                                               "
echo -e "# *主机监控模板下载地址:https://grafana.com/api/dashboards/8919/revisions/25/download"
echo -e "#                                                                               "
echo -e "# *黑盒监控模板下载地址:https://grafana.com/api/dashboards/9965/revisions/3/download"
echo -e "#                                                                               "
echo -e "# *$counter                                                                     "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "

