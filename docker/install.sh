#!/bin/bash
# 作者: [菜芽]
# 更新日期: [2025-06-23]
# 描述: 该脚本用于安装 Docker 环境、下载 docker-compose.yml 文件，并根据用户选择安装和配置服务。

# 安装 Docker 环境
docker_install(){
    echo -e "\033[1;34m正在检查依赖工具...\033[0m"
    if ! type wget >/dev/null 2>&1; then
        echo -e "\033[1;33mwget 未安装，正在安装中...\033[0m"
        apt install wget -y || yum install wget -y
    else
        echo -e "\033[1;32mwget 已安装，继续操作\033[0m"
    fi
    
    if ! type curl >/dev/null 2>&1; then
        echo -e "\033[1;33mcurl 未安装，正在安装中...\033[0m"
        apt install curl -y || yum install curl -y
    else
        echo -e "\033[1;32mcurl 已安装，继续操作\033[0m"
    fi
    
    if ! type docker >/dev/null 2>&1; then
        echo -e "\033[1;33mdocker 未安装，正在安装中...\033[0m"
        curl -fsSL https://fastly.jsdelivr.net/gh/e5sub/docker-install@master/install.sh | bash -s docker --mirror Aliyun
        systemctl enable docker
    else 
        echo -e "\033[1;32mdocker 已安装，继续操作\033[0m"
    fi
}
docker_install

echo -e "\033[1;34m正在配置 Docker...\033[0m"
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

# 定义配置文件路径和下载地址
compose_file="./docker-compose.yml"
compose_url="https://fastly.jsdelivr.net/gh/e5sub/hst@master/docker/docker-compose.yml"

# 检查文件是否存在
if [ -f "$compose_file" ]; then
    echo -e "\033[1;33m检测到已有 docker-compose.yml 文件，跳过下载\033[0m"
else
    # 下载文件
    echo -e "\033[1;34m正在下载 docker-compose.yml 文件...\033[0m"
    wget -q -N --no-cache "$compose_url" -O "$compose_file"
    
    # 检查下载结果
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31m下载失败，请检查网络或 URL 地址\033[0m"
        exit 1
    else
        echo -e "\033[1;32m下载成功\033[0m"
    fi
fi

# 创建临时文件用于后续处理
temp_compose_file="./docker-compose.temp.yml"
cp "$compose_file" "$temp_compose_file"
echo -e "\033[1;34m已创建临时配置文件\033[0m"

# 提取服务描述
service_descriptions=()
services=()
prev_line=""

while IFS= read -r line; do
    if [[ "$line" =~ ^\ \ [a-zA-Z0-9_-]+: ]]; then
        service=$(echo "$line" | awk '{print $1}' | tr -d ':')
        description=$(echo "$prev_line" | sed 's/^[[:space:]]*#[[:space:]]*//')
        
        services+=("$service")
        service_descriptions+=("$description")
    fi
    prev_line="$line"
done < "$compose_file"

# 颜色定义
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # 恢复默认颜色

# 计算最大序号宽度
max_width=${#services[@]}
max_width=${#max_width}

# 打印美化标题
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                         ${WHITE}Docker 服务安装菜单${CYAN}                          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}请选择要安装的服务（用空格分隔多个选项，输入 all 选择所有服务）：${NC}"
echo -e "${YELLOW}--------------------------------------------------------------------------------${NC}"

# 按原始顺序打印服务列表
for ((i = 0; i < ${#services[@]}; i++)); do
    printf "${GREEN}%${max_width}d.${NC} ${BLUE}%-25s${NC} ${WHITE}%s${NC}\n" "$((i + 1))" "${services[$i]}" "${service_descriptions[$i]}"
done

echo -e "${YELLOW}--------------------------------------------------------------------------------${NC}"
read -p "选择: " choices

# 处理用户选择
echo -e "\n${CYAN}正在处理你的选择...${NC}"
if [ "$choices" == "all" ]; then
    selected_services=("${services[@]}")
    echo -e "${GREEN}已选择安装所有服务${NC}"
else
    selected_services=()
    valid_choice=false
    for choice in $choices; do
        index=$((choice - 1))
        if [ $index -ge 0 ] && [ $index -lt ${#services[@]} ]; then
            selected_services+=("${services[$index]}")
            valid_choice=true
        else
            echo -e "${RED}无效的选择: $choice${NC}"
        fi
    done
    
    if ! $valid_choice; then
        echo -e "${RED}没有选择任何有效服务，退出安装${NC}"
        exit 1
    fi
fi

# 显示用户选择的服务
echo -e "\n${CYAN}你选择安装的服务：${NC}"
for ((i = 0; i < ${#selected_services[@]}; i++)); do
    service="${selected_services[$i]}"
    for ((j = 0; j < ${#services[@]}; j++)); do
        if [[ "${services[$j]}" == "$service" ]]; then
            printf "${GREEN}%${max_width}d.${NC} ${BLUE}%-25s${NC} ${WHITE}%s${NC}\n" "$((j + 1))" "$service" "${service_descriptions[$j]}"
            break
        fi
    done
done

# 参数注入
echo -e "\n${CYAN}正在配置所选服务...${NC}"
if [[ " ${selected_services[@]} " =~ " tailscaled " ]]; then
    read -p "请输入你的 Tailscale Auth Key: " ts_authkey
    sed -i "s/TS_AUTHKEY=.*# 替换为你的 Tailscale Auth Key/TS_AUTHKEY=$ts_authkey/" "$temp_compose_file"
    echo -e "${GREEN}Tailscale Auth Key 已配置${NC}"
fi

if [[ " ${selected_services[@]} " =~ " rustdesk " ]]; then
    read -p "请输入你的中继服务器地址: " relay_server
    read -p "请输入你的 ID 服务器地址: " id_server
    read -p "请输入你的 API 服务器地址: " api_server
    
    sed -i "s/RELAY=.*# 替换为你的中继服务器地址（21117端口）/RELAY=$relay_server/" "$temp_compose_file"
    sed -i "s/RUSTDESK_API_RUSTDESK_ID_SERVER=.*# 替换为你的ID服务器地址（21116端口）/RUSTDESK_API_RUSTDESK_ID_SERVER=$id_server/" "$temp_compose_file"
    sed -i "s/RUSTDESK_API_RUSTDESK_RELAY_SERVER=.*# 替换为你的中继服务器地址（21117端口）/RUSTDESK_API_RUSTDESK_RELAY_SERVER=$relay_server/" "$temp_compose_file"
    sed -i "s/RUSTDESK_API_RUSTDESK_API_SERVER=.*# 替换为你的API服务器地址/RUSTDESK_API_RUSTDESK_API_SERVER=$api_server/" "$temp_compose_file"
    
    echo -e "${GREEN}RustDesk 服务器地址已配置${NC}"
fi

# 其他参数注入...

# 启动所选服务
echo -e "\n${CYAN}正在启动所选服务...${NC}"
if ! [[ " ${selected_services[*]} " == "sgcc_electricity_app" ]]; then
    docker compose -f "$temp_compose_file" up -d ${selected_services[@]}
else
    # 特殊处理 sgcc_electricity_app
    git_repo="https://github.com/ARC-MX/sgcc_electricity_new.git"
    git_dir="sgcc_electricity_new"
    [ ! -d "$git_dir" ] && git clone "$git_repo" "$git_dir" || (cd "$git_dir" && git pull && cd ..)
    cd "$git_dir"
    cp example.env .env
    docker compose -f "$temp_compose_file" up -d sgcc_electricity_app
    cd ..
fi

rm "$temp_compose_file"

# 显示安装结果
echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                          ${GREEN}服务安装完成${CYAN}                           ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"

echo -e "${GREEN}已成功安装以下服务：${NC}"
echo -e "${YELLOW}--------------------------------------------------------------------------------${NC}"
for service in "${selected_services[@]}"; do
    for ((i = 0; i < ${#services[@]}; i++)); do
        if [[ "${services[$i]}" == "$service" ]]; then
            printf "${GREEN}%${max_width}d.${NC} ${BLUE}%-25s${NC} ${WHITE}%s${NC}\n" "$((i + 1))" "$service" "${service_descriptions[$i]}"
            break
        fi
    done
done
echo -e "${YELLOW}--------------------------------------------------------------------------------${NC}"