echo "请选择需要安装的版本【默认只安装CES标准版】:"
echo ""
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 4341. \033[0m CES v4.34.5.1单机版"
echo -e " \033[32m 4342. \033[0m CES v4.34.5.1集群主服务器"
echo -e " \033[32m 4343. \033[0m CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 4344. \033[0m CES v4.34.5.1人脸识别服务器"
echo -e " \033[31m=====*4.32版本*=====\033[0m"
echo -e " \033[32m 4321. \033[0m CES v4.32.8.5单机版"
echo -e " \033[32m 4322. \033[0m CES v4.32.8.5集群主服务器"
echo -e " \033[32m 4323. \033[0m CES v4.32.8.5集群节点服务器"
echo -e " \033[32m 4324. \033[0m CES v4.32.8.5人脸识别服务器"
echo -e " \033[31m=====*4.31版本*=====\033[0m"
echo -e " \033[32m 4311. \033[0m CES v4.31.3.6单机版"
echo -e " \033[32m 4312. \033[0m CES v4.31.3.6集群主服务器"
echo -e " \033[32m 4313. \033[0m CES v4.31.3.6集群节点服务器"
echo -e " \033[44;37m 国产化CES服务端 For ARM \033[0m"
echo -e " \033[32m 40. \033[0m 国产化CES v4.35.1.30单机版服务器"
echo -e " \033[32m 41. \033[0m 国产化CES v4.35.1.30集群主服务器"
echo -e " \033[32m 42. \033[0m 国产化CES v4.35.1.30集群节点服务器"
echo -e " \033[32m 43. \033[0m 国产化CES v4.35.1.30人脸识别服务器"
echo -e " \033[32m 44. \033[0m 国产化CES v4.34.5.1单机版服务器"
echo -e " \033[32m 45. \033[0m 国产化CES v4.34.5.1集群主服务器"
echo -e " \033[32m 46. \033[0m 国产化CES v4.34.5.1集群节点服务器"
echo -e " \033[32m 47. \033[0m 国产化CES v4.34.5.1人脸识别服务器"
echo -e " \033[32m 48. \033[0m 国产化CES v4.31.2.16单机版服务器"
echo -e " \033[32m 49. \033[0m 国产化CES v4.31.2.16集群主服务器"
echo -e " \033[32m 50. \033[0m 国产化CES v4.31.2.16集群节点服务器"
echo -e " \033[44;37m 国产化CES服务端 For MIPS \033[0m"
echo -e " \033[32m 60. \033[0m 国产化CES v4.35.1.30单机版服务器"
echo -e " \033[32m 61. \033[0m 国产化CES v4.35.1.30集群主服务器"
echo -e " \033[32m 62. \033[0m 国产化CES v4.35.1.30集群节点服务器"
echo -e " \033[32m 63. \033[0m 国产化CES v4.35.1.30人脸识别服务器"
echo -e ""
echo -e " \033[32m 00. \033[0m 返回安装新版本CES服务器"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N
echo ""
case $N in
  4341) bash install.sh -434dj ;;
  4342) bash install.sh -434jq ;;
  4343) bash install.sh -434node ;;
  4344) bash install.sh -434face ;
  4321) bash install.sh -432dj ;;
  4322) bash install.sh -432jq ;;
  4323) bash install.sh -432node ;;
  4324) bash install.sh -432face ;;
  4311) bash install.sh -431dj ;;
  4312) bash install.sh -431jq ;;
  4313) bash install.sh -431node;;
  40) bash install.sh -gc435dj;;
  41) bash install.sh -gc435jq;;
  42) bash install.sh -gc435node;;
  43) bash install.sh -gc435face;;
  44) bash install.sh -gc434dj;;
  45) bash install.sh -gc434jq;;
  46) bash install.sh -gc434node;;
  47) bash install.sh -gc434face;;
  48) bash install.sh -gc431dj;;
  49) bash install.sh -gc431jq;;
  50) bash install.sh -gc431node;;
  60) bash install.sh -m435dj;;
  61) bash install.sh -m435jq;;
  62) bash install.sh -m435node;;
  63) bash install.sh -m435face;;
  00) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/ces.sh -O ces.sh && chmod +x ces.sh && bash ces.sh;;
   *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac