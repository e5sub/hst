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
echo -e " \033[32m 40. \033[0m 国产化CES v4.35.1.29单机版服务器"
echo -e " \033[32m 41. \033[0m 国产化CES v4.35.1.29集群主服务器"
echo -e " \033[32m 42. \033[0m 国产化CES v4.35.1.29集群节点服务器"
echo -e " \033[32m 43. \033[0m 国产化CES v4.35.1.29人脸识别服务器"
echo -e " \033[32m 44. \033[0m 国产化CES v4.34.5.1单机版服务器"
echo -e " \033[32m 45. \033[0m 国产化CES v4.34.5.1集群主服务器"
echo -e " \033[32m 46. \033[0m 国产化CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 47. \033[0m 国产化CES v4.34.5.1人脸识别服务器"
echo -e ""
echo -e " \033[32m 00. \033[0m 返回安装标准版CES服务器"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N
echo ""
case $N in
  1) bash install.sh -zx435single ;;
  2) bash install.sh -zx435main ;;
  3) bash install.sh -zx434single ;;
  4) bash install.sh -zx434main ;;
  5) bash install.sh -zx432single ;;
  6) bash install.sh -zx432main ;;
  7) bash install.sh -zx431single ;;
  8) bash install.sh -zx431main ;;
  20) bash install.sh -zx435dj ;;
  21) bash install.sh -zx435jq ;;
  22) bash install.sh -zx435node ;;
  23) bash install.sh -zx435face ;;
  24) bash install.sh -zx434dj ;;
  25) bash install.sh -zx434jq ;;
  26) bash install.sh -zx434node ;;
  27) bash install.sh -zx434face ;;
  28) bash install.sh -zx432dj ;;
  29) bash install.sh -zx432jq ;;
  30) bash install.sh -zx432node ;;
  31) bash install.sh -zx432face ;;
  32) bash install.sh -zx431dj ;;
  33) bash install.sh -zx431jq ;;
  34) bash install.sh -zx431node;;
  40) bash install.sh -gczx435dj;;
  41) bash install.sh -gczx435jq;;
  42) bash install.sh -gczx435node;;
  43) bash install.sh -gczx435face;;
  44) bash install.sh -gczx434dj;;
  45) bash install.sh -gczx434jq;;
  46) bash install.sh -gczx434node;;
  47) bash install.sh -gczx434face;;
  00) bash ces.sh ;;
  *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac
