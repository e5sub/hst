#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2024年6月8日                          "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *本脚本支持所有linxu版本,若安装失败请手动安装docker  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
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
sys_install(){
    if ! type docker >/dev/null 2>&1; then
        echo 'docker 未安装 正在安装中';
        sudo curl -sSL https://get.docker.com/ | sh
        systemctl enable docker
        systemctl start docker
    else 
        echo 'docker 已安装，继续操作'
    fi	
}
sys_install
mkdir /etc/docker
cat >/etc/docker/daemon.json<<EOF
{
"log-driver": "json-file",
"log-opts": {"max-size":"20m", "max-file":"2"}
}
{
"registry-mirrors": ["https://hlx1vn88.mirror.aliyuncs.com"]
}
EOF
# 使用docker部署node-exporter
docker run -d -p 9100:9100 -v /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro -v /home/grafana/node-exporter/proc:/host/proc:ro -v /home/grafana/node-exporter/sys:/host/sys:ro -v /home/grafana/node-exporter/:/homefs:ro --name node-exporter --restart=always prom/node-exporter
echo -e "                                                                                "
echo -e "#*******************************************************************************"
echo -e "#                                                                               "
echo -e "# *登陆信息                                                                     "
echo -e "#                                                                               "
echo -e "# *node-exporter: http://$local_ip:9100/metrics                                 "
echo -e "#                                                                               "
echo -e "# *模板下载地址 https://grafana.com/api/dashboards/8919/revisions/25/download   "
echo -e "#                                                                               "
echo -e "# ******************************************************************************"
echo -e "                                                                                "