# palo-gen.ps1
#
# Generate Palo Alto commands based on input
# Called by omniscience.ps1 (Mode A). Not meant for stand-alone use.
# PowerShell port of firewall/palo-gen.sh
#
# Kaicheng Ye / 2026 port

Write-Host -ForegroundColor Green "Starting palo-gen script"

# Helper: check if all items in $searchStr are present in $wordList
function Contains {
    param(
        [string]$searchStr,
        [string]$wordList
    )
    $words = $wordList -split '\s+'
    if ($searchStr -match '\s') {
        # multiple items — every one must be in the list
        foreach ($item in ($searchStr -split '\s+')) {
            if ($words -notcontains $item) {
                return $false
            }
        }
        return $true
    } else {
        return $words -contains $searchStr
    }
}

# Clear old palo-gen.txt
if (Test-Path .\palo-gen.txt) { Remove-Item .\palo-gen.txt }

# Zone names (may already be set via $env:ZONES from omniscience.ps1)
if ($env:ZONES -ne "" -and $null -ne $env:ZONES) {
    Write-Host -ForegroundColor Green "Zone names already acquired"
    Write-Host $env:ZONES
    $ZONES = $env:ZONES
} else {
    Write-Host -ForegroundColor Green "Enter zone names found on web console. CAPITALIZATION MATTERS!"
    $ZONES = Read-Host "Separate each one by a single space"
}

# Team number
$teamInput = Read-Host "Enter team number"
$TEAM_NUMBER = 20 + [int]$teamInput

# --- Network Objects ---
Write-Host ""
Write-Host -ForegroundColor Green "Create Network Objects"
$input = "placeholder"
while ($true) {
    $name = ""
    $ip = ""

    $input = Read-Host "Name of object"

    if ($input -eq "") { break }
    $name = $input

    $input = Read-Host "IP/CIDR (put [20] wherever team number should be)"

    $input = $input -replace '\[20\]', $TEAM_NUMBER

    if ($input -eq "") {
        Write-Host -ForegroundColor Yellow "No Address entered. Invalidated $name"
        Write-Host ""
        continue
    }
    $ip = $input

    Write-Host -ForegroundColor Green "================================================================"
    Write-Host -ForegroundColor Green "Name: " -NoNewline; Write-Host $name
    Write-Host -ForegroundColor Green "  IP: " -NoNewline; Write-Host $ip
    Write-Host -ForegroundColor Green "================================================================"
    $input = Read-Host "Add rule? [y/n]"

    if ($input -eq "N" -or $input -eq "n" -or $input -eq "") {
        Write-Host -ForegroundColor Yellow "Discarding $name..."
        Write-Host ""
        continue
    }

    "set address $name ip-netmask $ip" | Add-Content .\palo-gen.txt
    Write-Host -ForegroundColor Green "Added: ${name}:${ip}"
    Write-Host ""
}

# --- Service Objects ---
Write-Host ""
Write-Host -ForegroundColor Green "Create Service Objects"
$input = "placeholder"
while ($true) {
    $name = ""
    $port = ""
    $protocol = ""

    $input = Read-Host "Name of Service"

    if ($input -eq "") { break }
    $name = $input

    $input = Read-Host "Port Number"

    if ($input -eq "") {
        Write-Host -ForegroundColor Yellow "No Port entered. Invalidated $name"
        Write-Host ""
        continue
    }
    $port = $input

    $input = Read-Host "Protocol [(t)cp/(u)dp]"

    if ($input -eq "") {
        Write-Host -ForegroundColor Yellow "No Protocol entered. Invalidated $name"
        Write-Host ""
        continue
    }

    if ($input -eq "t") {
        $protocol = "tcp"
    } elseif ($input -eq "u") {
        $protocol = "udp"
    } elseif ($input -eq "tcp" -or $input -eq "udp") {
        $protocol = $input
    } else {
        Write-Host -ForegroundColor Yellow "Unknown Protocol Entered. Invalidated $name"
        Write-Host ""
        continue
    }

    Write-Host -ForegroundColor Green "================================================================"
    Write-Host -ForegroundColor Green "    Name: " -NoNewline; Write-Host $name
    Write-Host -ForegroundColor Green "    Port: " -NoNewline; Write-Host $port
    Write-Host -ForegroundColor Green "Protocol: " -NoNewline; Write-Host $protocol
    Write-Host -ForegroundColor Green "================================================================"
    $input = Read-Host "Add rule? [y/n]"

    if ($input -eq "N" -or $input -eq "n" -or $input -eq "") {
        Write-Host -ForegroundColor Yellow "Discarding $name..."
        Write-Host ""
        continue
    }

    "set service $name protocol $protocol port $port" | Add-Content .\palo-gen.txt
    "set service $name protocol $protocol override no" | Add-Content .\palo-gen.txt
    Write-Host -ForegroundColor Green "Added: ${name}:${port}:${protocol}"
    Write-Host ""
}

# --- Security Rules ---
Write-Host ""
Write-Host -ForegroundColor Green "Create Security Rules"
$input = "placeholder"
while ($true) {
    $name = ""
    $s_zone = ""
    $s_addr = ""
    $d_zone = ""
    $d_addr = ""
    $app = ""
    $service = ""
    $action = ""

    $input = Read-Host "Name of rule"

    if ($input -eq "") { break }
    $name = $input

    # Source zone
    $input = Read-Host "Source Zone [$ZONES]"

    if ($input -eq "a" -or $input -eq "any") {
        $input = "any"
    } elseif ($input -eq "" -or -not (Contains $input $ZONES)) {
        Write-Host -ForegroundColor Yellow "Bad Zone. Invalidated $name"
        Write-Host ""
        continue
    }
    $s_zone = $input

    # Source address
    $input = Read-Host "Source Address [Name or IP/CIDR]"

    if ($input -eq "a") {
        $input = "any"
    } elseif ($input -eq "") {
        Write-Host -ForegroundColor Yellow "No Address entered. Invalidated $name"
        Write-Host ""
        continue
    }
    $s_addr = $input

    # Destination zone
    $input = Read-Host "Destination Zone [$ZONES]"

    if ($input -eq "a" -or $input -eq "any") {
        $input = "any"
    } elseif ($input -eq "" -or -not (Contains $input $ZONES)) {
        Write-Host -ForegroundColor Yellow "Bad Zone. Invalidated $name"
        Write-Host ""
        continue
    }
    $d_zone = $input

    # Destination address
    $input = Read-Host "Destination Address [Name or IP/CIDR]"

    if ($input -eq "a") {
        $input = "any"
    } elseif ($input -eq "") {
        Write-Host -ForegroundColor Yellow "No Address entered. Invalidated $name"
        Write-Host ""
        continue
    }
    $d_addr = $input

    # Application
    $input = Read-Host "Application"

    if ($input -eq "a") {
        $input = "any"
    } elseif ($input -eq "") {
        Write-Host -ForegroundColor Yellow "No Application entered. Invalidated $name"
        Write-Host ""
        continue
    }
    $app = $input

    # Service
    $input = Read-Host "Service"

    if ($input -eq "a") {
        $input = "application-default"
    } elseif ($input -eq "") {
        Write-Host -ForegroundColor Yellow "No Service entered. Invalidated $name"
        Write-Host ""
        continue
    }
    $service = $input

    # Action
    $input = Read-Host "Action [allow deny drop]"

    if ($input -ne "allow" -and $input -ne "deny" -and $input -ne "drop") {
        Write-Host -ForegroundColor Yellow "Invalid Action. Invalidated $name"
        Write-Host ""
        continue
    }
    $action = $input

    Write-Host -ForegroundColor Green "================================================================"
    Write-Host -ForegroundColor Green "            Name: " -NoNewline; Write-Host $name
    Write-Host -ForegroundColor Green "     Source Zone: " -NoNewline; Write-Host $s_zone
    Write-Host -ForegroundColor Green "     Source Addr: " -NoNewline; Write-Host $s_addr
    Write-Host -ForegroundColor Green "Destination Zone: " -NoNewline; Write-Host $d_zone
    Write-Host -ForegroundColor Green "Destination Addr: " -NoNewline; Write-Host $d_addr
    Write-Host -ForegroundColor Green "     Application: " -NoNewline; Write-Host $app
    Write-Host -ForegroundColor Green "         Service: " -NoNewline; Write-Host $service
    Write-Host -ForegroundColor Green "          Action: " -NoNewline; Write-Host $action
    Write-Host -ForegroundColor Green "================================================================"
    $input = Read-Host "Add rule? [y/n]"

    if ($input -eq "N" -or $input -eq "n" -or $input -eq "") {
        Write-Host -ForegroundColor Yellow "Discarding $name..."
        Write-Host ""
        continue
    }

    "set rulebase security rules $name profile-setting group ccdc" | Add-Content .\palo-gen.txt

    if ($s_zone -match '\s') {
        "set rulebase security rules $name from [ $s_zone ]" | Add-Content .\palo-gen.txt
    } else {
        "set rulebase security rules $name from $s_zone" | Add-Content .\palo-gen.txt
    }

    if ($s_addr -match '\s') {
        "set rulebase security rules $name source [ $s_addr ]" | Add-Content .\palo-gen.txt
    } else {
        "set rulebase security rules $name source $s_addr" | Add-Content .\palo-gen.txt
    }

    if ($d_zone -match '\s') {
        "set rulebase security rules $name to [ $d_zone ]" | Add-Content .\palo-gen.txt
    } else {
        "set rulebase security rules $name to $d_zone" | Add-Content .\palo-gen.txt
    }

    if ($d_addr -match '\s') {
        "set rulebase security rules $name destination [ $d_addr ]" | Add-Content .\palo-gen.txt
    } else {
        "set rulebase security rules $name destination $d_addr" | Add-Content .\palo-gen.txt
    }

    if ($app -match '\s') {
        "set rulebase security rules $name application [ $app ]" | Add-Content .\palo-gen.txt
    } else {
        "set rulebase security rules $name application $app" | Add-Content .\palo-gen.txt
    }

    if ($service -match '\s') {
        "set rulebase security rules $name service [ $service ]" | Add-Content .\palo-gen.txt
    } else {
        "set rulebase security rules $name service $service" | Add-Content .\palo-gen.txt
    }

    "set rulebase security rules $name action $action" | Add-Content .\palo-gen.txt
    "set rulebase security rules $name log-start no" | Add-Content .\palo-gen.txt
    "set rulebase security rules $name log-end yes" | Add-Content .\palo-gen.txt
    "set rulebase security rules $name log-setting default" | Add-Content .\palo-gen.txt

    Write-Host -ForegroundColor Green "Added: ${name}:${action}"
    Write-Host ""
}

Write-Host -ForegroundColor Green "Finished palo-gen script"
