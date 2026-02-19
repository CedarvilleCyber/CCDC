@echo off
title Providence MAX - Ultimate Windows Security Suite
:: ============================================================================
:: PROVIDENCE MAX - Ultimate Windows Security Suite
:: ============================================================================
:: Author: Aaron Campbell for the Cedarville Cyber Team
:: Enhanced by: Matt Reid and the Cedarville Cyber Team
:: Version: MAX 3.1 - Stability Edition
:: Last Updated: 2026-02-19
::
:: FIXES IN 3.1:
::   - All subroutines wrapped in cmd /c to prevent shell crashes
::   - disable_netbios uses registry only (no live adapter touching)
::   - harden_lsass removes RunAsPPL/VBS/CredentialGuard (crash risk)
::   - clean_wmi_completely deferred to post-reboot only
::   - repair_network_stack removes ipconfig /release /renew
::   - harden_registry_full uses single-line PowerShell calls
::   - enable_aslr_dep uses single-line PowerShell
::   - clear_all_persistence removes GP Scripts reg delete
::   - create_baseline wraps everything in cmd /c
::   - fix_all_backdoors no longer calls clean_wmi_completely
::   - harden_wmi no longer stops Winmgmt service
:: ============================================================================

color 0A
echo.
echo ===============================================================================
echo    PPPP  RRRR   OOO  V   V III DDDD  EEEE N   N  CCC  EEEE
echo    P   P R   R O   O V   V  I  D   D E    NN  N C   C E
echo    PPPP  RRRR  O   O V   V  I  D   D EEE  N N N C     EEE
echo    P     R  R  O   O  V V   I  D   D E    N  NN C   C E
echo    P     R   R  OOO    V   III DDDD  EEEE N   N  CCC  EEEE
echo.
echo                  M A X I M U M   E D I T I O N   v3.1
echo                     Cedarville University Cyber Team
echo ===============================================================================
echo.
echo  WARNING: This script makes EXTENSIVE changes to your system.
echo  Includes hardening, repair, cleanup, and threat hunting.
echo.
echo  Press Ctrl+C to cancel, or any key to continue...
pause >NUL

:: ============================================================================
:: ADMIN CHECK
:: ============================================================================
echo.
echo [*] Checking for administrative privileges...
net session >NUL 2>&1
if %errorlevel% NEQ 0 (
    color 0C
    echo [!] ERROR: Must be run as Administrator!
    echo [!] Right-click and select "Run as Administrator"
    pause
    exit /b 1
)
echo [+] Administrator privileges confirmed.

:: ============================================================================
:: ENVIRONMENT INITIALIZATION
:: ============================================================================
setlocal EnableDelayedExpansion
set "ccdcpath=C:\ccdc"
set "logfile=%ccdcpath%\providence_max.log"

:: Build timestamp via wmic (locale-safe)
for /f "tokens=2 delims==" %%I in ('wmic os get LocalDateTime /value 2^>nul') do set "dt=%%I"
set "timestamp=%dt:~0,8%_%dt:~8,6%"

:: Create directory structure
echo [*] Initializing working directories...
for %%D in (
    "%ccdcpath%"
    "%ccdcpath%\ThreatHunting"
    "%ccdcpath%\ThreatHunting\Tasks"
    "%ccdcpath%\Config"
    "%ccdcpath%\Regback"
    "%ccdcpath%\Proof"
    "%ccdcpath%\Quarantine"
    "%ccdcpath%\Logs"
    "%ccdcpath%\Baseline"
    "%ccdcpath%\Repair"
) do (
    if not exist %%D mkdir %%D >NUL 2>&1
)

:: Start log
(
echo ================================================================================
echo  Providence MAX 3.1 Execution Log
echo  Timestamp : %timestamp%
echo  Computer  : %COMPUTERNAME%
echo  User      : %USERNAME%
echo  Domain    : %USERDOMAIN%
echo ================================================================================
echo.
) > "%logfile%"

echo [+] Directories created. Log: %logfile%
echo.

:: ============================================================================
:: MAIN MENU
:: ============================================================================
:main_menu
cls
echo.
echo ===============================================================================
echo                  PROVIDENCE MAX v3.1 - Main Menu
echo                  Cedarville University Cyber Team
echo ===============================================================================
echo.
echo   [HARDENING]
echo    1  - Express Hardening     ^(Recommended for CCDC - Fast, ~5 min^)
echo    2  - Full Hardening        ^(Complete Security Lockdown, ~15 min^)
echo   11  - MAXIMUM SECURITY      ^(Everything possible, 30+ min^)
echo.
echo   [INVESTIGATION]
echo    4  - Threat Hunting        ^(Find malware and persistence^)
echo    9  - Baseline Creator      ^(Snapshot system for comparison^)
echo.
echo   [REPAIR]
echo    3  - System Repair         ^(Fix broken Windows components^)
echo    5  - Emergency Response    ^(System completely broken? Start here^)
echo    7  - Performance Recovery  ^(Fix high CPU/Memory^)
echo    8  - Network Diagnostics   ^(Fix DNS/connectivity^)
echo.
echo   [CLEANUP]
echo    6  - Malware Cleanup       ^(Nuclear option - remove all suspicious^)
echo   12  - Undo/Restore          ^(Revert script changes^)
echo.
echo   [OTHER]
echo   10  - Custom Mode           ^(Choose specific actions^)
echo    0  - Exit
echo.
echo ===============================================================================
set /p "main_choice=Enter your choice: "

if "%main_choice%"=="1"  goto express_hardening
if "%main_choice%"=="2"  goto full_hardening
if "%main_choice%"=="3"  goto system_repair
if "%main_choice%"=="4"  goto threat_hunting
if "%main_choice%"=="5"  goto emergency_response
if "%main_choice%"=="6"  goto malware_cleanup
if "%main_choice%"=="7"  goto performance_recovery
if "%main_choice%"=="8"  goto network_diagnostics
if "%main_choice%"=="9"  goto baseline_creator
if "%main_choice%"=="10" goto custom_mode
if "%main_choice%"=="11" goto maximum_security
if "%main_choice%"=="12" goto restore_mode
if "%main_choice%"=="0"  goto script_exit
echo [!] Invalid choice. Try again.
timeout /t 2 >NUL
goto main_menu

:: ============================================================================
:: MODE 1: EXPRESS HARDENING
:: ============================================================================
:express_hardening
cls
echo.
echo ===============================================================================
echo                        EXPRESS HARDENING MODE
echo ===============================================================================
echo.
pause

echo [*] Starting express hardening... >> "%logfile%"
call :get_network_info
call :backup_critical_configs
call :enable_firewall_express
call :disable_dangerous_services
call :fix_common_backdoors
call :enable_basic_logging
call :set_password_policy
call :disable_guest_account
call :clear_run_keys
call :harden_smb
call :harden_lsass
call :disable_llmnr
call :disable_netbios
echo [+] Express hardening complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] EXPRESS HARDENING COMPLETE!
echo ===============================================================================
echo [*] Logs: %logfile%
echo [*] Firewall is DEFAULT DENY - add rules for scored services.
echo [!] REBOOT RECOMMENDED.
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 2: FULL HARDENING
:: ============================================================================
:full_hardening
cls
echo.
echo ===============================================================================
echo                         FULL HARDENING MODE
echo ===============================================================================
echo.
pause

echo [*] Starting full hardening... >> "%logfile%"
call :get_network_info
call :backup_all_configs
call :enable_firewall_full
call :harden_registry_full
call :disable_all_dangerous_services
call :fix_all_backdoors
call :enable_advanced_logging
call :harden_smb
call :harden_rdp
call :harden_wmi
call :set_password_policy
call :disable_guest_account
call :harden_lsass
call :disable_legacy_protocols
call :clear_all_persistence
call :harden_powershell
call :disable_unnecessary_features
call :configure_uac_max
call :enable_aslr_dep
call :harden_network_protocols
call :disable_netbios
call :disable_llmnr
call :apply_cis_benchmarks
call :apply_stig_settings
echo [+] Full hardening complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] FULL HARDENING COMPLETE!
echo ===============================================================================
echo [*] Review logs in %ccdcpath%
echo [!] REBOOT REQUIRED for all changes to take effect.
echo.
set /p "reboot_now=Reboot now? [y/n]: "
if /i "%reboot_now%"=="y" shutdown /r /t 30 /c "Rebooting for Providence MAX security changes"
pause
goto main_menu

:: ============================================================================
:: MODE 3: SYSTEM REPAIR
:: ============================================================================
:system_repair
cls
echo.
echo ===============================================================================
echo                         SYSTEM REPAIR MODE
echo ===============================================================================
echo.
pause

echo [*] Starting system repair... >> "%logfile%"
call :repair_windows_explorer
call :repair_system_files
call :repair_windows_update
call :repair_event_logs
call :repair_windows_defender
call :clear_temp_files
call :rebuild_icon_cache
call :check_disk_health
echo [+] System repair complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] SYSTEM REPAIR COMPLETE!
echo ===============================================================================
echo [*] If issues persist, try Mode 5: Emergency Response
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 4: THREAT HUNTING
:: ============================================================================
:threat_hunting
cls
echo.
echo ===============================================================================
echo                        THREAT HUNTING MODE
echo     Results saved to %ccdcpath%\ThreatHunting\
echo ===============================================================================
echo.
pause

echo [*] Starting threat hunting... >> "%logfile%"
call :hunt_persistence_registry
call :hunt_persistence_wmi
call :hunt_persistence_services
call :hunt_persistence_tasks
call :hunt_persistence_files
call :hunt_suspicious_processes
call :hunt_suspicious_network
call :hunt_suspicious_files
call :hunt_browser_hijacks
call :hunt_dll_hijacking
call :analyze_autoruns
call :check_known_malware_paths
call :analyze_prefetch
call :check_alternate_data_streams
echo [+] Threat hunting complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] THREAT HUNTING COMPLETE!
echo ===============================================================================
echo [*] Results: %ccdcpath%\ThreatHunting\
echo.
echo [!] MANUALLY REVIEW:
echo     - HKCU_Run.txt / HKLM_Run.txt
echo     - WMI_EventFilters.txt
echo     - ScheduledTasks_Full.txt
echo     - Service_Paths.txt / Suspicious_Services.txt
echo     - Suspicious_Process_Locations.txt
echo     - Autoruns_Comprehensive.txt
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 5: EMERGENCY RESPONSE
:: ============================================================================
:emergency_response
cls
echo.
echo ===============================================================================
echo                       EMERGENCY RESPONSE MODE
echo     WARNING: Aggressive repair - may cause temporary instability.
echo ===============================================================================
echo.
pause

echo [*] Starting emergency response... >> "%logfile%"
call :emergency_process_termination
call :emergency_restore_explorer
call :emergency_restore_services
call :repair_system_files
call :repair_component_store
call :repair_windows_update
echo [+] Emergency response complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] EMERGENCY RESPONSE COMPLETE!
echo ===============================================================================
echo [*] If still broken:
echo     - Restore from backup
echo     - Run Mode 12 to revert changes
echo     - Perform a Windows repair install
echo     - Boot Safe Mode and fix manually
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 6: MALWARE CLEANUP
:: ============================================================================
:malware_cleanup
cls
echo.
echo ===============================================================================
echo                        MALWARE CLEANUP MODE
echo     NUCLEAR OPTION - Removes anything suspicious.
echo     WARNING: May break legitimate software!
echo ===============================================================================
echo.
set /p "confirm_nuclear=Type NUKE to continue (Ctrl+C to cancel): "
if /i not "%confirm_nuclear%"=="NUKE" (
    echo [*] Cancelled.
    timeout /t 2 >NUL
    goto main_menu
)

echo [*] Starting malware cleanup... >> "%logfile%"
call :backup_critical_configs
call :quarantine_suspicious_files
call :remove_all_persistence
call :kill_suspicious_processes
call :delete_temp_files_aggressive
call :clean_browser_completely
call :remove_suspicious_services
call :clean_wmi_completely
call :reset_hosts_file
call :clear_dns_cache
call :remove_proxy_settings
call :clean_scheduled_tasks_aggressive
echo [+] Malware cleanup complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] MALWARE CLEANUP COMPLETE!
echo ===============================================================================
echo [*] Quarantined: %ccdcpath%\Quarantine\
echo [!] REBOOT IMMEDIATELY!
echo.
set /p "reboot_now=Reboot now? [y/n]: "
if /i "%reboot_now%"=="y" shutdown /r /t 10 /c "Rebooting after malware cleanup"
pause
goto main_menu

:: ============================================================================
:: MODE 7: PERFORMANCE RECOVERY
:: ============================================================================
:performance_recovery
cls
echo.
echo ===============================================================================
echo                      PERFORMANCE RECOVERY MODE
echo ===============================================================================
echo.
pause

echo [*] Starting performance recovery... >> "%logfile%"
call :identify_resource_hogs
call :disable_telemetry
call :disable_superfetch
call :optimize_page_file
call :clear_temp_files
call :optimize_startup
call :disable_maintenance_tasks
echo [+] Performance recovery complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] PERFORMANCE RECOVERY COMPLETE!
echo ===============================================================================
echo [*] Resource reports: %ccdcpath%\Repair\
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 8: NETWORK DIAGNOSTICS
:: ============================================================================
:network_diagnostics
cls
echo.
echo ===============================================================================
echo                       NETWORK DIAGNOSTICS MODE
echo ===============================================================================
echo.
pause

echo [*] Starting network diagnostics... >> "%logfile%"
call :diagnose_network
call :flush_dns
call :fix_dns_client
call :test_connectivity
call :check_proxy_settings
echo [+] Network diagnostics complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] NETWORK DIAGNOSTICS COMPLETE!
echo ===============================================================================
echo [*] Network reports: %ccdcpath%\Repair\Network_*.txt
echo.
echo [!] To fully reset network stack (WILL DROP CONNECTION - run locally only):
echo     netsh winsock reset
echo     netsh int ip reset
echo     ipconfig /release
echo     ipconfig /renew
echo     Then REBOOT.
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 9: BASELINE CREATOR
:: ============================================================================
:baseline_creator
cls
echo.
echo ===============================================================================
echo                        BASELINE CREATOR MODE
echo ===============================================================================
echo.
pause

echo [*] Creating baseline... >> "%logfile%"
call :create_baseline
echo [+] Baseline created >> "%logfile%"

echo.
echo ===============================================================================
echo [+] BASELINE CREATED!
echo ===============================================================================
echo [*] Saved to: %ccdcpath%\Baseline\%timestamp%\
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 10: CUSTOM MODE
:: ============================================================================
:custom_mode
cls
echo.
echo ===============================================================================
echo                           CUSTOM MODE
echo ===============================================================================
echo.

set /p "do_firewall=Configure Firewall? [y/n]: "
set /p "do_services=Harden Services? [y/n]: "
set /p "do_registry=Harden Registry? [y/n]: "
set /p "do_persistence=Clear Persistence? [y/n]: "
set /p "do_repair=Repair System Files? [y/n]: "
set /p "do_cleanup=Clean Temp Files? [y/n]: "
set /p "do_logging=Enable Advanced Logging? [y/n]: "
set /p "do_password=Set Password Policy? [y/n]: "
set /p "do_smb=Harden SMB? [y/n]: "
set /p "do_rdp=Harden RDP? [y/n]: "
set /p "do_lsass=Harden LSASS? [y/n]: "

echo.
echo [*] Executing custom configuration...

if /i "%do_firewall%"=="y"     call :enable_firewall_full
if /i "%do_services%"=="y"     call :disable_all_dangerous_services
if /i "%do_registry%"=="y"     call :harden_registry_full
if /i "%do_persistence%"=="y"  call :clear_all_persistence
if /i "%do_repair%"=="y"       call :repair_system_files
if /i "%do_cleanup%"=="y"      call :clear_temp_files
if /i "%do_logging%"=="y"      call :enable_advanced_logging
if /i "%do_password%"=="y"     call :set_password_policy
if /i "%do_smb%"=="y"          call :harden_smb
if /i "%do_rdp%"=="y"          call :harden_rdp
if /i "%do_lsass%"=="y"        call :harden_lsass

echo.
echo ===============================================================================
echo [+] CUSTOM EXECUTION COMPLETE!
echo ===============================================================================
pause
goto main_menu

:: ============================================================================
:: MODE 11: MAXIMUM SECURITY
:: ============================================================================
:maximum_security
cls
echo.
echo ===============================================================================
echo                       MAXIMUM SECURITY MODE
echo     Apply EVERY security measure. ~30+ minutes.
echo     WARNING: May break some applications. REBOOT AFTER.
echo ===============================================================================
echo.
set /p "confirm_max=Type MAXIMUM to continue (Ctrl+C to cancel): "
if /i not "%confirm_max%"=="MAXIMUM" (
    echo [*] Cancelled.
    timeout /t 2 >NUL
    goto main_menu
)

echo [*] Starting maximum security... >> "%logfile%"

call :backup_all_configs
call :create_baseline
call :get_network_info
call :enable_firewall_full
call :harden_registry_full
call :disable_all_dangerous_services
call :fix_all_backdoors
call :enable_advanced_logging
call :harden_smb
call :harden_rdp
call :harden_wmi
call :set_password_policy
call :disable_guest_account
call :harden_lsass
call :disable_legacy_protocols
call :clear_all_persistence
call :harden_powershell
call :disable_unnecessary_features
call :configure_uac_max
call :enable_aslr_dep
call :harden_network_protocols
call :disable_netbios
call :disable_llmnr
call :apply_cis_benchmarks
call :apply_stig_settings
call :apply_nsa_guidance
call :harden_certificates
call :enable_exploit_protection
call :harden_scheduled_tasks
call :disable_autorun_all
call :harden_browsers
call :hunt_all_persistence
call :clear_temp_files

echo [+] Maximum security complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] MAXIMUM SECURITY COMPLETE!
echo ===============================================================================
echo [!] REBOOT REQUIRED.
echo.
set /p "reboot_now=Reboot now? [y/n]: "
if /i "%reboot_now%"=="y" shutdown /r /t 60 /c "Rebooting - Providence MAX applied"
pause
goto main_menu

:: ============================================================================
:: MODE 12: RESTORE MODE
:: ============================================================================
:restore_mode
cls
echo.
echo ===============================================================================
echo                          RESTORE MODE
echo ===============================================================================
echo.

if not exist "%ccdcpath%\Config" (
    echo [!] No backups found.
    pause
    goto main_menu
)

echo Available backups:
dir /b "%ccdcpath%\Config" 2>NUL
echo.

set /p "restore_firewall=Restore firewall configuration? [y/n]: "
if /i "%restore_firewall%"=="y" (
    for /f "delims=" %%F in ('dir /b /od "%ccdcpath%\Config\firewall*.wfw" 2^>nul') do set "latest_fw=%%F"
    if defined latest_fw (
        netsh advfirewall import "%ccdcpath%\Config\!latest_fw!" >NUL 2>&1
        echo [+] Firewall restored from !latest_fw!
    ) else (
        echo [!] No firewall backup found.
    )
)

echo.
echo [!] Registry restoration requires Safe Mode:
echo     reg import "%ccdcpath%\Regback\[filename].reg"
echo.
pause
goto main_menu

:: ============================================================================
:: EXIT
:: ============================================================================
:script_exit
cls
echo.
echo ===============================================================================
echo                   Thank you for using Providence MAX
echo                    Cedarville University Cyber Team
echo ===============================================================================
echo.
echo Session log : %logfile%
echo All outputs : %ccdcpath%\
echo.
echo "Providence - The protective care of God"
echo Go Yellow Jackets!
echo.
pause
exit /b 0

:: ============================================================================
:: PROVIDENCE MAX v3.1 - SUBROUTINES PART 2
:: Network Info, Backup, Firewall
:: ============================================================================

:get_network_info
echo [*] Gathering network information...
echo [*] Network info collection... >> "%logfile%"
cmd /c "ipconfig /all > \"%ccdcpath%\Proof\NetworkInfo_%timestamp%.txt\" 2>NUL"
cmd /c "netstat -ano  > \"%ccdcpath%\Proof\Netstat_%timestamp%.txt\" 2>NUL"
cmd /c "arp -a        > \"%ccdcpath%\Proof\ARP_%timestamp%.txt\" 2>NUL"
cmd /c "route print   > \"%ccdcpath%\Proof\Routes_%timestamp%.txt\" 2>NUL"
cmd /c "net share     > \"%ccdcpath%\Proof\Shares_%timestamp%.txt\" 2>NUL"
cmd /c "wmic useraccount list brief > \"%ccdcpath%\Proof\Users_%timestamp%.txt\" 2>NUL"
cmd /c "net localgroup administrators >> \"%ccdcpath%\Proof\Users_%timestamp%.txt\" 2>NUL"
echo [+] Network info saved.
exit /b

:backup_critical_configs
echo [*] Backing up critical configurations...
echo [*] Backing up critical configs... >> "%logfile%"
cmd /c "reg export \"HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" \"%ccdcpath%\Regback\HKCU_Run_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "reg export \"HKLM\Software\Microsoft\Windows\CurrentVersion\Run\" \"%ccdcpath%\Regback\HKLM_Run_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "reg export \"HKLM\SYSTEM\CurrentControlSet\Services\" \"%ccdcpath%\Regback\Services_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "reg export \"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" \"%ccdcpath%\Regback\Winlogon_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "reg export \"HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" \"%ccdcpath%\Regback\LSA_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "copy /y \"%SystemRoot%\System32\drivers\etc\hosts\" \"%ccdcpath%\Config\hosts_%timestamp%.bak\" >NUL 2>&1"
cmd /c "netsh advfirewall export \"%ccdcpath%\Config\firewall_%timestamp%.wfw\" >NUL 2>&1"
cmd /c "schtasks /query /fo LIST /v > \"%ccdcpath%\Config\ScheduledTasks_%timestamp%.txt\" 2>NUL"
cmd /c "sc query type= service state= all > \"%ccdcpath%\Config\Services_%timestamp%.txt\" 2>NUL"
echo [+] Critical configs backed up.
exit /b

:backup_all_configs
echo [*] Backing up ALL configurations...
echo [*] Full backup starting... >> "%logfile%"
call :backup_critical_configs
cmd /c "reg export \"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\" \"%ccdcpath%\Regback\Policies_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "reg export \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\" \"%ccdcpath%\Regback\SessionMgr_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "reg export \"HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\" \"%ccdcpath%\Regback\Explorer_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "wmic useraccount list full > \"%ccdcpath%\Config\UserAccounts_%timestamp%.txt\" 2>NUL"
cmd /c "wmic group list full > \"%ccdcpath%\Config\Groups_%timestamp%.txt\" 2>NUL"
cmd /c "net localgroup administrators > \"%ccdcpath%\Config\Admins_%timestamp%.txt\" 2>NUL"
cmd /c "auditpol /get /category:* > \"%ccdcpath%\Config\AuditPolicy_%timestamp%.txt\" 2>NUL"
cmd /c "secedit /export /cfg \"%ccdcpath%\Config\SecurityPolicy_%timestamp%.cfg\" >NUL 2>&1"
echo [+] All configs backed up.
exit /b

:enable_firewall_express
echo [*] Configuring firewall (Express)...
echo [*] Enabling firewall express... >> "%logfile%"
netsh advfirewall set allprofiles state on >NUL 2>&1
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound >NUL 2>&1
netsh advfirewall firewall add rule name="Allow DNS In"    dir=in  action=allow protocol=udp localport=53    >NUL 2>&1
netsh advfirewall firewall add rule name="Allow DNS Out"   dir=out action=allow protocol=udp remoteport=53   >NUL 2>&1
netsh advfirewall firewall add rule name="Allow HTTP Out"  dir=out action=allow protocol=tcp remoteport=80   >NUL 2>&1
netsh advfirewall firewall add rule name="Allow HTTPS Out" dir=out action=allow protocol=tcp remoteport=443  >NUL 2>&1
netsh advfirewall firewall add rule name="Allow RDP In"    dir=in  action=allow protocol=tcp localport=3389  >NUL 2>&1
netsh advfirewall firewall add rule name="Allow Loopback"  dir=in  action=allow remoteip=127.0.0.1           >NUL 2>&1
netsh advfirewall firewall add rule name="Block NetBIOS UDP" dir=in action=block protocol=udp localport=137,138 >NUL 2>&1
netsh advfirewall firewall add rule name="Block NetBIOS TCP" dir=in action=block protocol=tcp localport=139  >NUL 2>&1
netsh advfirewall firewall add rule name="Block WMI In"    dir=in  action=block protocol=tcp localport=135   >NUL 2>&1
echo [+] Firewall configured (express).
echo [!] Add rules for your scored services as needed.
exit /b

:enable_firewall_full
echo [*] Configuring firewall (Full - default deny both directions)...
echo [*] Enabling firewall full... >> "%logfile%"
netsh advfirewall set allprofiles state on >NUL 2>&1
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound >NUL 2>&1
netsh advfirewall set allprofiles settings inboundusernotification disable >NUL 2>&1
:: Outbound
netsh advfirewall firewall add rule name="FW: DNS UDP Out"  dir=out action=allow protocol=udp remoteport=53  >NUL 2>&1
netsh advfirewall firewall add rule name="FW: DNS TCP Out"  dir=out action=allow protocol=tcp remoteport=53  >NUL 2>&1
netsh advfirewall firewall add rule name="FW: HTTP Out"     dir=out action=allow protocol=tcp remoteport=80  >NUL 2>&1
netsh advfirewall firewall add rule name="FW: HTTPS Out"    dir=out action=allow protocol=tcp remoteport=443 >NUL 2>&1
netsh advfirewall firewall add rule name="FW: ICMP Out"     dir=out action=allow protocol=icmpv4             >NUL 2>&1
netsh advfirewall firewall add rule name="FW: DHCP Out"     dir=out action=allow protocol=udp localport=68 remoteport=67 >NUL 2>&1
netsh advfirewall firewall add rule name="FW: Kerberos Out" dir=out action=allow protocol=tcp remoteport=88  >NUL 2>&1
netsh advfirewall firewall add rule name="FW: LDAP Out"     dir=out action=allow protocol=tcp remoteport=389 >NUL 2>&1
netsh advfirewall firewall add rule name="FW: LDAPS Out"    dir=out action=allow protocol=tcp remoteport=636 >NUL 2>&1
netsh advfirewall firewall add rule name="FW: NTP Out"      dir=out action=allow protocol=udp remoteport=123 >NUL 2>&1
:: Inbound
netsh advfirewall firewall add rule name="FW: ICMP In"      dir=in  action=allow protocol=icmpv4             >NUL 2>&1
netsh advfirewall firewall add rule name="FW: Loopback In"  dir=in  action=allow remoteip=127.0.0.1          >NUL 2>&1
netsh advfirewall firewall add rule name="FW: RDP In"       dir=in  action=allow protocol=tcp localport=3389 >NUL 2>&1
:: Block dangerous inbound
netsh advfirewall firewall add rule name="FW: Block WMI In"      dir=in action=block protocol=tcp localport=135     >NUL 2>&1
netsh advfirewall firewall add rule name="FW: Block NetBIOS TCP" dir=in action=block protocol=tcp localport=139     >NUL 2>&1
netsh advfirewall firewall add rule name="FW: Block NetBIOS UDP" dir=in action=block protocol=udp localport=137,138 >NUL 2>&1
netsh advfirewall firewall add rule name="FW: Block SMB In"      dir=in action=block protocol=tcp localport=445     >NUL 2>&1
echo [+] Firewall configured (full - default deny both directions).
echo [!] Add inbound rules for scored services:
echo     netsh advfirewall firewall add rule name="SVC" dir=in action=allow protocol=tcp localport=PORT
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.1 - SUBROUTINES PART 3
:: Services, Backdoors, Logging, Passwords
:: ============================================================================

:disable_dangerous_services
echo [*] Disabling dangerous services (express)...
echo [*] Disabling dangerous services... >> "%logfile%"
for %%S in (tlntsvr msftpsvc RemoteRegistry WinRM SNMP SNMPTrap simptcp RemoteAccess tftpd) do (
    sc config %%S start= disabled >NUL 2>&1
    net stop %%S /y >NUL 2>&1
)
echo [+] Dangerous services disabled.
exit /b

:disable_all_dangerous_services
echo [*] Disabling all dangerous services (comprehensive)...
echo [*] Disabling all dangerous services... >> "%logfile%"
call :disable_dangerous_services
for %%S in (
    XblAuthManager XblGameSave XboxNetApiSvc XboxGipSvc
    DiagTrack dmwappushservice WMPNetworkSvc WerSvc wercplsupport
    PeerDistSvc p2pimsvc p2psvc PNRPSvc PNRPAutoReg
    HomeGroupListener HomeGroupProvider icssvc lltdsvc
    MapsBroker PhoneSvc RasAuto RasMan
    SessionEnv UmRdpService upnphost SSDPSRV fdPHost FDResPub
    SharedAccess
) do (
    sc config %%S start= disabled >NUL 2>&1
    net stop %%S /y >NUL 2>&1
)
echo [+] All dangerous services disabled.
exit /b

:fix_common_backdoors
echo [*] Fixing common backdoors...
echo [*] Fixing common backdoors... >> "%logfile%"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >NUL 2>&1
:: Clear IFEO debuggers on accessibility tools (classic backdoor)
for %%P in (sethc.exe utilman.exe osk.exe magnify.exe narrator.exe displayswitch.exe atbroker.exe) do (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%P" /v Debugger /f >NUL 2>&1
)
:: Restore sethc if replaced with cmd
if exist "%SystemRoot%\System32\sethc.exe.bak" (
    copy /y "%SystemRoot%\System32\sethc.exe.bak" "%SystemRoot%\System32\sethc.exe" >NUL 2>&1
)
:: Clear AppInit DLLs
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs /t REG_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs /t REG_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v LoadAppInit_DLLs /t REG_DWORD /d 0 /f >NUL 2>&1
:: Reset LSA notification packages
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Notification Packages" /t REG_MULTI_SZ /d "scecli" /f >NUL 2>&1
echo [+] Common backdoors fixed.
exit /b

:fix_all_backdoors
echo [*] Fixing all backdoors (comprehensive)...
echo [*] Fixing all backdoors... >> "%logfile%"
call :fix_common_backdoors
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Authentication Packages" /t REG_MULTI_SZ /d "msv1_0" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Security Packages" /t REG_MULTI_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1
:: NOTE: WMI cleanup deferred - stopping Winmgmt mid-session crashes the shell
echo [!] WMI cleanup deferred - run Mode 6 after reboot.
echo [+] All backdoors fixed.
exit /b

:clear_run_keys
echo [*] Clearing Run keys...
echo [*] Clearing run keys... >> "%logfile%"
cmd /c "reg export \"HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" \"%ccdcpath%\Regback\HKCU_Run_pre_clear_%timestamp%.reg\" /y >NUL 2>&1"
cmd /c "reg export \"HKLM\Software\Microsoft\Windows\CurrentVersion\Run\" \"%ccdcpath%\Regback\HKLM_Run_pre_clear_%timestamp%.reg\" /y >NUL 2>&1"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"    /f >NUL 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"    /f >NUL 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\RunServices" /f >NUL 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices" /f >NUL 2>&1
echo [!] Run keys backed up - review and remove suspicious entries manually.
echo [+] RunOnce and RunServices cleared.
exit /b

:clear_all_persistence
echo [*] Clearing all persistence mechanisms...
echo [*] Clearing all persistence... >> "%logfile%"
call :clear_run_keys
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*" >NUL 2>&1
del /f /q "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*" >NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d "0" /f >NUL 2>&1
:: NOTE: WMI cleanup and GP Scripts reg delete deferred - can crash shell
echo [!] WMI persistence cleanup deferred - run Mode 6 after reboot.
echo [+] Persistence cleared (startup folders, run keys).
exit /b

:enable_basic_logging
echo [*] Enabling basic security logging...
echo [*] Enabling basic logging... >> "%logfile%"
auditpol /set /category:"Logon/Logoff"     /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Account Logon"    /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Account Management" /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Object Access"    /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Policy Change"    /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Privilege Use"    /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"System"           /success:enable /failure:enable >NUL 2>&1
wevtutil sl Security    /ms:512000000 >NUL 2>&1
wevtutil sl System      /ms:128000000 >NUL 2>&1
wevtutil sl Application /ms:128000000 >NUL 2>&1
echo [+] Basic logging enabled.
exit /b

:enable_advanced_logging
echo [*] Enabling advanced security logging...
echo [*] Enabling advanced logging... >> "%logfile%"
call :enable_basic_logging
auditpol /set /subcategory:"Process Creation"               /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Process Termination"            /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"File System"                    /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Registry"                       /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"SAM"                            /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"File Share"                     /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Filtering Platform Connection"  /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Removable Storage"              /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Security System Extension"      /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"System Integrity"               /success:enable /failure:enable >NUL 2>&1
:: Command line logging in process creation events
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
:: PowerShell logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockInvocationLogging /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableTranscripting /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v OutputDirectory /t REG_SZ /d "%ccdcpath%\Logs\PSTranscripts" /f >NUL 2>&1
wevtutil sl Security    /ms:1073741824 >NUL 2>&1
wevtutil sl System      /ms:268435456  >NUL 2>&1
wevtutil sl Application /ms:268435456  >NUL 2>&1
echo [+] Advanced logging enabled.
exit /b

:set_password_policy
echo [*] Configuring password policy...
echo [*] Setting password policy... >> "%logfile%"
net accounts /maxpwage:90 /minpwage:0 /minpwlen:14 /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30 >NUL 2>&1
(
echo [System Access]
echo MinimumPasswordAge = 0
echo MaximumPasswordAge = 90
echo MinimumPasswordLength = 14
echo PasswordComplexity = 1
echo PasswordHistorySize = 24
echo LockoutBadCount = 5
echo ResetLockoutCount = 30
echo LockoutDuration = 30
echo ClearTextPassword = 0
echo LSAAnonymousNameLookup = 0
echo EnableGuestAccount = 0
) > "%TEMP%\secpol.cfg"
secedit /configure /cfg "%TEMP%\secpol.cfg" /db "%TEMP%\secpol.sdb" /quiet >NUL 2>&1
del "%TEMP%\secpol.cfg" >NUL 2>&1
del "%TEMP%\secpol.sdb" >NUL 2>&1
echo [+] Password policy configured (14+ chars, complexity, 5-attempt lockout).
exit /b

:disable_guest_account
echo [*] Disabling Guest account...
net user Guest /active:no >NUL 2>&1
net user Guest /passwordreq:yes >NUL 2>&1
echo [+] Guest account disabled.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.1 - SUBROUTINES PART 4
:: Protocol and Component Hardening
:: ============================================================================

:harden_smb
echo [*] Hardening SMB...
echo [*] Hardening SMB... >> "%logfile%"
powershell -Command "Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force" >NUL 2>&1
sc config mrxsmb10 start= disabled >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mrxsmb10" /v Start /t REG_DWORD /d 4 /f >NUL 2>&1
Dism /online /Disable-Feature /FeatureName:SMB1Protocol /NoRestart >NUL 2>&1
powershell -Command "Set-SmbServerConfiguration -DisableCompression $true -Force" >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v EnableSecuritySignature  /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Services\Rdr\Parameters"          /v RequireSecuritySignature /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v RestrictSendingNTLMTraffic /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 5 /f >NUL 2>&1
echo [+] SMB hardened (SMBv1 disabled, signing required, NTLMv1 disabled).
exit /b

:harden_rdp
echo [*] Hardening RDP...
echo [*] Hardening RDP... >> "%logfile%"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v UserAuthentication /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel /t REG_DWORD /d 3 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MinEncryptionLevel /t REG_DWORD /d 3 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fDisableClip /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fDisableCdm  /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxConnectionTime /t REG_DWORD /d 3600000 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime /t REG_DWORD /d 900000 /f >NUL 2>&1
echo [+] RDP hardened (NLA required, high encryption, clipboard disabled).
exit /b

:harden_wmi
echo [*] Hardening WMI...
echo [*] Hardening WMI... >> "%logfile%"
:: Block remote WMI via firewall only - do NOT stop Winmgmt mid-session (crashes shell)
netsh advfirewall firewall add rule name="Block WMI Remote" dir=in action=block protocol=tcp localport=135 >NUL 2>&1
echo [!] WMI subscription cleanup deferred - run Mode 6 after reboot.
echo [+] WMI remote access blocked via firewall.
exit /b

:harden_lsass
echo [*] Hardening LSASS (credential protection)...
echo [*] Hardening LSASS... >> "%logfile%"
:: SAFE registry-only changes - no service restarts, no VBS/PPL (crashes shell)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v NoLMHash /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 5 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v EveryoneIncludesAnonymous /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinClientSec /t REG_DWORD /d 537395200 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinServerSec /t REG_DWORD /d 537395200 /f >NUL 2>&1
echo [+] LSASS hardened (WDigest off, NTLMv1 disabled, anonymous restricted).
echo [!] RunAsPPL and Credential Guard skipped - apply those post-reboot manually.
exit /b

:disable_legacy_protocols
echo [*] Disabling legacy protocols...
echo [*] Disabling legacy protocols... >> "%logfile%"
:: Registry only - safe, takes effect after reboot
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" /v DisabledByDefault /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v DisabledByDefault /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" /v Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" /v Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"  /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL"        /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128"  /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128"  /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128"  /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
echo [+] Legacy protocols disabled (takes effect after reboot).
exit /b

:disable_netbios
echo [*] Disabling NetBIOS over TCP/IP...
echo [*] Disabling NetBIOS... >> "%logfile%"
:: Registry only - do NOT touch live adapters (crashes shell/drops connection)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" /v TransportBindName /t REG_SZ /d "" /f >NUL 2>&1
for /f "tokens=*" %%K in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" 2^>nul') do (
    reg add "%%K" /v NetbiosOptions /t REG_DWORD /d 2 /f >NUL 2>&1
)
echo [+] NetBIOS disabled (takes full effect after reboot).
exit /b

:disable_llmnr
echo [*] Disabling LLMNR...
echo [*] Disabling LLMNR... >> "%logfile%"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f >NUL 2>&1
echo [+] LLMNR disabled.
exit /b

:harden_powershell
echo [*] Hardening PowerShell...
echo [*] Hardening PowerShell... >> "%logfile%"
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force" >NUL 2>&1
powershell -Command "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart" >NUL 2>&1
powershell -Command "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart" >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f >NUL 2>&1
echo [+] PowerShell hardened (v2 disabled, execution policy set, logging enabled).
exit /b

:configure_uac_max
echo [*] Configuring UAC to maximum...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorUser  /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop      /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v FilterAdministratorToken   /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableUIADesktopToggle     /t REG_DWORD /d 0 /f >NUL 2>&1
echo [+] UAC configured to maximum.
exit /b

:enable_aslr_dep
echo [*] Enabling ASLR and DEP system-wide...
echo [*] Enabling ASLR and DEP... >> "%logfile%"
bcdedit /set nx AlwaysOn >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v EnableCfg /t REG_DWORD /d 1 /f >NUL 2>&1
powershell -Command "Set-ProcessMitigation -System -Enable DEP,BottomUp,HighEntropy,SEHOP,TerminateOnHeapError" >NUL 2>&1
echo [+] ASLR and DEP enabled system-wide.
exit /b

:enable_exploit_protection
echo [*] Enabling Windows Exploit Protection...
powershell -Command "Set-ProcessMitigation -System -Enable DEP,BottomUp,HighEntropy,SEHOP,TerminateOnHeapError" >NUL 2>&1
echo [+] Exploit protection enabled.
exit /b

:harden_network_protocols
echo [*] Hardening network protocols...
echo [*] Hardening network protocols... >> "%logfile%"
call :disable_netbios
call :disable_llmnr
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" /v WpadOverride /t REG_DWORD /d 1 /f >NUL 2>&1
:: TCP stack hardening (registry only - safe)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v SynAttackProtect /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxSynBacklog /t REG_DWORD /d 2048 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v PerformRouterDiscovery /t REG_DWORD /d 0 /f >NUL 2>&1
echo [+] Network protocols hardened.
exit /b

:disable_unnecessary_features
echo [*] Disabling unnecessary Windows features...
for %%F in (TelnetClient TFTP SimpleTCP SMB1Protocol MicrosoftWindowsPowerShellV2Root MicrosoftWindowsPowerShellV2) do (
    Dism /online /Disable-Feature /FeatureName:%%F /NoRestart >NUL 2>&1
)
echo [+] Unnecessary features disabled.
exit /b

:disable_autorun_all
echo [*] Disabling AutoRun/AutoPlay...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f >NUL 2>&1
echo [+] AutoRun/AutoPlay disabled.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.1 - SUBROUTINES PART 5
:: Registry Hardening, CIS/STIG/NSA Standards
:: ============================================================================

:harden_registry_full
echo [*] Applying comprehensive registry hardening...
echo [*] Registry hardening starting... >> "%logfile%"

echo [*] Phase 1: Account and logon settings...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "0" /f >NUL 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeCaption /t REG_SZ /d "AUTHORIZED USE ONLY" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeText /t REG_SZ /d "This system is for authorized use only. All activity may be monitored." /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v CachedLogonsCount /t REG_SZ /d "1" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d 900 /f >NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d "900" /f >NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d "1" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v HideFastUserSwitching /t REG_DWORD /d 1 /f >NUL 2>&1

echo [*] Phase 2: Network security settings...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v NullSessionPipes /t REG_MULTI_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v RestrictNullSessAccess /t REG_DWORD /d 1 /f >NUL 2>&1

echo [*] Phase 3: System security settings...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowFullControl /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug" /v Auto /t REG_SZ /d "0" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredUI" /v DisablePasswordReveal /t REG_DWORD /d 1 /f >NUL 2>&1

echo [*] Phase 4: Windows Defender settings...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting /t REG_DWORD /d 2 /f >NUL 2>&1

echo [*] Phase 5: Attack Surface Reduction rules (one at a time to avoid crashes)...
powershell -Command "Set-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 -AttackSurfaceReductionRules_Actions Enabled" >NUL 2>&1
powershell -Command "Set-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A -AttackSurfaceReductionRules_Actions Enabled" >NUL 2>&1
powershell -Command "Set-MpPreference -AttackSurfaceReductionRules_Ids 3B576869-A4EC-4529-8536-B80A7769E899 -AttackSurfaceReductionRules_Actions Enabled" >NUL 2>&1
powershell -Command "Set-MpPreference -AttackSurfaceReductionRules_Ids 75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84 -AttackSurfaceReductionRules_Actions Enabled" >NUL 2>&1
powershell -Command "Set-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC -AttackSurfaceReductionRules_Actions Enabled" >NUL 2>&1
powershell -Command "Set-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B -AttackSurfaceReductionRules_Actions Enabled" >NUL 2>&1
powershell -Command "Set-MpPreference -AttackSurfaceReductionRules_Ids 01443614-CD74-433A-B99E-2ECDC07BFC25 -AttackSurfaceReductionRules_Actions Enabled" >NUL 2>&1

echo [*] Phase 6: Misc hardening...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >NUL 2>&1

echo [+] Registry hardening complete.
echo [+] Registry hardening complete >> "%logfile%"
exit /b

:apply_cis_benchmarks
echo [*] Applying CIS Benchmark settings...
echo [*] Applying CIS benchmarks... >> "%logfile%"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinClientSec /t REG_DWORD /d 537395200 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinServerSec /t REG_DWORD /d 537395200 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v NoLMHash /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v EnableForcedLogOff /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f >NUL 2>&1
auditpol /set /subcategory:"Logon"         /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Special Logon" /success:enable /failure:enable >NUL 2>&1
echo [+] CIS Benchmark settings applied.
exit /b

:apply_stig_settings
echo [*] Applying STIG settings...
echo [*] Applying STIG settings... >> "%logfile%"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d 900 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v NoLmHash /t REG_DWORD /d 1 /f >NUL 2>&1
bcdedit /set nx AlwaysOn >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisableIpSourceRouting /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"  /v DisableIPSourceRouting /t REG_DWORD /d 2 /f >NUL 2>&1
echo [+] STIG settings applied.
exit /b

:apply_nsa_guidance
echo [*] Applying NSA cybersecurity guidance...
echo [*] Applying NSA guidance... >> "%logfile%"
call :harden_smb
call :harden_powershell
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false" >NUL 2>&1
powershell -Command "Set-MpPreference -DisableIOAVProtection $false" >NUL 2>&1
powershell -Command "Set-MpPreference -DisableScriptScanning $false" >NUL 2>&1
echo [+] NSA guidance applied.
exit /b

:harden_certificates
echo [*] Hardening certificate trust...
reg add "HKLM\SOFTWARE\Policies\Microsoft\SystemCertificates\Root\ProtectedRoots" /v Flags /t REG_DWORD /d 1 /f >NUL 2>&1
echo [+] Certificate trust hardened.
exit /b

:harden_browsers
echo [*] Hardening browser security settings...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" /v WpadOverride /t REG_DWORD /d 1 /f >NUL 2>&1
echo [+] Browser security settings hardened.
exit /b

:harden_scheduled_tasks
echo [*] Hardening scheduled tasks...
echo [*] Hardening scheduled tasks... >> "%logfile%"
cmd /c "schtasks /query /fo LIST /v > \"%ccdcpath%\Config\Tasks_before_harden_%timestamp%.txt\" 2>NUL"
for %%T in (
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Maps\MapsUpdateTask"
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
) do (
    schtasks /change /tn "%%T" /disable >NUL 2>&1
)
echo [+] Scheduled tasks hardened.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.1 - SUBROUTINES PART 6
:: Threat Hunting Subroutines - all wrapped in cmd /c for crash safety
:: ============================================================================

:hunt_all_persistence
echo [*] Comprehensive persistence hunting...
call :hunt_persistence_registry
call :hunt_persistence_wmi
call :hunt_persistence_services
call :hunt_persistence_tasks
call :hunt_persistence_files
call :hunt_browser_hijacks
call :hunt_dll_hijacking
echo [+] Comprehensive persistence hunt complete.
exit /b

:hunt_persistence_registry
echo [*] Hunting registry persistence...
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" > \"%ccdcpath%\ThreatHunting\HKCU_Run.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Microsoft\Windows\CurrentVersion\Run\" > \"%ccdcpath%\ThreatHunting\HKLM_Run.txt\" 2>NUL"
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce\" > \"%ccdcpath%\ThreatHunting\HKCU_RunOnce.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce\" > \"%ccdcpath%\ThreatHunting\HKLM_RunOnce.txt\" 2>NUL"
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\RunServices\" > \"%ccdcpath%\ThreatHunting\HKCU_RunServices.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices\" > \"%ccdcpath%\ThreatHunting\HKLM_RunServices.txt\" 2>NUL"
cmd /c "dir /b \"%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\" > \"%ccdcpath%\ThreatHunting\User_Startup.txt\" 2>NUL"
cmd /c "dir /b \"%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup\" > \"%ccdcpath%\ThreatHunting\AllUsers_Startup.txt\" 2>NUL"
cmd /c "reg query \"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\" > \"%ccdcpath%\ThreatHunting\IFEO.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\" > \"%ccdcpath%\ThreatHunting\Winlogon.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows\" /v AppInit_DLLs > \"%ccdcpath%\ThreatHunting\AppInit_x64.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows\" /v AppInit_DLLs > \"%ccdcpath%\ThreatHunting\AppInit_x86.txt\" 2>NUL"
cmd /c "reg query \"HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" /v \"Notification Packages\" > \"%ccdcpath%\ThreatHunting\LSA_NotificationPackages.txt\" 2>NUL"
cmd /c "reg query \"HKLM\SYSTEM\CurrentControlSet\Control\Lsa\" /v \"Authentication Packages\" > \"%ccdcpath%\ThreatHunting\LSA_AuthenticationPackages.txt\" 2>NUL"
cmd /c "reg query \"HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors\" > \"%ccdcpath%\ThreatHunting\PrintMonitors.txt\" 2>NUL"
cmd /c "reg query \"HKCU\Control Panel\Desktop\" /v SCRNSAVE.EXE > \"%ccdcpath%\ThreatHunting\Screensaver.txt\" 2>NUL"
cmd /c "reg query \"HKLM\SOFTWARE\Microsoft\NetSh\" > \"%ccdcpath%\ThreatHunting\NetSH_Helpers.txt\" 2>NUL"
cmd /c "reg query \"HKCU\Software\Classes\CLSID\" > \"%ccdcpath%\ThreatHunting\User_COM_Objects.txt\" 2>NUL"
echo [+] Registry persistence hunt complete.
exit /b

:hunt_persistence_wmi
echo [*] Hunting WMI persistence...
cmd /c "powershell -Command \"Get-WMIObject -Namespace root\Subscription -Class __EventFilter -ErrorAction SilentlyContinue | Select-Object Name,Query | Format-List | Out-File '%ccdcpath%\ThreatHunting\WMI_EventFilters.txt'\""
cmd /c "powershell -Command \"Get-WMIObject -Namespace root\Subscription -Class __EventConsumer -ErrorAction SilentlyContinue | Select-Object Name,CommandLineTemplate | Format-List | Out-File '%ccdcpath%\ThreatHunting\WMI_EventConsumers.txt'\""
cmd /c "powershell -Command \"Get-WMIObject -Namespace root\Subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue | Select-Object Filter,Consumer | Format-List | Out-File '%ccdcpath%\ThreatHunting\WMI_Bindings.txt'\""
echo [+] WMI persistence hunt complete.
exit /b

:hunt_persistence_services
echo [*] Hunting service persistence...
cmd /c "sc query type= service state= all > \"%ccdcpath%\ThreatHunting\All_Services.txt\" 2>NUL"
cmd /c "wmic service get Name,DisplayName,PathName,StartMode,State > \"%ccdcpath%\ThreatHunting\Service_Paths.txt\" 2>NUL"
cmd /c "powershell -Command \"Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\*\Parameters' -ErrorAction SilentlyContinue | Where-Object {$_.ServiceDll} | Select-Object PSPath,ServiceDll | Out-File '%ccdcpath%\ThreatHunting\Service_DLLs.txt'\""
cmd /c "powershell -Command \"Get-WmiObject Win32_Service | Where-Object {$_.PathName -and $_.PathName -notlike '*System32*' -and $_.PathName -notlike '*Program Files*'} | Select-Object Name,PathName | Out-File '%ccdcpath%\ThreatHunting\Suspicious_Services.txt'\""
echo [+] Service persistence hunt complete.
exit /b

:hunt_persistence_tasks
echo [*] Hunting scheduled task persistence...
cmd /c "schtasks /query /fo LIST /v > \"%ccdcpath%\ThreatHunting\ScheduledTasks_Full.txt\" 2>NUL"
cmd /c "powershell -Command \"Get-ScheduledTask | Where-Object {$_.TaskPath -notlike '\Microsoft\*' -and $_.State -ne 'Disabled'} | Select-Object TaskName,TaskPath,State | Out-File '%ccdcpath%\ThreatHunting\NonMicrosoft_Tasks.txt'\""
echo [+] Scheduled task hunt complete.
exit /b

:hunt_persistence_files
echo [*] Hunting file-based persistence...
cmd /c "dir /s /b \"%TEMP%\*.exe\" > \"%ccdcpath%\ThreatHunting\EXE_in_TEMP.txt\" 2>NUL"
cmd /c "dir /s /b \"%APPDATA%\*.exe\" > \"%ccdcpath%\ThreatHunting\EXE_in_APPDATA.txt\" 2>NUL"
cmd /c "dir /s /b \"%LOCALAPPDATA%\Temp\*.exe\" > \"%ccdcpath%\ThreatHunting\EXE_in_LOCALTEMP.txt\" 2>NUL"
cmd /c "dir /s /b \"%TEMP%\*.ps1\" \"%TEMP%\*.vbs\" \"%TEMP%\*.js\" \"%TEMP%\*.hta\" > \"%ccdcpath%\ThreatHunting\Scripts_in_TEMP.txt\" 2>NUL"
cmd /c "powershell -Command \"Get-ChildItem C:\Users -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -match '\.(pdf|doc|xls|zip)\.(exe|bat|ps1|vbs)$'} | Select-Object FullName | Out-File '%ccdcpath%\ThreatHunting\Double_Extension_Files.txt'\""
echo [+] File persistence hunt complete.
exit /b

:hunt_suspicious_processes
echo [*] Analyzing running processes...
cmd /c "tasklist /v > \"%ccdcpath%\ThreatHunting\Processes_Detailed.txt\" 2>NUL"
cmd /c "tasklist /svc > \"%ccdcpath%\ThreatHunting\Processes_Services.txt\" 2>NUL"
cmd /c "wmic process get ProcessId,Name,CommandLine > \"%ccdcpath%\ThreatHunting\Process_CommandLines.txt\" 2>NUL"
cmd /c "powershell -Command \"Get-Process | Select-Object Id,Name,Path | Where-Object {$_.Path -like '*\Temp\*' -or $_.Path -like '*\AppData\*' -or $_.Path -like '*\Users\Public\*'} | Out-File '%ccdcpath%\ThreatHunting\Suspicious_Process_Locations.txt'\""
cmd /c "powershell -Command \"Get-Process | Where-Object {-not $_.Path} | Select-Object Id,Name | Out-File '%ccdcpath%\ThreatHunting\Processes_No_Path.txt'\""
cmd /c "netstat -ano > \"%ccdcpath%\ThreatHunting\Network_Connections.txt\" 2>NUL"
cmd /c "netstat -anob > \"%ccdcpath%\ThreatHunting\Network_Connections_WithBinary.txt\" 2>NUL"
echo [+] Process analysis complete.
exit /b

:hunt_suspicious_network
echo [*] Analyzing network activity...
cmd /c "netstat -ano > \"%ccdcpath%\ThreatHunting\Netstat_Current.txt\" 2>NUL"
cmd /c "route print > \"%ccdcpath%\ThreatHunting\Routing_Table.txt\" 2>NUL"
cmd /c "arp -a > \"%ccdcpath%\ThreatHunting\ARP_Cache.txt\" 2>NUL"
cmd /c "ipconfig /displaydns > \"%ccdcpath%\ThreatHunting\DNS_Cache.txt\" 2>NUL"
cmd /c "type \"%SystemRoot%\System32\drivers\etc\hosts\" > \"%ccdcpath%\ThreatHunting\Hosts_File.txt\" 2>NUL"
cmd /c "net share > \"%ccdcpath%\ThreatHunting\Network_Shares.txt\" 2>NUL"
cmd /c "net use > \"%ccdcpath%\ThreatHunting\Mapped_Drives.txt\" 2>NUL"
cmd /c "netsh advfirewall firewall show rule name=all > \"%ccdcpath%\ThreatHunting\Firewall_Rules.txt\" 2>NUL"
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\" > \"%ccdcpath%\ThreatHunting\Proxy_Settings.txt\" 2>NUL"
echo [+] Network analysis complete.
exit /b

:hunt_suspicious_files
echo [*] Searching for suspicious files...
cmd /c "powershell -Command \"Get-ChildItem C:\Users -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.CreationTime -gt (Get-Date).AddDays(-7) -and $_.Extension -in @('.exe','.dll','.bat','.ps1','.vbs','.js','.hta')} | Select-Object FullName,CreationTime | Sort-Object CreationTime -Descending | Out-File '%ccdcpath%\ThreatHunting\Recent_Executables.txt'\""
cmd /c "powershell -Command \"Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Length -gt 10MB} | Select-Object FullName,Length | Out-File '%ccdcpath%\ThreatHunting\Large_Temp_Files.txt'\""
echo [+] Suspicious file search complete.
exit /b

:hunt_browser_hijacks
echo [*] Hunting browser hijacks...
cmd /c "reg query \"HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\" > \"%ccdcpath%\ThreatHunting\BHO_x64.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\" > \"%ccdcpath%\ThreatHunting\BHO_x86.txt\" 2>NUL"
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\" > \"%ccdcpath%\ThreatHunting\Proxy_Settings.txt\" 2>NUL"
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Extensions" (
    cmd /c "dir /b \"%LOCALAPPDATA%\Google\Chrome\User Data\Default\Extensions\" > \"%ccdcpath%\ThreatHunting\Chrome_Extensions.txt\" 2>NUL"
)
echo [+] Browser hijack hunt complete.
exit /b

:hunt_dll_hijacking
echo [*] Hunting DLL hijacking...
cmd /c "reg query \"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\" /v SafeDllSearchMode > \"%ccdcpath%\ThreatHunting\SafeDllSearchMode.txt\" 2>NUL"
cmd /c "dir /s /b \"%USERPROFILE%\*.dll\" > \"%ccdcpath%\ThreatHunting\DLLs_UserProfile.txt\" 2>NUL"
cmd /c "echo %PATH% > \"%ccdcpath%\ThreatHunting\PATH_Variable.txt\" 2>NUL"
echo [+] DLL hijacking hunt complete.
exit /b

:analyze_autoruns
echo [*] Compiling autorun report...
(
echo ================================================================================
echo Autoruns Analysis - %timestamp%
echo ================================================================================
echo.
echo [HKCU Run Keys]
) > "%ccdcpath%\ThreatHunting\Autoruns_Comprehensive.txt"
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" >> \"%ccdcpath%\ThreatHunting\Autoruns_Comprehensive.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Microsoft\Windows\CurrentVersion\Run\" >> \"%ccdcpath%\ThreatHunting\Autoruns_Comprehensive.txt\" 2>NUL"
cmd /c "reg query \"HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\" >> \"%ccdcpath%\ThreatHunting\Autoruns_Comprehensive.txt\" 2>NUL"
echo [+] Autorun analysis complete.
exit /b

:check_known_malware_paths
echo [*] Checking known malware paths...
(echo Known Malware Path Check - %timestamp%) > "%ccdcpath%\ThreatHunting\Known_Malware_Paths.txt"
for %%P in ("C:\Windows\Temp" "C:\Windows\Tasks" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" "C:\Users\Public") do (
    if exist %%P (
        echo [%%P] >> "%ccdcpath%\ThreatHunting\Known_Malware_Paths.txt"
        cmd /c "dir /s /b %%P >> \"%ccdcpath%\ThreatHunting\Known_Malware_Paths.txt\" 2>NUL"
    )
)
echo [+] Known malware path check complete.
exit /b

:analyze_prefetch
echo [*] Analyzing prefetch files...
if exist "C:\Windows\Prefetch" (
    cmd /c "dir /b /o:-d \"C:\Windows\Prefetch\*.pf\" > \"%ccdcpath%\ThreatHunting\Prefetch_Files.txt\" 2>NUL"
)
echo [+] Prefetch analysis complete.
exit /b

:check_alternate_data_streams
echo [*] Checking for Alternate Data Streams...
for %%D in ("C:\Windows\Temp" "%USERPROFILE%\Desktop" "%USERPROFILE%\Downloads") do (
    cmd /c "dir /r %%D 2>NUL | find \":$DATA\" >> \"%ccdcpath%\ThreatHunting\Alternate_Data_Streams.txt\" 2>NUL"
)
echo [+] ADS check complete.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.1 - SUBROUTINES PART 7
:: System Repair, Performance, Network Diagnostics
:: ============================================================================

:repair_windows_explorer
echo [*] Repairing Windows Explorer...
taskkill /f /im explorer.exe >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >NUL 2>&1
start explorer.exe
echo [+] Explorer restarted.
exit /b

:emergency_restore_explorer
echo [*] Emergency Explorer restoration...
taskkill /f /im explorer.exe >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >NUL 2>&1
if not exist "%SystemRoot%\explorer.exe" (
    echo [!] CRITICAL: explorer.exe missing!
    if exist "%SystemRoot%\System32\dllcache\explorer.exe" (
        copy /y "%SystemRoot%\System32\dllcache\explorer.exe" "%SystemRoot%\explorer.exe" >NUL 2>&1
    )
)
start %SystemRoot%\explorer.exe
echo [+] Emergency Explorer restoration complete.
exit /b

:repair_system_files
echo [*] Running System File Checker (SFC)...
echo [*] This may take 10-30 minutes...
sfc /scannow
echo [+] SFC complete.
exit /b

:repair_component_store
echo [*] Repairing component store with DISM...
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /RestoreHealth
echo [+] DISM repair complete.
exit /b

:repair_windows_update
echo [*] Repairing Windows Update...
net stop wuauserv  >NUL 2>&1
net stop cryptSvc  >NUL 2>&1
net stop bits      >NUL 2>&1
net stop msiserver >NUL 2>&1
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old >NUL 2>&1
ren C:\Windows\System32\catroot2 catroot2.old >NUL 2>&1
for %%D in (atl.dll urlmon.dll mshtml.dll jscript.dll vbscript.dll ole32.dll oleaut32.dll shell32.dll wuapi.dll wuaueng.dll wups.dll wups2.dll qmgr.dll) do (
    regsvr32.exe /s %%D >NUL 2>&1
)
net start wuauserv  >NUL 2>&1
net start cryptSvc  >NUL 2>&1
net start bits      >NUL 2>&1
net start msiserver >NUL 2>&1
echo [+] Windows Update repair complete.
exit /b

:repair_event_logs
echo [*] Repairing Event Log service...
net stop EventLog >NUL 2>&1
wevtutil cl System      >NUL 2>&1
wevtutil cl Application >NUL 2>&1
net start EventLog >NUL 2>&1
echo [+] Event Log repaired.
exit /b

:repair_windows_defender
echo [*] Repairing Windows Defender...
cmd /c "\"%ProgramFiles%\Windows Defender\MpCmdRun.exe\" -SignatureUpdate >NUL 2>&1"
echo [+] Windows Defender updated.
exit /b

:clear_temp_files
echo [*] Clearing temporary files...
del /f /s /q "%SystemRoot%\Temp\*.*" >NUL 2>&1
del /f /s /q "%TEMP%\*.*" >NUL 2>&1
del /f /q "%SystemRoot%\Prefetch\*.*" >NUL 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*.*" >NUL 2>&1
echo [+] Temp files cleared.
exit /b

:delete_temp_files_aggressive
echo [*] Aggressively deleting temp files...
call :clear_temp_files
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >NUL 2>&1
)
if exist "%APPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%F in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do (
        rd /s /q "%%F\cache2" >NUL 2>&1
    )
)
echo [+] Aggressive temp deletion complete.
exit /b

:rebuild_icon_cache
echo [*] Rebuilding icon cache...
taskkill /f /im explorer.exe >NUL 2>&1
del /f /a "%LOCALAPPDATA%\IconCache.db" >NUL 2>&1
del /f /a /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\*.db" >NUL 2>&1
start explorer.exe
echo [+] Icon cache rebuilt.
exit /b

:check_disk_health
echo [*] Checking disk health...
cmd /c "wmic diskdrive get status,model > \"%ccdcpath%\Repair\Disk_SMART_Status.txt\" 2>NUL"
echo [+] Disk health: %ccdcpath%\Repair\Disk_SMART_Status.txt
exit /b

:emergency_process_termination
echo [*] EMERGENCY: Terminating suspicious interpreter processes...
for %%P in (wscript.exe cscript.exe mshta.exe) do (
    taskkill /f /im %%P >NUL 2>&1
)
echo [+] Emergency process termination complete.
echo [!] cmd.exe and powershell.exe preserved to keep your session alive.
exit /b

:emergency_restore_services
echo [*] Restoring critical Windows services...
for %%S in (Winmgmt EventLog Dhcp Dnscache LanmanWorkstation RpcSs SENS ShellHWDetection Schedule) do (
    sc config %%S start= auto >NUL 2>&1
    net start %%S >NUL 2>&1
)
echo [+] Critical services restored.
exit /b

:identify_resource_hogs
echo [*] Identifying resource hogs...
cmd /c "powershell -Command \"Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table ProcessName,CPU,@{N='RAM_MB';E={[math]::Round($_.WorkingSet/1MB,1)}},Id -AutoSize | Out-File '%ccdcpath%\Repair\Top_CPU_Users.txt'\""
cmd /c "powershell -Command \"Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | Format-Table ProcessName,@{N='RAM_MB';E={[math]::Round($_.WorkingSet/1MB,1)}},Id -AutoSize | Out-File '%ccdcpath%\Repair\Top_Memory_Users.txt'\""
echo [+] Resource hogs identified: %ccdcpath%\Repair\
exit /b

:disable_telemetry
echo [*] Disabling telemetry...
sc config DiagTrack       start= disabled >NUL 2>&1 & net stop DiagTrack       /y >NUL 2>&1
sc config dmwappushservice start= disabled >NUL 2>&1 & net stop dmwappushservice /y >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >NUL 2>&1
echo [+] Telemetry disabled.
exit /b

:disable_superfetch
echo [*] Disabling Superfetch/SysMain...
sc config SysMain start= disabled >NUL 2>&1
net stop SysMain /y >NUL 2>&1
echo [+] Superfetch disabled.
exit /b

:optimize_page_file
echo [*] Setting page file to system-managed...
powershell -Command "$cs = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges; $cs.AutomaticManagedPagefile = $true; $cs.Put()" >NUL 2>&1
echo [+] Page file optimized.
exit /b

:optimize_startup
echo [*] Auditing startup programs...
cmd /c "wmic startup get caption,command,location > \"%ccdcpath%\Repair\Startup_Items.txt\" 2>NUL"
echo [+] Startup items: %ccdcpath%\Repair\Startup_Items.txt
exit /b

:disable_maintenance_tasks
echo [*] Disabling Windows maintenance tasks...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f >NUL 2>&1
schtasks /change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /disable >NUL 2>&1
echo [+] Maintenance tasks disabled.
exit /b

:optimize_performance
echo [*] Applying performance optimizations...
call :disable_telemetry
call :disable_superfetch
call :optimize_page_file
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >NUL 2>&1
echo [+] Performance optimizations applied.
exit /b

:: ============================================================================
:: NETWORK DIAGNOSTICS - safe versions (no ipconfig /release /renew)
:: ============================================================================

:diagnose_network
echo [*] Running network diagnostics...
cmd /c "ping -n 4 8.8.8.8 > \"%ccdcpath%\Repair\Network_Ping_Test.txt\" 2>NUL"
cmd /c "nslookup google.com > \"%ccdcpath%\Repair\Network_DNS_Test.txt\" 2>NUL"
cmd /c "ipconfig /all > \"%ccdcpath%\Repair\Network_IPConfig.txt\" 2>NUL"
echo [+] Network diagnostics saved to %ccdcpath%\Repair\
exit /b

:flush_dns
echo [*] Flushing DNS cache...
ipconfig /flushdns >NUL 2>&1
echo [+] DNS cache flushed.
exit /b

:fix_dns_client
echo [*] Fixing DNS Client service...
net stop Dnscache  >NUL 2>&1
net start Dnscache >NUL 2>&1
sc config Dnscache start= auto >NUL 2>&1
echo [+] DNS Client restarted.
exit /b

:test_connectivity
echo [*] Testing connectivity...
ping -n 1 8.8.8.8 >NUL 2>&1
if %errorlevel% EQU 0 (echo [+] Internet connectivity: OK) else (echo [!] Internet connectivity: FAILED)
nslookup google.com >NUL 2>&1
if %errorlevel% EQU 0 (echo [+] DNS resolution: OK) else (echo [!] DNS resolution: FAILED)
exit /b

:check_proxy_settings
echo [*] Checking proxy settings...
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\" > \"%ccdcpath%\Repair\Proxy_Settings.txt\" 2>NUL"
echo [+] Proxy settings: %ccdcpath%\Repair\Proxy_Settings.txt
exit /b

:: NOTE: repair_network_stack intentionally removed - ipconfig /release drops connections
:: To manually reset network stack run these LOCALLY (not over RDP):
::   netsh winsock reset
::   netsh int ip reset
::   ipconfig /release
::   ipconfig /renew
::   Then reboot.

:: ============================================================================
:: PROVIDENCE MAX v3.1 - SUBROUTINES PART 8
:: Malware Cleanup, Baseline Creator, Utility Subroutines
:: ============================================================================

:quarantine_suspicious_files
echo [*] Quarantining suspicious files...
set "quarantine_dir=%ccdcpath%\Quarantine\%timestamp%"
mkdir "%quarantine_dir%" >NUL 2>&1
if exist "%TEMP%\*.exe"  move /y "%TEMP%\*.exe"  "%quarantine_dir%\" >NUL 2>&1
for %%E in (vbs js hta ps1 bat cmd wsf) do (
    if exist "%TEMP%\*.%%E" move /y "%TEMP%\*.%%E" "%quarantine_dir%\" >NUL 2>&1
    move /y "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*.%%E" "%quarantine_dir%\" >NUL 2>&1
    move /y "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*.%%E" "%quarantine_dir%\" >NUL 2>&1
)
echo [+] Quarantine complete: %quarantine_dir%
exit /b

:remove_all_persistence
echo [*] Removing all persistence mechanisms...
call :clear_all_persistence
cmd /c "schtasks /query /fo LIST /v > \"%ccdcpath%\Config\Tasks_before_cleanup_%timestamp%.txt\" 2>NUL"
echo.
set /p "delete_user_tasks=Delete all non-Microsoft scheduled tasks? [y/n]: "
if /i "%delete_user_tasks%"=="y" (
    powershell -Command "Get-ScheduledTask | Where-Object {$_.TaskPath -notlike '\Microsoft\*'} | Unregister-ScheduledTask -Confirm:$false" >NUL 2>&1
    echo [+] Non-Microsoft tasks removed.
)
echo [+] Persistence removal complete.
exit /b

:kill_suspicious_processes
echo [*] Killing processes from suspicious locations...
powershell -Command "Get-Process | Where-Object {$_.Path -like '*\Temp\*' -or $_.Path -like '*\Users\Public\*'} | ForEach-Object { Write-Host \"Killing: $($_.Name)\"; Stop-Process -Id $_.Id -Force }" >NUL 2>&1
for %%P in (wscript.exe cscript.exe mshta.exe) do (
    taskkill /f /im %%P >NUL 2>&1
)
echo [+] Suspicious processes terminated.
exit /b

:clean_browser_completely
echo [*] Cleaning browsers...
call :delete_temp_files_aggressive
RunDll32.exe InetCpl.cpl,ResetIEtoDefaults >NUL 2>&1
echo.
set /p "clear_chrome=Completely reset Chrome (DELETES ALL DATA)? [y/n]: "
if /i "%clear_chrome%"=="y" (
    taskkill /f /im chrome.exe >NUL 2>&1
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data" >NUL 2>&1
    echo [+] Chrome data removed.
)
echo [+] Browsers cleaned.
exit /b

:remove_suspicious_services
echo [*] Identifying suspicious services...
cmd /c "powershell -Command \"Get-WmiObject Win32_Service | Where-Object {$_.PathName -and $_.PathName -notlike '*System32*' -and $_.PathName -notlike '*Program Files*' -and $_.StartMode -ne 'Disabled'} | Select-Object Name,PathName | Format-Table -AutoSize | Out-File '%ccdcpath%\ThreatHunting\Suspicious_Services.txt'\""
echo [+] Suspicious services logged: %ccdcpath%\ThreatHunting\Suspicious_Services.txt
echo [!] Review and stop/delete manually: sc stop [name] then sc delete [name]
exit /b

:clean_wmi_completely
echo [*] Removing WMI persistence subscriptions...
powershell -Command "Get-WMIObject -Namespace root\Subscription -Class __EventFilter -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue" >NUL 2>&1
powershell -Command "Get-WMIObject -Namespace root\Subscription -Class __EventConsumer -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue" >NUL 2>&1
powershell -Command "Get-WMIObject -Namespace root\Subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue" >NUL 2>&1
net stop Winmgmt /y >NUL 2>&1
net start Winmgmt   >NUL 2>&1
echo [+] WMI subscriptions cleaned.
echo [!] NOTE: Only run this mode after rebooting - stopping Winmgmt mid-session is safe post-reboot.
exit /b

:reset_hosts_file
echo [*] Resetting hosts file...
copy /y "%SystemRoot%\System32\drivers\etc\hosts" "%ccdcpath%\Config\hosts_backup_%timestamp%.txt" >NUL 2>&1
(
echo # Copyright ^(c^) 1993-2009 Microsoft Corp.
echo #
echo # This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
echo #
echo 127.0.0.1       localhost
echo ::1             localhost
) > "%SystemRoot%\System32\drivers\etc\hosts"
echo [+] Hosts file reset. Backup saved.
exit /b

:clear_dns_cache
echo [*] Clearing DNS cache...
ipconfig /flushdns >NUL 2>&1
echo [+] DNS cache cleared.
exit /b

:remove_proxy_settings
echo [*] Removing proxy settings...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >NUL 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer   /f >NUL 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >NUL 2>&1
netsh winhttp reset proxy >NUL 2>&1
echo [+] Proxy settings removed.
exit /b

:clean_scheduled_tasks_aggressive
echo [*] Cleaning scheduled tasks...
cmd /c "schtasks /query /fo LIST /v > \"%ccdcpath%\Config\ScheduledTasks_Before_Cleanup_%timestamp%.txt\" 2>NUL"
echo.
set /p "confirm_tasks=Delete ALL non-Microsoft scheduled tasks? [y/n]: "
if /i "%confirm_tasks%"=="y" (
    powershell -Command "Get-ScheduledTask | Where-Object {$_.TaskPath -notlike '\Microsoft\*'} | Unregister-ScheduledTask -Confirm:$false" >NUL 2>&1
    echo [+] Non-Microsoft tasks deleted.
)
exit /b

:: ============================================================================
:: SUBROUTINE: CREATE BASELINE
:: All operations wrapped in cmd /c to prevent crashes killing the shell
:: ============================================================================
:create_baseline
echo [*] Creating system baseline snapshot...
set "baseline_dir=%ccdcpath%\Baseline\%timestamp%"
mkdir "%baseline_dir%" >NUL 2>&1

echo [*] Collecting user accounts...
cmd /c "wmic useraccount list brief > \"%baseline_dir%\Users.txt\" 2>NUL"
cmd /c "net localgroup administrators > \"%baseline_dir%\Administrators.txt\" 2>NUL"
cmd /c "wmic group list brief > \"%baseline_dir%\Groups.txt\" 2>NUL"

echo [*] Collecting services...
cmd /c "sc query type= service state= all > \"%baseline_dir%\Services.txt\" 2>NUL"
cmd /c "wmic service get Name,DisplayName,PathName,StartMode,State > \"%baseline_dir%\Services_Detailed.txt\" 2>NUL"

echo [*] Collecting scheduled tasks...
cmd /c "schtasks /query /fo LIST /v > \"%baseline_dir%\ScheduledTasks.txt\" 2>NUL"

echo [*] Collecting processes...
cmd /c "tasklist /v > \"%baseline_dir%\Processes.txt\" 2>NUL"
cmd /c "wmic process get ProcessId,Name,CommandLine > \"%baseline_dir%\Process_CommandLines.txt\" 2>NUL"

echo [*] Collecting network state...
cmd /c "netstat -ano > \"%baseline_dir%\NetworkConnections.txt\" 2>NUL"
cmd /c "ipconfig /all > \"%baseline_dir%\NetworkConfig.txt\" 2>NUL"
cmd /c "arp -a > \"%baseline_dir%\ARP.txt\" 2>NUL"
cmd /c "route print > \"%baseline_dir%\Routes.txt\" 2>NUL"
cmd /c "net share > \"%baseline_dir%\Shares.txt\" 2>NUL"

echo [*] Collecting installed programs...
cmd /c "wmic product get name,version,vendor > \"%baseline_dir%\InstalledPrograms.txt\" 2>NUL"

echo [*] Collecting startup programs...
cmd /c "wmic startup get caption,command,location > \"%baseline_dir%\StartupPrograms.txt\" 2>NUL"

echo [*] Collecting registry run keys...
cmd /c "reg query \"HKCU\Software\Microsoft\Windows\CurrentVersion\Run\" > \"%baseline_dir%\HKCU_Run.txt\" 2>NUL"
cmd /c "reg query \"HKLM\Software\Microsoft\Windows\CurrentVersion\Run\" > \"%baseline_dir%\HKLM_Run.txt\" 2>NUL"

echo [*] Collecting firewall rules...
cmd /c "netsh advfirewall firewall show rule name=all > \"%baseline_dir%\FirewallRules.txt\" 2>NUL"

echo [*] Collecting system info...
cmd /c "systeminfo > \"%baseline_dir%\SystemInfo.txt\" 2>NUL"

echo [*] Collecting audit policy...
cmd /c "auditpol /get /category:* > \"%baseline_dir%\AuditPolicy.txt\" 2>NUL"

echo [*] Collecting security policy...
cmd /c "secedit /export /cfg \"%baseline_dir%\SecurityPolicy.cfg\" >NUL 2>&1"

echo [*] Collecting WMI subscriptions...
cmd /c "powershell -Command \"Get-WMIObject -Namespace root\Subscription -Class __EventFilter -ErrorAction SilentlyContinue | Select-Object Name,Query | Out-File '%baseline_dir%\WMI_Subscriptions.txt'\""

echo [*] Hashing System32 executables (this takes a minute)...
cmd /c "powershell -Command \"Get-ChildItem 'C:\Windows\System32\*.exe' | Get-FileHash -Algorithm SHA256 | Select-Object Path,Hash | Out-File '%baseline_dir%\System32_Hashes.txt'\""

(
echo ================================================================================
echo  Providence MAX 3.1 Baseline Manifest
echo  Created: %timestamp%
echo  Computer: %COMPUTERNAME%
echo  Domain:   %USERDOMAIN%
echo ================================================================================
) > "%baseline_dir%\MANIFEST.txt"
cmd /c "dir /b \"%baseline_dir%\" >> \"%baseline_dir%\MANIFEST.txt\""

echo [+] Baseline created: %baseline_dir%
echo [*] Compare states with: fc baseline1\file.txt baseline2\file.txt
exit /b

:: ============================================================================
:: END OF PROVIDENCE MAX v3.1
:: ============================================================================
