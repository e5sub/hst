@echo off
title ���������ܲ��Թ���(�ͻ���) ���ߣ��ƻ�
color 0a
iperf.exe -v
@echo �ù������ڲ��Է�������ͻ���֮���TCP�������ܡ�
@echo ��Ҫȡ�������밴Ctrl+Cȡ��֮���ٹرմ��ڡ�
@echo.
set /p SerIP=���������˵�ip��
set /p port=���������˵Ķ˿ںţ�
iperf.exe -c %SerIP% -p %port% -f 'M' -t 6000 -w 64k -R