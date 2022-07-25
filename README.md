## 好视通私有云服务器一键安装脚本
脚本目前功能：  
1、同步linux时间  
2、检测linux硬件配置  
3、自动获取linux内外网IP地址  
4、一键安装CES标准版/CES中性版/FSP服务器/H323网关/录制服务器       
5、[RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器](https://github.com/ossrs/srs)   
6、iperf3网络性能测试工具   
7、HTML5网络速度测试工具  
8、一键安装Frp内网穿透工具    
9、一键修改webapp配置文件     
10、一键修改节点配置文件    
11、一键修改录制服务器配置文件   
12、一键修改H323服务器配置信息    
13、重置后台admin密码    
14、[ddns-go动态域名解析服务](https://github.com/jeessy2/ddns-go)    

推流服务器采用了ossrs开源代码 
  
后续计划添加zabbix服务器监控应用  

一键安装脚本：     

bash <(curl -Ls https://ghproxy.com/https://raw.githubusercontent.com/e5sub/hst/master/ces.sh)
