#!/bin/bash

config_file="/etc/consul.d/consul.hcl"
local_ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
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