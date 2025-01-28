FROM debian:bullseye-slim

COPY ./badproxy /etc/apt/apt.conf.d/99badproxy

RUN apt update && apt install -y \
  bind9 \
  bind9utils \
  bind9-doc \
  dnsutils \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/named \
  && chown -R bind:bind /run/named \
  && chmod 775 /run/named \
  && mkdir -p /var/cache/bind \
  && mkdir -p /var/lib/bind \
  && chown -R bind:bind /var/cache/bind \
  && chown -R bind:bind /var/lib/bind \
  && chmod 775 /var/cache/bind \
  && chmod 775 /var/lib/bind

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 53/tcp
EXPOSE 53/udp

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["named", "-g", "-c", "/etc/bind/named.conf", "-u", "bind"]