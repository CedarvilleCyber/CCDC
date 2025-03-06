set /p passwd="What would you like the password to be?"
net user %username% %passwd%
echo Changed password for %username%
timeout /t 5