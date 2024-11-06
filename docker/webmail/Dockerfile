FROM fedora:42

RUN yum upgrade -y

RUN yum install postfix dovecot telnet net-tools -y

WORKDIR "/startup"

CMD ["/startup/start.sh"]
