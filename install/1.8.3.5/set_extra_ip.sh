#!/bin/bash

[ $# -lt 1 ] && echo "需要输入外部可连接ip地址，例：192.168.10.20" && exit 5

ip_addr=$1

docker_id=`docker ps|grep fsp_pri|awk '{print $1}'`

docker exec -ti $docker_id sed -i "s/\"net_address_list\":.*,/\"net_address_list\": \"${ip_addr}\",/g" /fsmeeting/fsp_sss_stream/cp/cp.config
cp_pid=`pidof client_proxy`
if [[ $cp_pid != "" ]]; then
  docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/cp/CPMonitorCtrl.sh restart
fi

docker exec -ti $docker_id sed -i "s/\"net_address_list\":.*,/\"net_address_list\": \"${ip_addr}\",/g" /fsmeeting/fsp_sss_stream/ss/ss.config
ss_pid=`pidof stream_server`
if [[ $ss_pid != "" ]]; then
  docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/ss/SSMonitorCtrl.sh restart
fi

docker exec -ti $docker_id sed -i "s/\"nat_address\":.*,/\"nat_address\": \"${ip_addr}\",/g" /fsmeeting/fsp_sss_stream/webgw/webgw.config
webgw_pid=`pidof web_gateway`
if [[ $webgw_pid != "" ]]; then
  docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/webgw/WEBGWMonitorCtrl.sh restart
fi

docker exec -ti $docker_id sed -i "s/\"net_address_list\":.*,/\"net_address_list\": \"${ip_addr}\",/g" /fsmeeting/fsp_sss_stream/wbgw/wbgw.config
wbgw_pid=`pidof wb_gateway`
if [[ $wbgw_pid != "" ]]; then
  docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/wbgw/WBGWMonitorCtrl.sh restart
fi