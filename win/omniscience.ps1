# omniscience.ps1
#
# Omniscience - All knowing
#
# Palo Alto setup script for FW2 (Windows subnet)
# PowerShell port of firewall/omniscience.sh
#
# FW2: Mgmt 172.20.240.200 | Outside 172.16.102.254 | Inside 172.20.240.254

# Write lines to a file with LF (Unix) line endings so PAN-OS CLI doesn't choke on \r
function Write-LF {
    param([string]$Path, [string[]]$Lines)
    $resolved = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $resolved) { $resolved = $Path }
    [System.IO.File]::WriteAllLines($resolved, $Lines, [System.Text.UTF8Encoding]::new($false))
}
function Add-LF {
    param([string]$Path, [string[]]$Lines)
    $all = (Get-Content $Path) + $Lines
    Write-LF -Path $Path -Lines $all
}

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
    Write-LF -Path .\run-omniscience.txt -Lines @("set cli scripting-mode on", "configure", "set address this-fw ip-netmask $this_fw")

    Add-LF -Path .\run-omniscience.txt -Lines (Get-Content "$PSScriptRoot\..\firewall\palo-base1.txt")

    # Replace SYSLOG_SERVER_IP placeholder
    Write-LF -Path .\run-omniscience.txt -Lines ((Get-Content .\run-omniscience.txt) -replace 'SYSLOG_SERVER_IP', $syslog)

    Add-LF -Path .\run-omniscience.txt -Lines (Get-Content .\palo-gen.txt)

    Add-LF -Path .\run-omniscience.txt -Lines (Get-Content "$PSScriptRoot\..\firewall\palo-base2.txt")

    # Replace zone name placeholders
    Write-LF -Path .\run-omniscience.txt -Lines ((Get-Content .\run-omniscience.txt) -replace 'EXT_ZONE', $EXT_ZONE)

    if ($INT_ZONES -match " ") {
        Write-LF -Path .\run-omniscience.txt -Lines ((Get-Content .\run-omniscience.txt) -replace 'INT_ZONES', "[ $INT_ZONES ]")
    } else {
        Write-LF -Path .\run-omniscience.txt -Lines ((Get-Content .\run-omniscience.txt) -replace 'INT_ZONES', $INT_ZONES)
    }

    Add-LF -Path .\run-omniscience.txt -Lines @("commit", "exit")

    Get-Content .\run-omniscience.txt | ssh.exe -T -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa admin@$IP

} else {
    # Mode B - Hardcoded FW2 2026 state

    $teamNum = Read-Host "Enter team number (1-12)"
    $team = 20 + [int]$teamNum

    Write-LF -Path .\run-omniscience.txt -Lines @(
        "set cli scripting-mode on",
        "configure",
        "set address this-fw ip-netmask 172.16.102.254",
        "set address this-fw2 ip-netmask 172.20.240.254",
        "set address public-ad-dns ip-netmask 172.25.$team.155",
        "set address public-web ip-netmask 172.25.$team.140",
        "set address public-ftp ip-netmask 172.25.$team.162",
        "set address public-win11wks ip-netmask 172.25.$team.144"
    )

    Add-LF -Path .\run-omniscience.txt -Lines (Get-Content "$PSScriptRoot\..\firewall\omniscience-fw2.txt")

    Add-LF -Path .\run-omniscience.txt -Lines @("commit", "exit")

    Get-Content .\run-omniscience.txt | ssh.exe -T -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa admin@172.20.240.200
}
