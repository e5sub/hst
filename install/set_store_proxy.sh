#!/bin/bash

docker_id=`docker ps|grep fsp_pri|awk '{print $1}'`

docker cp fsmeeting.conf $docker_id:/
docker exec -ti $docker_id /bin/bash -c "mv -f /fsmeeting.conf /etc/nginx/conf.d/fsmeeting.conf && nginx -s reload"
