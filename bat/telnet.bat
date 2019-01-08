set a = ls

echo set sh=WScript.CreateObject("WScript.Shell") >Telnet_tmp.vbs
echo WScript.Sleep 300 >>Telnet_tmp.vbs

echo sh.SendKeys "open 192.168.100.1{ENTER}" >>Telnet_tmp.vbs
echo WScript.Sleep 400 >>Telnet_tmp.vbs

echo sh.SendKeys "root{ENTER}" >>Telnet_tmp.vbs
echo WScript.Sleep 400 >>Telnet_tmp.vbs

echo sh.SendKeys "123456{ENTER}">>Telnet_tmp.vbs
echo WScript.Sleep 400 >>Telnet_tmp.vbs

echo sh.SendKeys "cd /tmp/{ENTER}">>Telnet_tmp.vbs
echo WScript.Sleep 400 >>Telnet_tmp.vbs

//echo sh.SendKeys "clear session{ENTER}" >>Telnet_tmp.vbs

start telnet.exe
cscript //nologo Telnet_tmp.vbs
del Telnet_tmp.vbs
cls
goto START
