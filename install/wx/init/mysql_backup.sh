#!/bin/bash
# 设置mysql的登录用户名和密码
mysql_user="smart"
mysql_password='WX#38746@'
#mysql_host="localhost"
#mysql_port="3306"
#mysql_charset="utf8mb4"
# 备份数据和日志存放地址
backup_dir=/data/mysql
backup_data=$backup_dir/data
backup_log=$backup_dir/log
backup_log_file=$backup_log/log.txt
usb_log=$backup_log/usb_log.txt
mail_txt=/home/wxadmin/桌面/U盘备份邮件通知配置.txt
#邮件通知地址
mail=$(grep -oE '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' "$mail_txt" | tr '\n' ',' | sed 's/,$//')   # 多个邮箱地址，用逗号或分号将它们分开
#网信运维邮件通知地址
wxmail=1040155@qq.com  # 多个邮箱地址，用逗号或分号将它们分开
#备份时间 
backup_time=$(date +%Y%m%d)
#log_time=`date +'%Y-%m-%d %H:%M:%S'`
DAYS=4
serial_number=$(dmidecode -t baseboard | grep "Serial Number" | awk '{print $3}')
#加密压缩密码
zip_password="WX#38746@"

#备份所有数据库
echo "开始备份" >> $backup_log_file

for dbname in $(mysql -u$mysql_user -p$mysql_password -e "show databases;" | grep -Evi "Database|information_schema|mysql|performance_schema|test|sys")
do
    echo $(date +'%Y-%m-%d %H:%M:%S') ": 开始备份数据库 $dbname" >> $backup_log_file
    mysqldump -u$mysql_user -p$mysql_password --no-tablespaces $dbname > $backup_data/${dbname}_$backup_time.sql
    if [ -f "$backup_data/${dbname}_$backup_time.sql" ]; then
        echo "${dbname}_$backup_time.sql备份成功" >> $backup_log_file 
        # 对备份的SQL文件进行zip加密
        cd $backup_data && zip -P $zip_password ${dbname}_$backup_time.sql.zip ${dbname}_$backup_time.sql && zip frpc_$backup_time.zip /opt/frpc/frpc.toml
        # 删除原始备份文件
        rm $backup_data/${dbname}_$backup_time.sql        
        # 删除过期的备份文件
        find /data/mysql/data -mtime +30 | xargs rm -rf
    fi
done
echo "完成备份" >> $backup_log_file

# 查找挂载的U盘设备
usb_device=$(lsblk | grep "disk" | grep "sda" | awk '{print $1}')
# 如果找到了U盘设备，则执行复制到U盘的操作
if [ -n "$usb_device" ]; then
    usb_mount_point=$(df -h | grep "/dev/$usb_device" | awk '{print $6}')
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 外接U盘设备的挂载路径为: $usb_mount_point" >> "$usb_log"   
    find $usb_mount_point/backup -mtime +30 | xargs rm -rf    
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] U盘未挂载成功，请检查" >> "$usb_log"    
    echo " $serial_number $backup_time U盘未挂载成功，请检查" | mail -s " $serial_number $backup_time U盘未挂载成功，请检查" $mail
    exit 1
fi
# 复制备份到U盘
cd $backup_data && cp ${dbname}_$backup_time.sql.zip $usb_mount_point/backup && cp frpc_$backup_time.zip $usb_mount_point/backup
# 检查复制是否成功
if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 数据成功复制到U盘" >> "$usb_log"    
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 数据复制到U盘失败" >> "$usb_log"
    echo " U盘备份故障：盒子$serial_number 复制${dbname}_$backup_time.sql.zip到U盘失败" | mail -s "U盘备份故障：盒子$serial_number 复制${dbname}_$backup_time.sql.zip到U盘失败" $wxmail,$mail
fi


