#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "# ******************************************************"
echo -e "#                                                      "*
echo -e "# *脚本更新时间：2023年4月26日                         "*
echo -e "#                                                      "*
echo -e "# *作者：Sugar                                         "*
echo -e "#                                                      "*
echo -e "# *抖音、微信视频号：萌萌哒菜芽，欢迎关注！            "*
echo -e "#                                                      "*
echo -e "# *请按照提示填写相应的参数                            "* 
echo -e "#                                                      "*
echo -e "# *如有不明白选项可以保持默认                          "*
echo -e "#                                                      "*
echo -e "# *如有问题或者遗漏的参数信息，请及时反馈              "*
echo -e "#                                                      "*
echo -e "# ******************************************************"
echo -e "                                                       "
#查看root和home卷标
df -lh
#提取root和home卷标
r=$(df -lh / | awk '$NF=="/" {print $1}')
h=$(df -lh | awk '$NF=="/home" {print $1}')
echo
echo "默认会自动提取卷标,如果获取的不正确,请手动输入卷标"
echo "请注意进行扩容之后会丢失home所有数据,请注意备份!!!"
echo "请确保/root有少量剩余空间,否则有可能导致扩容失败!!!"
echo
pre_kuorong(){
    # Set root
    read -ep "(请输入上方的root目录卷标,按回车自动提取):" root
    [ -z "${root}" ] && root=${r}
    echo 
    echo "---------------------------"
    echo "root卷标 = ${root}"
    echo "---------------------------"
    echo
    # Set home
    read -ep "(请输入上方的home目录卷标,按回车自动提取):" home
    [ -z "${home}" ] && home=${h}
    echo
    echo "---------------------------"
    echo "home卷标 = ${home}"
    echo "---------------------------"
    echo
}
# Config kuorong
config_kuorong(){
    echo "正在调整根分区大小"       
    umount ${home} 
    lvremove ${home} -y
    lvextend -l +100%FREE ${root}
    xfs_growfs ${root}
} 
#调用函数
pre_kuorong
config_kuorong
#备份并删除/etc/fstab挂载路径
sudo cp /etc/fstab /etc/fstab_bak
sudo sed -i "\|^$home|d" /etc/fstab
#查看是否成功扩容
df -lh
