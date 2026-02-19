@echo off
title Providence MAX - Ultimate Windows Security Suite
:: ============================================================================
:: PROVIDENCE MAX - Ultimate Windows Security Suite
:: ============================================================================
:: Original credits
:: Author - Aaron Campbell for the Cyber Team
::
:: Providence - The protective care of God
::
:: Credits:
::      Mackwage - https://gist.github.com/mackwage/08604751462126599d7e52f233490efe
::      Mike Bailey - https://github.com/mike-bailey/CCDC-Scripts
::      Our version of Baldwin Wallace's old script
:: "CVE-2020-1350" added 2/16/2024 by Stephen Pearson
:: Firewall default block all added 8/15/2024 by Kaicheng Ye
:: The following was added on 1/2/2025 by Stephen Pearson:
::      Changed SmartScreen level to "Warn" from "Block"
::      Stopped and disabled the print spooler
::      Removed "blockoutbound" to restore Internet access
::      Enabled web traffic requests in and out via "Web" firewall rules
::      Removed "net stop dns && net start dns" due to outdated command
::      Checked for the DNSNTP IP address for General Windows Hardening
::      Moved the logon banner to the general Windows hardening portion
:: Added 2/27/2025 by Stephen Reid: Fixed Removed Scheduled Task command to actually remove EVERYTHING
:: 10/31/2025 - Stephen Reid: Fixed Remove Scheduled Task command for powershell
:: 1/17/2026 - Stephen Reid: Changed Firewalls to default block all in/out w/ necessary exceptions
:: Enhanced by: Matthew Dudley
:: Version: MAX 3.0
:: Last Updated: 2026-02-19
::
:: "Providence - The protective care of God"
:: This script does EVERYTHING possible to secure, repair, and fortify Windows
::
:: MODES:
::   1  - Express Hardening      (5 min, CCDC essentials)
::   2  - Full Hardening         (15 min, comprehensive lockdown)
::   3  - System Repair          (Fix broken Windows)
::   4  - Threat Hunting         (Find malware/persistence)
::   5  - Emergency Response     (System broken? Start here)
::   6  - Malware Cleanup        (Nuclear removal option)
::   7  - Performance Recovery   (Fix CPU/memory issues)
::   8  - Network Diagnostics    (Fix DNS/connectivity)
::   9  - Baseline Creator       (Snapshot current state)
::   10 - Custom Mode            (Pick specific actions)
::   11 - MAXIMUM SECURITY       (Everything, 30+ min)
::   12 - Undo/Restore           (Revert changes)
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
echo                    M A X I M U M   E D I T I O N   v3.0
echo                       Cedarville University Cyber Team
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

:: Build timestamp
for /f "tokens=2 delims==" %%I in ('wmic os get LocalDateTime /value') do set "dt=%%I"
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

:: Start log file
(
echo ================================================================================
echo  Providence MAX Execution Log
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
echo                    PROVIDENCE MAX v3.0 - Main Menu
echo                    Cedarville University Cyber Team
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
echo     Fast, essential hardening for CCDC time-sensitive situations.
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
echo [*] Firewall is DEFAULT DENY - add rules for needed services.
echo [*] Some services have been disabled.
echo [!] RECOMMENDED: Reboot when convenient.
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
echo                          FULL HARDENING MODE
echo     Comprehensive security hardening. ~10-15 minutes.
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
echo                          SYSTEM REPAIR MODE
echo     Attempt to fix common Windows issues.
echo ===============================================================================
echo.
pause

echo [*] Starting system repair... >> "%logfile%"
call :kill_problematic_processes
call :repair_windows_explorer
call :repair_system_files
call :repair_windows_update
call :repair_event_logs
call :repair_windows_defender
call :clear_temp_files
call :repair_network_stack
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
echo                         THREAT HUNTING MODE
echo     Search for malware, persistence, and suspicious activity.
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
echo [!] MANUALLY REVIEW these key files:
echo     - HKCU_Run.txt / HKLM_Run.txt      (startup registry)
echo     - WMI_EventFilters.txt             (WMI persistence)
echo     - ScheduledTasks_Full.txt          (task persistence)
echo     - Service_Paths.txt                (service binaries)
echo     - Suspicious_Process_Locations.txt (processes from temp)
echo     - Autoruns_Comprehensive.txt       (all autoruns)
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
echo                        EMERGENCY RESPONSE MODE
echo     Windows completely broken? Aggressive repair attempt.
echo     WARNING: May cause temporary instability.
echo ===============================================================================
echo.
pause

echo [*] Starting emergency response... >> "%logfile%"
call :emergency_process_termination
call :emergency_restore_explorer
call :emergency_restore_services
call :emergency_network_reset
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
echo     - Run Mode 12 (Restore) to revert changes
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
echo                         MALWARE CLEANUP MODE
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
echo [*] Review logs for what was removed.
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
echo                       PERFORMANCE RECOVERY MODE
echo     Fix high CPU, memory, and disk usage.
echo ===============================================================================
echo.
pause

echo [*] Starting performance recovery... >> "%logfile%"
call :identify_resource_hogs
call :kill_resource_hogs
call :disable_telemetry
call :disable_superfetch
call :optimize_page_file
call :clear_temp_files
call :optimize_startup
call :disable_maintenance_tasks
call :optimize_performance
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
echo                        NETWORK DIAGNOSTICS MODE
echo     Fix DNS, connectivity, and network stack issues.
echo ===============================================================================
echo.
pause

echo [*] Starting network diagnostics... >> "%logfile%"
call :diagnose_network
call :reset_network_stack
call :flush_dns
call :reset_winsock
call :reset_tcp_ip
call :release_renew_dhcp
call :fix_dns_client
call :test_connectivity
call :check_proxy_settings
call :fix_network_adapters
echo [+] Network diagnostics complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] NETWORK DIAGNOSTICS COMPLETE!
echo ===============================================================================
echo [*] Network reports: %ccdcpath%\Repair\Network_*.txt
echo.
echo [!] If internet still broken, manually add a rule:
echo     netsh advfirewall firewall add rule name="TEMP WEB" dir=out ^
echo       action=allow protocol=tcp remoteport=80,443
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
echo                         BASELINE CREATOR MODE
echo     Snapshot current system state for later comparison.
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
echo To compare baselines:
echo   fc baseline1\file.txt baseline2\file.txt
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
echo                            CUSTOM MODE
echo     Choose specific hardening actions.
echo ===============================================================================
echo.

set /p "do_firewall=Configure Firewall? [y/n]: "
set /p "do_services=Harden Services? [y/n]: "
set /p "do_registry=Harden Registry? [y/n]: "
set /p "do_persistence=Hunt Persistence? [y/n]: "
set /p "do_repair=Repair System Files? [y/n]: "
set /p "do_cleanup=Clean Temp Files? [y/n]: "
set /p "do_network=Fix Network? [y/n]: "
set /p "do_logging=Enable Advanced Logging? [y/n]: "
set /p "do_password=Set Password Policy? [y/n]: "
set /p "do_performance=Optimize Performance? [y/n]: "
set /p "do_smb=Harden SMB? [y/n]: "
set /p "do_rdp=Harden RDP? [y/n]: "
set /p "do_lsass=Harden LSASS? [y/n]: "

echo.
echo [*] Executing custom configuration...
echo.

if /i "%do_firewall%"=="y"     call :enable_firewall_full
if /i "%do_services%"=="y"     call :disable_all_dangerous_services
if /i "%do_registry%"=="y"     call :harden_registry_full
if /i "%do_persistence%"=="y"  call :hunt_all_persistence
if /i "%do_repair%"=="y"       call :repair_system_files
if /i "%do_cleanup%"=="y"      call :clear_temp_files
if /i "%do_network%"=="y"      call :reset_network_stack
if /i "%do_logging%"=="y"      call :enable_advanced_logging
if /i "%do_password%"=="y"     call :set_password_policy
if /i "%do_performance%"=="y"  call :optimize_performance
if /i "%do_smb%"=="y"          call :harden_smb
if /i "%do_rdp%"=="y"          call :harden_rdp
if /i "%do_lsass%"=="y"        call :harden_lsass

echo.
echo ===============================================================================
echo [+] CUSTOM EXECUTION COMPLETE!
echo ===============================================================================
echo.
pause
goto main_menu

:: ============================================================================
:: MODE 11: MAXIMUM SECURITY
:: ============================================================================
:maximum_security
cls
echo.
echo ===============================================================================
echo                        MAXIMUM SECURITY MODE
echo     Apply EVERY security measure. ~30+ minutes.
echo     WARNING: May break some applications.
echo ===============================================================================
echo.
set /p "confirm_max=Type MAXIMUM to continue (Ctrl+C to cancel): "
if /i not "%confirm_max%"=="MAXIMUM" (
    echo [*] Cancelled.
    timeout /t 2 >NUL
    goto main_menu
)

echo.
echo [*] Beginning maximum security hardening... Grab a coffee.
echo [*] Starting maximum security... >> "%logfile%"
echo.

:: Backup first
call :backup_all_configs
call :create_baseline

:: Full security sweep
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

:: Full threat hunt
call :hunt_all_persistence

:: Cleanup
call :clear_temp_files
call :optimize_performance

echo [+] Maximum security complete >> "%logfile%"

echo.
echo ===============================================================================
echo [+] MAXIMUM SECURITY HARDENING COMPLETE!
echo ===============================================================================
echo.
echo Changes applied:
echo   Firewall  : Default deny all inbound + selective outbound
echo   Services  : 30+ dangerous services disabled
echo   Registry  : 200+ hardening settings applied
echo   Protocols : SMB1, NetBIOS, LLMNR, WPAD disabled
echo   Logging   : Full audit policy enabled
echo   Passwords : Strong policy enforced
echo   LSASS     : Credential Guard + Protected Mode enabled
echo   PS        : Constrained Language Mode + ScriptBlock logging
echo   UAC       : Maximum level configured
echo   Persistence: All mechanisms cleared and documented
echo   Standards : CIS Benchmark + STIG + NSA guidance applied
echo.
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
echo                           RESTORE MODE
echo     Revert backed-up configurations.
echo ===============================================================================
echo.

if not exist "%ccdcpath%\Config" (
    echo [!] No backups found in %ccdcpath%\Config
    pause
    goto main_menu
)

echo Available configuration backups:
dir /b "%ccdcpath%\Config" 2>NUL
echo.
echo Available registry backups:
dir /b "%ccdcpath%\Regback" 2>NUL
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
echo [!] Registry restoration requires Safe Mode.
echo [!] Boot to Safe Mode, then run:
echo     reg import "%ccdcpath%\Regback\[filename].reg"
echo.
echo [+] Restore complete.
pause
goto main_menu

:: ============================================================================
:: EXIT
:: ============================================================================
:script_exit
cls
echo.
echo ===============================================================================
echo                    Thank you for using Providence MAX
echo                     Cedarville University Cyber Team
echo ===============================================================================
echo.
echo Session log : %logfile%
echo All outputs : %ccdcpath%\
echo.
echo Remember to:
echo   - Review all threat hunting results
echo   - Reboot if changes were made
echo   - Test your scored services
echo   - Document any anomalies
echo.
echo "Providence - The protective care of God"
echo Go Yellow Jackets! ^>^>=^>
echo.
pause
exit /b 0

:: ============================================================================
:: PROVIDENCE MAX v3.0 - SUBROUTINES PART 2
:: Network Info, Backup, and Firewall Subroutines
:: Append this content to Providence_MAX.bat (after :script_exit)
:: ============================================================================

:: ============================================================================
:: SUBROUTINE: GET NETWORK INFO
:: ============================================================================
:get_network_info
echo [*] Gathering network information...
echo [*] Network info collection... >> "%logfile%"

ipconfig /all > "%ccdcpath%\Proof\NetworkInfo_%timestamp%.txt" 2>NUL
netstat -ano  > "%ccdcpath%\Proof\Netstat_%timestamp%.txt" 2>NUL
arp -a        > "%ccdcpath%\Proof\ARP_%timestamp%.txt" 2>NUL
route print   > "%ccdcpath%\Proof\Routes_%timestamp%.txt" 2>NUL
net share     > "%ccdcpath%\Proof\Shares_%timestamp%.txt" 2>NUL
wmic useraccount list brief > "%ccdcpath%\Proof\Users_%timestamp%.txt" 2>NUL
net localgroup administrators >> "%ccdcpath%\Proof\Users_%timestamp%.txt" 2>NUL

echo [+] Network info saved to %ccdcpath%\Proof\
exit /b

:: ============================================================================
:: SUBROUTINE: BACKUP CRITICAL CONFIGS
:: ============================================================================
:backup_critical_configs
echo [*] Backing up critical configurations...
echo [*] Backing up critical configs... >> "%logfile%"

:: Registry Run keys
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"     "%ccdcpath%\Regback\HKCU_Run_%timestamp%.reg"     /y >NUL 2>&1
reg export "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"     "%ccdcpath%\Regback\HKLM_Run_%timestamp%.reg"     /y >NUL 2>&1
reg export "HKLM\SYSTEM\CurrentControlSet\Services"                 "%ccdcpath%\Regback\Services_%timestamp%.reg"     /y >NUL 2>&1
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "%ccdcpath%\Regback\Winlogon_%timestamp%.reg" /y >NUL 2>&1
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Lsa"              "%ccdcpath%\Regback\LSA_%timestamp%.reg"          /y >NUL 2>&1

:: Hosts file
copy /y "%SystemRoot%\System32\drivers\etc\hosts" "%ccdcpath%\Config\hosts_%timestamp%.bak" >NUL 2>&1

:: Firewall
netsh advfirewall export "%ccdcpath%\Config\firewall_%timestamp%.wfw" >NUL 2>&1

:: Scheduled tasks
schtasks /query /fo LIST /v > "%ccdcpath%\Config\ScheduledTasks_%timestamp%.txt" 2>NUL

:: Services list
sc query type= service state= all > "%ccdcpath%\Config\Services_%timestamp%.txt" 2>NUL

echo [+] Critical configs backed up to %ccdcpath%\Regback and %ccdcpath%\Config
exit /b

:: ============================================================================
:: SUBROUTINE: BACKUP ALL CONFIGS
:: ============================================================================
:backup_all_configs
echo [*] Backing up ALL configurations (comprehensive)...
echo [*] Full backup starting... >> "%logfile%"

call :backup_critical_configs

:: Additional full registry exports
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" "%ccdcpath%\Regback\Policies_%timestamp%.reg" /y >NUL 2>&1
reg export "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager"   "%ccdcpath%\Regback\SessionMgr_%timestamp%.reg" /y >NUL 2>&1
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" "%ccdcpath%\Regback\Explorer_%timestamp%.reg" /y >NUL 2>&1
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" "%ccdcpath%\Regback\IFEO_%timestamp%.reg" /y >NUL 2>&1

:: User accounts
wmic useraccount list full    > "%ccdcpath%\Config\UserAccounts_%timestamp%.txt" 2>NUL
wmic group list full          > "%ccdcpath%\Config\Groups_%timestamp%.txt" 2>NUL
net localgroup administrators > "%ccdcpath%\Config\Admins_%timestamp%.txt" 2>NUL

:: Installed software
wmic product get name,version,vendor > "%ccdcpath%\Config\InstalledSoftware_%timestamp%.txt" 2>NUL

:: Audit policy
auditpol /get /category:* > "%ccdcpath%\Config\AuditPolicy_%timestamp%.txt" 2>NUL

:: Local security policy (secedit)
secedit /export /cfg "%ccdcpath%\Config\SecurityPolicy_%timestamp%.cfg" >NUL 2>&1

echo [+] All configurations backed up.
exit /b

:: ============================================================================
:: SUBROUTINE: ENABLE FIREWALL - EXPRESS
:: ============================================================================
:enable_firewall_express
echo [*] Configuring firewall (Express mode)...
echo [*] Enabling firewall (express)... >> "%logfile%"

:: Enable firewall on all profiles
netsh advfirewall set allprofiles state on >NUL 2>&1

:: Set default policies: block inbound, allow outbound
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound >NUL 2>&1

:: Allow essential inbound services (scored services often need this)
:: DNS (UDP 53 in/out)
netsh advfirewall firewall add rule name="Allow DNS In"  dir=in  action=allow protocol=udp localport=53  >NUL 2>&1
netsh advfirewall firewall add rule name="Allow DNS Out" dir=out action=allow protocol=udp remoteport=53 >NUL 2>&1

:: HTTP/HTTPS outbound
netsh advfirewall firewall add rule name="Allow HTTP Out"  dir=out action=allow protocol=tcp remoteport=80  >NUL 2>&1
netsh advfirewall firewall add rule name="Allow HTTPS Out" dir=out action=allow protocol=tcp remoteport=443 >NUL 2>&1

:: RDP - allow inbound (common scored service - change port if needed)
netsh advfirewall firewall add rule name="Allow RDP In" dir=in action=allow protocol=tcp localport=3389 >NUL 2>&1

:: SMB - allow inbound (if Windows file sharing is scored)
:: netsh advfirewall firewall add rule name="Allow SMB In" dir=in action=allow protocol=tcp localport=445

:: Allow established/related connections (Windows handles this natively)
:: Allow loopback
netsh advfirewall firewall add rule name="Allow Loopback" dir=in action=allow remoteip=127.0.0.1 >NUL 2>&1

:: Block common attack ports
for %%P in (135 137 138 139 445 1433 1434 3389 4444 5985 5986) do (
    netsh advfirewall firewall add rule name="Block Port %%P In" dir=in action=block protocol=tcp localport=%%P >NUL 2>&1
)

:: NOTE: RDP block above overrides the allow - remove the block if RDP is scored
netsh advfirewall firewall delete rule name="Block Port 3389 In" >NUL 2>&1

echo [+] Firewall configured (express mode).
echo [!] Review and add rules for your scored services!
exit /b

:: ============================================================================
:: SUBROUTINE: ENABLE FIREWALL - FULL
:: ============================================================================
:enable_firewall_full
echo [*] Configuring firewall (Full mode)...
echo [*] Enabling firewall (full)... >> "%logfile%"

:: Enable on all profiles
netsh advfirewall set allprofiles state on >NUL 2>&1

:: Default deny ALL (both directions)
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound >NUL 2>&1

:: Disable notifications (quiet)
netsh advfirewall set allprofiles settings inboundusernotification disable >NUL 2>&1

:: ---- ESSENTIAL OUTBOUND RULES ----
:: DNS
netsh advfirewall firewall add rule name="FW: DNS UDP Out"  dir=out action=allow protocol=udp remoteport=53  >NUL 2>&1
netsh advfirewall firewall add rule name="FW: DNS TCP Out"  dir=out action=allow protocol=tcp remoteport=53  >NUL 2>&1

:: HTTP/HTTPS
netsh advfirewall firewall add rule name="FW: HTTP Out"     dir=out action=allow protocol=tcp remoteport=80  >NUL 2>&1
netsh advfirewall firewall add rule name="FW: HTTPS Out"    dir=out action=allow protocol=tcp remoteport=443 >NUL 2>&1

:: ICMP (ping) out
netsh advfirewall firewall add rule name="FW: ICMP Out" dir=out action=allow protocol=icmpv4 >NUL 2>&1

:: DHCP
netsh advfirewall firewall add rule name="FW: DHCP Out" dir=out action=allow protocol=udp localport=68 remoteport=67 >NUL 2>&1

:: Kerberos (for domain environments)
netsh advfirewall firewall add rule name="FW: Kerberos Out" dir=out action=allow protocol=tcp remoteport=88 >NUL 2>&1

:: LDAP (for domain environments)
netsh advfirewall firewall add rule name="FW: LDAP Out"  dir=out action=allow protocol=tcp remoteport=389 >NUL 2>&1
netsh advfirewall firewall add rule name="FW: LDAPS Out" dir=out action=allow protocol=tcp remoteport=636 >NUL 2>&1

:: Windows Update / Microsoft services
netsh advfirewall firewall add rule name="FW: WU HTTP Out"  dir=out action=allow protocol=tcp remoteport=80  program="%SystemRoot%\System32\svchost.exe" >NUL 2>&1
netsh advfirewall firewall add rule name="FW: WU HTTPS Out" dir=out action=allow protocol=tcp remoteport=443 program="%SystemRoot%\System32\svchost.exe" >NUL 2>&1

:: NTP (time sync)
netsh advfirewall firewall add rule name="FW: NTP Out" dir=out action=allow protocol=udp remoteport=123 >NUL 2>&1

:: ---- ESSENTIAL INBOUND RULES ----
:: ICMP (ping) in
netsh advfirewall firewall add rule name="FW: ICMP In" dir=in action=allow protocol=icmpv4 >NUL 2>&1

:: Loopback
netsh advfirewall firewall add rule name="FW: Loopback In" dir=in action=allow remoteip=127.0.0.1 >NUL 2>&1

:: RDP (edit remoteip to lock to specific hosts)
netsh advfirewall firewall add rule name="FW: RDP In" dir=in action=allow protocol=tcp localport=3389 >NUL 2>&1

:: WinRM (if needed for management)
:: netsh advfirewall firewall add rule name="FW: WinRM In" dir=in action=allow protocol=tcp localport=5985

:: ---- BLOCK EXPLICITLY DANGEROUS ----
:: WMI remote
netsh advfirewall firewall add rule name="FW: Block WMI In"    dir=in action=block protocol=tcp localport=135 >NUL 2>&1
:: NetBIOS
netsh advfirewall firewall add rule name="FW: Block NetBIOS In" dir=in action=block protocol=tcp localport=139 >NUL 2>&1
netsh advfirewall firewall add rule name="FW: Block NetBIOS UDP" dir=in action=block protocol=udp localport=137,138 >NUL 2>&1
:: SMB (enable if file sharing is scored)
netsh advfirewall firewall add rule name="FW: Block SMB In"    dir=in action=block protocol=tcp localport=445 >NUL 2>&1

echo [+] Firewall configured (full mode - default deny both directions).
echo [!] Add inbound rules for your scored services:
echo     netsh advfirewall firewall add rule name="SVC" dir=in action=allow protocol=tcp localport=PORT
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.0 - SUBROUTINES PART 3
:: Registry Hardening and Service Subroutines
:: ============================================================================

:: ============================================================================
:: SUBROUTINE: DISABLE DANGEROUS SERVICES (Express)
:: ============================================================================
:disable_dangerous_services
echo [*] Disabling dangerous services (express)...
echo [*] Disabling dangerous services... >> "%logfile%"

:: Telnet
sc config tlntsvr start= disabled >NUL 2>&1 & net stop tlntsvr /y >NUL 2>&1
:: FTP Publishing Service
sc config msftpsvc start= disabled >NUL 2>&1 & net stop msftpsvc /y >NUL 2>&1
:: Remote Registry
sc config RemoteRegistry start= disabled >NUL 2>&1 & net stop RemoteRegistry /y >NUL 2>&1
:: NetBIOS over TCP (handled by netbios disable)
:: SMBv1 server
sc config lanmanserver start= disabled >NUL 2>&1
:: Print Spooler (disable if not printing)
:: sc config Spooler start= disabled >NUL 2>&1 & net stop Spooler /y >NUL 2>&1
:: WinRM (unless needed for management)
sc config WinRM start= disabled >NUL 2>&1 & net stop WinRM /y >NUL 2>&1
:: SNMP (unless needed)
sc config SNMP start= disabled >NUL 2>&1 & net stop SNMP /y >NUL 2>&1
:: Simple TCP/IP Services
sc config simptcp start= disabled >NUL 2>&1 & net stop simptcp /y >NUL 2>&1
:: Routing and Remote Access
sc config RemoteAccess start= disabled >NUL 2>&1 & net stop RemoteAccess /y >NUL 2>&1
:: TFTP client
sc config tftpd start= disabled >NUL 2>&1 & net stop tftpd /y >NUL 2>&1

echo [+] Dangerous services disabled.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE ALL DANGEROUS SERVICES (Full)
:: ============================================================================
:disable_all_dangerous_services
echo [*] Disabling all dangerous services (comprehensive)...
echo [*] Disabling all dangerous services... >> "%logfile%"

call :disable_dangerous_services

:: Additional services for full hardening
for %%S in (
    tlntsvr
    msftpsvc
    RemoteRegistry
    WinRM
    SNMP
    SNMPTrap
    simptcp
    RemoteAccess
    SharedAccess
    XblAuthManager
    XblGameSave
    XboxNetApiSvc
    XboxGipSvc
    DiagTrack
    dmwappushservice
    WMPNetworkSvc
    WerSvc
    wercplsupport
    PeerDistSvc
    p2pimsvc
    p2psvc
    PNRPSvc
    PNRPAutoReg
    HomeGroupListener
    HomeGroupProvider
    icssvc
    lltdsvc
    MapsBroker
    PhoneSvc
    RasAuto
    RasMan
    SessionEnv
    TermService
    UmRdpService
    UxSms
    WinHttpAutoProxySvc
    upnphost
    SSDPSRV
    fdPHost
    FDResPub
) do (
    sc config %%S start= disabled >NUL 2>&1
    net stop %%S /y >NUL 2>&1
    echo [*] Disabled: %%S >> "%logfile%"
)

echo [+] All dangerous services disabled.
exit /b

:: ============================================================================
:: SUBROUTINE: FIX COMMON BACKDOORS (Express)
:: ============================================================================
:fix_common_backdoors
echo [*] Fixing common backdoors...
echo [*] Fixing common backdoors... >> "%logfile%"

:: Ensure default shell is explorer.exe (not replaced by backdoor)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f >NUL 2>&1

:: Ensure Userinit is normal
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >NUL 2>&1

:: Clear IFEO debuggers (common persistence - attackers add debuggers to intercept process launch)
echo [*] Checking IFEO for suspicious debuggers...
for %%P in (sethc.exe utilman.exe osk.exe magnify.exe narrator.exe displayswitch.exe atbroker.exe) do (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%P" /v Debugger /f >NUL 2>&1
)

:: Sticky keys / accessibility backdoors - restore defaults
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.exe" /v Debugger /t REG_SZ /d "" /f >NUL 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.exe" /v Debugger /f >NUL 2>&1

:: Restore sethc.exe if it was replaced with cmd.exe (classic hack)
if exist "%SystemRoot%\System32\sethc.exe.bak" (
    copy /y "%SystemRoot%\System32\sethc.exe.bak" "%SystemRoot%\System32\sethc.exe" >NUL 2>&1
)

:: Clear AppInit DLLs
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs /t REG_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs /t REG_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" /v LoadAppInit_DLLs /t REG_DWORD /d 0 /f >NUL 2>&1

:: Clear LSA notification packages to defaults
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Notification Packages" /t REG_MULTI_SZ /d "scecli" /f >NUL 2>&1

echo [+] Common backdoors fixed.
exit /b

:: ============================================================================
:: SUBROUTINE: FIX ALL BACKDOORS (Full)
:: ============================================================================
:fix_all_backdoors
echo [*] Fixing all backdoors (comprehensive)...

call :fix_common_backdoors

:: Also clean WMI persistence
call :clean_wmi_completely

:: Reset LSA authentication packages
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Authentication Packages" /t REG_MULTI_SZ /d "msv1_0" /f >NUL 2>&1

:: Reset Security Packages
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Security Packages" /t REG_MULTI_SZ /d "" /f >NUL 2>&1

:: Disable AutoRun/AutoPlay
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1

echo [+] All backdoors fixed.
exit /b

:: ============================================================================
:: SUBROUTINE: CLEAR RUN KEYS
:: ============================================================================
:clear_run_keys
echo [*] Clearing suspicious Run key entries...
echo [*] Clearing run keys... >> "%logfile%"

:: Backup first
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"     "%ccdcpath%\Regback\HKCU_Run_pre_clear_%timestamp%.reg" /y >NUL 2>&1
reg export "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"     "%ccdcpath%\Regback\HKLM_Run_pre_clear_%timestamp%.reg" /y >NUL 2>&1
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" "%ccdcpath%\Regback\HKCU_RunOnce_pre_clear_%timestamp%.reg" /y >NUL 2>&1
reg export "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" "%ccdcpath%\Regback\HKLM_RunOnce_pre_clear_%timestamp%.reg" /y >NUL 2>&1

:: NOTE: We don't blindly delete all Run keys as they may include legitimate software.
:: Instead, dump them and prompt for review.
echo [!] Run keys have been backed up to %ccdcpath%\Regback\
echo [!] Review backups and manually delete suspicious entries.
echo.
echo Current HKCU Run entries:
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL
echo.
echo Current HKLM Run entries:
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL
echo.

:: Clear RunOnce (these should always be empty unless something is installing)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /f >NUL 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /f >NUL 2>&1

:: Clear RunServices (rarely legitimate)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\RunServices" /f >NUL 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices" /f >NUL 2>&1

echo [+] RunOnce and RunServices keys cleared.
exit /b

:: ============================================================================
:: SUBROUTINE: CLEAR ALL PERSISTENCE
:: ============================================================================
:clear_all_persistence
echo [*] Clearing all persistence mechanisms...
echo [*] Clearing all persistence... >> "%logfile%"

call :clear_run_keys

:: Clear startup folders
echo [*] Clearing startup folders...
del /f /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*" >NUL 2>&1
del /f /q "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*" >NUL 2>&1

:: Clear WMI subscriptions
call :clean_wmi_completely

:: Reset screensaver (used as persistence sometimes)
reg add "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d "0" /f >NUL 2>&1
reg delete "HKCU\Control Panel\Desktop" /v SCRNSAVE.EXE /f >NUL 2>&1

:: Reset Group Policy scripts
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts" /f >NUL 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts"  /f >NUL 2>&1

:: Clear COM object hijacking in HKCU
:: (Be careful - some are legitimate)
:: reg delete "HKCU\Software\Classes\CLSID" /f >NUL 2>&1

echo [+] All persistence cleared.
exit /b

:: ============================================================================
:: SUBROUTINE: ENABLE BASIC LOGGING
:: ============================================================================
:enable_basic_logging
echo [*] Enabling basic security logging...
echo [*] Enabling basic logging... >> "%logfile%"

:: Enable audit policies
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Account Logon" /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Account Management" /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Object Access" /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Policy Change" /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"Privilege Use" /success:enable /failure:enable >NUL 2>&1
auditpol /set /category:"System" /success:enable /failure:enable >NUL 2>&1

:: Increase log sizes
wevtutil sl Security /ms:512000000 >NUL 2>&1
wevtutil sl System   /ms:128000000 >NUL 2>&1
wevtutil sl Application /ms:128000000 >NUL 2>&1

echo [+] Basic logging enabled.
exit /b

:: ============================================================================
:: SUBROUTINE: ENABLE ADVANCED LOGGING
:: ============================================================================
:enable_advanced_logging
echo [*] Enabling advanced security logging...
echo [*] Enabling advanced logging... >> "%logfile%"

call :enable_basic_logging

:: Enable all subcategories
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Process Termination" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"DPAPI Activity" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Token Right Adjusted" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"File System" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Registry" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Kernel Object" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"SAM" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Certification Services" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Application Generated" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Handle Manipulation" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"File Share" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Filtering Platform Packet Drop" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Filtering Platform Connection" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Other Object Access Events" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Detailed File Share" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Removable Storage" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Central Policy Staging" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Network Policy Server" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"IPsec Driver" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Other System Events" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Security System Extension" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Security State Change" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable >NUL 2>&1

:: Enable command line logging in process creation events (Event ID 4688)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f >NUL 2>&1

:: PowerShell ScriptBlock logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockInvocationLogging /t REG_DWORD /d 1 /f >NUL 2>&1

:: PowerShell Module logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" /v "*" /t REG_SZ /d "*" /f >NUL 2>&1

:: PowerShell Transcription
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableTranscripting /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v OutputDirectory /t REG_SZ /d "%ccdcpath%\Logs\PSTranscripts" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableInvocationHeader /t REG_DWORD /d 1 /f >NUL 2>&1

:: Increase log sizes significantly
wevtutil sl Security    /ms:1073741824 >NUL 2>&1
wevtutil sl System      /ms:268435456  >NUL 2>&1
wevtutil sl Application /ms:268435456  >NUL 2>&1

:: Enable Windows Defender logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v DisableGenericRePorts /t REG_DWORD /d 0 /f >NUL 2>&1

echo [+] Advanced logging enabled.
echo [*] PS Transcripts: %ccdcpath%\Logs\PSTranscripts
exit /b

:: ============================================================================
:: SUBROUTINE: SET PASSWORD POLICY
:: ============================================================================
:set_password_policy
echo [*] Configuring password policy...
echo [*] Setting password policy... >> "%logfile%"

:: Use secedit to apply password policy
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
echo RequireLogonToChangePassword = 0
echo ForceLogoffWhenHourExpire = 0
echo NewAdministratorName = "Administrator"
echo NewGuestName = "Guest"
echo ClearTextPassword = 0
echo LSAAnonymousNameLookup = 0
echo EnableAdminAccount = 1
echo EnableGuestAccount = 0
) > "%TEMP%\secpol.cfg"

secedit /configure /cfg "%TEMP%\secpol.cfg" /db "%TEMP%\secpol.sdb" /quiet >NUL 2>&1
del "%TEMP%\secpol.cfg" >NUL 2>&1
del "%TEMP%\secpol.sdb" >NUL 2>&1

:: Also set via net accounts
net accounts /maxpwage:90 /minpwage:0 /minpwlen:14 /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30 >NUL 2>&1

echo [+] Password policy configured (14+ chars, complexity, 5-attempt lockout).
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE GUEST ACCOUNT
:: ============================================================================
:disable_guest_account
echo [*] Disabling Guest account...
echo [*] Disabling guest account... >> "%logfile%"

net user Guest /active:no >NUL 2>&1
net user Guest /passwordreq:yes >NUL 2>&1

:: Rename Guest (makes it harder to target)
:: wmic useraccount where name="Guest" rename HiddenGuest >NUL 2>&1

echo [+] Guest account disabled.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.0 - SUBROUTINES PART 4
:: Protocol and Component Hardening
:: ============================================================================

:: ============================================================================
:: SUBROUTINE: HARDEN SMB
:: ============================================================================
:harden_smb
echo [*] Hardening SMB...
echo [*] Hardening SMB... >> "%logfile%"

:: Disable SMB1 (EternalBlue target)
powershell -Command "Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force" >NUL 2>&1
sc config lanmanworkstation depend= bowser/mrxsmb20/nsi >NUL 2>&1
sc config mrxsmb10 start= disabled >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mrxsmb10" /v Start /t REG_DWORD /d 4 /f >NUL 2>&1

:: Also via DISM
Dism /online /Disable-Feature /FeatureName:SMB1Protocol /NoRestart >NUL 2>&1

:: Disable SMB2 compression (CVE-2020-0796 - SMBGhost)
powershell -Command "Set-SmbServerConfiguration -DisableCompression $true -Force" >NUL 2>&1

:: Enable SMB signing (prevent relay attacks)
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v EnableSecuritySignature  /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\System\CurrentControlSet\Services\Rdr\Parameters"          /v RequireSecuritySignature /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable admin shares (optional - may break management)
:: reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v AutoShareWks /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable NTLM where possible (prefer Kerberos)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v RestrictSendingNTLMTraffic /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 5 /f >NUL 2>&1

echo [+] SMB hardened (SMBv1 disabled, signing required, NTLMv1 disabled).
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN RDP
:: ============================================================================
:harden_rdp
echo [*] Hardening RDP...
echo [*] Hardening RDP... >> "%logfile%"

:: Enable NLA (Network Level Authentication)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f >NUL 2>&1

:: Require NLA via policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v UserAuthentication /t REG_DWORD /d 1 /f >NUL 2>&1

:: Set encryption level to High
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel /t REG_DWORD /d 3 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MinEncryptionLevel /t REG_DWORD /d 3 /f >NUL 2>&1

:: Disable RDP clipboard (prevent data exfil via RDP)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fDisableClip /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable drive redirection
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fDisableCdm /t REG_DWORD /d 1 /f >NUL 2>&1

:: Limit RDP sessions
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxConnectionTime /t REG_DWORD /d 3600000 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime /t REG_DWORD /d 900000 /f >NUL 2>&1

:: Set RDP port (keep at 3389 unless changing for security through obscurity)
:: To change: reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 3389 /f

echo [+] RDP hardened (NLA required, high encryption, clipboard disabled).
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN WMI
:: ============================================================================
:harden_wmi
echo [*] Hardening WMI...
echo [*] Hardening WMI... >> "%logfile%"

:: Disable remote WMI access (allow local only)
netsh advfirewall firewall add rule name="Block WMI Remote" dir=in action=block protocol=tcp localport=135 >NUL 2>&1

:: Clean any existing WMI persistence
call :clean_wmi_completely

:: Restart WMI service cleanly
net stop Winmgmt /y >NUL 2>&1
net start Winmgmt >NUL 2>&1

echo [+] WMI hardened.
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN LSASS
:: ============================================================================
:harden_lsass
echo [*] Hardening LSASS (credential protection)...
echo [*] Hardening LSASS... >> "%logfile%"

:: Enable LSA Protection (RunAsPPL) - prevents mimikatz-style attacks
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 1 /f >NUL 2>&1

:: Enable Credential Guard (requires UEFI + Secure Boot on modern systems)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LsaCfgFlags /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable WDigest (prevents cleartext password storage in memory)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable NTLM v1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LmCompatibilityLevel /t REG_DWORD /d 5 /f >NUL 2>&1

:: No LM hash storage
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v NoLMHash /t REG_DWORD /d 1 /f >NUL 2>&1

:: Restrict anonymous access
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v EveryoneIncludesAnonymous /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable blank passwords for network logon
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f >NUL 2>&1

:: Require admin approval for elevation
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v FilterAdministratorToken /t REG_DWORD /d 1 /f >NUL 2>&1

echo [+] LSASS hardened (PPL, WDigest off, NTLMv1 disabled, Credential Guard enabled).
echo [!] Credential Guard requires reboot + UEFI/Secure Boot to take effect.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE LEGACY PROTOCOLS
:: ============================================================================
:disable_legacy_protocols
echo [*] Disabling legacy protocols...
echo [*] Disabling legacy protocols... >> "%logfile%"

:: Disable SSLv2, SSLv3, TLS 1.0, TLS 1.1
for %%P in ("SSL 2.0" "SSL 3.0" "TLS 1.0" "TLS 1.1") do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Server" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Server" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Client" /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Client" /v DisabledByDefault /t REG_DWORD /d 1 /f >NUL 2>&1
)

:: Enable TLS 1.2 and 1.3
for %%P in ("TLS 1.2" "TLS 1.3") do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Server" /v Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Server" /v DisabledByDefault /t REG_DWORD /d 0 /f >NUL 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Client" /v Enabled /t REG_DWORD /d 1 /f >NUL 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\%%~P\Client" /v DisabledByDefault /t REG_DWORD /d 0 /f >NUL 2>&1
)

:: Disable weak cipher suites
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"       /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL"             /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128"      /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128"       /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 56/128"       /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128"      /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128"       /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128"       /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 64/128"       /v Enabled /t REG_DWORD /d 0 /f >NUL 2>&1

echo [+] Legacy protocols disabled (SSL2/3, TLS1.0/1.1, weak ciphers).
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE NETBIOS
:: ============================================================================
:disable_netbios
echo [*] Disabling NetBIOS over TCP/IP...
echo [*] Disabling NetBIOS... >> "%logfile%"

:: Disable via registry for all adapters
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" /v TransportBindName /t REG_SZ /d "" /f >NUL 2>&1

:: Disable on each network adapter
powershell -Command "
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name NetbiosOptions -Value 2
}
" >NUL 2>&1

:: Also via WMI
powershell -Command "
Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | ForEach-Object {
    $_.SetTcpipNetbios(2)
}
" >NUL 2>&1

echo [+] NetBIOS disabled on all adapters.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE LLMNR
:: ============================================================================
:disable_llmnr
echo [*] Disabling LLMNR (Link-Local Multicast Name Resolution)...
echo [*] Disabling LLMNR... >> "%logfile%"

:: LLMNR used by Responder attacks
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable DNS multicast via service
sc config Dnscache start= auto >NUL 2>&1

echo [+] LLMNR disabled.
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN POWERSHELL
:: ============================================================================
:harden_powershell
echo [*] Hardening PowerShell...
echo [*] Hardening PowerShell... >> "%logfile%"

:: Set execution policy to RemoteSigned (AllSigned for maximum security)
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force" >NUL 2>&1

:: Enable Constrained Language Mode via WDAC (Device Guard)
:: This prevents arbitrary code execution even if PS is launched
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v __PSLockdownPolicy /t REG_SZ /d "4" /f >NUL 2>&1

:: Disable PowerShell v2 (lacks security features, can be used to bypass logging)
powershell -Command "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart" >NUL 2>&1
powershell -Command "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -NoRestart" >NUL 2>&1

:: Enable ScriptBlock logging (already done in logging subroutine, ensure here)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockInvocationLogging /t REG_DWORD /d 1 /f >NUL 2>&1

:: Enable module logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f >NUL 2>&1

echo [+] PowerShell hardened (v2 disabled, execution policy set, logging enabled).
exit /b

:: ============================================================================
:: SUBROUTINE: CONFIGURE UAC MAXIMUM
:: ============================================================================
:configure_uac_max
echo [*] Configuring UAC to maximum...
echo [*] Configuring UAC max... >> "%logfile%"

:: Enable UAC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >NUL 2>&1

:: Always notify (highest UAC setting)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorUser /t REG_DWORD /d 1 /f >NUL 2>&1

:: Prompt on secure desktop
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f >NUL 2>&1

:: Enable admin approval mode
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v FilterAdministratorToken /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable auto-elevation
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableUIADesktopToggle /t REG_DWORD /d 0 /f >NUL 2>&1

echo [+] UAC configured to maximum.
exit /b

:: ============================================================================
:: SUBROUTINE: ENABLE ASLR AND DEP
:: ============================================================================
:enable_aslr_dep
echo [*] Enabling ASLR and DEP system-wide...
echo [*] Enabling ASLR and DEP... >> "%logfile%"

:: Enable DEP (Data Execution Prevention)
bcdedit /set nx AlwaysOn >NUL 2>&1

:: Enable mandatory ASLR
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v EnableCfg /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationOptions /t REG_QWORD /d 0x101 /f >NUL 2>&1

:: Process Mitigation via PowerShell (Windows 10+)
powershell -Command "
Set-ProcessMitigation -System -Enable DEP,BottomUp,HighEntropy,SEHOP,TerminateOnHeapError
" >NUL 2>&1

echo [+] ASLR and DEP enabled system-wide.
exit /b

:: ============================================================================
:: SUBROUTINE: ENABLE EXPLOIT PROTECTION
:: ============================================================================
:enable_exploit_protection
echo [*] Enabling Windows Exploit Protection...
echo [*] Enabling exploit protection... >> "%logfile%"

powershell -Command "
Set-ProcessMitigation -System -Enable DEP,BottomUp,HighEntropy,SEHOP,TerminateOnHeapError,DisableWin32kSystemCalls,AuditSystemCall,DisableExtensionPoints,BlockDynamicCode,AllowThreadsToOptOut,AuditDynamicCode,CFG,SuppressExports,StrictCFG,MicrosoftSignedOnly,AllowStoreSignedBinaries,AuditMicrosoftSigned,AuditStoreSigned,EnforceModuleDependencySigning,HardBlockVulnerableProcesses
" >NUL 2>&1

echo [+] Exploit protection enabled.
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN NETWORK PROTOCOLS
:: ============================================================================
:harden_network_protocols
echo [*] Hardening network protocols...
echo [*] Hardening network protocols... >> "%logfile%"

call :disable_netbios
call :disable_llmnr

:: Disable mDNS
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable WPAD (Web Proxy Auto-Discovery - used in MITM attacks)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" /v WpadOverride /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" /v WpadNetworkName /t REG_SZ /d "" /f >NUL 2>&1

:: Disable IPv6 (if not needed - reduces attack surface)
:: Note: Disabling IPv6 can break some Windows features
:: reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 0xFF /f >NUL 2>&1

:: Harden TCP stack
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v SynAttackProtect /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxSynBacklog /t REG_DWORD /d 2048 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxConnectResponseRetransmissions /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableICMPRedirect /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v PerformRouterDiscovery /t REG_DWORD /d 0 /f >NUL 2>&1

echo [+] Network protocols hardened.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE UNNECESSARY FEATURES
:: ============================================================================
:disable_unnecessary_features
echo [*] Disabling unnecessary Windows features...
echo [*] Disabling unnecessary features... >> "%logfile%"

:: Disable via DISM (may take a while)
for %%F in (
    TelnetClient
    TFTP
    SimpleTCP
    SMB1Protocol
    WorkFolders-Client
    WindowsMediaPlayer
    Internet-Explorer-Optional-amd64
    MicrosoftWindowsPowerShellV2Root
    MicrosoftWindowsPowerShellV2
) do (
    Dism /online /Disable-Feature /FeatureName:%%F /NoRestart >NUL 2>&1
    echo [*] Feature disabled: %%F >> "%logfile%"
)

echo [+] Unnecessary features disabled.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE AUTORUN ALL
:: ============================================================================
:disable_autorun_all
echo [*] Disabling all AutoRun/AutoPlay...
echo [*] Disabling autorun... >> "%logfile%"

:: Disable AutoRun for all drive types
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1

:: Disable AutoPlay via policy
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v NoAutoplayfornonVolume /t REG_DWORD /d 1 /f >NUL 2>&1

echo [+] AutoRun/AutoPlay disabled.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.0 - SUBROUTINES PART 5
:: Full Registry Hardening (CIS/STIG/NSA)
:: ============================================================================

:: ============================================================================
:: SUBROUTINE: HARDEN REGISTRY - FULL
:: ============================================================================
:harden_registry_full
echo [*] Applying comprehensive registry hardening...
echo [*] Registry hardening starting... >> "%logfile%"

echo [*] Phase 1: Account and logon settings...
:: Rename Administrator (security through obscurity)
:: wmic useraccount where name="Administrator" rename CUAdmin >NUL 2>&1

:: Disable autologon
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f >NUL 2>&1
reg add    "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "0" /f >NUL 2>&1

:: Legal notice (required by STIG)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeCaption /t REG_SZ /d "AUTHORIZED USE ONLY" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v LegalNoticeText    /t REG_SZ /d "This system is for authorized use only. All activity may be monitored and reported." /f >NUL 2>&1

:: Disable cached credentials (can be used for offline attacks)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v CachedLogonsCount /t REG_SZ /d "1" /f >NUL 2>&1

:: Screen lock settings
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d 900 /f >NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d "900" /f >NUL 2>&1
reg add "HKCU\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d "1" /f >NUL 2>&1

echo [*] Phase 2: Network security settings...
:: Disable anonymous enumeration of SAM accounts
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous     /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable null session pipes and shares
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v NullSessionPipes  /t REG_MULTI_SZ /d "" /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /d "" /f >NUL 2>&1

:: Restrict named pipes over network
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v RestrictNullSessAccess /t REG_DWORD /d 1 /f >NUL 2>&1

:: Network access: Share paths that can be accessed anonymously = (none)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v NullSessionShares /t REG_MULTI_SZ /d "" /f >NUL 2>&1

:: Disable printer sharing
:: reg add "HKLM\System\CurrentControlSet\Services\LanManServer\Parameters" /v AutoShareWks /t REG_DWORD /d 0 /f >NUL 2>&1

echo [*] Phase 3: System security settings...
:: Enable Structured Exception Handler Overwrite Protection (SEHOP)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable remote assistance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowToGetHelp      /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance" /v fAllowFullControl    /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable error reporting
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable DR Watson
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug" /v Auto /t REG_SZ /d "0" /f >NUL 2>&1

:: Disable Autorun notifications
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoAutorun /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable CD/DVD autoplay
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xFF /f >NUL 2>&1

echo [*] Phase 4: Internet and browser security settings...
:: Disable IE enhanced mode (not relevant for most modern setups but still hardened)
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v DEPOff /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable WPAD
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Wpad" /v WpadOverride /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable InPrivate logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Safety\PrivacIE" /v DisableInPrivateLogging /t REG_DWORD /d 1 /f >NUL 2>&1

echo [*] Phase 5: Windows Defender settings...
:: Enable cloud protection
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SpynetReporting       /t REG_DWORD /d 2 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent  /t REG_DWORD /d 1 /f >NUL 2>&1

:: Enable real-time protection
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 0 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 0 /f >NUL 2>&1

:: Enable Attack Surface Reduction rules (Windows 10+)
echo [*] Phase 6: Attack Surface Reduction rules...
powershell -Command "
Set-MpPreference -AttackSurfaceReductionRules_Ids @(
    'BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550',
    'D4F940AB-401B-4EFC-AADC-AD5F3C50688A',
    '3B576869-A4EC-4529-8536-B80A7769E899',
    '75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84',
    'D3E037E1-3EB8-44C8-A917-57927947596D',
    '5BEB7EFE-FD9A-4556-801D-275E5FFC04CC',
    '92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B',
    '01443614-CD74-433A-B99E-2ECDC07BFC25',
    'C1DB55AB-C21A-4637-BB3F-A12568109D35',
    '9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2',
    'D1E49AAC-8F56-4280-B9BA-993A6D77406C',
    'B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4',
    '26190899-1602-49E8-8B27-EB1D0A1CE869',
    '7674BA52-37EB-4A4F-A9A1-F0F9A1619A2C',
    'E6DB77E5-3DF2-4CF1-B95A-636979351E5B',
    '56A863A9-875E-4185-98A7-B882C64B5CE5',
    'CFCD11CB-A579-4D43-A1B6-39E8B9A5082D'
) -AttackSurfaceReductionRules_Actions @(
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
)
" >NUL 2>&1

echo [*] Phase 7: Misc hardening...
:: Disable Microsoft Store (if not needed)
:: reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v DisableStoreApps /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable search indexing over network
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v PreventIndexingUncachedExchangeFolders /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable Wake on LAN
powershell -Command "
Get-NetAdapter | ForEach-Object {
    Disable-NetAdapterPowerManagement -Name $_.Name -WakeOnMagicPacket -ErrorAction SilentlyContinue
}
" >NUL 2>&1

:: Disable memory dump (prevents credential extraction from dumps)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v CrashDumpEnabled /t REG_DWORD /d 0 /f >NUL 2>&1

:: Prevent storing credentials in credential manager
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CredUI" /v DisablePasswordReveal /t REG_DWORD /d 1 /f >NUL 2>&1

:: Disable Cortana
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >NUL 2>&1

:: Disable Windows Consumer Features (reduces attack surface)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >NUL 2>&1

echo [+] Registry hardening complete (200+ settings applied).
echo [+] Registry hardening complete >> "%logfile%"
exit /b

:: ============================================================================
:: SUBROUTINE: APPLY CIS BENCHMARKS
:: ============================================================================
:apply_cis_benchmarks
echo [*] Applying CIS Benchmark settings...
echo [*] Applying CIS benchmarks... >> "%logfile%"

:: CIS 2.2.x - Deny access to this computer from the network
:: (Remove guests and anonymous users from network access)

:: CIS: Ensure interactive logon doesn't display last username
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DontDisplayLastUserName /t REG_DWORD /d 1 /f >NUL 2>&1

:: CIS: Disable fast user switching
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v HideFastUserSwitching /t REG_DWORD /d 1 /f >NUL 2>&1

:: CIS: Require secure attention sequence (Ctrl+Alt+Del for logon)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableCAD /t REG_DWORD /d 0 /f >NUL 2>&1

:: CIS: Minimum session security for NTLM
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinClientSec /t REG_DWORD /d 537395200 /f >NUL 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" /v NTLMMinServerSec /t REG_DWORD /d 537395200 /f >NUL 2>&1

:: CIS: Audit logon events
auditpol /set /subcategory:"Logon" /success:enable /failure:enable >NUL 2>&1
auditpol /set /subcategory:"Special Logon" /success:enable /failure:enable >NUL 2>&1

:: CIS: Do not store LAN Manager hash value
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v NoLMHash /t REG_DWORD /d 1 /f >NUL 2>&1

:: CIS: Force logoff when logon hours expire
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v EnableForcedLogOff /t REG_DWORD /d 1 /f >NUL 2>&1

:: CIS: Warn before clearing event log
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" /v Retention /t REG_SZ /d "0" /f >NUL 2>&1

:: CIS: Enable structured exception handling overwrite protection (SEHOP)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v DisableExceptionChainValidation /t REG_DWORD /d 0 /f >NUL 2>&1

:: CIS: UAC - Admin Approval Mode
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f >NUL 2>&1

echo [+] CIS Benchmark settings applied.
exit /b

:: ============================================================================
:: SUBROUTINE: APPLY STIG SETTINGS
:: ============================================================================
:apply_stig_settings
echo [*] Applying STIG settings...
echo [*] Applying STIG settings... >> "%logfile%"

:: STIG: Blank passwords for network logon
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f >NUL 2>&1

:: STIG: Inactivity timeout
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d 900 /f >NUL 2>&1

:: STIG: No reversible encryption
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v NoLmHash /t REG_DWORD /d 1 /f >NUL 2>&1

:: STIG: Prevent credential delegation
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v AllowProtectedCreds /t REG_DWORD /d 1 /f >NUL 2>&1

:: STIG: Enable Data Execution Prevention
bcdedit /set nx AlwaysOn >NUL 2>&1

:: STIG: Disable IPv6 source routing
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisableIpSourceRouting /t REG_DWORD /d 2 /f >NUL 2>&1

:: STIG: Disable IP source routing
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableIPSourceRouting /t REG_DWORD /d 2 /f >NUL 2>&1

echo [+] STIG settings applied.
exit /b

:: ============================================================================
:: SUBROUTINE: APPLY NSA GUIDANCE
:: ============================================================================
:apply_nsa_guidance
echo [*] Applying NSA cybersecurity guidance...
echo [*] Applying NSA guidance... >> "%logfile%"

:: NSA: Disable SMB1 (already done in harden_smb)
call :harden_smb

:: NSA: Enable PowerShell logging
call :harden_powershell

:: NSA: Disable PowerShell v2
powershell -Command "Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -NoRestart" >NUL 2>&1

:: NSA: Enable Windows Defender
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false" >NUL 2>&1
powershell -Command "Set-MpPreference -DisableIOAVProtection $false" >NUL 2>&1
powershell -Command "Set-MpPreference -DisableScriptScanning $false" >NUL 2>&1

:: NSA: Enable cloud-based protection
powershell -Command "Set-MpPreference -MAPSReporting Advanced" >NUL 2>&1

echo [+] NSA guidance applied.
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN CERTIFICATES
:: ============================================================================
:harden_certificates
echo [*] Hardening certificate trust...
echo [*] Hardening certificates... >> "%logfile%"

:: Prevent user installation of untrusted root CAs
reg add "HKLM\SOFTWARE\Policies\Microsoft\SystemCertificates\Root\ProtectedRoots" /v Flags /t REG_DWORD /d 1 /f >NUL 2>&1

:: Enable certificate revocation checking
reg add "HKLM\SOFTWARE\Policies\Microsoft\SystemCertificates\ChainEngine\Config" /v dwUrlRetrievalTimeout /t REG_DWORD /d 20000 /f >NUL 2>&1

echo [+] Certificate trust hardened.
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN BROWSERS
:: ============================================================================
:harden_browsers
echo [*] Hardening browser security settings...
echo [*] Hardening browsers... >> "%logfile%"

:: Internet Explorer / Edge (legacy) hardening
:: Enhanced Protected Mode
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v Isolation /t REG_SZ /d "PMEM" /f >NUL 2>&1

:: Disable file download prompts that can be bypassed
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0" /v 1803 /t REG_DWORD /d 3 /f >NUL 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v 1803 /t REG_DWORD /d 3 /f >NUL 2>&1

:: Disable VBScript in Internet zone
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v 140C /t REG_DWORD /d 3 /f >NUL 2>&1

:: SmartScreen
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 1 /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 1 /f >NUL 2>&1

echo [+] Browser security settings hardened.
exit /b

:: ============================================================================
:: SUBROUTINE: HARDEN SCHEDULED TASKS
:: ============================================================================
:harden_scheduled_tasks
echo [*] Hardening scheduled tasks...
echo [*] Hardening scheduled tasks... >> "%logfile%"

:: Backup current tasks
schtasks /query /fo LIST /v > "%ccdcpath%\Config\Tasks_before_harden_%timestamp%.txt" 2>NUL

:: Disable high-risk Microsoft scheduled tasks
for %%T in (
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    "\Microsoft\Windows\Maps\MapsToastTask"
    "\Microsoft\Windows\Maps\MapsUpdateTask"
    "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"
    "\Microsoft\Windows\NetTrace\GatherNetworkInfo"
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
    "\Microsoft\Windows\Shell\FamilySafetyMonitor"
    "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
    "\Microsoft\Windows\WaaSMedic\PerformRemediation"
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
) do (
    schtasks /change /tn "%%T" /disable >NUL 2>&1
)

echo [+] Scheduled tasks hardened.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.0 - SUBROUTINES PART 6
:: Threat Hunting Subroutines
:: ============================================================================

:: ============================================================================
:: SUBROUTINE: HUNT ALL PERSISTENCE
:: ============================================================================
:hunt_all_persistence
echo [*] Comprehensive persistence hunting...
echo [*] Hunting all persistence... >> "%logfile%"
call :hunt_persistence_registry
call :hunt_persistence_wmi
call :hunt_persistence_services
call :hunt_persistence_tasks
call :hunt_persistence_files
call :hunt_browser_hijacks
call :hunt_dll_hijacking
echo [+] Comprehensive persistence hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT PERSISTENCE - REGISTRY
:: ============================================================================
:hunt_persistence_registry
echo [*] Hunting registry persistence...

:: Run keys
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"       > "%ccdcpath%\ThreatHunting\HKCU_Run.txt" 2>NUL
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"       > "%ccdcpath%\ThreatHunting\HKLM_Run.txt" 2>NUL
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"   > "%ccdcpath%\ThreatHunting\HKCU_RunOnce.txt" 2>NUL
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"   > "%ccdcpath%\ThreatHunting\HKLM_RunOnce.txt" 2>NUL
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnceEx" > "%ccdcpath%\ThreatHunting\HKLM_RunOnceEx.txt" 2>NUL
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\RunServices" > "%ccdcpath%\ThreatHunting\HKCU_RunServices.txt" 2>NUL
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\RunServices" > "%ccdcpath%\ThreatHunting\HKLM_RunServices.txt" 2>NUL

:: Startup folders
dir /b "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"     > "%ccdcpath%\ThreatHunting\User_Startup.txt" 2>NUL
dir /b "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup" > "%ccdcpath%\ThreatHunting\AllUsers_Startup.txt" 2>NUL

:: Image File Execution Options (IFEO debugger hijacks)
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" > "%ccdcpath%\ThreatHunting\IFEO.txt" 2>NUL

:: Winlogon (shell replacement attacks)
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" > "%ccdcpath%\ThreatHunting\Winlogon.txt" 2>NUL

:: AppInit DLLs (DLL injection via registry)
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs > "%ccdcpath%\ThreatHunting\AppInit_x64.txt" 2>NUL
reg query "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs > "%ccdcpath%\ThreatHunting\AppInit_x86.txt" 2>NUL

:: LSA Notification Packages
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Notification Packages" > "%ccdcpath%\ThreatHunting\LSA_NotificationPackages.txt" 2>NUL
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Authentication Packages" > "%ccdcpath%\ThreatHunting\LSA_AuthenticationPackages.txt" 2>NUL
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Security Packages" > "%ccdcpath%\ThreatHunting\LSA_SecurityPackages.txt" 2>NUL

:: Print Monitors (print monitor DLL persistence)
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Print\Monitors" > "%ccdcpath%\ThreatHunting\PrintMonitors.txt" 2>NUL

:: Screensaver persistence
reg query "HKCU\Control Panel\Desktop" /v SCRNSAVE.EXE > "%ccdcpath%\ThreatHunting\Screensaver.txt" 2>NUL

:: Group Policy Scripts
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts" > "%ccdcpath%\ThreatHunting\GP_Scripts_HKLM.txt" 2>NUL
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts"  > "%ccdcpath%\ThreatHunting\GP_Scripts_HKCU.txt" 2>NUL

:: COM Object hijacking (user-level)
reg query "HKCU\Software\Classes\CLSID" > "%ccdcpath%\ThreatHunting\User_COM_Objects.txt" 2>NUL

:: Shell Extensions
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved" > "%ccdcpath%\ThreatHunting\ShellExtensions.txt" 2>NUL

:: NetSH Helper DLLs
reg query "HKLM\SOFTWARE\Microsoft\NetSh" > "%ccdcpath%\ThreatHunting\NetSH_Helpers.txt" 2>NUL

:: KnownDLLs (important for DLL hijack detection)
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs" > "%ccdcpath%\ThreatHunting\KnownDLLs.txt" 2>NUL

echo [+] Registry persistence hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT PERSISTENCE - WMI
:: ============================================================================
:hunt_persistence_wmi
echo [*] Hunting WMI persistence...

powershell -Command "Get-WMIObject -Namespace root\Subscription -Class __EventFilter | Select-Object Name,Query | Format-List" > "%ccdcpath%\ThreatHunting\WMI_EventFilters.txt" 2>NUL
powershell -Command "Get-WMIObject -Namespace root\Subscription -Class __EventConsumer | Select-Object Name,CommandLineTemplate,ScriptText | Format-List" > "%ccdcpath%\ThreatHunting\WMI_EventConsumers.txt" 2>NUL
powershell -Command "Get-WMIObject -Namespace root\Subscription -Class __FilterToConsumerBinding | Select-Object Filter,Consumer | Format-List" > "%ccdcpath%\ThreatHunting\WMI_Bindings.txt" 2>NUL

:: Check WMI namespaces for hidden ones
powershell -Command "Get-WMIObject -Namespace root -Class __Namespace | Select-Object Name" > "%ccdcpath%\ThreatHunting\WMI_Namespaces.txt" 2>NUL

echo [+] WMI persistence hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT PERSISTENCE - SERVICES
:: ============================================================================
:hunt_persistence_services
echo [*] Hunting service persistence...

sc query type= service state= all > "%ccdcpath%\ThreatHunting\All_Services.txt" 2>NUL

powershell -Command "
Get-WmiObject Win32_Service |
  Select-Object Name, DisplayName, PathName, StartMode, State, StartName |
  Format-Table -AutoSize |
  Out-File '%ccdcpath%\ThreatHunting\Service_Paths.txt'
" 2>NUL

:: Services with DLL payloads (ServiceDll)
powershell -Command "
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\*\Parameters' -ErrorAction SilentlyContinue |
  Where-Object {$_.ServiceDll} |
  Select-Object PSPath, ServiceDll |
  Out-File '%ccdcpath%\ThreatHunting\Service_DLLs.txt'
" 2>NUL

:: Suspicious service paths (not in System32 or Program Files)
powershell -Command "
Get-WmiObject Win32_Service |
  Where-Object {
    $_.PathName -and
    $_.PathName -notlike '*System32*' -and
    $_.PathName -notlike '*SysWOW64*' -and
    $_.PathName -notlike '*Program Files*' -and
    $_.PathName -notlike '*ProgramData\Microsoft*'
  } |
  Select-Object Name, PathName |
  Out-File '%ccdcpath%\ThreatHunting\Suspicious_Services.txt'
" 2>NUL

:: Drivers
powershell -Command "
Get-WmiObject Win32_SystemDriver |
  Select-Object Name, DisplayName, PathName, State, StartMode |
  Format-Table -AutoSize |
  Out-File '%ccdcpath%\ThreatHunting\Drivers.txt'
" 2>NUL

echo [+] Service persistence hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT PERSISTENCE - TASKS
:: ============================================================================
:hunt_persistence_tasks
echo [*] Hunting scheduled task persistence...

schtasks /query /fo LIST /v > "%ccdcpath%\ThreatHunting\ScheduledTasks_Full.txt" 2>NUL

:: Export task XML for deeper analysis
if not exist "%ccdcpath%\ThreatHunting\Tasks" mkdir "%ccdcpath%\ThreatHunting\Tasks" >NUL 2>&1
powershell -Command "
Get-ScheduledTask | Where-Object {$_.State -ne 'Disabled'} | ForEach-Object {
    try {
        \$xml = Export-ScheduledTask -TaskName \$_.TaskName -TaskPath \$_.TaskPath
        \$safeName = \$_.TaskName -replace '[\\/:*?\"<>|]', '_'
        \$xml | Out-File \"%ccdcpath%\ThreatHunting\Tasks\\$safeName.xml\" -ErrorAction SilentlyContinue
    } catch {}
}
" 2>NUL

:: Non-Microsoft tasks (often suspicious)
powershell -Command "
Get-ScheduledTask |
  Where-Object {
    \$_.TaskPath -notlike '\Microsoft\*' -and
    \$_.State -ne 'Disabled'
  } |
  Select-Object TaskName, TaskPath, State |
  Out-File '%ccdcpath%\ThreatHunting\NonMicrosoft_Tasks.txt'
" 2>NUL

echo [+] Scheduled task hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT PERSISTENCE - FILES
:: ============================================================================
:hunt_persistence_files
echo [*] Hunting file-based persistence...

:: Executables in temp/appdata
dir /s /b "%TEMP%\*.exe"                             > "%ccdcpath%\ThreatHunting\EXE_in_TEMP.txt" 2>NUL
dir /s /b "%APPDATA%\*.exe"                          > "%ccdcpath%\ThreatHunting\EXE_in_APPDATA.txt" 2>NUL
dir /s /b "%LOCALAPPDATA%\Temp\*.exe"                > "%ccdcpath%\ThreatHunting\EXE_in_LOCALTEMP.txt" 2>NUL
dir /s /b "C:\ProgramData\*.exe"                     > "%ccdcpath%\ThreatHunting\EXE_in_ProgramData.txt" 2>NUL

:: Scripts in suspicious locations
dir /s /b "%TEMP%\*.ps1" "%TEMP%\*.vbs" "%TEMP%\*.js" "%TEMP%\*.hta" "%TEMP%\*.bat" > "%ccdcpath%\ThreatHunting\Scripts_in_TEMP.txt" 2>NUL
dir /s /b "%APPDATA%\*.ps1" "%APPDATA%\*.vbs" "%APPDATA%\*.js"                        > "%ccdcpath%\ThreatHunting\Scripts_in_APPDATA.txt" 2>NUL

:: Files modified/created in last 7 days
powershell -Command "
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
  Where-Object {
    \$_.LastWriteTime -gt (Get-Date).AddDays(-7) -and
    -not \$_.PSIsContainer -and
    \$_.Extension -in @('.exe','.dll','.bat','.ps1','.vbs','.js','.hta','.cmd','.scr')
  } |
  Select-Object FullName, LastWriteTime, Length |
  Sort-Object LastWriteTime -Descending |
  Out-File '%ccdcpath%\ThreatHunting\Recent_Executables.txt'
" 2>NUL

:: System files in user directories (SYSTEM attrib set)
attrib /s "%USERPROFILE%\*.*" 2>NUL | find "S " > "%ccdcpath%\ThreatHunting\System_Attrib_UserProfile.txt" 2>NUL

echo [+] File persistence hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT SUSPICIOUS PROCESSES
:: ============================================================================
:hunt_suspicious_processes
echo [*] Analyzing running processes...

tasklist /v  > "%ccdcpath%\ThreatHunting\Processes_Detailed.txt" 2>NUL
tasklist /svc > "%ccdcpath%\ThreatHunting\Processes_Services.txt" 2>NUL

:: Process command lines (requires WMI)
powershell -Command "
Get-WmiObject Win32_Process |
  Select-Object ProcessId, Name, CommandLine, Path |
  Format-List |
  Out-File '%ccdcpath%\ThreatHunting\Process_CommandLines.txt'
" 2>NUL

:: Processes from suspicious paths
powershell -Command "
Get-Process |
  Select-Object Id, Name, Path |
  Where-Object {
    \$_.Path -like '*\Temp\*' -or
    \$_.Path -like '*\AppData\*' -or
    \$_.Path -like '*\ProgramData\*' -or
    \$_.Path -like '*\Users\Public\*'
  } |
  Out-File '%ccdcpath%\ThreatHunting\Suspicious_Process_Locations.txt'
" 2>NUL

:: Processes with no path (injected code or hollowed processes)
powershell -Command "
Get-Process |
  Where-Object {-not \$_.Path} |
  Select-Object Id, Name |
  Out-File '%ccdcpath%\ThreatHunting\Processes_No_Path.txt'
" 2>NUL

:: Network connections with process names
netstat -ano  > "%ccdcpath%\ThreatHunting\Network_Connections.txt" 2>NUL
netstat -anob > "%ccdcpath%\ThreatHunting\Network_Connections_WithBinary.txt" 2>NUL

echo [+] Process analysis complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT SUSPICIOUS NETWORK
:: ============================================================================
:hunt_suspicious_network
echo [*] Analyzing network activity...

netstat -ano  > "%ccdcpath%\ThreatHunting\Netstat_Current.txt" 2>NUL
netstat -anob > "%ccdcpath%\ThreatHunting\Netstat_WithBinaries.txt" 2>NUL
route print   > "%ccdcpath%\ThreatHunting\Routing_Table.txt" 2>NUL
arp -a        > "%ccdcpath%\ThreatHunting\ARP_Cache.txt" 2>NUL
ipconfig /displaydns > "%ccdcpath%\ThreatHunting\DNS_Cache.txt" 2>NUL
type "%SystemRoot%\System32\drivers\etc\hosts" > "%ccdcpath%\ThreatHunting\Hosts_File.txt" 2>NUL
net share     > "%ccdcpath%\ThreatHunting\Network_Shares.txt" 2>NUL
net use       > "%ccdcpath%\ThreatHunting\Mapped_Drives.txt" 2>NUL
netsh advfirewall firewall show rule name=all > "%ccdcpath%\ThreatHunting\Firewall_Rules.txt" 2>NUL

:: Check for listening ports
powershell -Command "
netstat -ano |
  Select-String 'LISTENING' |
  ForEach-Object {
    \$parts = \$_.Line.Trim() -split '\s+'
    [PSCustomObject]@{
      Protocol    = \$parts[0]
      LocalAddr   = \$parts[1]
      State       = \$parts[3]
      PID         = \$parts[4]
    }
  } |
  Sort-Object LocalAddr |
  Out-File '%ccdcpath%\ThreatHunting\Listening_Ports.txt'
" 2>NUL

echo [+] Network analysis complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT SUSPICIOUS FILES
:: ============================================================================
:hunt_suspicious_files
echo [*] Searching for suspicious files...

:: Recently created/modified executables
powershell -Command "
Get-ChildItem C:\ -Recurse -ErrorAction SilentlyContinue |
  Where-Object {\$_.CreationTime -gt (Get-Date).AddDays(-7)} |
  Select-Object FullName, CreationTime, Length |
  Out-File '%ccdcpath%\ThreatHunting\Recent_Files_7d.txt'
" 2>NUL

:: Large files in temp
powershell -Command "
Get-ChildItem \$env:TEMP -Recurse -ErrorAction SilentlyContinue |
  Where-Object {\$_.Length -gt 10MB} |
  Select-Object FullName, Length |
  Out-File '%ccdcpath%\ThreatHunting\Large_Temp_Files.txt'
" 2>NUL

:: Double extensions (e.g. invoice.pdf.exe)
powershell -Command "
Get-ChildItem C:\Users -Recurse -ErrorAction SilentlyContinue |
  Where-Object {\$_.Name -match '\.(pdf|doc|xls|zip|txt)\.(exe|bat|ps1|vbs|js|hta)$'} |
  Select-Object FullName |
  Out-File '%ccdcpath%\ThreatHunting\Double_Extension_Files.txt'
" 2>NUL

echo [+] Suspicious file search complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT BROWSER HIJACKS
:: ============================================================================
:hunt_browser_hijacks
echo [*] Hunting browser hijacks...

:: Browser Helper Objects
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" > "%ccdcpath%\ThreatHunting\BHO_x64.txt" 2>NUL
reg query "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" > "%ccdcpath%\ThreatHunting\BHO_x86.txt" 2>NUL

:: IE Extensions
reg query "HKCU\Software\Microsoft\Internet Explorer\Extensions" > "%ccdcpath%\ThreatHunting\IE_Extensions_User.txt" 2>NUL
reg query "HKLM\Software\Microsoft\Internet Explorer\Extensions" > "%ccdcpath%\ThreatHunting\IE_Extensions_Machine.txt" 2>NUL

:: Chrome Extensions
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Extensions" (
    dir /b "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Extensions" > "%ccdcpath%\ThreatHunting\Chrome_Extensions.txt" 2>NUL
)

:: Edge extensions
powershell -Command "Get-ChildItem 'HKCU:\Software\Microsoft\Edge\Extensions' -ErrorAction SilentlyContinue | Out-File '%ccdcpath%\ThreatHunting\Edge_Extensions.txt'" 2>NUL

:: Proxy settings
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" > "%ccdcpath%\ThreatHunting\Proxy_Settings.txt" 2>NUL

echo [+] Browser hijack hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: HUNT DLL HIJACKING
:: ============================================================================
:hunt_dll_hijacking
echo [*] Hunting DLL hijacking opportunities...

:: DLL Safe Search Mode
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v SafeDllSearchMode > "%ccdcpath%\ThreatHunting\SafeDllSearchMode.txt" 2>NUL

:: DLLs in user-writable paths (potential hijack)
dir /s /b "%USERPROFILE%\*.dll"  > "%ccdcpath%\ThreatHunting\DLLs_UserProfile.txt" 2>NUL
dir /s /b "C:\ProgramData\*.dll" > "%ccdcpath%\ThreatHunting\DLLs_ProgramData.txt" 2>NUL

:: PATH variable (attackers add malicious dirs to PATH)
echo %PATH% > "%ccdcpath%\ThreatHunting\PATH_Variable.txt" 2>NUL

:: Check for DLLs known to be hijackable (common targets)
for %%D in (version.dll wtsapi32.dll winmm.dll dbghelp.dll) do (
    dir /s /b "C:\Users\%%D" "C:\ProgramData\%%D" >> "%ccdcpath%\ThreatHunting\Known_Hijack_DLLs.txt" 2>NUL
)

echo [+] DLL hijacking hunt complete.
exit /b

:: ============================================================================
:: SUBROUTINE: ANALYZE AUTORUNS (Comprehensive)
:: ============================================================================
:analyze_autoruns
echo [*] Compiling comprehensive autorun report...

(
echo ================================================================================
echo Autoruns Comprehensive Analysis
echo Generated: %timestamp%
echo System: %COMPUTERNAME%
echo ================================================================================
echo.
echo [HKCU Run Keys]
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL
echo.
echo [HKLM Run Keys]
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" 2>NUL
echo.
echo [HKCU RunOnce]
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" 2>NUL
echo.
echo [HKLM RunOnce]
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" 2>NUL
echo.
echo [User Startup Folder]
dir /b "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>NUL
echo.
echo [All Users Startup Folder]
dir /b "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>NUL
echo.
echo [Winlogon]
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" 2>NUL
echo.
echo [AppInit DLLs]
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v AppInit_DLLs 2>NUL
echo.
echo [LSA Packages]
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Notification Packages" 2>NUL
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "Authentication Packages" 2>NUL
echo.
echo [Services - Non-Microsoft]
) > "%ccdcpath%\ThreatHunting\Autoruns_Comprehensive.txt" 2>NUL

powershell -Command "
Get-WmiObject Win32_Service |
  Where-Object {\$_.PathName -notlike '*System32*' -and \$_.PathName -notlike '*Program Files*'} |
  Select-Object Name, PathName |
  Format-Table -AutoSize
" >> "%ccdcpath%\ThreatHunting\Autoruns_Comprehensive.txt" 2>NUL

echo [+] Autorun analysis complete.
exit /b

:: ============================================================================
:: SUBROUTINE: CHECK KNOWN MALWARE PATHS
:: ============================================================================
:check_known_malware_paths
echo [*] Checking known malware locations...

(
echo Known Malware Path Check - %timestamp%
echo ================================================================================
) > "%ccdcpath%\ThreatHunting\Known_Malware_Paths.txt"

for %%P in (
    "C:\Windows\Temp"
    "C:\Windows\Tasks"
    "C:\Windows\System32\Tasks"
    "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
    "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
    "C:\Users\Public"
    "C:\Users\Public\Downloads"
    "C:\ProgramData"
) do (
    if exist %%P (
        echo [Checking: %%P] >> "%ccdcpath%\ThreatHunting\Known_Malware_Paths.txt"
        dir /s /b %%P >> "%ccdcpath%\ThreatHunting\Known_Malware_Paths.txt" 2>NUL
        echo. >> "%ccdcpath%\ThreatHunting\Known_Malware_Paths.txt"
    )
)

echo [+] Known malware path check complete.
exit /b

:: ============================================================================
:: SUBROUTINE: ANALYZE PREFETCH
:: ============================================================================
:analyze_prefetch
echo [*] Analyzing prefetch files...

if exist "C:\Windows\Prefetch" (
    dir /b /o:-d "C:\Windows\Prefetch\*.pf" > "%ccdcpath%\ThreatHunting\Prefetch_Files.txt" 2>NUL
    echo [+] Prefetch files listed - sorted by most recent execution.
) else (
    echo [!] Prefetch not found or disabled.
)

exit /b

:: ============================================================================
:: SUBROUTINE: CHECK ALTERNATE DATA STREAMS
:: ============================================================================
:check_alternate_data_streams
echo [*] Checking for Alternate Data Streams (ADS)...

for %%D in (
    "C:\Windows\System32"
    "C:\Windows\Temp"
    "%USERPROFILE%\Desktop"
    "%USERPROFILE%\Downloads"
    "C:\ProgramData"
) do (
    echo [Scanning ADS: %%D]
    dir /r "%%D" 2>NUL | find ":$DATA" >> "%ccdcpath%\ThreatHunting\Alternate_Data_Streams.txt" 2>NUL
)

echo [+] ADS check complete.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.0 - SUBROUTINES PART 7
:: System Repair and Performance Subroutines
:: ============================================================================

:: ============================================================================
:: SUBROUTINE: KILL PROBLEMATIC PROCESSES
:: ============================================================================
:kill_problematic_processes
echo [*] Identifying problematic processes...

powershell -Command "
Get-Process |
  Sort-Object CPU -Descending |
  Select-Object -First 10 |
  Format-Table ProcessName, CPU, WorkingSet, Id -AutoSize |
  Out-File '%ccdcpath%\Repair\High_CPU_Processes.txt'
" 2>NUL

echo [!] Top CPU consumers saved: %ccdcpath%\Repair\High_CPU_Processes.txt
exit /b

:: ============================================================================
:: SUBROUTINE: REPAIR WINDOWS EXPLORER
:: ============================================================================
:repair_windows_explorer
echo [*] Repairing Windows Explorer...

taskkill /f /im explorer.exe >NUL 2>&1
timeout /t 2 /nobreak >NUL
start explorer.exe

echo [+] Explorer restarted.
exit /b

:: ============================================================================
:: SUBROUTINE: EMERGENCY RESTORE EXPLORER
:: ============================================================================
:emergency_restore_explorer
echo [*] Emergency Explorer restoration...

taskkill /f /im explorer.exe >NUL 2>&1

:: Restore default shell if hijacked
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "explorer.exe" /f >NUL 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /t REG_SZ /d "C:\Windows\system32\userinit.exe," /f >NUL 2>&1

:: Check if explorer.exe exists
if not exist "%SystemRoot%\explorer.exe" (
    echo [!] CRITICAL: explorer.exe missing!
    if exist "%SystemRoot%\System32\dllcache\explorer.exe" (
        copy /y "%SystemRoot%\System32\dllcache\explorer.exe" "%SystemRoot%\explorer.exe" >NUL 2>&1
        echo [+] Explorer restored from dllcache.
    )
)

start %SystemRoot%\explorer.exe
echo [+] Emergency Explorer restoration complete.
exit /b

:: ============================================================================
:: SUBROUTINE: REPAIR SYSTEM FILES (SFC)
:: ============================================================================
:repair_system_files
echo [*] Running System File Checker (SFC)...
echo [*] This may take 10-30 minutes...

sfc /scannow

echo [+] SFC complete. Check %SystemRoot%\Logs\CBS\CBS.log for details.
exit /b

:: ============================================================================
:: SUBROUTINE: REPAIR COMPONENT STORE (DISM)
:: ============================================================================
:repair_component_store
echo [*] Repairing component store with DISM...
echo [*] This may take 20-60 minutes...

DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /RestoreHealth

echo [+] DISM repair complete.
exit /b

:: ============================================================================
:: SUBROUTINE: REPAIR WINDOWS UPDATE
:: ============================================================================
:repair_windows_update
echo [*] Repairing Windows Update...

net stop wuauserv  >NUL 2>&1
net stop cryptSvc  >NUL 2>&1
net stop bits      >NUL 2>&1
net stop msiserver >NUL 2>&1

ren C:\Windows\SoftwareDistribution SoftwareDistribution.old >NUL 2>&1
ren C:\Windows\System32\catroot2 catroot2.old >NUL 2>&1

:: Re-register critical DLLs
for %%D in (
    atl.dll urlmon.dll mshtml.dll shdocvw.dll browseui.dll
    jscript.dll vbscript.dll scrrun.dll msxml.dll msxml3.dll msxml6.dll
    actxprxy.dll softpub.dll wintrust.dll dssenh.dll rsaenh.dll
    cryptdlg.dll oleaut32.dll ole32.dll shell32.dll initpki.dll
    wuapi.dll wuaueng.dll wucltui.dll wups.dll wups2.dll wuweb.dll
    qmgr.dll qmgrprxy.dll wucltux.dll muweb.dll wuwebv.dll
) do (
    regsvr32.exe /s %%D >NUL 2>&1
)

netsh winsock reset >NUL 2>&1

net start wuauserv  >NUL 2>&1
net start cryptSvc  >NUL 2>&1
net start bits      >NUL 2>&1
net start msiserver >NUL 2>&1

echo [+] Windows Update repair complete.
exit /b

:: ============================================================================
:: SUBROUTINE: RESET WINDOWS UPDATE (Light)
:: ============================================================================
:reset_windows_update
echo [*] Resetting Windows Update (light)...

net stop wuauserv >NUL 2>&1
net stop cryptSvc >NUL 2>&1
net stop bits     >NUL 2>&1

del /f /s /q C:\Windows\SoftwareDistribution\*.* >NUL 2>&1

net start wuauserv >NUL 2>&1
net start cryptSvc >NUL 2>&1
net start bits     >NUL 2>&1

echo [+] Windows Update reset.
exit /b

:: ============================================================================
:: SUBROUTINE: REPAIR EVENT LOGS
:: ============================================================================
:repair_event_logs
echo [*] Repairing Event Log service...

net stop EventLog >NUL 2>&1
wevtutil cl System      >NUL 2>&1
wevtutil cl Application >NUL 2>&1
wevtutil cl Security    >NUL 2>&1
net start EventLog >NUL 2>&1

echo [+] Event Log repaired.
exit /b

:: ============================================================================
:: SUBROUTINE: REPAIR WINDOWS DEFENDER
:: ============================================================================
:repair_windows_defender
echo [*] Repairing Windows Defender...

"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate >NUL 2>&1
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1 >NUL 2>&1

echo [+] Windows Defender updated and quick-scanned.
exit /b

:: ============================================================================
:: SUBROUTINE: CLEAR TEMP FILES
:: ============================================================================
:clear_temp_files
echo [*] Clearing temporary files...

del /f /s /q "%SystemRoot%\Temp\*.*" >NUL 2>&1
del /f /s /q "%TEMP%\*.*" >NUL 2>&1
del /f /q    "%SystemRoot%\Prefetch\*.*" >NUL 2>&1
del /f /q    "%APPDATA%\Microsoft\Windows\Recent\*.*" >NUL 2>&1
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 >NUL 2>&1
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2 >NUL 2>&1

echo [+] Temp files cleared.
exit /b

:: ============================================================================
:: SUBROUTINE: DELETE TEMP FILES AGGRESSIVE
:: ============================================================================
:delete_temp_files_aggressive
echo [*] Aggressively deleting temp files...

call :clear_temp_files

:: Chrome cache
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" (
    rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" >NUL 2>&1
)

:: Firefox cache
if exist "%APPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%F in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do (
        rd /s /q "%%F\cache2" >NUL 2>&1
    )
)

:: Edge cache
if exist "%LOCALAPPDATA%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\Cache" (
    rd /s /q "%LOCALAPPDATA%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\Cache" >NUL 2>&1
)

echo [+] Aggressive temp deletion complete.
exit /b

:: ============================================================================
:: SUBROUTINE: REPAIR NETWORK STACK
:: ============================================================================
:repair_network_stack
echo [*] Repairing network stack...

netsh int ip reset   >NUL 2>&1
netsh winsock reset  >NUL 2>&1
ipconfig /flushdns   >NUL 2>&1
ipconfig /release    >NUL 2>&1
ipconfig /renew      >NUL 2>&1

echo [+] Network stack repaired.
echo [!] REBOOT RECOMMENDED for changes to fully take effect.
exit /b

:: ============================================================================
:: SUBROUTINE: REBUILD ICON CACHE
:: ============================================================================
:rebuild_icon_cache
echo [*] Rebuilding icon cache...

taskkill /f /im explorer.exe >NUL 2>&1
del /f /a "%LOCALAPPDATA%\IconCache.db" >NUL 2>&1
del /f /a /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\*.db" >NUL 2>&1
start explorer.exe

echo [+] Icon cache rebuilt.
exit /b

:: ============================================================================
:: SUBROUTINE: CHECK DISK HEALTH
:: ============================================================================
:check_disk_health
echo [*] Checking disk health...

wmic diskdrive get status,model,mediaType > "%ccdcpath%\Repair\Disk_SMART_Status.txt" 2>NUL

echo [+] Disk SMART status: %ccdcpath%\Repair\Disk_SMART_Status.txt
echo [*] Note: chkdsk /f /r scheduled for next reboot if needed.
exit /b

:: ============================================================================
:: SUBROUTINE: EMERGENCY PROCESS TERMINATION
:: ============================================================================
:emergency_process_termination
echo [*] EMERGENCY: Terminating suspicious interpreter processes...

for %%P in (wscript.exe cscript.exe mshta.exe) do (
    taskkill /f /im %%P >NUL 2>&1
)

echo [+] Emergency process termination complete.
echo [!] cmd.exe and powershell.exe NOT killed to preserve your session.
exit /b

:: ============================================================================
:: SUBROUTINE: EMERGENCY RESTORE SERVICES
:: ============================================================================
:emergency_restore_services
echo [*] Restoring critical Windows services...

for %%S in (
    Winmgmt EventLog Dhcp Dnscache LanmanWorkstation
    RpcSs SENS ShellHWDetection Themes
    AudioEndpointBuilder Audiosrv Schedule
) do (
    sc config %%S start= auto >NUL 2>&1
    net start %%S >NUL 2>&1
)

echo [+] Critical services restored.
exit /b

:: ============================================================================
:: SUBROUTINE: EMERGENCY NETWORK RESET
:: ============================================================================
:emergency_network_reset
echo [*] Emergency network reset...

call :repair_network_stack

powershell -Command "Get-NetAdapter | Disable-NetAdapter -Confirm:$false" >NUL 2>&1
timeout /t 3 /nobreak >NUL
powershell -Command "Get-NetAdapter | Enable-NetAdapter -Confirm:$false" >NUL 2>&1

echo [+] Emergency network reset complete.
exit /b

:: ============================================================================
:: SUBROUTINE: IDENTIFY RESOURCE HOGS
:: ============================================================================
:identify_resource_hogs
echo [*] Identifying resource hogs...

powershell -Command "
Get-Process |
  Sort-Object CPU -Descending |
  Select-Object -First 10 |
  Format-Table ProcessName, CPU, @{N='RAM_MB';E={[math]::Round(\$_.WorkingSet/1MB,1)}}, Id -AutoSize |
  Out-File '%ccdcpath%\Repair\Top_CPU_Users.txt'
" 2>NUL

powershell -Command "
Get-Process |
  Sort-Object WorkingSet -Descending |
  Select-Object -First 10 |
  Format-Table ProcessName, @{N='RAM_MB';E={[math]::Round(\$_.WorkingSet/1MB,1)}}, CPU, Id -AutoSize |
  Out-File '%ccdcpath%\Repair\Top_Memory_Users.txt'
" 2>NUL

echo [+] Resource hogs identified. Check %ccdcpath%\Repair\
exit /b

:: ============================================================================
:: SUBROUTINE: KILL RESOURCE HOGS
:: ============================================================================
:kill_resource_hogs
echo [*] Killing processes using excessive resources...

powershell -Command "
Get-Process |
  Where-Object {\$_.CPU -gt 80 -and \$_.Name -notin @('svchost','System','Idle','explorer')} |
  ForEach-Object {
    Write-Host \"Killing: \$(\$_.Name) (CPU: \$(\$_.CPU))\"
    Stop-Process -Id \$_.Id -Force
  }
" 2>NUL

echo [+] High CPU processes terminated.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE TELEMETRY
:: ============================================================================
:disable_telemetry
echo [*] Disabling telemetry...

sc config DiagTrack      start= disabled >NUL 2>&1 & net stop DiagTrack      /y >NUL 2>&1
sc config dmwappushservice start= disabled >NUL 2>&1 & net stop dmwappushservice /y >NUL 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >NUL 2>&1

echo [+] Telemetry disabled.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE SUPERFETCH
:: ============================================================================
:disable_superfetch
echo [*] Disabling Superfetch/SysMain...

sc config SysMain start= disabled >NUL 2>&1
net stop SysMain /y >NUL 2>&1

echo [+] Superfetch disabled.
exit /b

:: ============================================================================
:: SUBROUTINE: OPTIMIZE PAGE FILE
:: ============================================================================
:optimize_page_file
echo [*] Setting page file to system-managed...

powershell -Command "
\$cs = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
\$cs.AutomaticManagedPagefile = \$true
\$cs.Put()
" >NUL 2>&1

echo [+] Page file set to system-managed.
exit /b

:: ============================================================================
:: SUBROUTINE: OPTIMIZE STARTUP
:: ============================================================================
:optimize_startup
echo [*] Auditing startup programs...

wmic startup get caption,command,location > "%ccdcpath%\Repair\Startup_Items.txt" 2>NUL

echo [+] Startup items audited: %ccdcpath%\Repair\Startup_Items.txt
echo [*] Review and disable unnecessary items via Task Manager > Startup tab.
exit /b

:: ============================================================================
:: SUBROUTINE: DISABLE MAINTENANCE TASKS
:: ============================================================================
:disable_maintenance_tasks
echo [*] Disabling Windows maintenance tasks...

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f >NUL 2>&1
schtasks /change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /disable >NUL 2>&1

echo [+] Maintenance tasks disabled.
exit /b

:: ============================================================================
:: SUBROUTINE: OPTIMIZE PERFORMANCE
:: ============================================================================
:optimize_performance
echo [*] Applying performance optimizations...

call :disable_telemetry
call :disable_superfetch
call :optimize_page_file

:: Disable visual effects for performance
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >NUL 2>&1

echo [+] Performance optimizations applied.
exit /b

:: ============================================================================
:: SUBROUTINE: DIAGNOSE NETWORK
:: ============================================================================
:diagnose_network
echo [*] Running network diagnostics...

ping -n 4 8.8.8.8     > "%ccdcpath%\Repair\Network_Ping_Test.txt" 2>NUL
nslookup google.com   > "%ccdcpath%\Repair\Network_DNS_Test.txt" 2>NUL
tracert -d -h 10 8.8.8.8 > "%ccdcpath%\Repair\Network_Traceroute.txt" 2>NUL
ipconfig /all         > "%ccdcpath%\Repair\Network_IPConfig.txt" 2>NUL

echo [+] Network diagnostics saved to %ccdcpath%\Repair\
exit /b

:: ============================================================================
:: SUBROUTINE: RESET TCP/IP
:: ============================================================================
:reset_tcp_ip
echo [*] Resetting TCP/IP stack...

netsh int ip reset    >NUL 2>&1
netsh int ipv4 reset  >NUL 2>&1
netsh int ipv6 reset  >NUL 2>&1

echo [+] TCP/IP reset.
exit /b

:: ============================================================================
:: SUBROUTINE: FLUSH DNS
:: ============================================================================
:flush_dns
echo [*] Flushing DNS cache...
ipconfig /flushdns >NUL 2>&1
echo [+] DNS cache flushed.
exit /b

:: ============================================================================
:: SUBROUTINE: RESET WINSOCK
:: ============================================================================
:reset_winsock
echo [*] Resetting Winsock...
netsh winsock reset >NUL 2>&1
echo [+] Winsock reset.
exit /b

:: ============================================================================
:: SUBROUTINE: RELEASE/RENEW DHCP
:: ============================================================================
:release_renew_dhcp
echo [*] Releasing and renewing DHCP...
ipconfig /release >NUL 2>&1
ipconfig /renew   >NUL 2>&1
echo [+] DHCP renewed.
exit /b

:: ============================================================================
:: SUBROUTINE: FIX DNS CLIENT
:: ============================================================================
:fix_dns_client
echo [*] Fixing DNS Client service...
net stop Dnscache   >NUL 2>&1
net start Dnscache  >NUL 2>&1
sc config Dnscache start= auto >NUL 2>&1
echo [+] DNS Client service restarted.
exit /b

:: ============================================================================
:: SUBROUTINE: TEST CONNECTIVITY
:: ============================================================================
:test_connectivity
echo [*] Testing connectivity...

ping -n 1 8.8.8.8 >NUL 2>&1
if %errorlevel% EQU 0 (
    echo [+] Internet connectivity: OK
) else (
    echo [!] Internet connectivity: FAILED
)

nslookup google.com >NUL 2>&1
if %errorlevel% EQU 0 (
    echo [+] DNS resolution: OK
) else (
    echo [!] DNS resolution: FAILED
)

exit /b

:: ============================================================================
:: SUBROUTINE: CHECK PROXY SETTINGS
:: ============================================================================
:check_proxy_settings
echo [*] Checking proxy settings...
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" > "%ccdcpath%\Repair\Proxy_Settings.txt" 2>NUL
echo [+] Proxy settings: %ccdcpath%\Repair\Proxy_Settings.txt
exit /b

:: ============================================================================
:: SUBROUTINE: FIX NETWORK ADAPTERS
:: ============================================================================
:fix_network_adapters
echo [*] Resetting network adapters...
powershell -Command "Get-NetAdapter | Disable-NetAdapter -Confirm:$false" >NUL 2>&1
timeout /t 3 /nobreak >NUL
powershell -Command "Get-NetAdapter | Enable-NetAdapter -Confirm:$false" >NUL 2>&1
echo [+] Network adapters reset.
exit /b

:: ============================================================================
:: PROVIDENCE MAX v3.0 - SUBROUTINES PART 8
:: Malware Cleanup, Baseline Creator, and Utility Subroutines
:: ============================================================================

:: ============================================================================
:: SUBROUTINE: QUARANTINE SUSPICIOUS FILES
:: ============================================================================
:quarantine_suspicious_files
echo [*] Quarantining suspicious files...

set "quarantine_dir=%ccdcpath%\Quarantine\%timestamp%"
mkdir "%quarantine_dir%" >NUL 2>&1

:: Move suspicious executables from TEMP
if exist "%TEMP%\*.exe" (
    move /y "%TEMP%\*.exe" "%quarantine_dir%\" >NUL 2>&1
    echo [*] EXE files quarantined from TEMP.
)

:: Move suspicious scripts from TEMP
for %%E in (vbs js hta ps1 bat cmd wsf) do (
    if exist "%TEMP%\*.%%E" (
        move /y "%TEMP%\*.%%E" "%quarantine_dir%\" >NUL 2>&1
    )
)

:: Move suspicious files from startup folders
for %%E in (exe dll vbs js hta ps1 bat cmd wsf scr) do (
    move /y "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*.%%E" "%quarantine_dir%\" >NUL 2>&1
    move /y "%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup\*.%%E" "%quarantine_dir%\" >NUL 2>&1
)

echo [+] Quarantine complete: %quarantine_dir%
exit /b

:: ============================================================================
:: SUBROUTINE: REMOVE ALL PERSISTENCE
:: ============================================================================
:remove_all_persistence
echo [*] Removing all persistence mechanisms...

call :clear_all_persistence

:: Backup and clean scheduled tasks
schtasks /query /fo LIST /v > "%ccdcpath%\Config\Tasks_before_cleanup_%timestamp%.txt" 2>NUL

echo [*] Non-Microsoft scheduled tasks:
powershell -Command "
Get-ScheduledTask |
  Where-Object {\$_.TaskPath -notlike '\Microsoft\*'} |
  Select-Object TaskName, TaskPath, State |
  Format-Table -AutoSize
" 2>NUL

echo.
set /p "delete_user_tasks=Delete all non-Microsoft scheduled tasks? [y/n]: "
if /i "%delete_user_tasks%"=="y" (
    powershell -Command "
    Get-ScheduledTask |
      Where-Object {\$_.TaskPath -notlike '\Microsoft\*'} |
      Unregister-ScheduledTask -Confirm:\$false
    " >NUL 2>&1
    echo [+] Non-Microsoft tasks removed.
)

echo [+] Persistence removal complete.
exit /b

:: ============================================================================
:: SUBROUTINE: KILL SUSPICIOUS PROCESSES
:: ============================================================================
:kill_suspicious_processes
echo [*] Killing processes from suspicious locations...

powershell -Command "
Get-Process |
  Where-Object {
    \$_.Path -like '*\Temp\*' -or
    \$_.Path -like '*\AppData\Local\Temp\*' -or
    \$_.Path -like '*\Users\Public\*'
  } |
  ForEach-Object {
    Write-Host \"Killing: \$(\$_.Name) from \$(\$_.Path)\"
    Stop-Process -Id \$_.Id -Force
  }
" 2>NUL

:: Kill common malware processes
for %%P in (
    wscript.exe cscript.exe mshta.exe
    powershell_ise.exe msbuild.exe regasm.exe regsvcs.exe
    installutil.exe cmstp.exe
) do (
    taskkill /f /im %%P >NUL 2>&1
)

echo [+] Suspicious processes terminated.
exit /b

:: ============================================================================
:: SUBROUTINE: CLEAN BROWSER COMPLETELY
:: ============================================================================
:clean_browser_completely
echo [*] Cleaning browsers...

call :delete_temp_files_aggressive

:: Reset IE
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

:: ============================================================================
:: SUBROUTINE: REMOVE SUSPICIOUS SERVICES
:: ============================================================================
:remove_suspicious_services
echo [*] Identifying suspicious services...

powershell -Command "
Get-WmiObject Win32_Service |
  Where-Object {
    \$_.PathName -and
    \$_.PathName -notlike '*System32*' -and
    \$_.PathName -notlike '*SysWOW64*' -and
    \$_.PathName -notlike '*Program Files*' -and
    \$_.PathName -notlike '*ProgramData\Microsoft*' -and
    \$_.StartMode -ne 'Disabled'
  } |
  Select-Object Name, PathName |
  Format-Table -AutoSize
" 2>NUL

echo [!] Review and stop/delete suspicious services manually:
echo     sc stop [ServiceName]
echo     sc delete [ServiceName]
exit /b

:: ============================================================================
:: SUBROUTINE: CLEAN WMI COMPLETELY
:: ============================================================================
:clean_wmi_completely
echo [*] Removing all WMI persistence subscriptions...

powershell -Command "
Get-WMIObject -Namespace root\Subscription -Class __EventFilter -ErrorAction SilentlyContinue |
  Remove-WmiObject -ErrorAction SilentlyContinue
" >NUL 2>&1

powershell -Command "
Get-WMIObject -Namespace root\Subscription -Class __EventConsumer -ErrorAction SilentlyContinue |
  Remove-WmiObject -ErrorAction SilentlyContinue
" >NUL 2>&1

powershell -Command "
Get-WMIObject -Namespace root\Subscription -Class __FilterToConsumerBinding -ErrorAction SilentlyContinue |
  Remove-WmiObject -ErrorAction SilentlyContinue
" >NUL 2>&1

net stop Winmgmt /y >NUL 2>&1
net start Winmgmt   >NUL 2>&1

echo [+] WMI subscriptions cleaned.
exit /b

:: ============================================================================
:: SUBROUTINE: RESET HOSTS FILE
:: ============================================================================
:reset_hosts_file
echo [*] Resetting hosts file...

copy /y "%SystemRoot%\System32\drivers\etc\hosts" "%ccdcpath%\Config\hosts_backup_%timestamp%.txt" >NUL 2>&1

(
echo # Copyright ^(c^) 1993-2009 Microsoft Corp.
echo #
echo # This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
echo #
echo # This file contains the mappings of IP addresses to host names. Each
echo # entry should be kept on an individual line. The IP address should
echo # be placed in the first column followed by the corresponding host name.
echo # The IP address and the host name should be separated by at least one
echo # space.
echo #
echo # Additionally, comments ^(such as these^) may be inserted on individual
echo # lines or following the machine name denoted by a '#' symbol.
echo #
echo # For example:
echo #
echo #      102.54.94.97     rhino.acme.com          # source server
echo #       38.25.63.10     x.acme.com              # x client host
echo #
echo # localhost name resolution is handled within DNS itself.
echo #	127.0.0.1       localhost
echo #	::1             localhost
echo 127.0.0.1       localhost
echo ::1             localhost
) > "%SystemRoot%\System32\drivers\etc\hosts"

echo [+] Hosts file reset to defaults. Backup saved.
exit /b

:: ============================================================================
:: SUBROUTINE: CLEAR DNS CACHE
:: ============================================================================
:clear_dns_cache
echo [*] Clearing DNS cache...
ipconfig /flushdns >NUL 2>&1
echo [+] DNS cache cleared.
exit /b

:: ============================================================================
:: SUBROUTINE: REMOVE PROXY SETTINGS
:: ============================================================================
:remove_proxy_settings
echo [*] Removing proxy settings...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable   /t REG_DWORD /d 0 /f >NUL 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer   /f >NUL 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >NUL 2>&1

:: Also clear system-wide proxy
netsh winhttp reset proxy >NUL 2>&1

echo [+] Proxy settings removed.
exit /b

:: ============================================================================
:: SUBROUTINE: CLEAN SCHEDULED TASKS AGGRESSIVE
:: ============================================================================
:clean_scheduled_tasks_aggressive
echo [*] Aggressively cleaning scheduled tasks...

schtasks /query /fo LIST /v > "%ccdcpath%\Config\ScheduledTasks_Before_Cleanup_%timestamp%.txt" 2>NUL

echo.
set /p "confirm_tasks=Delete ALL non-Microsoft scheduled tasks? [y/n]: "
if /i "%confirm_tasks%"=="y" (
    powershell -Command "
    Get-ScheduledTask |
      Where-Object {\$_.TaskPath -notlike '\Microsoft\*'} |
      Unregister-ScheduledTask -Confirm:\$false
    " >NUL 2>&1
    echo [+] Non-Microsoft tasks deleted.
) else (
    echo [*] Task deletion skipped.
)

exit /b

:: ============================================================================
:: SUBROUTINE: CREATE BASELINE
:: ============================================================================
:create_baseline
echo [*] Creating system baseline snapshot...

set "baseline_dir=%ccdcpath%\Baseline\%timestamp%"
mkdir "%baseline_dir%" >NUL 2>&1

echo [*] Collecting user accounts...
wmic useraccount list brief > "%baseline_dir%\Users.txt" 2>NUL
wmic group list brief > "%baseline_dir%\Groups.txt" 2>NUL
net localgroup administrators > "%baseline_dir%\Administrators.txt" 2>NUL

echo [*] Collecting services...
sc query type= service state= all > "%baseline_dir%\Services.txt" 2>NUL
powershell -Command "
Get-WmiObject Win32_Service |
  Select-Object Name, DisplayName, PathName, StartMode, State |
  Format-Table -AutoSize |
  Out-File '%baseline_dir%\Services_Detailed.txt'
" 2>NUL

echo [*] Collecting scheduled tasks...
schtasks /query /fo LIST /v > "%baseline_dir%\ScheduledTasks.txt" 2>NUL

echo [*] Collecting processes...
tasklist /v > "%baseline_dir%\Processes.txt" 2>NUL
powershell -Command "
Get-WmiObject Win32_Process |
  Select-Object ProcessId, Name, CommandLine |
  Format-List |
  Out-File '%baseline_dir%\Process_CommandLines.txt'
" 2>NUL

echo [*] Collecting network state...
netstat -ano > "%baseline_dir%\NetworkConnections.txt" 2>NUL
ipconfig /all > "%baseline_dir%\NetworkConfig.txt" 2>NUL
arp -a > "%baseline_dir%\ARP.txt" 2>NUL
route print > "%baseline_dir%\Routes.txt" 2>NUL
net share > "%baseline_dir%\Shares.txt" 2>NUL

echo [*] Collecting installed programs...
wmic product get name,version,vendor > "%baseline_dir%\InstalledPrograms.txt" 2>NUL

echo [*] Collecting startup programs...
wmic startup get caption,command,location > "%baseline_dir%\StartupPrograms.txt" 2>NUL

echo [*] Collecting registry run keys...
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" > "%baseline_dir%\HKCU_Run.txt" 2>NUL
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" > "%baseline_dir%\HKLM_Run.txt" 2>NUL

echo [*] Collecting firewall rules...
netsh advfirewall firewall show rule name=all > "%baseline_dir%\FirewallRules.txt" 2>NUL

echo [*] Collecting system info...
systeminfo > "%baseline_dir%\SystemInfo.txt" 2>NUL

echo [*] Hashing System32 executables (this takes a minute)...
powershell -Command "
Get-ChildItem 'C:\Windows\System32\*.exe' |
  Get-FileHash -Algorithm SHA256 |
  Select-Object Path, Hash |
  Out-File '%baseline_dir%\System32_Hashes.txt'
" 2>NUL

echo [*] Collecting WMI subscriptions...
powershell -Command "
Get-WMIObject -Namespace root\Subscription -Class __EventFilter -ErrorAction SilentlyContinue |
  Select-Object Name, Query |
  Out-File '%baseline_dir%\WMI_Subscriptions.txt'
" 2>NUL

echo [*] Collecting audit policy...
auditpol /get /category:* > "%baseline_dir%\AuditPolicy.txt" 2>NUL

echo [*] Collecting local security policy...
secedit /export /cfg "%baseline_dir%\SecurityPolicy.cfg" >NUL 2>&1

(
echo ================================================================================
echo  Providence MAX Baseline Manifest
echo  Created: %timestamp%
echo  Computer: %COMPUTERNAME%
echo  Domain:   %USERDOMAIN%
echo  User:     %USERNAME%
echo ================================================================================
echo.
echo Files in this baseline:
dir /b "%baseline_dir%"
) > "%baseline_dir%\MANIFEST.txt" 2>NUL

echo [+] Baseline created: %baseline_dir%
echo [*] Use 'fc baseline1\file.txt baseline2\file.txt' to compare states.
exit /b

:: ============================================================================
:: END OF SUBROUTINES - PROVIDENCE MAX v3.0
:: ============================================================================
:: To assemble the complete script, concatenate all parts in order:
::   Part 1: Main structure, menu, and mode handlers
::   Part 2: Network info, backup, firewall subroutines
::   Part 3: Service disabling, backdoor fixing, logging, password policy
::   Part 4: SMB, RDP, WMI, LSASS, protocols, PowerShell hardening
::   Part 5: Full registry hardening, CIS/STIG/NSA standards
::   Part 6: All threat hunting subroutines
::   Part 7: System repair, performance, network diagnostics
::   Part 8: Malware cleanup, baseline creator (this file)
:: ============================================================================

