# Logging
The shell scripts present here will configure the splunk server and install splunk universal forwarders.

## Assumptions
- The splunk forwarders are not assumed to be installed, but it is assumed the user knows the certificate password created for their server and what operating system their server is running.

## Running
### Server (Indexer)
1. Create two files in this directory, one containing the CA passphrase and the other containing the Server Passphrase (Warning: server passphrase is used for the indexer and all forwarders). Pass these as CLI arguments as -C name-of-file and -S name-of-other-file .
2. Run the [server setup script](server_setup.sh) on the Splunk Enterprise Instance with the CLI parameters mentioned above as root or using sudo.
3. There should be no prompts for extra information if run with the parameters and should run in under a minute.

### Client (Forwarder)
1. Know the Splunk Server IP, the admin user, and the admin user's password
2. Run the [client setup script](install_and_setup_forwarder.sh) on the machine, responding to the Splunk Login prompts and entering the SSL password. Only install the universal forwarder once.

