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
echo 请选择要操作的序号（1/2/3...），然后按回车
echo.
echo              1.升级 %uploadDir:"=% 的内容
echo.
echo              2.获知当前主卡或副卡
echo.
echo              3.主卡切副卡
echo.
echo              4.副卡切主卡
echo.
echo              5.单取主卡日志
echo.
echo              6.单取副卡日志
echo.
echo              7.终止adb服务
echo.
echo              h.显示帮助
echo.
echo              c.清屏
echo.
echo              q.退出
echo.
echo =======================================================

rem choice方法，判断errorlevel时，返回值要按高到低排列，上面的序号也只能用1/2/3等数字
rem choice /c 12 /m 请输入你的选择：
rem if errorlevel 2 goto Ops_Quit
rem if errorlevel 1 goto Ops_Update

:select_option

rem 添加这句主要为了避免选择过一次选项之后，直接敲入回车会重复上一次的操作
set option=0

echo.
set /p option="请输入你的选择{h显示帮助}："
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
	echo "不支持的命令"
	goto select_option
)

rem 开启adb服务
:start_adb_server (
	tasklist | find "adb.exe" > nul || (
		echo "开始开启adb服务..."
		%ADB% start-server || (echo "Error!" && goto select_option)
		echo "开启adb服务完成"
		echo.
	)

	goto:eof
)

rem 判断主副卡
:get_current_channel (
	echo "开始判断主卡或副卡..."

	for /f "delims=" %%t in ('%ADB% shell "cat /proc/cmdline | awk -F 'com_chip_id=' '{print $2}' | awk -F ' ' '{print$1}'"') do set cpu_version=%%t
	if "%cpu_version%" == "297" (
		echo "确认是主卡"
		echo.

		set %~1="prime"
	) else if "%cpu_version%" == "296" (
		echo "确认是副卡"
		echo.

		set %~1="vice"
	) else (
		echo "无法确定主卡还是副卡"
		echo.
	)

	goto:eof
)

rem 判断当前程序路径
:get_ctrl_used_path (
	echo "开始获取程序路径..."

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

rem 取消操作
:Ops_Quit (
	goto eof
)

rem 单取副卡日志
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

		echo "日志已存放至 log/basiclog.tar.gz"
		echo.
	) else if %channel% == "prime" (
		echo "请切换至副卡再操作"
		echo.
	) else (
		echo "未知错误"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem 单取主卡日志
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

		echo "日志已存放至 log/mainlog.tar.gz"
		echo.
	) else if %channel% == "vice" (
		echo "请切换至主卡再操作"
		echo.
	) else (
		echo "未知错误"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem 副卡切主卡
:Ops_SwitchToPrimeChannel (
	SETLOCAL

	call :start_adb_server

	set channel=0
	call :get_current_channel channel
	if %channel% == "vice" (
		echo "开始副卡切换至主卡..."

		%ADB% shell "rsimCfg 0" || (echo "Error!" && goto select_option)

		echo "切卡完成"
		echo.
	) else if %channel% == "prime" (
		echo "当前已是主卡，无需切换"
		echo.
	) else (
		echo "未知错误"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem 切换到副卡
:Ops_SwitchToViceChannel (
	SETLOCAL

	call :start_adb_server

	set channel=0
	call :get_current_channel channel
	if %channel% == "prime" (
		echo "开始主卡切换至副卡..."

		%ADB% shell "usbswitch 8207" || (echo "Error!" && goto select_option)

		echo "切卡完成"
		echo.
	) else if %channel% == "vice" (
		echo "当前已是副卡，无需切换"
		echo.
	) else (
		echo "未知错误"
		echo.
	)

	ENDLOCAL

	goto select_option
)

rem 获知当前主卡或副卡
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
		echo "请确保是主卡再操作"
		echo.

		goto select_option
	)

	rem %uploadDir:"=% 是去掉双引号
	set headPath=%cd%\%uploadDir:"=%\
	call :get_strlen headPathLen %headPath%

	for /f "delims=" %%i in ('dir /a-d/b/s %uploadDir%') do (
		rem 拿到类似 usr/bin/sh 的路径
		set fullPath=%%i
		set windowsPathname=!fullPath:~%headPathLen%!

		rem 特殊文件特殊处理
		rem if "!windowsPathname!" == "data\ueapp\macaroon_first\macaroon" (
		rem 	call :get_ctrl_used_path binPath
		rem 	echo "macaroon升级路径为：!binPath!"
		rem 	echo.

		rem 	set windowsPathname=data\ueapp\macaroon_first\macaroon
		rem 	set linuxPathname=!binPath:"=!macaroon

		rem 	rem 去掉第一个 "/" 截取至末尾
		rem 	set linuxPathname=!linuxPathname:~1!

		rem 	rem "/" 转 "\"
		rem 	set linuxPathname=!linuxPathname:/=\!

		rem ) else (
			rem "\" 转 "/"
			set linuxPathname=!windowsPathname:\=/!
		rem )

		%ADB% push %uploadDir:"=%\!windowsPathname! /!linuxPathname:\=/! || (echo "Error!" && goto select_option)
		%ADB% shell "chmod 755 /!linuxPathname:\=/!" || (echo "Error!" && goto select_option)
	)

	echo "升级完成！"

	ENDLOCAL

	goto select_option
)

:Ops_KillAdbServer (
	SETLOCAL

	tasklist | find "adb.exe" || (
		echo "没有运行adb服务，无需终止"
		goto select_option
	)

	taskkill /f /t /im adb.exe || (
		echo "终止adb服务失败!"
		goto select_option
	)

	echo "已终止adb服务"

	ENDLOCAL

	goto select_option
)


:eof
rem echo.
rem echo "请按任意键以退出程序"
rem pause > nul

exit
