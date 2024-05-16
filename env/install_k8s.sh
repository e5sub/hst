#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2024年1月9日                         "*
echo -e "#                                                      "*
echo -e "# *建议使用CentOS7,其他版本暂未测试                    "* 
echo -e "#                                                      "*
echo -e "# *可按Ctrl+Z取消安装                                  "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
# 获取内网IP
IP=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)
# 关闭SElinux
sed -i '/^SELINUX=/c SELINUX=disabled' /etc/selinux/config && setenforce 0
# 克隆kubeadm-ha代码
git clone https://gitee.com/kesion/kubeadm.git /home/kubeadm
# 安装ansible
cd /home/kubeadm/ansible && bash install.sh
# 安装helm
curl https://cdn.jsdelivr.net/gh/helm/helm@main/scripts/get-helm-3 | bash
# 添加rancher chart仓库
helm repo add rancher-stable http://rancher-mirror.oss-cn-beijing.aliyuncs.com/server-charts/stable && helm repo update
# 等待修改配置文件
echo "请修改/home/kubeadm/example文件夹里的配置文件"
echo ""
echo "配置文件说明，请根据实际情况修改"
echo "---------------------------------"
echo "|       节点类型      |       样式一       |       样式二       |"
echo "---------------------------------"
echo "|       单节点        |  hosts.allinone.ip  | hosts.allinone.hostname |"
echo "---------------------------------"
echo "|     单主多节点      |  hosts.s-master.ip  | hosts.s-master.hostname |"
echo "---------------------------------"
echo "|     多主多节点      |  hosts.m-master.ip  | hosts.m-master.hostname |"
echo "---------------------------------"
read -p "修改完成之后按下回车键继续..."
echo ""
read -ep "请输入修改完成之后的配置文件名称: " config_name
# 一键部署k8s，带高级配置的命令 ansible-playbook -i /home/kubeadm/example/$config_name -e @example/variables.yaml 90-init-cluster.yml
ansible-playbook -i /home/kubeadm/example/$config_name 90-init-cluster.yml
# 安装rancher
echo "ranche对k8s版本有要求，如果报错不影响k8s安装"
echo ""
helm install rancher rancher-stable/rancher \
 --create-namespace	\
 --namespace cattle-system \
 --set hostname=rancher.local.com
kubectl -n cattle-system rollout status deploy/rancher