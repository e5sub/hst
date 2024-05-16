@echo off
title 局域网性能测试工具(客户端) 作者：唐辉
color 0a
iperf.exe -v
@echo 该工具用于测试服务器与客户机之间的TCP传输性能。
@echo 如要取消测试请按Ctrl+C取消之后再关闭窗口。
@echo.
set /p SerIP=请输入服务端的ip：
set /p port=请输入服务端的端口号：
iperf.exe -c %SerIP% -p %port% -f 'M' -t 6000 -w 64k -R