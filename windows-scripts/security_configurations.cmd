@echo off

echo Section: Security Config
echo Section: Security Config >> output.txt
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
mkdir %ccdcpath%\ThreatHunting >NUL




:: Export Services
sc query > %ccdcpath%\ThreatHunting\Services.txt
:: Export Session
:: Port assignments for certain services
REG add "HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" /v "TCP/IP Port" /t REG_DWORD /d 50243 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v "DCTcpipPort" /t REG_DWORD /d 50244 /f
REG add "HKLM\SYSTEM\CurrentControlSet\Services\NTFRS\Parameters" /v "RPC TCP/IP Port Assignment" /t REG_DWORD /d 50245 /f

:: \/\/ IMPORTANT!! If your service go down after running this script look here first. Could be one of these rules, I couldn't really test the changes
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DNS\Parameters" /v TcpReceivePacketSize /t REG_DWORD /d 65280 /f
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
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netbt\Parameters" /v NoNameReleaseOnDemand /t REG_DWORD /d 1 /f
wmic /interactive:off nicconfig where (TcpipNetbiosOptions=0 OR TcpipNetbiosOptions=1) call SetTcpipNetbios 2
::
:: Turns off RDP
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SealSecureChannel /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SignSecureChannel /t REG_DWORD /d 1 /f
::
:: Enable SmartScreen
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v ShellSmartScreenLevel /t REG_SZ /d Warn /f
::
:: Enforce device driver signing
BCDEDIT /set nointegritychecks OFF
::
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
:: Configures lsass.exe as a protected process and disables wdigest
:: Enables delegation of non-exported credentials which enables support for Restricted Admin Mode or Remote Credential Guard
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
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /v AddPrinterDrivers /t REG_DWORD /d 1 /f
:: Limit local account use of blank passwords to console
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
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
:: Stop and disable the print spooler
net stop spooler
sc config spooler start=disabled

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
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 0 /f
:: Disable Autorun
reg add "HKCU\SYSTEM\CurrentControlSet\Services\CDROM" /v AutoRun /t REG_DWORD /d 1 /f
:: Disabled Internet Explorer Password Caching
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v DisablePasswordCaching /t REG_DWORD /d 1 /f 
:: Enable Do Not Track
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v DoNotTrack /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Download" /v RunInvalidSignatures /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings" /v LOCALMACHINE_CD_UNLOCK /t REG_DWORD /d 1 /t
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonBadCertRecving /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnPostRedirect /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonZoneCrossing /t REG_DWORD /d 1 /f
echo Secured IE
echo Secured IE >> output.txt
::
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
:: Enable PowerShell Logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
::
:: Enable Windows Event Detailed Logging
Auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
Auditpol /set /subcategory:"Logoff" /success:enable /failure:disable
Auditpol /set /subcategory:"Logon" /success:enable /failure:enable 
Auditpol /set /subcategory:"Filtering Platform Connection" /success:enable /failure:disable
Auditpol /set /subcategory:"Removable Storage" /success:enable /failure:enable
Auditpol /set /subcategory:"SAM" /success:disable /failure:disable
Auditpol /set /subcategory:"IPsec Driver" /success:enable /failure:enable
Auditpol /set /subcategory:"Security State Change" /success:enable /failure:enable
Auditpol /set /subcategory:"Security System Extension" /success:enable /failure:enable
Auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable

:: Disables common rules
::Enable Web Traffic on ports 443 and 80
echo Enabled Web Traffic on Ports 80 and 443
echo Web changes >> output.txt

reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v EnablePlainTextPassword /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 1 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v RequireSignOrSeal /t REG_DWORD /d 1 /f

:: Enforce LDAP client signing
:: Commented out as most consumers don't use LDAP auth
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LDAP" /v LDAPClientIntegrity /t REG_DWORD /d 1 /f

:: Prevent unauthenticated RPC connections
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" /v RestrictRemoteClients /t REG_DWORD /d 1 /f
echo Danger completed >> output.txt

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

:end
echo Security Config: Done
echo Security Config: Done >> output.txt
pause