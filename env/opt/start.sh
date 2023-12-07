#!/bin/bash
git clone https://gitee.com/kesion/archery.git /opt/app/archery
# 安装ELK
bash /opt/elk.sh
chmod -R 777 /opt/app
COMPOSE_PATHS=(
    "/opt/app/archery/src/docker-compose/docker-compose.yml"
    "/opt/app/elk/docker-compose.yml"
    "/opt/app/kafka/docker-compose.yml"
    "/opt/app/nacos/docker-compose.yml"
    "/opt/app/rabbitmq/docker-compose.yml"
    "/opt/app/xxl-job/docker-compose.yml"
    "/opt/app/sentinel/docker-compose.yml"
)
# 遍历每个docker-compose绝对路径
for path in "${COMPOSE_PATHS[@]}"; do
    # 获取docker-compose的目录路径
    dir=$(dirname "$path")
    # 进入docker-compose所在的目录
    cd "$dir"
    # 启动docker-compose
    docker-compose up -d
done
echo -e "# 注意：请手动修改nacos、xxl-job和archery数据库配置文件"*