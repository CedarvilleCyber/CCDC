@echo off
::Splunk Universal Forwarder Setup for Windows Hosts
set /p splunk_ip "What is the IP address of the Splunk server?: "
set /p certfile "What is the path of the .pem SSL certificate for this forwarder?: "
:passwd_section
set /p %passwd% "What is the SSL password?: "
set /p %confpass% "Please confirm the password: "
if %passwd% != %confpasswd%
(
  echo Passwords do not match. Try again.
  GOTO :passwd_section
)
msiexec.exe /i splunkuniversalforwarder_x86.msi CERTFILE=%certfile% CERTPASSWD=%passwd% RECEIVING_INDEXER="%splunk_ip%:9997" WINEVENTLOG_SEC_ENABLE=1 WINEVENTLOG_SYS_ENABLE=1 AGREETOLICENSE=Yes /quiet
