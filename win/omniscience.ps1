# omniscience.ps1
#
# Omniscience - All knowing
#
# Palo Alto setup script for FW2 (Windows subnet)
# PowerShell port of firewall/omniscience.sh
#
# FW2: Mgmt 172.20.240.200 | Outside 172.16.102.254 | Inside 172.20.240.254

Write-Host "Starting omniscience script"

$gen = Read-Host "Do you want to generate rules? [y/n]"

if ($gen -eq "y" -or $gen -eq "Y") {
    # Mode A - Generate rules interactively

    $IP = Read-Host "What is the IP of the firewall management?"

    $this_fw = Read-Host "What is the IP of the external firewall interface? (Blank if unknown)"
    if ($this_fw -eq "") {
        $this_fw = "127.0.0.1"
    }

    $syslog = Read-Host "What is the IP of the Syslog Server? (Blank if unknown)"
    if ($syslog -eq "") {
        $syslog = "127.0.0.1"
    }

    $ZONES = Read-Host "List all the zones (CAPITALIZATION Matters)"
    $EXT_ZONE = Read-Host "Which one is externally facing? [$ZONES]"
    $INT_ZONES = Read-Host "Which ones are internally facing? [$ZONES]"

    # Pass zone info to palo-gen.ps1 via environment variable
    $env:ZONES = $ZONES
    & "$PSScriptRoot\palo-gen.ps1"

    # Assemble run-omniscience.txt
    "set cli scripting-mode on" | Set-Content .\run-omniscience.txt
    "configure" | Add-Content .\run-omniscience.txt
    "set address this-fw ip-netmask $this_fw" | Add-Content .\run-omniscience.txt

    Get-Content "$PSScriptRoot\..\firewall\palo-base1.txt" | Add-Content .\run-omniscience.txt

    # Replace SYSLOG_SERVER_IP placeholder
    (Get-Content .\run-omniscience.txt) -replace 'SYSLOG_SERVER_IP', $syslog | Set-Content .\run-omniscience.txt

    Get-Content .\palo-gen.txt | Add-Content .\run-omniscience.txt

    Get-Content "$PSScriptRoot\..\firewall\palo-base2.txt" | Add-Content .\run-omniscience.txt

    # Replace zone name placeholders
    (Get-Content .\run-omniscience.txt) -replace 'EXT_ZONE', $EXT_ZONE | Set-Content .\run-omniscience.txt

    if ($INT_ZONES -match " ") {
        (Get-Content .\run-omniscience.txt) -replace 'INT_ZONES', "[ $INT_ZONES ]" | Set-Content .\run-omniscience.txt
    } else {
        (Get-Content .\run-omniscience.txt) -replace 'INT_ZONES', $INT_ZONES | Set-Content .\run-omniscience.txt
    }

    "commit" | Add-Content .\run-omniscience.txt
    "exit" | Add-Content .\run-omniscience.txt

    Get-Content .\run-omniscience.txt | ssh.exe -T -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa admin@$IP

} else {
    # Mode B - Hardcoded FW2 2026 state

    $teamNum = Read-Host "Enter team number (1-12)"
    $team = 20 + [int]$teamNum

    "set cli scripting-mode on" | Set-Content .\run-omniscience.txt
    "configure" | Add-Content .\run-omniscience.txt

    # FW2 interface address objects
    "set address this-fw ip-netmask 172.16.102.254" | Add-Content .\run-omniscience.txt
    "set address this-fw2 ip-netmask 172.20.240.254" | Add-Content .\run-omniscience.txt

    # Public address objects (team-specific)
    # team = 20 + team_number (e.g. team 1 -> 172.25.21.x)
    "set address public-ad-dns ip-netmask 172.25.$team.155" | Add-Content .\run-omniscience.txt
    "set address public-web ip-netmask 172.25.$team.140" | Add-Content .\run-omniscience.txt
    "set address public-ftp ip-netmask 172.25.$team.162" | Add-Content .\run-omniscience.txt
    "set address public-win11wks ip-netmask 172.25.$team.144" | Add-Content .\run-omniscience.txt

    Get-Content "$PSScriptRoot\..\firewall\omniscience-fw2.txt" | Add-Content .\run-omniscience.txt

    "commit" | Add-Content .\run-omniscience.txt
    "exit" | Add-Content .\run-omniscience.txt

    Get-Content .\run-omniscience.txt | ssh.exe -T -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa admin@172.20.240.200
}
