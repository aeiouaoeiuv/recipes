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
echo ��ѡ��Ҫ��������ţ�1/2/3...����Ȼ�󰴻س�
echo.
echo              1.���� %uploadDir:"=% ������
echo.
echo              2.�������� %pullPath%%pullName% ����ǰĿ¼
echo.
echo              h.��ʾ����
echo.
echo              c.����
echo.
echo              q.�˳�
echo.
echo =======================================================

:select_option

rem ��������ҪΪ�˱���ѡ���һ��ѡ��֮��ֱ������س����ظ���һ�εĲ���
set option=0

echo.
set /p option="���������ѡ��{h��ʾ����}��"
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

		rem "\" ת "/"
		set linuxPathname=!windowsPathname:\=/!

		%ADB% push %uploadDir:"=%\!windowsPathname! /!linuxPathname:\=/! || (echo "Error!" && goto select_option)
		%ADB% shell "chmod 755 /!linuxPathname:\=/!" || (echo "Error!" && goto select_option)
	)

	echo "������ɣ�"

	ENDLOCAL

	goto select_option
)

:Ops_PullFile (
	SETLOCAL enabledelayedexpansion

	call :start_adb_server

	call :get_current_channel channel
	if not %channel% == "prime" (
		echo "��ȷ���������ٲ���"
		echo.

		goto select_option
	)

	for /f "delims=" %%i in ('%ADB% shell "find %pullPath%%pullName% -size +0 -maxdepth 1"') do (
		rem �õ����� /tmp/abc.txt
		set tmpStr=%%i

		rem ȥ��ĩβ�Ļ��з�
		set tmpStr=!tmpStr:~0,-1!

		rem ��·��ǰ׺ȥ�� ʣ������ abc.txt
		set basename=!tmpStr:%pullPath%=!

		%ADB% pull !tmpStr! !basename!

		echo.
		echo "�ѽ��ļ������� %~dp0!basename!"
		echo.
	)

	ENDLOCAL

	goto select_option
)

:eof

exit
