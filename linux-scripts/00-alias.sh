date | tr -d "\n" >> /usr/logs; printf " $PPID" >> /usr/logs; echo ": ALERT: Bash Session created" >> /usr/logs
alias whoami='whoami; date | tr -d "\n" >> /usr/logs; printf " $PPID" >> /usr/logs; echo ": whoami" >> /usr/logs'
alias id='id; date | tr -d "\n" >> /usr/logs; printf " $PPID" >> /usr/logs; echo ": id" >> /usr/logs'
alias nc='nc 5; date | tr -d "\n" >> /usr/logs; printf " $PPID" >> /usr/logs; echo ": nc" >> /usr/logs'
