@echo off

set server_ipv4=192.168.31.100
set uplink_result_file=test_data_uplink.txt
set downlink_result_file=test_data_downlink.txt

SETLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do     rem"') do (
    set "DEL=%%a"
)

echo -- This is client side.

echo.
:pingloop
echo -- ping -n 1 %server_ipv4%
ping -n 1 %server_ipv4% | find "TTL=" >nul
if errorlevel 1 (
    echo -- Ping %server_ipv4% fail, please check your network or ip.
    goto :pingloop
) else (
    echo -- Ping %server_ipv4% success.
)

echo.
echo -- Start to test uplink.
echo -- It will cost about 60s, please wait.
iperf3.exe -c %server_ipv4% -p 5301 -i 10 -t 60 -R --logfile %uplink_result_file%
echo -- Test result was exported to %uplink_result_file%.

echo.
echo -- Start to test downlink.
echo -- It will cost about 60s, please wait.
iperf3.exe -c %server_ipv4% -p 5201 -i 10 -t 60 --logfile %downlink_result_file%
echo -- Test result was exported to %downlink_result_file%.

echo.
call :colorEcho 2e "-- All tests FINISHED. Press any key to close this window."
echo.

pause >nul

exit
:colorEcho
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
