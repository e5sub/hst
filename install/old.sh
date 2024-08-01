echo "请选择需要安装的版本【标准版】:"
echo ""
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 4341. \033[0m CES v4.34.5.1服务器"
echo -e " \033[31m=====*4.32版本*=====\033[0m"
echo -e " \033[32m 4321. \033[0m CES v4.32.8.5服务器"
echo -e " \033[31m=====*4.31版本*=====\033[0m"
echo -e " \033[32m 4311. \033[0m CES v4.31.3.6服务器"
echo -e " \033[44;37m 国产化CES服务端 For ARM \033[0m"
echo -e " \033[32m 40. \033[0m 国产化CES v4.35.1.30服务器"
echo -e " \033[32m 41. \033[0m 国产化CES v4.34.5.1服务器"
echo -e " \033[32m 42. \033[0m 国产化CES v4.31.2.16服务器"
echo -e " \033[44;37m 国产化CES服务端 For MIPS \033[0m"
echo -e " \033[32m 50. \033[0m 国产化CES v4.35.1.30服务器"
echo -e ""
echo -e " \033[32m 00. \033[0m 返回安装新版本CES服务器"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N
echo ""
case $N in
  4341) bash cesinstall.sh -434 ;;
  4321) bash cessinstall.sh -432 ;;
  4311) bash cesinstall.sh -431 ;;
  40) bash cesinstall.sh -gc435;;
  41) bash cesinstall.sh -gc434;;
  42) bash cesinstall.sh -gc431;;
  50) bash cesinstall.sh -m435;;
  00) wget --no-check-certificate https://fastly.jsdelivr.net/gh/e5sub/hst@master/ces.sh -O ces.sh && chmod +x ces.sh && bash ces.sh;;
   *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac