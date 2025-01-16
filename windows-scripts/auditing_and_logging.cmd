@echo off

echo Section: Audit and Log
echo Section: Audit and Log >> output.txt
:: Checks for admin permissions, errorlevel indicates number of errors
echo Administrative permissions required. Detecting permissions...
echo Administrative permissions required. Detecting permissions... >> output.txt
net session >nul 2>&1
if %errorlevel% == 1 ( 
    echo please rerun as admin.
    goto :end
)

:: Logon Banner text settings \/
REG add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption /t REG_SZ /d "* * * * * * * * * * W A R N I N G * * * * * * * * * *"
echo Logon Banner Set
echo Logon Banner Set >> output.txt

:: Patching CVE-2020-1350
echo Patching CVE-2020-1350
:: Harden lsass to help protect against credential dumping (mimikatz) and audit lsass access requests
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 00000001 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateCDRoms /t REG_DWORD /d 1 /f
:: Automatic Admin logon
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_DWORD /d 0 /f
:: Wipe page file from shutdown
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f
:: Disallow remote access to floppie disks
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AllocateFloppies /t REG_DWORD /d 1 /f
:: Auditing access of Global System Objects
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v auditbaseobjects /t REG_DWORD /d 1 /f
:: Auditing Backup and Restore
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v fullprivilegeauditing /t REG_DWORD /d 1 /f
:: Undock without logon
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v undockwithoutlogon /t REG_DWORD /d 0 /f
:: Maximum Machine Password Age
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts" /f
:: This is intentionally meant to be a subset of expected enterprise logging as this script may be used on consumer devices.
:: For more extensive Windows logging, I recommend https://www.malwarearchaeology.com/cheat-sheets
net accounts /FORCELOGOFF:30 /MINPWLEN:8 /MAXPWAGE:30 /MINPWAGE:10 /UNIQUEPW:3
echo Force log off after 30 minutes
echo Minimum password length of 8 characters
echo Maximum password age of 30
echo Minimum password age of 10
echo Unique password threshold set to 3 (default is 5)

:: Delete system tasks
schtasks /Delete /TN *


:: Prevent guest logons to SMB servers
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" /v AllowInsecureGuestAuth /t REG_DWORD /d 0 /f

:: Force SMB server signing
:: This is commented out by default as it could impact access to consumer-grade file shares but it's a recommended setting

:end
echo Audit and Log Script: Done
echo Audit and Log Script: Done: Done >> output.txt
pause