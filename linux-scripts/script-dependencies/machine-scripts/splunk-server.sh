#!/bin/bash

echo "Begin splunk-server script ..."

export ID=splunk
iptables -f
# after ID is fixed, more rules will apply
/opt/CCDC/linux-scripts/script-dependencies/firewall/iptables.sh

echo "... splunk-server script complete!"
