@echo off

echo Section: Network Hardening
echo Section: Network Hardening >> output.txt
:: Checks for admin permissions, errorlevel indicates number of errors
echo Administrative permissions required. Detecting permissions...
echo Administrative permissions required. Detecting permissions... >> output.txt
net session >nul 2>&1
if %errorlevel% == 1 ( 
    echo please rerun as admin.
    goto :end
)

echo Making directories as needed see c:\ccdc for more
echo Making directories as needed see c:\ccdc for more >> output.txt
:: Makes some directories for us to work with
set ccdcpath="c:\ccdc"
mkdir %ccdcpath% >NUL
icacls %ccdcpath% /inheritancelevel:e >NUL



:: Turn on firewall
netsh advfirewall set allprofiles state on
::netsh advfirewall firewall set rule name=all new enable=no
echo Firewall turned on

:: ### Section for 2012 Active Directory specific commands ###
:2012adSpecific
echo 2012AD Commands running... 
echo 2012AD Commands running... >> output.txt
echo Running AD Specific firewall rules
echo Running AD Specific firewall rules >> output.txt
netsh advfirewall firewall add rule name="DNS Out to Any" dir=out action=allow enable=no profile=any remoteport=53 protocol=udp
netsh advfirewall firewall add rule name="Splunk OUT" dir=out action=allow enable=yes profile=any remoteip=%Splunk% remoteport=8000,8089,9997 protocol=tcp
netsh advfirewall firewall add rule name="Allow Pings" protocol=icmpv4:8,any dir=in action=allow enable=yes
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

::_____________________________________________### Section for general windows hardening commands ###__________________________________________
:GeneralWindows
echo General Windows Commands running...
echo General Windows Commands running... >> output.txt
if "%DNSNTP%"=="" (
	set /p DNSNTP=ENTER DNS/NTP 10 IP:
)
:: Clean DNS cache and hosts file
echo Cleaning out the DNS cache...
echo Cleaning out the DNS cache... >> output.txt
ipconfig /flushdns
echo Writing over the hosts file...
attrib -r -s C:\WINDOWS\system32\drivers\etc\hosts
echo > C:\Windows\System32\drivers\etc\hosts

REG add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext /t REG_SZ /d "Warning: Only authorized users are permitted to login. All network activity is being monitored and logged, and may be used to investigate and prosecute any instance of unauthorized access."
netsh interface teredo set state disabled
netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled
netsh interface ipv6 isatap set state state=disabled
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v AutoConnectAllowedOEM /t REG_DWORD /d 0 /f
::___________________________________________### Section for general firewall configs ###____________________________________________
:Firewall
echo Firewall Commands Running...
echo Firewall Commands Running... >> output.txt
:: Enable Firewall Logging
netsh advfirewall export %ccdcpath%\firewall.old
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

:: Block everything else
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound

netsh advfirewall firewall add rule name="Web in" dir=in action=allow enable=yes profile=any localport=80,443 protocol=tcp
netsh advfirewall firewall add rule name="Web out" dir=out action=allow enable=yes profile=any localport=80,443 protocol=tcp
:: See other AD specific firewall rules in 2012AD section...


::_____________________________________________ ### Section for dangerous commands ### __________________________________________
:: If something broke and its not a firewall issue it could be one of these commands
:Danger
echo Running dangerous commands >> output.txt
:: Enforce NTLMv2 and LM authentication
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 5 /f

:: Prevent unencrypted passwords being sent to third-party SMB servers
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting
:: Restrict privileged local admin tokens being used from network 
:: Commented out as it only works on domain-joined assets

:end
echo Network Hardening: Done
echo Network Hardening: Done >> output.txt
pause