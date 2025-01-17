FROM prestashop/prestashop:1.5.6.3

RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list 

RUN apt update -y
RUN apt install vim -y

COPY ./waf.sh /root/waf.sh

RUN /root/waf.sh

CMD source /etc/apache2/envvars; apache2 -DFOREGROUND
