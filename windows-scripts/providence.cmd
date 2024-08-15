@echo off
title = "Cedarville Windows Script - 'Providence' "
:: Author - Aaron Campbell for the Cedarville Cyber Team
:: Credits:
::      Mackwage - https://gist.github.com/mackwage/08604751462126599d7e52f233490efe
::      Mike Bailey - https://github.com/mike-bailey/CCDC-Scripts
::      Cedarville's version of Baldwin Wallace's old script - https://github.com/CedarvilleCyber/CCDC/blob/main/CCDC-Collection/Windows/windowsBW.cmd
:: Line 172 "CVE-2020-1350" added 2/16/2024 by Stephen Pearson
:: Firewall default block all added 8/15/2024 by Kaicheng Ye

echo Welcome fellow yellow jacket, lets do this thing. If you're not from CU and stole this from github, I sure hope you know what it does... You may want to increae the powershell buffer size as well.
echo Welcome fellow yellow jacket, lets do this thing. If you're not from CU and stole this from github, I sure hope you know what it does... >> output.txt
:: Checks for admin permissions, errorlevel indicates number of errors
echo Administrative permissions required. Detecting permissions...
echo Administrative permissions required. Detecting permissions... >> output.txt
net session >nul 2>&1
if %errorlevel% == 1 ( 
    echo please rerun as admin.
    goto :end
)

:: Turn on firewall
netsh advfirewall set allprofiles state on
::netsh advfirewall firewall set rule name=all new enable=no
echo Firewall turned on

set /p prestep="Would you like to run the presteps of sfc scannow and dism health checks? May take up to 20 min (recommended yes) [y/n]: "
if "%prestep%" == "y" (
    echo Cleaning up corrupted system files...
    echo Cleaning up corrupted system files... >> output.txt
	sfc /scannow
    echo system files are clean
    echo system files are clean  >> output.txt

    echo Running registry scan, check, and health restoration...
    echo Running registry scan, check, and health restoration... >> output.txt
    DISM /Online /Cleanup-Image /ScanHealth
    DISM /Online /Cleanup-Image /CheckHealth
    DISM /Online /Cleanup-Image /RestoreHealth
    echo Registry is healthy
    echo Registry is healthy >> output.txt
)

echo Making some working directories. see c:\ccdc for more
echo Making some working directories. see c:\ccdc for more >> output.txt
:: Makes some directories for us to work with
set ccdcpath="c:\ccdc"
mkdir %ccdcpath% >NUL
icacls %ccdcpath% /inheritancelevel:e >NUL
mkdir %ccdcpath%\ThreatHunting >NUL
mkdir %ccdcpath%\Config >NUL
mkdir %ccdcpath%\Regback >NUL
mkdir %ccdcpath%\Proof >NUL

echo Saving old configs
echo Saving old configs >> output.txt
echo for normal usage answer yes to any following prompts.
:: Export Hosts
copy %systemroot%\system32\drivers\etc\hosts %ccdcpath%\hosts
:: Export Users
wmic useraccount list brief > %ccdcpath%\Config\Users.txt
:: Export Groups
wmic group list brief > %ccdcpath%\Config\Groups.txt
:: Export Scheduled tasks
schtasks > %ccdcpath%\ThreatHunting\ScheduledTasks.txt
:: Export Services
sc query > %ccdcpath%\ThreatHunting\Services.txt
:: Export Session
query user > %ccdcpath%\ThreatHunting\UserSessions.txt
:: Export registry
reg export HKLM %ccdcpath%\Regback\hlkm.reg
reg export HKCU %ccdcpath%\Regback\hkcu.reg
reg export HKCR %ccdcpath%\Regback\hlcr.reg
reg export HKU %ccdcpath%\Regback\hlku.reg
reg export HKCC %ccdcpath%\Regback\hlcc.reg

set /p box="If you are running this on 2012AD enter any key. Otherwise for general windows use enter 'W': "
if "%box%" == "W" (
	GOTO :GeneralWindows
) else (
    set box="2012ad"
)
echo the following prompts only matter on the 2012AD computer
echo the following prompts only matter on the 2012AD computer >> output.txt
set /p Dname="[ What is the Domain Name in DOMAIN.COM format? This is only for the logon banner ]:   "
set /p EComm="ENTER EComm IP: "
set /p DNSNTP="ENTER DNS/NTP 10 IP: "
set /p WebMail="ENTER WEBMAIL IP: "
set /p Splunk="ENTER SPLUNK IP: "
set /p ADDNS="ENTER AD/DNS IP: "
set /p Windows10="ENTER WINDOWS 10 IP: "
set /p UbuntuWkst="ENTER UBUNTU WKST IP: "
set /p PAMI="ENTER PaloAlto IP: "
set /p 2016Docker="ENTER 2016 Server IP: "
set /p UbuntuWeb="ENTER UbuntuWeb IP: "
echo IPs set, this is only for a few AD specific firewall rules so you can go into those and change if needed otherwise now is your only time to ctrl+c and cancel...
echo IPs set, this is only for a few AD specific firewall rules so you can go into those and change if needed otherwise now is your only time to ctrl+c and cancel... >> output.txt
pause
echo Let us begin :)
echo Let us begin :) >> output.txt

:: ### Section for 2012 Active Directory specific commands ###
:2012adSpecific
echo 2012AD Commands running... 
echo 2012AD Commands running... >> output.txt
:: Port assignments for certain services
REG add "HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" /v "TCP/IP Port" /t REG_DWORD /d 50243 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "DCTcpipPort" /t REG_DWORD /d 50244 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Services\NTFRS\Parameters" /v "RPC TCP/IP Port Assignment" /t REG_DWORD /d 50245 /f
:: Logon Banner text settings \/
REG add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption /t REG_SZ /d "* * * * * * * * * * W A R N I N G * * * * * * * * * *"
REG add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext /t REG_SZ /d "This computer system/network is the property of %Dname%. It is for authorized use only. By using this system, all users acknowledge notice of, and agree to comply with, the Company’s Acceptable Use of Information Technology Resources Policy (“AUP”). Users have no personal privacy rights in any materials they place, view, access, or transmit on this system. The Company complies with state and federal law regarding certain legally protected confidential information, but makes no representation that any uses of this system will be private or confidential. Any or all uses of this system and all files on this system may be intercepted, monitored, recorded, copied, audited, inspected, and disclosed to authorized Company and law enforcement personnel, as well as authorized individuals of other organizations. By using this system, the user consents to such interception, monitoring, recording, copying, auditing, inspection, and disclosure at the discretion of authorized Company personnel. Unauthorized or improper use of this system may result in administrative disciplinary action, civil charges/criminal penalties, and/or other sanctions as set forth in the Company’s AUP. By continuing to use this system you indicate your awareness of and consent to these terms and conditions of use. ALL USERS SHALL LOG OFF OF A %Dname% OWNED SYSTEM IMMEDIATELY IF SAID USER DOES NOT AGREE TO THE CONDITIONS STATED ABOVE."
echo Logon Banner Set
echo Logon Banner Set >> output.txt

echo Running AD Specific firewall rules
echo Running AD Specific firewall rules >> output.txt
:: \/\/ IMPORTANT!! If your service go down after running this script look here first. Could be one of these rules, I couldn't really test the changes
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
:: Clean DNS cache and hosts file
echo Cleaning out the DNS cache...
echo Cleaning out the DNS cache... >> output.txt
ipconfig /flushdns
echo Writing over the hosts file...
attrib -r -s C:\WINDOWS\system32\drivers\etc\hosts
echo > C:\Windows\System32\drivers\etc\hosts
:: Patching CVE-2020-1350
echo Patching CVE-2020-1350
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DNS\Parameters" /v TcpReceivePacketSize /t REG_DWORD /d 65280 /f
net stop dns && net start dns
:: Services
echo Showing you the currently running services...
echo Showing you the currently running services... >> output.txt
net start
echo Now writing services to a file and searching for vulnerable services...
echo Now writing services to a file and searching for vulnerable services... >> output.txt 
net start > current_services.txt
echo This is only common services, not nessecarily going to catch 100%
:: looks to see if remote registry is on
net start | findstr Remote Registry
if %errorlevel%==0 (
	echo Remote Registry is running!
	echo Attempting to stop...
    echo Remote Registry is running! Attempting to stop >> output.txt
	net stop RemoteRegistry
	sc config RemoteRegistry start=disabled
	if %errorlevel%==1 (
        echo Stop failed... 
        echo Stop failed... >> output.txt
    )
) else ( 
	echo Remote Registry is already indicating stopped.
    echo Remote Registry is already indicating stopped. >> output.txt
)
::
:: Remove all saved credentials
cmdkey.exe /list > "%TEMP%\List.txt"
findstr.exe Target "%TEMP%\List.txt" > "%TEMP%\tokensonly.txt"
FOR /F "tokens=1,2 delims= " %%G IN (%TEMP%\tokensonly.txt) DO cmdkey.exe /delete:%%H
del "%TEMP%\*.*" /s /f /q
echo Removed saved credentials
echo Removed saved credentials >> output.txt
::
:: Guest Account is deactivating
net user Guest | findstr Active | findstr Yes
if %errorlevel%==0 (
    echo Guest account is active, deactivating
    echo Guest account is active, deactivating >> output.txt
)
if %errorlevel%==1 (
    echo Guest account is not active, checking default admin account
    echo Guest account is not active, checking default admin account >> output.txt
)
net user Guest /active:NO
echo Attempted to disable guest, double check yourself
echo Attempted to disable guest, double check yourself >> output.txt

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

:: #########################################################################
:: # Change file associations to protect against common ransomware attacks #
:: #########################################################################
:: Note that if you legitimately use these extensions, like .bat, you will now need to execute them manually from cmd or powershell
:: Alternatively, you can right-click on them and hit 'Run as Administrator' but ensure it's a script you want to run :) 
:: https://support.microsoft.com/en-us/help/883260/information-about-the-attachment-manager-in-microsoft-windows
ftype htafile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype wshfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype wsffile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype batfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype jsfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype jsefile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype vbefile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
ftype vbsfile="%SystemRoot%\system32\NOTEPAD.EXE" "%1"
echo Ransomware protections on
echo Ransomware protections on >> output.txt

::##########################################################
::# Enable and Configure General Windows Security Settings #
::##########################################################
echo Enabling general security settings...
echo Enabling general security settings... >> output.txt
echo Disable DNS multicast, smart mutli-homed resolution, netbios, printer driver download and printing over http, icmp redirect
echo Enable UAC and sets to always notify, Safe DLL loading (DLL Hijacking prevention), saving zone information, explorer DEP, explorer shell protocol protected mode
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v DisableSmartNameResolution /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v DisableParallelAandAAAA /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v IGMPLevel /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 2 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableVirtualization /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v SafeDLLSearchMode /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v ProtectionMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v SaveZoneInformation /t REG_DWORD /d 2 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoDataExecutionPrevention /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoHeapTerminationOnCorruption /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v PreXPSP2ShellProtocolBehavior /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v DisableWebPnPDownload /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v DisableHTTPPrinting /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" /v AutoConnectAllowedOEM /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" /v fMinimizeConnections /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netbt\Parameters" /v NoNameReleaseOnDemand /t REG_DWORD /d 1 /f
wmic /interactive:off nicconfig where (TcpipNetbiosOptions=0 OR TcpipNetbiosOptions=1) call SetTcpipNetbios 2
::
:: Turns off RDP
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
echo Turned off rdp
echo Turned off rdp >> output.txt
:: Windows automatic updates
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 3 /f
::
:: Prioritize ECC Curves with longer keys
::reg add "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002" /v EccCurves /t REG_MULTI_SZ /d NistP384,NistP256 /f
:: Prevent Kerberos from using DES or RC4
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" /v SupportedEncryptionTypes /t REG_DWORD /d 2147483640 /f
:: Encrypt and sign outgoing secure channel traffic when possible
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SealSecureChannel /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SignSecureChannel /t REG_DWORD /d 1 /f
::
:: Enable SmartScreen
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v ShellSmartScreenLevel /t REG_SZ /d Block /f
::
:: Enforce device driver signing
BCDEDIT /set nointegritychecks OFF
::
:: Windows Update Settings
:: Prevent Delivery Optimization from downloading Updates from other computers across the internet
:: 1 will restrict to LAN only. 0 will disable the feature entirely
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config\" /v DODownloadMode /t REG_DWORD /d 1 /f
::
:: Set screen saver inactivity timeout to 15 minutes
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d 900 /f
:: Enable password prompt on sleep resume while plugged in and on battery
reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" /v ACSettingIndex /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" /v DCSettingIndex /t REG_DWORD /d 1 /f
::
:: Windows Remote Access Settings
:: Disable solicited remote assistance
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
:: Require encrypted RPC connections to Remote Desktop
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEncryptRPCTraffic /t REG_DWORD /d 1 /f
:: Prevent sharing of local drives via Remote Desktop Session Hosts
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fDisableCdm /t REG_DWORD /d 1 /f
echo Secured remote access
echo Secured remote access >> output.txt
:: 
:: Removal Media Settings
:: Disable autorun/autoplay on all drives
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoAutorun /t REG_DWORD /d 1 /f
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
::
:: Harden lsass to help protect against credential dumping (mimikatz) and audit lsass access requests
:: Configures lsass.exe as a protected process and disables wdigest
:: Enables delegation of non-exported credentials which enables support for Restricted Admin Mode or Remote Credential Guard
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 00000001 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" /v AllowProtectedCreds /t REG_DWORD /d 1 /f
::
:: Windows RPC and WinRM settings
:: Stop WinRM
net stop WinRM
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" /v AllowUnencryptedTraffic /t REG_DWORD /d 0 /f
:: Disable WinRM Client Digiest authentication
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" /v AllowDigest /t REG_DWORD /d 0 /f
:: Disabling RPC usage from a remote asset interacting with scheduled tasks
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Schedule" /v DisableRpcOverTcp /t REG_DWORD /d 1 /f
:: Disabling RPC usage from a remote asset interacting with services
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v DisableRemoteScmEndpoints /t REG_DWORD /d 1 /f
echo secured Win RPC and WinRM
echo secured Win RPC and WinRM >> output.txt
:: Common Policies
:: Restrict CD ROM drive
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateCDRoms /t REG_DWORD /d 1 /f
:: Automatic Admin logon
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_DWORD /d 0 /f
:: Wipe page file from shutdown
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f
:: Disallow remote access to floppie disks
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateFloppies /t REG_DWORD /d 1 /f
:: Prevent print driver installs 
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v AddPrinterDrivers /t REG_DWORD /d 1 /f
:: Limit local account use of blank passwords to console
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
:: Auditing access of Global System Objects
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v auditbaseobjects /t REG_DWORD /d 1 /f
:: Auditing Backup and Restore
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v fullprivilegeauditing /t REG_DWORD /d 1 /f
:: Do not display last user on logon
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 1 /f
:: UAC setting (Prompt on Secure Desktop)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
:: Enable Installer Detection
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableInstallerDetection /t REG_DWORD /d 1 /f
:: Undock without logon
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v undockwithoutlogon /t REG_DWORD /d 0 /f
:: Maximum Machine Password Age
reg add "HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" /v MaximumPasswordAge /t REG_DWORD /d 15 /f
:: Disable machine account password changes
reg add "HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" /v DisablePasswordChange /t REG_DWORD /d 1 /f
:: Require Strong Session Key
reg add "HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" /v RequireStrongKey /t REG_DWORD /d 1 /f
:: Require Sign/Seal
reg add "HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" /v RequireSignOrSeal /t REG_DWORD /d 1 /f
:: Sign Channel
reg add "HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" /v SignSecureChannel /t REG_DWORD /d 1 /f
:: Seal Channel
reg add "HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters" /v SealSecureChannel /t REG_DWORD /d 1 /f
:: Restrict Anonymous Enumeration #1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymous /t REG_DWORD /d 1 /f 
:: Restrict Anonymous Enumeration #2
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymoussam /t REG_DWORD /d 1 /f 
:: Require Security Signature - Disabled pursuant to checklist
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v enablesecuritysignature /t REG_DWORD /d 0 /f 
:: Enable Security Signature - Disabled pursuant to checklist
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v requiresecuritysignature /t REG_DWORD /d 0 /f 
:: Disable Domain Credential Storage
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v disabledomaincreds /t REG_DWORD /d 1 /f 
:: Don't Give Anons Everyone Permissions
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v everyoneincludesanonymous /t REG_DWORD /d 0 /f 
:: SMB Passwords unencrypted to third party? How bout nah
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters" /v EnablePlainTextPassword /t REG_DWORD /d 0 /f
:: Null Session Pipes Cleared
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v NullSessionPipes /t REG_MULTI_SZ /d "" /f
:: Remotely accessible registry paths cleared
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths" /v Machine /t REG_MULTI_SZ /d "" /f
:: Remotely accessible registry paths and sub-paths cleared
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedPaths" /v Machine /t REG_MULTI_SZ /d "" /f
:: Restict anonymous access to named pipes and shares
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /d "" /f
:: Allow to use Machine ID for NTLM
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v UseMachineId /t REG_DWORD /d 0 /f
echo Tons of smaller fixes done, check code for more info
echo Tons of smaller fixes done, check code for more info >> output.txt
::
:: Internet Explorer
:: Smart Screen for IE8
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV8 /t REG_DWORD /d 1 /f
:: Smart Screen for IE9+
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f
:: Windows Explorer Settings
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSuperHidden /t REG_DWORD /d 1 /f
:: Disable Dump file creation
reg "add HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 0 /f
:: Disable Autorun
reg add "HKCU\SYSTEM\CurrentControlSet\Services\CDROM" /v AutoRun /t REG_DWORD /d 1 /f
:: Disabled Internet Explorer Password Caching
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v DisablePasswordCaching /t REG_DWORD /d 1 /f 
:: Enable Do Not Track
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v DoNotTrack /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Download" /v RunInvalidSignatures /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings" /v LOCALMACHINE_CD_UNLOCK /t REG_DWORD /d 1 /t
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonBadCertRecving /t REG_DWORD /d /1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnPostRedirect /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonZoneCrossing /t REG_DWORD /d 1 /f
echo Secured IE
echo Secured IE >> output.txt
::
:: Windows Updates
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\WindowsUpdate" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\Internet Communication Management\Internet Communication" /v DisableWindowsUpdateAccess /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoWindowsUpdate /t REG_DWORD /d 0 /f
echo Attempt to fix win update
echo Attempt to fix win update >> output.txt
::
:: Delete the image hijack that kills taskmanager
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /f /v Debugger
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /f
echo Secure taskmanager
echo Secure taskmanager >> output.txt
::
:: Fix Local Security Authority(LSA)
:: Restrict anonymous
reg add "HKLM\SYSTEM\CurrentControlSet\Control\LSA" /v restrictanonymous /t REG_DWORD /d 1 /f
:: Restrict anonymoussam
reg add "HKLM\SYSTEM\CurrentControlSet\Control\LSA" /v restrictanonymoussam /t REG_DWORD /d 1 /f
:: Change everyone includes anonymous
reg add "HKLM\SYSTEM\CurrentControlSet\Control\LSA" /v everyoneincludesanonymous /t REG_DWORD /d 0 /f
:: Turn off Local Machine Hash
reg add "HKLM\SYSTEM\CurrentControlSet\Control\LSA" /v NoLMHash /t REG_DWORD /d 1 /f
:: delete use machine id
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\LSA" /v UseMachineID /f
:: Change notification packages
reg add "HKLM\SYSTEM\CurrentControlSet\Control\LSA" /v "Notification Packages" /t REG_MULTI_SZ /d "scecli" /f
:: Show hidden users in gui
reg delete "HKLM\Software\Microsoft\WindowsNT\CurrentVersion\Winlogon\SpecialAccounts" /f
:: Disable possible backdoors
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\utilman.exe" /v "Debugger" /t REG_SZ /d "systray.exe" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\osk.exe" /v Debugger /t REG_SZ /d "systray.exe" /f
echo Fix LSA and Backdoors
echo Fix LSA and Backdoors >> output.txt

:: ###################################
:: # Enable Advanced Windows Logging #
:: ###################################
:: Enlarge Windows Event Security Log Size
echo Attempting to configure logging and audit rules, please double check the security policies yourself
echo Attempting to configure logging and audit rules, please double check the security policies yourself >> output.txt
wevtutil sl Security /ms:1024000
wevtutil sl Application /ms:1024000
wevtutil sl System /ms:1024000
wevtutil sl "Windows Powershell" /ms:1024000
wevtutil sl "Microsoft-Windows-PowerShell/Operational" /ms:1024000
:: Record command line data in process creation events eventid 4688
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f
::
:: Enabled Advanced Settings
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f
:: Enable PowerShell Logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
::
:: Enable Windows Event Detailed Logging
:: This is intentionally meant to be a subset of expected enterprise logging as this script may be used on consumer devices.
:: For more extensive Windows logging, I recommend https://www.malwarearchaeology.com/cheat-sheets
Auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable
Auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
Auditpol /set /subcategory:"Logoff" /success:enable /failure:disable
Auditpol /set /subcategory:"Logon" /success:enable /failure:enable 
Auditpol /set /subcategory:"Filtering Platform Connection" /success:enable /failure:disable
Auditpol /set /subcategory:"Removable Storage" /success:enable /failure:enable
Auditpol /set /subcategory:"SAM" /success:disable /failure:disable
Auditpol /set /subcategory:"Filtering Platform Policy Change" /success:disable /failure:disable
Auditpol /set /subcategory:"IPsec Driver" /success:enable /failure:enable
Auditpol /set /subcategory:"Security State Change" /success:enable /failure:enable
Auditpol /set /subcategory:"Security System Extension" /success:enable /failure:enable
Auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable

:: account password policy set
echo Attempting to set password policies, please double check the account policies yourself
echo Attempting to set password policies, please double check the account policies yourself >> output.txt
echo New requirements are being set for your passwords
net accounts /FORCELOGOFF:30 /MINPWLEN:8 /MAXPWAGE:30 /MINPWAGE:10 /UNIQUEPW:3
echo New password policy:
echo Force log off after 30 minutes
echo Minimum password length of 8 characters
echo Maximum password age of 30
echo Minimum password age of 10
echo Unique password threshold set to 3 (default is 5)

:: Delete system tasks
schtasks /Delete /TN *


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

:: Block everything else
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

::Web
netsh advfirewall firewall add rule name="Web in" dir=in action=allow enable=no profile=any localport=80,443 protocol=tcp
echo Web changes
echo Web changes >> output.txt

:: See other AD specific firewall rules in 2012AD section...


::_____________________________________________ ### Section for dangerous commands ### __________________________________________
:: If something broke and its not a firewall issue it could be one of these commands
:Danger
echo Running dangerous commands, but don't worry, it'll be okay (maybe), I promise (hopefully), trust me (actually)
echo Running dangerous commands >> output.txt
:: Enforce NTLMv2 and LM authentication
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 5 /f

:: Prevent unencrypted passwords being sent to third-party SMB servers
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnablePlainTextPassword /t REG_DWORD /d 0 /f

:: Prevent guest logons to SMB servers
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" /v AllowInsecureGuestAuth /t REG_DWORD /d 0 /f

:: Force SMB server signing
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 1 /f

:: Restrict privileged local admin tokens being used from network 
:: Commented out as it only works on domain-joined assets
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 0 /f

:: Ensure outgoing secure channel traffic is encrytped
:: Commented out as it only works on domain-joined assets
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v RequireSignOrSeal /t REG_DWORD /d 1 /f

:: Enforce LDAP client signing
:: Commented out as most consumers don't use LDAP auth
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LDAP" /v LDAPClientIntegrity /t REG_DWORD /d 1 /f

:: Prevent unauthenticated RPC connections
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" /v RestrictRemoteClients /t REG_DWORD /d 1 /f
echo Danger completed
echo Danger completed >> output.txt

echo Please reboot when convinent to apply some changes.
echo Please reboot when convinent to apply some changes. >> output.txt
:end
echo Done!
echo Done! >> output.txt
pause
cmd /k
