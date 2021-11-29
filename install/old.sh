echo "请选择需要安装的版本【默认只安装CES标准版】:"
echo ""
echo -e " \033[31m=====*4.32版本*=====\033[0m"
echo -e " \033[32m 4321. \033[0m CES v4.32.8.5单机版"
echo -e " \033[32m 4322. \033[0m CES v4.32.8.5集群主服务器"
echo -e " \033[32m 4323. \033[0m CES v4.32.8.5集群节点服务器"
echo -e " \033[32m 4324. \033[0m CES v4.32.8.5人脸识别服务器"
echo -e " \033[31m=====*4.31版本*=====\033[0m"
echo -e " \033[32m 4311. \033[0m CES v4.31.3.6单机版"
echo -e " \033[32m 4312. \033[0m CES v4.31.3.6集群主服务器"
echo -e " \033[32m 4313. \033[0m CES v4.31.3.6集群节点服务器"
echo -e " \033[32m 4314. \033[0m 国产化CES v4.31.2.16单机版服务器"
echo -e " \033[32m 4315. \033[0m 国产化CES v4.31.2.16集群主服务器"
echo -e " \033[32m 4316. \033[0m 国产化CES v4.31.2.16集群节点服务器"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N
echo ""
case $N in
  4321) bash install.sh -432dj ;;
  4322) bash install.sh -432jq ;;
  4323) bash install.sh -432node ;;
  4324) bash install.sh -432face ;;
  4311) bash install.sh -431dj ;;
  4312) bash install.sh -431jq ;;
  4313) bash install.sh -431node;;
  4314) bash install.sh -gc431dj;;
  4315) bash install.sh -gc431jq;;
  4316) bash install.sh -gc431node;;
   *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac