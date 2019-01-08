@echo off

set username=root
set password=123456
set remoteip=192.168.100.1

ping -n 2 -w 1 %remoteip% >nul

if %errorlevel% == 1 (
	color 0C
	echo "########## ping %remoteip% fail ##########"
	echo.
	pause
	exit
)

%~dp0pscp.exe -scp -r -pw %password% root/* %username%@%remoteip%:/

if %errorlevel% == 1 (
	color 0C
	echo.
	echo "########## upload fail ##########"
	echo.
) else (
	color 0A
	echo.
	echo "########## upload success ##########"
	echo.
)

pause
