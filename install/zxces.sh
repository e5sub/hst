echo "# #####################################################################"#
echo "                                                       "
echo "请选择需要安装的版本【中性版】:"
echo ""
echo -e " \033[31m=====*4.36版本*=====\033[0m"
echo -e " \033[32m 1. \033[0m CES v4.36.5.5服务器"
echo -e " \033[31m=====*4.35版本*=====\033[0m"
echo -e " \033[32m 2. \033[0m CES v4.35.4.5服务器"
echo -e " \033[31m=====*4.34版本*=====\033[0m"
echo -e " \033[32m 3. \033[0m CES v4.34.5.1服务器"
echo -e " \033[31m=====*4.32版本*=====\033[0m"
echo -e " \033[32m 4. \033[0m CES v4.32.8.5服务器"
echo -e " \033[31m=====*4.31版本*=====\033[0m"
echo -e " \033[32m 5. \033[0m CES v4.31.3.6服务器"
echo -e " \033[44;37m 国产化CES服务端 For ARM \033[0m"
echo -e " \033[32m 10. \033[0m 国产化CES v4.35.1.30服务器"
echo -e " \033[32m 11. \033[0m 国产化CES v4.34.5.1服务器"
echo -e " \033[44;37m 国产化CES服务端 For MIPS \033[0m"
echo -e " \033[32m 20. \033[0m 国产化CES v4.35.1.30服务器"
echo -e ""
echo -e " \033[32m 00. \033[0m 返回安装标准版CES服务器"
echo -e ""
echo -e -n "\033[41;33m 请输入编号:  \033[0m"
echo ""
read N
echo ""
case $N in
  1) bash install.sh -zx436 ;;
  2) bash install.sh -zx435 ;;
  3) bash install.sh -zx434 ;;
  4) bash install.sh -zx432 ;;
  5) bash install.sh -zx431 ;;
  10) bash install.sh -gczx435 ;;
  11) bash install.sh -gczx434 ;;
  20) bash install.sh -mzx435 ;;
  00) wget --no-check-certificate https://ghproxy.com/https://github.com/e5sub/hst/blob/master/ces.sh -O ces.sh && chmod +x ces.sh && bash ces.sh;;
  *) echo -e "输入的编号有误，请重新运行安装脚本!" ;;
esac
