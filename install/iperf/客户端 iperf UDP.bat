@echo off
title ���������ܲ��Թ���(�ͻ���) ���ߣ��ƻ�
color 0a
iperf.exe -v
@echo �ù������ڲ��Է�������ͻ���֮���UDP�������ܡ�
@echo ��Ҫȡ�������밴Ctrl+Cȡ��֮���ٹرմ��ڡ�
@echo.
set /p SerIP=���������˵�ip��
set /p port=���������˵Ķ˿ںţ�
set /p size=������������ݰ���С����λ:M����
iperf.exe -u -c %SerIP% -p %port% -f 'M' -b %size%M -t 6000 -R