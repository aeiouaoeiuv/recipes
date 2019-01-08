@echo off

:clear_screen
cls
color 03

set uploadDir="updates"
set ADB=%~dp0adb.exe
rem set ADB=D:\Softwares\adb\adb

:menu
echo.
echo =======================================================
echo.
echo ��ѡ��Ҫ��������ţ�1/2/3...����Ȼ�󰴻س�
echo.
echo              1.���� %uploadDir:"=% ������
echo.
echo              2.��֪��ǰ�����򸱿�
echo.
echo              3.�����и���
echo.
echo              4.����������
echo.
echo              5.��ȡ������־
echo.
echo              6.��ȡ������־
echo.
echo              7.��ֹadb����
echo.
echo              h.��ʾ����
echo.
echo              c.����
echo.
echo              q.�˳�
echo.
echo =======================================================

rem choice�������ж�errorlevelʱ������ֵҪ���ߵ������У���������Ҳֻ����1/2/3������
rem choice /c 12 /m ���������ѡ��
rem if errorlevel 2 goto Ops_Quit
rem if errorlevel 1 goto Ops_Update

:select_option

rem ��������ҪΪ�˱���ѡ���һ��ѡ��֮��ֱ������س����ظ���һ�εĲ���
set option=0

echo.
set /p option="���������ѡ��{h��ʾ����}��"
if "%option%" == "1" (
	goto Ops_Update
) else if "%option%" == "2" (
	goto Ops_GetCurrentChannel
) else if "%option%" == "3" (
	goto Ops_SwitchToViceChannel
) else if "%option%" == "4" (
	goto Ops_SwitchToPrimeChannel
) else if "%option%" == "5" (
	goto Ops_GetPrimeLog
) else if "%option%" == "6" (
	goto Ops_GetViceLog
) else if "%option%" == "7" (
	goto Ops_KillAdbServer
) else if "%option%" == "h" (
	goto menu
) else if "%option%" == "c" (
	goto clear_screen
) else if "%option%" == "q" (
	goto Ops_Quit
) else (
	echo "��֧�ֵ�����"
	goto select_option
)

rem ����adb����
:start_adb_server (
	tasklist | find "adb.exe" > nul || (
		echo "��ʼ����adb����..."
		%ADB% start-server || (echo "Error!" && goto select_option)
		echo "����adb�������"
		echo.
	)

	goto:eof
)

rem �ж�������
:get_current_channel (
	echo "��ʼ�ж������򸱿�..."

	for /f "delims=" %%t in ('%ADB% shell "cat /proc/cmdline | awk -F 'com_chip_id=' '{print $2}' | awk -F ' ' '{print$1}'"') do set cpu_version=%%t
	if "%cpu_version%" == "297" (
		echo "ȷ��������"
		echo.

		set %~1="prime"
	) else if "%cpu_version%" == "296" (
		echo "ȷ���Ǹ���"
		echo.

		set %~1="vice"
	) else (
		echo "�޷�ȷ���������Ǹ���"
		echo.
	)

	goto:eof
)

rem �жϵ�ǰ����·��
:get_ctrl_used_path (
	echo "��ʼ��ȡ����·��..."

	for /f "delims=" %%t in ('%ADB% shell "cat /data/ueapp/config/ctrl_used"') do set ctrl_used=%%t
	if "%ctrl_used%" == "1" (
		echo "ctrl_used==1"
		echo.

		set %~1="/data/ueapp/macaroon_first/"
	) else (
		echo "ctrl_used==2"
		echo.

		set %~1="/data/ueapp/macaroon_second/"
	)

	goto:eof
)

:get_strlen (
	set str=%~2
	set /a max=8190,min=0
	for /l %%a in (1,1,14) do (
		set /a "num=(max+min)/2"
		for /f "delims=" %%b in ("!num!") do if "!str:~%%b!" equ "" (set /a max=num) else set /a min=num
	)
	if "!str:~%num%!" neq "" set /a num+=1
	set %~1=%num%

	goto:eof
)

rem ȡ������
:Ops_Quit (
	goto eof
)

rem ��ȡ������־
:Ops_GetViceLog (
	SETLOCAL

	call :start_adb_server

	set channel=0
	call :get_current_channel channel
	if %channel% == "vice" (
		%ADB% shell "mkdir -p /run/basiclog" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/basiclog/macaroon_basic.tar.gz /data/ueapp/log" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/basiclog/tmp.tar.gz /var/volatile/tmp" || (echo "Error!" && goto select_option)
		%ADB% shell "dmesg > /run/basiclog/dmesg.log" || (echo "Error!" && goto select_option)
		%ADB% shell "ifconfig >/run/basiclog/ifconfig.log" || (echo "Error!" && goto select_option)
		%ADB% shell "ip link >/run/basiclog/ip_link.log" || (echo "Error!" && goto select_option)
		%ADB% shell "route >/run/basiclog/route.log" || (echo "Error!" && goto select_option)
		%ADB% shell "ps aux >/run/basiclog/ps.log" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /cache/fota* /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /cache/recovery/ /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /etc/mobileap_cfg.xml /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /etc/sta_mode_hostapd.conf /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /etc/resolv.conf /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /lib/firmware/wlan/qca_cld/WCNSS_qcom_cfg.ini /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /data/test_sleep /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /data/test_timer /run/basiclog/" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/basiclog/userstore.tar.gz /userstore" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/basiclog.tar.gz /run/basiclog" || (echo "Error!" && goto select_option)
		%ADB% pull /run/basiclog.tar.gz log/basiclog.tar.gz || (echo "Error!" && goto select_option)
		%ADB% shell "rm -rf /run/basiclog.tar.gz" || (echo "Error!" && goto select_option)

		echo "��־�Ѵ���� log/basiclog.tar.gz"
		echo.
	) else if %channel% == "prime" (
		echo "���л��������ٲ���"
		echo.
	) else (
		echo "δ֪����"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem ��ȡ������־
:Ops_GetPrimeLog (
	SETLOCAL

	call :start_adb_server

	set channel=0
	call :get_current_channel channel
	if %channel% == "prime" (
		%ADB% shell "mkdir -p /run/mainlog" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/mainlog/macaroon_main.tar.gz /data/ueapp/log" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/mainlog/tmp.tar.gz /var/volatile/tmp" || (echo "Error!" && goto select_option)
		%ADB% shell "dmesg > /run/mainlog/dmesg.log" || (echo "Error!" && goto select_option)
		%ADB% shell "ifconfig >/run/mainlog/ifconfig.log" || (echo "Error!" && goto select_option)
		%ADB% shell "ip link >/run/mainlog/ip_link.log" || (echo "Error!" && goto select_option)
		%ADB% shell "route >/run/mainlog/route.log" || (echo "Error!" && goto select_option)
		%ADB% shell "ps aux >/run/mainlog/ps.log" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /cache/fota* /run/mainlog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /cache/*.tar.gz /run/mainlog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /cache/recovery/ /run/mainlog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /etc/mobileap_cfg.xml /run/mainlog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /etc/sta_mode_hostapd.conf /run/mainlog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /etc/resolv.conf /run/mainlog/" || (echo "Error!" && goto select_option)
		%ADB% shell "cp -rf /lib/firmware/wlan/qca_cld/WCNSS_qcom_cfg.ini /run/mainlog/" || (echo "Error!" && goto select_option)
		%ADB% shell "tcpdump -i rmnet_data0 -c 30 -w /tmp/mainlog/test.pcap &" || (echo "Error!" && goto select_option)
		%ADB% shell "ping -c 30 8.8.8.8" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/mainlog/userstore.tar.gz /userstore" || (echo "Error!" && goto select_option)
		%ADB% shell "tar -cvzf /run/mainlog.tar.gz /run/mainlog" || (echo "Error!" && goto select_option)
		%ADB% pull /run/mainlog.tar.gz log/mainlog.tar.gz || (echo "Error!" && goto select_option)
		%ADB% shell "rm -rf /run/mainlog.tar.gz" || (echo "Error!" && goto select_option)

		echo "��־�Ѵ���� log/mainlog.tar.gz"
		echo.
	) else if %channel% == "vice" (
		echo "���л��������ٲ���"
		echo.
	) else (
		echo "δ֪����"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem ����������
:Ops_SwitchToPrimeChannel (
	SETLOCAL

	call :start_adb_server

	set channel=0
	call :get_current_channel channel
	if %channel% == "vice" (
		echo "��ʼ�����л�������..."

		%ADB% shell "rsimCfg 0" || (echo "Error!" && goto select_option)

		echo "�п����"
		echo.
	) else if %channel% == "prime" (
		echo "��ǰ���������������л�"
		echo.
	) else (
		echo "δ֪����"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem �л�������
:Ops_SwitchToViceChannel (
	SETLOCAL

	call :start_adb_server

	set channel=0
	call :get_current_channel channel
	if %channel% == "prime" (
		echo "��ʼ�����л�������..."

		%ADB% shell "usbswitch 8207" || (echo "Error!" && goto select_option)

		echo "�п����"
		echo.
	) else if %channel% == "vice" (
		echo "��ǰ���Ǹ����������л�"
		echo.
	) else (
		echo "δ֪����"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem ��֪��ǰ�����򸱿�
:Ops_GetCurrentChannel (
	SETLOCAL

	call :start_adb_server

	set channel=0
	call :get_current_channel channel

	ENDLOCAL

	goto select_option
)

:Ops_Update (
	SETLOCAL enabledelayedexpansion

	call :start_adb_server

	call :get_current_channel channel
	if not %channel% == "prime" (
		echo "��ȷ���������ٲ���"
		echo.

		goto select_option
	)

	rem %uploadDir:"=% ��ȥ��˫����
	set headPath=%cd%\%uploadDir:"=%\
	call :get_strlen headPathLen %headPath%

	for /f "delims=" %%i in ('dir /a-d/b/s %uploadDir%') do (
		rem �õ����� usr/bin/sh ��·��
		set fullPath=%%i
		set windowsPathname=!fullPath:~%headPathLen%!

		rem �����ļ����⴦��
		rem if "!windowsPathname!" == "data\ueapp\macaroon_first\macaroon" (
		rem 	call :get_ctrl_used_path binPath
		rem 	echo "macaroon����·��Ϊ��!binPath!"
		rem 	echo.

		rem 	set windowsPathname=data\ueapp\macaroon_first\macaroon
		rem 	set linuxPathname=!binPath:"=!macaroon

		rem 	rem ȥ����һ�� "/" ��ȡ��ĩβ
		rem 	set linuxPathname=!linuxPathname:~1!

		rem 	rem "/" ת "\"
		rem 	set linuxPathname=!linuxPathname:/=\!

		rem ) else (
			rem "\" ת "/"
			set linuxPathname=!windowsPathname:\=/!
		rem )

		%ADB% push %uploadDir:"=%\!windowsPathname! /!linuxPathname:\=/! || (echo "Error!" && goto select_option)
		%ADB% shell "chmod 755 /!linuxPathname:\=/!" || (echo "Error!" && goto select_option)
	)

	echo "������ɣ�"

	ENDLOCAL

	goto select_option
)

:Ops_KillAdbServer (
	SETLOCAL

	tasklist | find "adb.exe" || (
		echo "û������adb����������ֹ"
		goto select_option
	)

	taskkill /f /t /im adb.exe || (
		echo "��ֹadb����ʧ��!"
		goto select_option
	)

	echo "����ֹadb����"

	ENDLOCAL

	goto select_option
)


:eof
rem echo.
rem echo "�밴��������˳�����"
rem pause > nul

exit
