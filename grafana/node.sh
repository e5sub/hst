#!/bin/bash
echo -e "                                                       "
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年6月2日                          "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *本脚本支持所有linxu版本,若安装失败请手动安装docker  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
sleep 5s
# 安装docker和docker-compose
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun | systemctl enable docker && systemctl start docker
pip3 install -upgrade pip && pip3 install docker-compose
# 使用docker部署node-exporter
docker run -d -p 9100:9100 -v /home/grafana/node-exporter/proc:/host/proc:ro -v /home/grafana/node-exporter/sys:/host/sys:ro -v /home/grafana/node-exporter/:/homefs:ro --name node-exporter --restart=always prom/node-exporter
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