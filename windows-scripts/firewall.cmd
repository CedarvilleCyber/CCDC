@echo off
title = "Windows Firewall Script"

echo Welcome to the Firewall Script. Please ensure that you know what you are doing before using this script.
echo Welcome to the Firewall Script. Please ensure that you know what you are doing before using this script. >> output.txt

echo Administrative permissions required. Detecting permissions...
echo Administrative permissions required. Detecting permissions... >> output.txt
net session >nul 2>&1
:: Check for permissions
if %errorlevel% ==1 (
    echo Please rerun as admin.
    goto :end
)

:: Turn on the firewall
netsh advfirewall set allprofiles state on
echo Firewall turned on
echo Firewall turned on >> output.txt

:: Ask the user which box we're on
set /p box="If you're running 2012AD press enter. For general Windows configuration, enter 'W': "
if "%box%" == "W" (
    goto :NonServerWindows
) else (
    set box="2012ad"
)

:: Set the ip adresses for the host machines on the network
set /p setNotDefault="The IP addresses of the servers are set to reasonable defaults based on previous team packs. Would you like to set them? "
if "%setNotDefault%" == "y" || "%setNotDefault%" == "Y" || "%setNotDefault%" == "yes" (
    set /p eComm="Enter the E-commerce machine IP: "
    set /p DNSNTP="Enter DNS/NTP 10 IP: "
    set /p WebMail="Enter the WebMail IP: "
    set /p Splunk="Enter the Splunk IP: "
    set /p ADDNS="Enter the AD/DNS IP: "
    set /p PaloAlto="Enter the PaloAlto IP: "
    set /p 2016Docker="Enter the 2016 Server IP: "
    set /p UbuntuWeb="Enter the Ubuntu Web IP: "
) else (
    set eComm="172.20.241.30"
    set DNSNTP="172.20.240.20"
    set WebMail="172.20.241.40"
    set Splunk="172.20.241.20"
    set ADDNS="172.20.242.200"
    set PaloAlto="172.20.242.150"
    set 2016Docker="172.20.240.10"
    set UbuntuWeb="172.20.242.10"
)
set /p Windows10="Enter the Windows 10 IP: "
set /p UbuntuWkst="Enter the Ubuntu Workstation IP: "

:2012ADCommands
echo 2012AD Commands running...
echo 2012AD Commands running... >> output.txt
:: Add port registrations for services
REG add "HKLM\SYSTEM\CurrentControlSet\Serviceces\NTDS\Parameters" /v "TCP/IP Port" /t REG_DWORD /d 50243 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "DCTcpipPort" /t REG_DWORD /d 50244 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Services\NTFRS\Parameters" /v "RPC TCP/IP Port Assignment" /t REG_DWORD /d 50245


echo Setting AD firewall rules
echo Setting AD firewall rules >> output.txt
netsh advfirewall firewall add rule name="DNS Out to Any" dir=out action=allow enable=no profile=any remoteport=53 protocol=udp
netsh advfirewall firewall add rule name="Splunk Out" dir=out action=allow enable=yes profile=any remoteip=%Splunk% remoteport=8000,8089,9997 protocol=
netsh advfirewall firewall add rules name="Allow Pings" protocol=icmpv4:8,any dir=in action=allow enable=yes
netsh advfirewall firewall add rule name="All the Pings!" dir=out action=allow enable=yes protocol=icmpv4:8,any
netsh advfirewall firewall add rule name="A - LDAP IN TCP" dir=in action=allow enable=yes profile=any localport=389 remoteip=%WebMail%,%PAMI%,%2016Docker% protocol=tcp
netsh advfirewall firewall add rule name="A - LDAP IN UDP" dir=in action=allow enable=yes profile=any localport=389 remoteip=%WebMail%,%PAMI%,%2016Docker% protocol=udp
netsh advfirewall firewall add rule name="LDAP Out UDP" dir=out action=allow enable=no profile=any remoteport=389 protocol=udp
netsh advfirewall firewall add rule name="LDAP Out TCP" dir=out action=allow enable=no profile=any remoteport=389 protocol=tcp
netsh advfirewall firewall add rule name="A - LDAPS IN TCP" dir=in action=allow enable=yes profile=any localport=636 remoteip=%WebMail%,%PAMI%,%2016Docker% protocol=tcp
netsh advfirewall firewall add rule name="LDAPS Out TCP" dir=out action=allow enable=no profile=any remoteport=636 protocol=tcp
netsh advfirewall firewall add rule name="A - LDAP GC IN TCP" dir=in action=allow enable=yes profile=any localport=3268 remoteip=%WebMail%,%PAMI%,%2016Docker% protocol=tcp
netsh advfirewall firewall add rule name="A - LDAP GC SSL IN TCP" dir=in action=allow enable=yes profile=any localport=3269 remoteip=%WebMail%,%PAMI%,%2016Docker% protocol=tcp
echo LDAP changes
echo LDAP changes >> output.txt

:: KERBEROS
netsh advfirewall firewall add rule name="A - Kerberos In UDP from Internal" dir=in action=allow enable=yes profile=any localport=88,464 remoteip=%WebMail%,%PAMI%,%2016Docker% protocol=udp
netsh advfirewall firewall add rule name="A - Kerberos In TCP from Internal" dir=in action=allow enable=yes profile=any localport=88,464 remoteip=%WebMail%,%PAMI%,%2016Docker% protocol=tcp
netsh advfirewall firewall set rule group="Kerberos Key Distribution Center (TCP-In)" new enable=yes
netsh advfirewall firewall set rule group="Kerberos Key Distribution Center (UDP-In)" new enable=yes
echo Kerberos changes
echo Kerberos changes >> output.txt

:: DNS 53
netsh advfirewall firewall add rule name="DNS Out UDP" dir=out action=allow enable=yes profile=any remoteport=53 remoteip=%DNSNTP%,8.8.8.8 protocol=udp
netsh advfirewall firewall add rule name="DNS Out TCP" dir=out action=allow enable=yes profile=any remoteport=53 remoteip=%DNSNTP%,8.8.8.8 protocol=tcp
netsh advfirewall firewall add rule name="DNS In TCP" dir=in action=allow enable=yes profile=any localport=53 protocol=tcp remoteip=%UbuntuWkst%,%WebMail%,%Splunk%,%EComm%,%DNSNTP%,%PAMI%,%UbuntuWeb% 
netsh advfirewall firewall add rule name="DNS In UDP from Internal" dir=in action=allow enable=yes profile=any localport=53  protocol=udp remoteip=%UbuntuWkst%,%WebMail%,%Splunk%,%EComm%,%DNSNTP%,%PAMI%,%UbuntuWeb%
netsh advfirewall firewall add rule name="DNS In UDP from ANY" dir=in action=allow enable=no profile=any localport=53  protocol=udp
echo DNS changes
echo DNS changes >> output.txt

:: Replication
netsh advfirewall firewall add rule name="MSRPC IN from Mail, PAN, Docker" dir=in action=allow enable=yes profile=any localport=135 remoteip=%WebMail%,%PAMI%, %2016Docker% protocol=tcp
netsh advfirewall firewall add rule name="Static RPC IN from Mail, PAN, Docker" dir=in action=allow enable=yes profile=any localport=50243,50244,50245 remoteip=%WebMail%,%PAMI%, %2016Docker% protocol=tcp
echo MSRPC changes
echo MSRPC changes >> output.txt

::DHCP
netsh advfirewall firewall add rule name="DHCP in" dir=in action=allow enable=yes profile=any localport=67 remoteip=%UbuntuWkst% protocol=udp
netsh advfirewall firewall add rule name="DHCP out" dir=out action=allow enable=yes profile=any remoteport=68 protocol=udp
echo DHCP changes
echo DHCP changes >> output.txt

:NonServerWindows
:: ##############################
:: # Disabling Windows Features # 
:: ##############################
DISM /online /disable-feature /featurename:"TelnetClient" >NUL
DISM /online /disable-feature /featurename:"TelnetServer" >NUL
DISM /online /disable-feature /featurename:"TFTP" >NUL
echo Disabled telnet and tftp
echo Disabled telnet and tftp >> output.txt

:: ###########################
:: # Disable Teredo and IPv6 #
:: ###########################
netsh interface teredo set state disabled
netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled
netsh interface ipv6 isatap set state state=disabled
echo Disabled teredo and IPv6
echo Disabled teredo and IPv6 >> output.txt

::
:: Windows Sharing/SMB Settings
:: Disable smb1, anonymous access to named pipes/shared, anonymous enumeration of SAM accounts, non-admin remote access to SAM
:: Enable optional SMB client signing
powershell.exe Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol -norestart
:: \/\/ IMPORTANT!!! Fixes Eternal Blue
powershell.exe Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force 
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mrxsmb10" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v RestrictNullSessAccess /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v EveryoneIncludesAnonymous /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictRemoteSAM /t REG_SZ /d "O:BAG:BAD:(A;;RC;;;BA)" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v UseMachineId /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\LSA\MSV1_0" /v allownullsessionfallback /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnableSecuritySignature /t REG_DWORD /d 1 /f
:: Force SMB server signing
:: This could cause impact if the Windows computer this is run on is hosting a file share and the other computers connecting to it do not have SMB client signing enabled.
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 1 /f
echo Secured SMB
echo Secured SMB >> output.txt

::___________________________________________### Section for general firewall configs ###____________________________________________
:Firewall
echo Firewall Commands Running...
echo Firewall Commands Running... >> output.txt
:: Enable Firewall Logging
netsh advfirewall export %ccdcpath%\firewall.old
netsh firewall set notifications ENABLE
netsh advfirewall set allprofiles settings inboundusernotification enable
netsh advfirewall set allprofiles logging filename %ccdcpath%\pfirewall.log
netsh advfirewall set allprofiles logging maxfilesize 8192
netsh advfirewall set allprofiles logging droppedconnections enable
netsh advfirewall set allprofiles logging allowedconnections enable
netsh advfirewall set global statefulftp disable
netsh advfirewall set global statefulpptp disable
echo Firewall logging enabled
echo Firewall logging enabled >> output.txt
echo Changing rules...
echo Changing rules... >> output.txt
netsh advfirewall firewall add rule name="NTP Allow" dir=out action=allow enable=yes profile=any remoteport=123 remoteip=%DNSNTP% protocol=udp

:: Block Win32 binaries from making netconns when they shouldn't - specifically targeting native processes known to be abused by bad actors
netsh advfirewall firewall add rule name="Block Notepad.exe netconns" program="%systemroot%\system32\notepad.exe" protocol=tcp dir=out enable=yes action=block profile=any
netsh advfirewall firewall add rule name="Block regsvr32.exe netconns" program="%systemroot%\system32\regsvr32.exe" protocol=tcp dir=out enable=yes action=block profile=any
netsh advfirewall firewall add rule name="Block calc.exe netconns" program="%systemroot%\system32\calc.exe" protocol=tcp dir=out enable=yes action=block profile=any
netsh advfirewall firewall add rule name="Block mshta.exe netconns" program="%systemroot%\system32\mshta.exe" protocol=tcp dir=out enable=yes action=block profile=any
netsh advfirewall firewall add rule name="Block wscript.exe netconns" program="%systemroot%\system32\wscript.exe" protocol=tcp dir=out enable=yes action=block profile=any
netsh advfirewall firewall add rule name="Block cscript.exe netconns" program="%systemroot%\system32\cscript.exe" protocol=tcp dir=out enable=yes action=block profile=any
netsh advfirewall firewall add rule name="Block runscripthelper.exe netconns" program="%systemroot%\system32\runscripthelper.exe" protocol=tcp dir=out enable=yes action=block profile=any
netsh advfirewall firewall add rule name="Block hh.exe netconns" program="%systemroot%\system32\hh.exe" protocol=tcp dir=out enable=yes action=block profile=any
echo blocked bad netconns
echo blocked bad netconns >> output.txt

:: Disables common rules
netsh advfirewall firewall set rule name="Remote Assistance (DCOM-In)" new enable=no >NUL
netsh advfirewall firewall set rule name="Remote Assistance (PNRP-In)" new enable=no >NUL
netsh advfirewall firewall set rule name="Remote Assistance (RA Server TCP-In)" new enable=no >NUL
netsh advfirewall firewall set rule name="Remote Assistance (SSDP TCP-In)" new enable=no >NUL
netsh advfirewall firewall set rule name="Remote Assistance (SSDP UDP-In)" new enable=no >NUL
netsh advfirewall firewall set rule name="Remote Assistance (TCP-In)" new enable=no >NUL
netsh advfirewall firewall set rule name="Telnet Server" new enable=no >NUL
netsh advfirewall firewall set rule name="netcat" new enable=no >NUL
echo Further secure remote assistance
echo Further secure remote assistance >> output.txt

::Web
netsh advfirewall firewall add rule name="Web in" dir=in action=allow enable=no profile=any localport=80,443 protocol=tcp
echo Web changes
echo Web changes >> output.txt

:end
echo Finished running the script. 
echo Finished running the script. >> output.txt
pause
