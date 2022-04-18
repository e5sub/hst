#!/bin/bash

[ $# -lt 1 ] && echo "use ./set_wb_app_id.sh  hst_app_id  example: ./set_wb_app_id.sh 3049291591cb6aed78e638c2aed53867" && exit 5

docker_id=`docker ps|grep fsp_pri|awk '{print $1}'`

docker exec -ti $docker_id sed -i "s/hst_app_id.*/hst_app_id\":\"$1\"/g" /fsmeeting/fsp_sss_stream/wbgw/wbgw.config
docker exec -ti $docker_id /bin/bash /fsmeeting/fsp_sss_stream/wbgw/WBGWMonitorCtrl.sh restart
