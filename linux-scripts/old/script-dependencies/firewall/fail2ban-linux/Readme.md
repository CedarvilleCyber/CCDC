## Fail2ban
There is some really solid potential here to protect our running services from different kinds of attacks. Fail2ban will watch the logs of a specific service and will implement firewall policies to ban users (block ips), rate limit, etc.

## Usage
The utility of this tool relies in the quality of your jail.conf file. I have not configured these for any machine except fedora. So, spend some time for your machine setting up the jail.conf to specifically harden your services.

## Dependencies
This uses firewalld to implement firewall rules. Keep that in mind.