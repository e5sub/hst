echo "# #####################################################################"#
echo ""
echo "请选择需要安装的版本【默认安装标准版】:"
echo ""
echo "【安装FSP和CES服务器】"
echo ""
echo "=====*4.34版本*====="
echo "  1) CES v4.34.5.1单机版（含FSP服务器）"
echo "  2) CES v4.34.5.1集群主服务器（含FSP服务器）"
echo ""
echo "=====*4.32版本*====="
echo "  3) CES v4.32.8.5单机版（含FSP服务器）"
echo "  4) CES v4.32.8.5集群主服务器（含FSP服务器）"
echo ""
echo "=====*4.31版本*====="
echo "  5) CES v4.31.3.6单机版（含FSP服务器）"
echo "  6) CES v4.31.3.6集群主服务器（含FSP服务器）"
echo ""
echo "【只安装CES服务器】"
echo ""
echo "=====*4.34版本*====="
echo "  20) CES v4.34.5.1单机版"
echo "  21) CES v4.34.5.1集群主服务器"
echo "  22) CES v4.34.5.1集群节点服务器"
echo "  23) CES v4.34.5.1人脸识别服务器"
echo ""
echo "=====*4.32版本*====="
echo "  24) CES v4.32.8.5单机版"
echo "  25) CES v4.32.8.5集群主服务器"
echo "  26) CES v4.32.8.5集群节点服务器"
echo "  27) CES v4.32.8.5人脸识别服务器"
echo ""
echo "=====*4.31版本*====="
echo "  28) CES v4.31.3.6单机版"
echo "  29) CES v4.31.3.6集群主服务器"
echo "  30) CES v4.31.3.6集群节点服务器"
echo ""
echo "【国产化CES服务端 For ARM】"
echo ""
echo "  40) 国产化CES v4.31.2.16单机版服务器"
echo "  41) 国产化CES v4.31.2.16集群主服务器"
echo "  42) 国产化CES v4.31.2.16集群节点服务器"
echo ""
echo "【只安装FSP服务器】"
echo ""
echo "  50) 安装FSP v1.4.1.17服务器（适用于4.31以下服务器）"
echo "  51) 安装FSP v1.6.4.4服务器（适用于4.32以上服务器）"
echo "  52) 安装FSP v1.7.1.19服务器"
echo ""
echo "【其他（非好视通产品）】"
echo ""
echo "  87) 安装RTMP/WebRTC/HLS/HTTP-FLV/SRT实时视频服务器（1935/1985/8080/8000端口）"
echo ""
echo "  88) 卸载CES服务器（请注意备份数据）"
echo "  98) 自动添加FSP公网地址（1.7.1.19以上才需要执行）"
echo "  99) 重置后台admin密码"
echo -n "请输入编号: "
echo ""
read N
echo ""
case $N in  
  1) bash hstinstall.sh -434single ;;
  2) bash hstinstall.sh -434main ;;
  3) bash hstinstall.sh -432single ;;
  4) bash hstinstall.sh -432main ;;
  5) bash hstinstall.sh -431single ;;
  6) bash hstinstall.sh -431main ;;
  20) bash hstinstall.sh -434dj ;;
  21) bash hstinstall.sh -434jq ;;
  22) bash hstinstall.sh -434node ;;
  23) bash hstinstall.sh -434face ;;
  24) bash hstinstall.sh -432dj ;;
  25) bash hstinstall.sh -432jq ;;
  26) bash hstinstall.sh -432node ;;
  27) bash hstinstall.sh -432face ;;
  28) bash hstinstall.sh -431dj ;;
  29) bash hstinstall.sh -431jq ;;
  30) bash hstinstall.sh -431node;;
  40) bash hstinstall.sh -gc431dj;;
  41) bash hstinstall.sh -gc431jq;;
  42) bash hstinstall.sh -gc431node;;
  50) bash hstinstall.sh -141fsp ;;
  51) bash hstinstall.sh -164fsp ;;
  52) bash hstinstall.sh -171fsp ;;
  87) bash hstinstall.sh -rtmp ;;
  88) bash hstinstall.sh -xiezai;;
  98) bash hstinstall.sh -setip ;;
  99) bash hstinstall.sh -resetadmin ;;
  *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac
