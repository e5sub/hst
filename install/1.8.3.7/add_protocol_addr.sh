#!/bin/bash

[ $# -lt 2 ] && echo "use ./add_protocol_addr <protocol(ws or wss)><addr(ip or domain)>  example: ./add_protocol_addr wss 192.168.6.78" && exit 5


protocol=$1
addr=$2
webgw_port=29600
wsgw_port=28900
ss_port=29300


if [[ $protocol == "wss" ]]; then
  webgw_port=21100
  wsgw_port=21001
  ss_port=21002
fi

docker_id=`docker ps|grep fsp_pri|awk '{print $1}'`


webgw_pid=`pidof web_gateway`
if [[ $webgw_pid != "" ]]; then
  docker exec -ti $docker_id sed -i "s/ws_address\":\(.*\)\",/ws_address\":\1;$protocol:\/\/$addr:$webgw_port\",/g" /fsmeeting/fsp_sss_stream/webgw/webgw.config
  docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/webgw/WEBGWMonitorCtrl.sh restart
fi

wsgw_pid=`pidof websocket_gateway`
if [[ $wsgw_pid != "" ]]; then
  docker exec -ti $docker_id sed -i "s/ws_address\":\(.*\)\",/ws_address\":\1;$protocol:\/\/$addr:$wsgw_port\",/g" /fsmeeting/fsp_sss_stream/wsgw/wsgw.config
  docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/wsgw/WSGWMonitorCtrl.sh restart
fi

ss_pid=`pidof stream_server`
if [[ $ss_pid != "" ]]; then
  docker exec -ti $docker_id sed -i "s/ws_address\":\(.*\)\",/ws_address\":\1;$protocol:\/\/$addr:$ss_port\",/g" /fsmeeting/fsp_sss_stream/ss/ss.config
  docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/ss/SSMonitorCtrl.sh restart
fi
