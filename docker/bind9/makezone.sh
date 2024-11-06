#!/bin/bash

# Get the domain name from the user
echo "Enter the domain name: "
read domain

domainzone="\$TTL 2d
\$ORIGIN $domain.
@ IN SOA $domain. ns.$domain. (
    `date +%Y%m%d%S` ; serial
    3h ; refresh
    15 ; retry
    1w ; expire
    3h ; minimum
)
@ IN NS ns.$domain.
"

echo "$domainzone" > "./config/$domain.zone"

echo "Put the following into your named.conf file:"
echo "zone \"$domain\" IN {
  type master;
  file \"/etc/bind/$domain.zone\";
};
"

echo -e "You will need an \033[34mns\033[0m A record: ns.$domain. IN A <ip address>"
echo "The A records will follow: <prefix>.$domain. IN A <ip address>"
echo -e "Put these in the generated zone file in the \033[34mconfig\033[0m directory"