FROM prestashop/prestashop:1.5.6.3

RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list 

RUN apt update -y
RUN apt install vim -y

CMD ["/root/waf.sh"]
