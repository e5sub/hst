echo "# #####################################################################"#
echo "                                                       "
echo "请选择需要安装的版本【默认安装中性版】:"
echo ""
echo -e " \033[44;37m 安装FSP和CES服务器 \033[0m"
echo -e " \033[31m=====*4.35版本*=====\033[0m"
echo -e " \033[32m 1. \033[0m CES v4.35.2.21单机版（含FSP服务器）"
echo -e " \033[32m 2. \033[0m CES v4.35.2.21集群主服务器（含FSP服务器）"
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 3. \033[0m CES v4.34.5.1单机版（含FSP服务器）"
echo -e " \033[32m 4. \033[0m CES v4.34.5.1集群主服务器（含FSP服务器）"
echo -e " \033[31m=====*4.32版本*=====\033[0m"
echo -e " \033[32m 5. \033[0m CES v4.32.8.5单机版（含FSP服务器）"
echo -e " \033[32m 6. \033[0m CES v4.32.8.5集群主服务器（含FSP服务器）"
echo -e " \033[31m=====*4.31版本*=====\033[0m"
echo -e " \033[32m 7. \033[0m CES v4.31.3.6单机版（含FSP服务器）"
echo -e " \033[32m 8. \033[0m CES v4.31.3.6集群主服务器（含FSP服务器）"
echo -e " \033[44;37m 只安装CES服务器 \033[0m"
echo -e " \033[31m=====*4.35版本*=====\033[0m"
echo -e " \033[32m 20. \033[0m CES v4.35.2.21单机版"
echo -e " \033[32m 21. \033[0m CES v4.35.2.21集群主服务器"
echo -e " \033[32m 22. \033[0m CES v4.35.2.21集群节点服务器"
echo -e " \033[32m 23. \033[0m CES v4.35.2.21人脸识别服务器"
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 24. \033[0m CES v4.34.5.1单机版"
echo -e " \033[32m 25. \033[0m CES v4.34.5.1集群主服务器"
echo -e " \033[32m 26. \033[0m CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 27. \033[0m CES v4.34.5.1人脸识别服务器"
echo -e " \033[31m=====*4.32版本*=====\033[0m"
echo -e " \033[32m 28. \033[0m CES v4.32.8.5单机版"
echo -e " \033[32m 29. \033[0m CES v4.32.8.5集群主服务器"
echo -e " \033[32m 30. \033[0m CES v4.32.8.5集群节点服务器"
echo -e " \033[32m 31. \033[0m CES v4.32.8.5人脸识别服务器"
echo -e " \033[31m=====*4.31版本*=====\033[0m"
echo -e " \033[32m 32. \033[0m CES v4.31.3.6单机版"
echo -e " \033[32m 33. \033[0m CES v4.31.3.6集群主服务器"
echo -e " \033[32m 34. \033[0m CES v4.31.3.6集群节点服务器"
echo -e " \033[44;37m 国产化CES服务端 For ARM \033[0m"
echo -e " \033[32m 40. \033[0m 国产化CES v4.34.5.1单机版服务器"
echo -e " \033[32m 41. \033[0m 国产化CES v4.34.5.1集群主服务器"
echo -e " \033[32m 42. \033[0m 国产化CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 43. \033[0m 国产化CES v4.34.5.1人脸识别服务器"
echo -e " \033[44;37m 只安装FSP服务器 \033[0m"
echo -e " \033[32m 50. \033[0m 安装FSP v1.4.1.17服务器（适用于4.31以下服务器）"
echo -e " \033[32m 51. \033[0m 安装FSP v1.6.4.4服务器（适用于4.32以上服务器）"
echo -e " \033[32m 52. \033[0m 安装FSP v1.7.1.19服务器"
echo -e " \033[44;37m 其他（非好视通产品） \033[0m"
echo -e " \033[32m 80. \033[0m 安装RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器（1935/1985/8080/8000端口）"
echo -e " \033[32m 81. \033[0m 安装iperf3局域网性能测试工具(服务端)（5201端口）"
echo -e ""
echo -e " \033[32m 88. \033[0m 卸载CES服务器"
echo -e " \033[32m 89. \033[0m 重启FSP服务器"
echo -e " \033[32m 90. \033[0m 卸载CES服务器"
echo -e ""
echo -e " \033[32m 98. \033[0m 自动添加FSP公网地址（1.7.1.19以上才需要执行）"
echo -e " \033[32m 99. \033[0m 重置后台admin密码"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N
echo ""
case $N in
  1) bash zxinstall.sh -435single ;;
  2) bash zxinstall.sh -435main ;;
  3) bash zxinstall.sh -434single ;;
  4) bash zxinstall.sh -434main ;;
  5) bash zxinstall.sh -432single ;;
  6) bash zxinstall.sh -432main ;;
  7) bash zxinstall.sh -431single ;;
  8) bash zxinstall.sh -431main ;;
  20) bash zxinstall.sh -435dj ;;
  21) bash zxinstall.sh -435jq ;;
  22) bash zxinstall.sh -435node ;;
  23) bash zxinstall.sh -435face ;;
  24) bash zxinstall.sh -434dj ;;
  25) bash zxinstall.sh -434jq ;;
  26) bash zxinstall.sh -434node ;;
  27) bash zxinstall.sh -434face ;;
  28) bash zxinstall.sh -432dj ;;
  29) bash zxinstall.sh -432jq ;;
  30) bash zxinstall.sh -432node ;;
  31) bash zxinstall.sh -432face ;;
  32) bash zxinstall.sh -431dj ;;
  33) bash zxinstall.sh -431jq ;;
  34) bash zxinstall.sh -431node;;
  40) bash zxinstall.sh -gc434dj;;
  41) bash zxinstall.sh -gc434jq;;
  42) bash zxinstall.sh -gc434node;;
  43) bash zxinstall.sh -gc434face;;
  50) bash zxinstall.sh -141fsp ;;
  51) bash zxinstall.sh -164fsp ;;
  52) bash zxinstall.sh -171fsp ;;
  80) bash zxinstall.sh -rtmp ;;
  81) bash zxinstall.sh -iperf ;; 
  88) bash zxinstall.sh -xiezai ;;
  89) bash zxinstall.sh -restartfsp ;;
  90) bash zxinstall.sh -unfsp ;;
  98) bash zxinstall.sh -setip ;;
  99) bash zxinstall.sh -resetadmin ;;
  *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac
