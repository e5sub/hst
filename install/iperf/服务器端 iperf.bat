@echo off
title 局域网性能测试工具(服务端) 作者：唐辉
color 0a
iperf.exe -v
@echo 该工具用于测试服务器与客户机之间的TCP/UDP传输性能。
@echo 默认监听5201端口，如需更改请修改bat文件。
@echo.
iperf.exe -s -p 5201