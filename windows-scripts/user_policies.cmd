@echo off

echo Section: User Policy
echo Section: User Policy >> output.txt
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
mkdir %ccdcpath%\Config >NUL
mkdir %ccdcpath%\Regback >NUL


:: Export Users
wmic useraccount list brief > %ccdcpath%\Config\Users.txt
:: Export Groups
wmic group list brief > %ccdcpath%\Config\Groups.txt
:: Export Scheduled tasks
schtasks > %ccdcpath%\ThreatHunting\ScheduledTasks.txt
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
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" /v fMinimizeConnections /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
echo Turned off rdp
echo Turned off rdp >> output.txt
:: Do not display last user on logon
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 1 /f
:: UAC setting (Prompt on Secure Desktop)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
:: Show hidden users in gui
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f
Auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable
Auditpol /set /subcategory:"Filtering Platform Policy Change" /success:disable /failure:disable
:: account password policy set
echo Attempting to set password policies, please double check the account policies yourself
echo Attempting to set password policies, please double check the account policies yourself >> output.txt
echo New requirements are being set for your passwords
echo New password policy:
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 0 /f

:: Ensure outgoing secure channel traffic is encrytped
:: Commented out as it only works on domain-joined assets

:end
echo User Policy Script: Done
echo User Policy Script: Done >> output.txt
pause