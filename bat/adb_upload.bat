@echo off

:clear_screen
cls
color 03

set uploadDir="updates"
set ADB=%~dp0adb.exe
rem set ADB=D:\Softwares\adb\adb.exe

set pullPath=/tmp/
set pullName=macaroon_current*.log

:menu
echo.
echo =======================================================
echo.
echo 请选择要操作的序号（1/2/3...），然后按回车
echo.
echo              1.升级 %uploadDir:"=% 的内容
echo.
echo              2.下载主卡 %pullPath%%pullName% 到当前目录
echo.
echo              h.显示帮助
echo.
echo              c.清屏
echo.
echo              q.退出
echo.
echo =======================================================

:select_option

rem 添加这句主要为了避免选择过一次选项之后，直接敲入回车会重复上一次的操作
set option=0

echo.
set /p option="请输入你的选择{h显示帮助}："
if "%option%" == "1" (
	goto Ops_Update
) else if "%option%" == "2" (
	goto Ops_PullFile
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

		rem "\" 转 "/"
		set linuxPathname=!windowsPathname:\=/!

		%ADB% push %uploadDir:"=%\!windowsPathname! /!linuxPathname:\=/! || (echo "Error!" && goto select_option)
		%ADB% shell "chmod 755 /!linuxPathname:\=/!" || (echo "Error!" && goto select_option)
	)

	echo "升级完成！"

	ENDLOCAL

	goto select_option
)

:Ops_PullFile (
	SETLOCAL enabledelayedexpansion

	call :start_adb_server

	call :get_current_channel channel
	if not %channel% == "prime" (
		echo "请确保是主卡再操作"
		echo.

		goto select_option
	)

	for /f "delims=" %%i in ('%ADB% shell "find %pullPath%%pullName% -size +0 -maxdepth 1"') do (
		rem 拿到类似 /tmp/abc.txt
		set tmpStr=%%i

		rem 去掉末尾的换行符
		set tmpStr=!tmpStr:~0,-1!

		rem 将路径前缀去掉 剩下类似 abc.txt
		set basename=!tmpStr:%pullPath%=!

		%ADB% pull !tmpStr! !basename!

		echo.
		echo "已将文件下载至 %~dp0!basename!"
		echo.
	)

	ENDLOCAL

	goto select_option
)

:eof

exit
