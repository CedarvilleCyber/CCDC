@echo off
REM Master script to run all hardening sections
title = "Cedarville Windows Script - 'Providence' "
:: Author - Aaron Campbell for the Cedarville Cyber Team
:: Credits:
::      Mackwage - https://gist.github.com/mackwage/08604751462126599d7e52f233490efe
::      Mike Bailey - https://github.com/mike-bailey/CCDC-Scripts
::      Cedarville's version of Baldwin Wallace's old script - https://github.com/CedarvilleCyber/CCDC/blob/main/CCDC-Collection/Windows/windowsBW.cmd
:: Line 172 "CVE-2020-1350" added 2/16/2024 by Stephen Pearson
:: Firewall default block all added 8/15/2024 by Kaicheng Ye
:: The following was added on 1/2/2025 by Stephen Pearson:
::      Line 292: Changed SmartScreen level to "Warn" from "Block"
::      Line 429: Stopped and disabled the print spooler
::      Line 596: Removed "blockoutbound" to restore Internet access
::      Line 600: Enabled web traffic requests in and out via "Web" firewall rules
::      Line 162: Removed "net stop dns && net start dns" due to outdated command
::      Line 572: Checked for the DNSNTP IP address for General Windows Hardening
::      Moved the logon banner to the general Windows hardening portion

:: These all need to be moved

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
echo IPs set, this is only for a few AD specific firewall rules so you can go into those and change if needed otherwise now is your only time to ctrl+c and cancel...
echo IPs set, this is only for a few AD specific firewall rules so you can go into those and change if needed otherwise now is your only time to ctrl+c and cancel... >> output.txt
pause
echo Let us begin :)
echo Let us begin :) >> output.txt

:: Call seprate scripts
call network_hardening.cmd
call user_policies.cmd
call software_updates.cmd
call security_configurations.cmd
call auditing_and_logging.cmd

echo All sections executed successfully.
echo All sections executed successfully. >> output.txt
echo Please reboot when convinent to apply some changes.
echo Please reboot when convinent to apply some changes. >> output.txt

:end
echo Done!
echo Done! >> output.txt
pause
cmd /k