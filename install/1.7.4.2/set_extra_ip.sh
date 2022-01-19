#!/bin/bash

[ $# -lt 1 ] && echo "需要输入外部可连接ip地址，例：192.168.10.20" && exit 5

ip_addr=$1

docker_id=`docker ps|grep fsp_pri|awk '{print $1}'`

docker exec -ti $docker_id sed -i "s/\"net_address_list\":.*,/\"net_address_list\": \"${ip_addr}\",/g" /fsmeeting/fsp_sss_stream/cp/cp.config

docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/cp/CPMonitorCtrl.sh restart

docker exec -ti $docker_id sed -i "s/\"net_address_list\":.*,/\"net_address_list\": \"${ip_addr}\",/g" /fsmeeting/fsp_sss_stream/ss/ss.config

docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/ss/SSMonitorCtrl.sh restart

docker exec -ti $docker_id sed -i "s/\"nat_address\": \".*\"/\"nat_address\": \"${ip_addr}\"/g" /fsmeeting/fsp_sss_stream/webgw/webgw.config

docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/webgw/WEBGWMonitorCtrl.sh restart