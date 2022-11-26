Write-Host "Running Script..."
Write-Host "Disabling Teredo"
netsh interface teredo set state disabled
netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled
netsh interface ipv6 isatap set state state=disabled 
Write-Host "Disabling SMB1.0 (EternalBlue)"
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Write-Host "Disabling RDP"
netsh advfirewall firewall add rule name="RDP from anywhere" dir=in action=allow enable=no profile=any localport=3389 protocol=tcp
Write-Host "Please Verify SMB1 is disabled"
Get-SmbServerConfiguration
