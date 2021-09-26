## 好视通会议服务器一键安装脚本
脚本目前功能：  
1、同步linux时间  
2、检测linux硬件配置  
3、自动获取linux内外网IP地址  
4、一键安装CES标准版/CES中性版/FSP服务器  
5、RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器（用于网络对接大疆无人机之类的设备）  
6、重置后台admin密码   

推流服务器采用了ossrs开源代码 
  
后续计划添加zabbix服务器监控应用  

一键安装脚本：  
 yum -y install wget && wget https://ghproxy.com/https://github.com/e5sub/hst/blob/master/ces.sh -O ces.sh && bash ./ces.sh  
备用脚本：     
 bash <(curl -Ls https://ghproxy.com/https://github.com/e5sub/hst/blob/master/ces.sh)
