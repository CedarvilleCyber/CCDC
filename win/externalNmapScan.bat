@echo off

:: REQUIRES: nmap downloaded, firewall exception for Windows 10
:: Info Needed for Inject: Service, Protocol, Port Number, Analysis: Expected or Needed, Mitigation Plan, and Evidence (nmapEvidence Text File)
:: Output of Script: Service, Protocol, Port Number, Evidence (stored in nmapEvidence.txt)

:: Date: 1/26/23

TITLE "Nmap Scan Tool"
:: 1. create a new text file to store the desired inject information:
type nul > nmapEvidence.txt

echo Welcome to the Nmap Scan Tool...
echo.
echo All Scan results will be stored in "nmapEvidence.txt"
echo.
:: 2. ask user for each IP one at a time

:GETIP
echo Finding Targets...
echo.
set /p TeamNumber="ENTER Team Number (or 'TEST' or 'CUSTOM'): "

:: For Testing Purposes...
if "%TeamNumber%"=="TEST" goto QUIKIP

if %TeamNumber%=="CUSTOM" goto CUSTOMIP
if %TeamNumber% < 10 goto TEAMLESSTHAN10
if %TeamNumber% >= 10 goto TEAMMORETHAN10

echo Please enter a valid Team Number or 'CUSTOM'...
echo.
goto GETIP

:QUIKIP
:: For Testing Purposes
 set EComm="scanme.nmap.org"
 set DNSNTP="scanme.nmap.org"
 set WebMail="scanme.nmap.org"
 set Splunk="scanme.nmap.org"
 set ADDNS="scanme.nmap.org"
 set Docker2016="scanme.nmap.org"
 set UbuntuWeb="scanme.nmap.org"
 set /p UbuntuWkst="ENTER UbuntuWkst External IP (or type 'SKIP'): "
goto SCANTYPE

:TEAMLESSTHAN10
 set EComm="172.25.2$team.11"
 set DNSNTP="172.25.2$team.20"
 set WebMail="172.25.2$team.39"
 set Splunk="172.25.2$team.9"
 set ADDNS="172.25.2$team.27"
 set Docker2016="172.25.2$team.97"
 set UbuntuWeb="172.25.2$team.23"
 set /p UbuntuWkst="ENTER UbuntuWkst External IP (or type 'SKIP'): "
goto SCANTYPE

:TEAMMORETHAN10
 set EComm="172.25.3$team.11"
 set DNSNTP="172.25.3$team.20"
 set WebMail="172.25.3$team.39"
 set Splunk="172.25.3$team.9"
 set ADDNS="172.25.3$team.27"
 set Docker2016="172.25.3$team.97"
 set UbuntuWeb="172.25.3$team.23"
 set /p UbuntuWkst="ENTER UbuntuWkst External IP (or type 'SKIP'): "
goto SCANTYPE

:CUSTOMIP
 set /p EComm="ENTER EComm External IP: " YES
 set /p DNSNTP="ENTER DNS/NTP 10 External IP: "
 set /p WebMail="ENTER WEBMAIL External IP: "
 set /p Splunk="ENTER SPLUNK External IP: "
 set /p ADDNS="ENTER AD/DNS External IP: "
 set /p UbuntuWkst="ENTER UBUNTU WKST External IP: "
 set /p 2016Docker="ENTER 2016 Server External IP: "
 set /p UbuntuWeb="ENTER UbuntuWeb External IP: "
goto SCANTYPE

:: At this point you should have all the necessary IPs to run nmap. Store each nmap result into the TXT File "nmapEvidence.txt"
echo.
echo Targets Acquired...
:: 2. The nmap will run a for most common 1000 ports - "nmap x.x.x.x -sS" and "nmap x.x.x.x -sU"

:SCANTYPE
echo.
echo What Kind of Scan Protocol Would You Like?
 echo 1) TCP
 echo 2) UDP - FAST
 echo 3) UDP - SLOW (Output shows on command line for status check)
 echo 4) TCP and UDP - FAST (recommended for injects)
 echo 5) TCP and UDP - SLOW (Output shows on command line for status check)
 echo 6) Custom
echo.

set /p scType="Input as Number {1,2,3,4,5}: "

if %scType%==1 goto SCAN1
if %scType%==2 goto SCAN2
if %scType%==3 goto SCAN3
if %scType%==4 goto SCAN4
if %scType%==5 goto SCAN5
if %scType%==6 goto CUSTOMSCAN

::Try again
echo.
echo %scType% is not a valid option. Please enter a valid option...
goto SCANTYPE

::1) TCP 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
:SCAN1
 echo.
echo You have selected a TCP scan. This will be quick!
 echo.
echo Nmap Scanning all machines...
echo TCP Scan Results: >> nmapEvidence.txt
 echo.

echo Scanning EComm -- 1000 Common Ports...
::TCP ECOMM
 echo EComm (%EComm%) TCP Scan Results: >> nmapEvidence.txt
 nmap %EComm% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt

echo Scanning DNSNTP -- 1000 Common Ports...
::TCP DNSNTP
 echo DNSNTP (%DNSNTP%) TCP Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt

echo Scanning WebMail -- 1000 Common Ports...
::TCP WebMail
 echo WebMail (%WebMail%) TCP Scan Results: >> nmapEvidence.txt
 nmap %WebMail% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt

echo Scanning Splunk -- 1000 Common Ports...
::TCP Splunk
 echo Splunk (%Splunk%) TCP Scan Results: >> nmapEvidence.txt
 nmap %Splunk% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt

echo Scanning ADDNS -- 1000 Common Ports...
::TCP ADDNS
 echo ADDNS (%ADDNS%) TCP Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt

echo Scanning 2016Docker -- 1000 Common Ports...
::TCP 2016Docker
 echo 2016Docker (%Docker2016%) TCP Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt

echo Scanning UbuntuWeb -- 1000 Common Ports...
::TCP UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) TCP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt

if "%UbuntuWkst%"=="SKIP" goto SCAN1UWSKIP
echo Scanning UbuntuWkst -- 1000 Common Ports...
::TCP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) TCP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
goto EOF

:SCAN1UWSKIP
echo Skipped UbuntuWkst...
 echo.
 echo UbuntuWkst (SKIPPED) TCP Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt

goto EOF

::UDP - FAST 22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
:SCAN2
echo You have selected a Fast UDP Scan. This will be quick!
 echo.
echo Nmap Scanning all machines...
echo UDP (FAST) Scan Results: >> nmapEvidence.txt
 echo.

echo Scanning EComm -- 1000 Common Ports...
::UDP ECOMM
 echo EComm (%EComm%) UDP Scan Results: >> nmapEvidence.txt
 nmap %EComm% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning DNSNTP -- 1000 Common Ports...
::UDP DNSNTP
 echo DNSNTP (%DNSNTP%) UDP Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning WebMail -- 1000 Common Ports...
::UDP WebMail
 echo WebMail (%WebMail%) UDP Scan Results: >> nmapEvidence.txt
 nmap %WebMail% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning Splunk -- 1000 Common Ports...
::UDP Splunk
 echo Splunk (%Splunk%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Splunk% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning ADDNS -- 1000 Common Ports...
::UDP ADDNS
 echo ADDNS (%ADDNS%) UDP Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning 2016Docker -- 1000 Common Ports...
::UDP 2016Docker
 echo 2016Docker (%Docker2016%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning UbuntuWeb -- 1000 Common Ports...
::UDP UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

if "%UbuntuWkst%"=="SKIP" goto SCAN2UWSKIP
echo Scanning UbuntuWkst -- 1000 Common Ports...
::UDP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sU --version-intensity 0 --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt
goto EOF

:SCAN2UWSKIP
echo Skipped UbuntuWkst...
 echo UbuntuWkst (SKIPPED) UDP Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt

goto EOF

::UDP - SLOW (--version-intensity is 7 by default) (The commands will show on command line so that the user can monitor the slow progress) 3333333333333333333333333333333333333333333333
:SCAN3
echo You have selected a Slow UDP Scan. This could take up to 25 minutes, so hang tight! (Cancel with ^C)
 echo.
echo P.S. The commands are showing on the command line so that you can press 'ENTER' to monitor the scan progress...
 echo.
echo Nmap Scanning all machines...
echo UDP (SLOW) Scan Results: >> nmapEvidence.txt
 echo.

echo Scanning EComm -- 1000 Common Ports...
::UDP ECOMM
 echo EComm (%EComm%) UDP Scan Results: >> nmapEvidence.txt
 nmap %EComm% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning DNSNTP -- 1000 Common Ports...
::UDP DNSNTP
 echo DNSNTP (%DNSNTP%) UDP Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning WebMail -- 1000 Common Ports...
::UDP WebMail
 echo WebMail (%WebMail%) UDP Scan Results: >> nmapEvidence.txt
 nmap %WebMail% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning Splunk -- 1000 Common Ports...
::UDP Splunk
 echo Splunk (%Splunk%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Splunk% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning ADDNS -- 1000 Common Ports...
::UDP ADDNS
 echo ADDNS (%ADDNS%) UDP Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning UbuntuWkst -- 1000 Common Ports...
::UDP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning 2016Docker -- 1000 Common Ports...
::UDP 2016Docker
 echo 2016Docker (%Docker2016%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning UbuntuWeb -- 1000 Common Ports...
::UDP UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

if "%UbuntuWkst%"=="SKIP" goto SCAN3UWSKIP
echo Scanning UbuntuWkst -- 1000 Common Ports...
::TCP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) TCP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
goto EOF

:SCAN3UWSKIP
 echo Skipped UbuntuWkst...
 echo UbuntuWkst (SKIPPED) UDP Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt

goto EOF

:: TCP and UDP - FAST (recommended since it gives all TCP data as well as minimal UDP data) 4444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
:SCAN4
echo You have selected a TCP Scan and a UDP Scan. This won't be long!
 echo.
echo Nmap Scanning all machines...
echo TCP and UDP (FAST) Scan Results: >> nmapEvidence.txt
 echo.

echo Scanning EComm -- 1000 Common Ports...
::TCP ECOMM
 echo EComm (%EComm%) TCP Scan Results: >> nmapEvidence.txt
 nmap %EComm% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP ECOMM
 echo EComm (%EComm%) UDP Scan Results: >> nmapEvidence.txt
 nmap %EComm% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning DNSNTP -- 1000 Common Ports...
::TCP DNSNTP
 echo DNSNTP (%DNSNTP%) TCP Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP DNSNTP
 echo DNSNTP (%DNSNTP%) UDP Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning WebMail -- 1000 Common Ports...
::TCP WebMail
 echo WebMail (%WebMail%) TCP Scan Results: >> nmapEvidence.txt
 nmap %WebMail% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP WebMail
 echo WebMail (%WebMail%) UDP Scan Results: >> nmapEvidence.txt
 nmap %WebMail% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning Splunk -- 1000 Common Ports...
::TCP Splunk
 echo Splunk (%Splunk%) TCP Scan Results: >> nmapEvidence.txt
 nmap %Splunk% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP Splunk
 echo Splunk (%Splunk%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Splunk% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning ADDNS -- 1000 Common Ports...
::TCP ADDNS
 echo ADDNS (%ADDNS%) TCP Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP ADDNS
 echo ADDNS (%ADDNS%) UDP Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning 2016Docker -- 1000 Common Ports...
::TCP 2016Docker
 echo 2016Docker (%Docker2016%) TCP Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP 2016Docker
 echo 2016Docker (%Docker2016%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

echo Scanning UbuntuWeb -- 1000 Common Ports...
::TCP UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) TCP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt

if "%UbuntuWkst%"=="SKIP" goto SCAN4UWSKIP
echo Scanning UbuntuWkst -- 1000 Common Ports...
::TCP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) TCP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sS --append-output -oG nmapEvidence.txt > nul
 echo. >> nmapEvidence.txt
::UDP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sU --version-light --append-output -oG nmapEvidence.txt >NUL
 echo. >> nmapEvidence.txt
goto EOF

:SCAN4UWSKIP
echo Skipped UbuntuWkst...
 echo UbuntuWkst (SKIPPED) TCP Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt
 echo UbuntuWkst (SKIPPED) UDP Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt

goto EOF

::TCP and UDP (SLOW) 5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
:SCAN5
echo You have selected a TCP Scan and a Slow UDP Scan. This could take up to 30 minutes, so hang tight! (Cancel with ^C)
 echo.
echo P.S. The commands are showing on the command line so that you can press 'ENTER' to monitor the scan progress...
 echo.
echo Nmap Scanning all machines...
echo TCP and UDP (SLOW) Scan Results: >> nmapEvidence.txt
 echo.

echo Scanning EComm -- 1000 Common Ports...
::TCP ECOMM
 echo EComm (%EComm%) TCP Scan Results: >> nmapEvidence.txt
 nmap %EComm% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP ECOMM
 echo EComm (%EComm%) UDP Scan Results: >> nmapEvidence.txt
 nmap %EComm% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning DNSNTP -- 1000 Common Ports...
::TCP DNSNTP
 echo DNSNTP (%DNSNTP%) TCP Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP DNSNTP
 echo DNSNTP (%DNSNTP%) UDP Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning WebMail -- 1000 Common Ports...
::TCP WebMail
 echo WebMail (%WebMail%) TCP Scan Results: >> nmapEvidence.txt
 nmap %WebMail% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP WebMail
 echo WebMail (%WebMail%) UDP Scan Results: >> nmapEvidence.txt
 nmap %WebMail% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning Splunk -- 1000 Common Ports...
::TCP Splunk
 echo Splunk (%Splunk%) TCP Scan Results: >> nmapEvidence.txt
 nmap %Splunk% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP Splunk
 echo Splunk (%Splunk%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Splunk% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning ADDNS -- 1000 Common Ports...
::TCP ADDNS
 echo ADDNS (%ADDNS%) TCP Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP ADDNS
 echo ADDNS (%ADDNS%) UDP Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning 2016Docker -- 1000 Common Ports...
::TCP 2016Docker
 echo 2016Docker (%Docker2016%) TCP Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP 2016Docker
 echo 2016Docker (%Docker2016%) UDP Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

echo Scanning UbuntuWeb -- 1000 Common Ports...
::TCP UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) TCP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt

if "%UbuntuWkst%"=="SKIP" goto SCAN5UWSKIP
echo Scanning UbuntuWkst -- 1000 Common Ports...
::TCP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) TCP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sS --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
::UDP UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) UDP Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% -sU --append-output -oG nmapEvidence.txt
 echo. >> nmapEvidence.txt
goto EOF

:SCAN5UWSKIP
echo Skipped UbuntuWkst...
 echo UbuntuWkst (SKIPPED) TCP Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt
 echo UbuntuWkst (SKIPPED) UDP Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt
goto EOF

::For custom switches in case user wants to try something unique 66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
:CUSTOMSCAN
set /p scanFlags="Please enter your scan flags. (i.e. '-sU --max-rtt-timeout 100ms -oN'): "
 echo.
echo Nmap Scanning all machines...
echo Custom Scan Results: >> nmapEvidence.txt
 echo.

echo Scanning EComm -- 1000 Common Ports...
::Custom ECOMM
 echo EComm (%EComm%) Custom Scan Results: >> nmapEvidence.txt
 nmap %EComm% %scanFlags%
 echo. >> nmapEvidence.txt

echo Scanning DNSNTP -- 1000 Common Ports...
::Custom DNSNTP
 echo DNSNTP (%DNSNTP%) Custom Scan Results: >> nmapEvidence.txt
 nmap %DNSNTP% %scanFlags%
 echo. >> nmapEvidence.txt

echo Scanning WebMail -- 1000 Common Ports...
::Custom WebMail
 echo WebMail (%WebMail%) Custom Scan Results: >> nmapEvidence.txt
 nmap %WebMail% %scanFlags%
 echo. >> nmapEvidence.txt

echo Scanning Splunk -- 1000 Common Ports...
::Custom Splunk
 echo Splunk (%Splunk%) Custom Scan Results: >> nmapEvidence.txt
 nmap %Splunk% %scanFlags%
 echo. >> nmapEvidence.txt

echo Scanning ADDNS -- 1000 Common Ports...
::Custom ADDNS
 echo ADDNS (%ADDNS%) Custom Scan Results: >> nmapEvidence.txt
 nmap %ADDNS% %scanFlags%
 echo. >> nmapEvidence.txt

echo Scanning 2016Docker -- 1000 Common Ports...
::Custom 2016Docker
 echo 2016Docker (%Docker2016%) Custom Scan Results: >> nmapEvidence.txt
 nmap %Docker2016% %scanFlags%
 echo. >> nmapEvidence.txt

echo Scanning UbuntuWeb -- 1000 Common Ports...
::Custom UbuntuWeb
 echo UbuntuWeb (%UbuntuWeb%) Custom Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWeb% %scanFlags%
 echo. >> nmapEvidence.txt

if "%UbuntuWkst%"=="SKIP" goto SCAN6UWSKIP
echo Scanning UbuntuWkst -- 1000 Common Ports...
::Custom UbuntuWkst
 echo UbuntuWkst (%UbuntuWkst%) Custom Scan Results: >> nmapEvidence.txt
 nmap %UbuntuWkst% %scanFlags%
 echo. >> nmapEvidence.txt
goto EOF

:SCAN6UWSKIP
echo Skipped UbuntuWkst...
 echo.
 echo UbuntuWkst (SKIPPED) Custom Scan Results: >> nmapEvidence.txt
 echo SKIPPED >> nmapEvidence.txt
  echo. >> nmapEvidence.txt

goto EOF



::FIXME: Will not get this done before 1/27/23 | Final Step - Read through nmapEvidence.txt, find keywords, and distribute info neatly into inject format (this was why --append-output -oG was used)

:EOF
echo Finished Scanning All Targets...
 echo.
set /p endSCAN="Click ENTER to see scan results..."
echo EOF >> nmapEvidence.txt

::FIXME: Final Step - Read through nmapEvidence.txt, find keywords, and distribute info neatly into inject format (this was why --append-output -oG was used)
::FIXME: Also turn scans into functions, if time permits
::see results
start nmapEvidence.txt
exit /B