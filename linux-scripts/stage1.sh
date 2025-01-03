#!/bin/bash
# 
# stage1.sh
# 
# Stage 1 of 2?
# 
# Kaicheng Ye
# Feb. 2024

# Check if script has been run with superuser privileges
if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

# command line flags
MACHINE=''
FORCE=0

print_usage() {
    printf "    -f force wget without certificate check
    -m <machine> to run pansophy with preconfigred firewall rules\n"
}

while getopts 'fm:h' flag; do
    case "${flag}" in
        f) FORCE=1 ;;
        m) MACHINE="${OPTARG}" ;;
        h) print_usage
	   exit 0 ;;
        *) print_usage
	   exit 1 ;;
    esac
done


printf "Initiating stage 1\n"

STAGE1=1
export STAGE1

mkdir work
cd work

case $MACHINE in
    "dns-ntp")     ;;
    "ecomm")       ;;
    "splunk")      ;;
    "web")         ;;
    "webmail")     ;;
    "workstation") ;;
    "")            ;;
    *)
printf "${error}ERROR: Enter respective name according to machine's purpose:
    dns-ntp
    ecomm
    splunk
    web
    webmail
    workstation
    or no parameters for generic${reset}\n"; exit 1 ;;
esac


# Set up some environment variables
. /etc/os-release

# Package Manager
if [[ "$ID" == "fedora" || "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "ol" ]]
then
    export PKG_MAN=yum
elif [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]
then
    export PKG_MAN=apt-get

    # disable apt user input
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
else
    export PKG_MAN=apt-get

    # disable apt user input
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    printf "${error}ERROR: Unsupported OS, assuming apt-get${reset}\n"
fi



# check if wget is installed
which wget > /dev/null
if [[ $? -eq 0 ]]
then

    # wget is installed
    # force means insecure (don't check certificate)
    if [[ $FORCE -eq 0 ]]
    then
    # NO force
        which tar > /dev/null
        if [[ $? -ne 0 ]]
        then
            if [[ "$PKG_MAN" == "apt-get" ]]
            then
                apt-get update
                apt-get install tar -y --force-yes
            else
                yum clean expire-cache
                yum check-update
                yum install epel-release -y
                yum install tar -y
            fi
        fi
        which tar > /dev/null
        if [[ $? -eq 0 ]]
        then
    	    wget https://github.com/CedarvilleCyber/CCDC/archive/main.tar.gz -O main.tar.gz
    	    tar -zxvf ./main.tar.gz
    	    cd ./CCDC-main/linux-scripts
    	    ./pansophy.sh "$MACHINE"
        else
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/pansophy.sh -O pansophy.sh
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/backup.sh -O backup.sh
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/check-cron.sh -O check-cron.sh
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/firewall.sh -O firewall.sh
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/restore-backup.sh -O restore-backup.sh
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/secure-os.sh -O secure-os.sh
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.txt -O prophylaxis.txt
    	    wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.sh -O prophylaxis.sh

    	    chmod 700 pansophy.sh
    	    chmod 700 backup.sh
    	    chmod 700 check-cron.sh
    	    chmod 700 firewall.sh
    	    chmod 700 restore-backup.sh
    	    chmod 700 secure-os.sh
    	    chmod 700 propylaxis.sh

    	    # check cron now!
    	    ./check-cron.sh

    	    #./pansophy.sh "$MACHINE" "stage1"
    	    git clone https://github.com/CedarvilleCyber/CCDC.git --depth 1

    	    printf "\n\nBasics secured. Now,   cd ./work/CCDC/linux-scripts
and run pansophy.sh like normal\n\n\n"
        fi
    else
    # YES force
        which tar > /dev/null
        if [[ $? -ne 0 ]]
        then
            if [[ "$PKG_MAN" == "apt-get" ]]
            then
                apt-get update
                apt-get install tar -y --force-yes
            else
                yum clean expire-cache
                yum check-update
                yum install epel-release -y
                yum install tar -y
            fi
        fi
        which tar > /dev/null
        if [[ $? -eq 0 ]]
        then
    	    wget --no-check-certificate https://github.com/CedarvilleCyber/CCDC/archive/main.tar.gz -O main.tar.gz
    	    tar -zxvf ./main.tar.gz
    	    cd ./CCDC-main/linux-scripts
	        ./pansophy.sh "$MACHINE"
        else
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/pansophy.sh -O pansophy.sh
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/backup.sh -O backup.sh
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/check-cron.sh -O check-cron.sh
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/firewall.sh -O firewall.sh
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/restore-backup.sh -O restore-backup.sh
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/secure-os.sh -O secure-os.sh
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.txt -O prophylaxis.txt
    	    wget --no-check-certificate --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.sh -O prophylaxis.sh

	        chmod 700 pansophy.sh
	        chmod 700 backup.sh
	        chmod 700 check-cron.sh
	        chmod 700 firewall.sh
        	chmod 700 restore-backup.sh
        	chmod 700 secure-os.sh
        	chmod 700 propylaxis.sh

        	# check cron now!
        	./check-cron.sh

        	#./pansophy.sh "$MACHINE" "stage1"
            git config --global http.sslVerify False
        	git clone https://github.com/CedarvilleCyber/CCDC.git --depth 1

        	printf "\n\nBasics secured. Now,   cd ./work/CCDC/linux-scripts
and run pansophy.sh like normal\n\n\n"
        fi
    fi


else

    # wget is NOT installed using curl
    # force means insecure (don't check certificate)
    if [[ $FORCE -eq 0 ]]
    then
    # NO force
        which tar > /dev/null
        if [[ $? -ne 0 ]]
        then
            if [[ "$PKG_MAN" == "apt-get" ]]
            then
                apt-get update
                apt-get install tar -y --force-yes
            else
                yum clean expire-cache
                yum check-update
                yum install epel-release -y
                yum install tar -y
            fi
        fi
        which tar > /dev/null
        if [[ $? -eq 0 ]]
        then
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://github.com/CedarvilleCyber/CCDC/archive/main.tar.gz -o main.tar.gz
    	    tar -zxvf ./main.tar.gz
    	    cd ./CCDC-main/linux-scripts
    	    ./pansophy.sh "$MACHINE"
        else
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/pansophy.sh -o pansophy.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/backup.sh -o backup.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/check-cron.sh -o check-cron.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/firewall.sh -o firewall.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/restore-backup.sh -o restore-backup.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/secure-os.sh -o secure-os.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.txt -o prophylaxis.txt
    	    curl -H 'Cache-Control: no-cache, no-store' -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.sh -o prophylaxis.sh

    	    chmod 700 pansophy.sh
    	    chmod 700 backup.sh
    	    chmod 700 check-cron.sh
    	    chmod 700 firewall.sh
    	    chmod 700 restore-backup.sh
    	    chmod 700 secure-os.sh
    	    chmod 700 propylaxis.sh

    	    # check cron now!
    	    ./check-cron.sh

    	    #./pansophy.sh "$MACHINE" "stage1"
    	    git clone https://github.com/CedarvilleCyber/CCDC.git --depth 1

    	    printf "\n\nBasics secured. Now,   cd ./work/CCDC/linux-scripts
and run pansophy.sh like normal\n\n\n"
        fi
    else
    # YES force
        which tar > /dev/null
        if [[ $? -ne 0 ]]
        then
            if [[ "$PKG_MAN" == "apt-get" ]]
            then
                apt-get update
                apt-get install tar -y --force-yes
            else
                yum clean expire-cache
                yum check-update
                yum install epel-release -y
                yum install tar -y
            fi
        fi
        which tar > /dev/null
        if [[ $? -eq 0 ]]
        then
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://github.com/CedarvilleCyber/CCDC/archive/main.tar.gz -o main.tar.gz
    	    tar -zxvf ./main.tar.gz
    	    cd ./CCDC-main/linux-scripts
	        ./pansophy.sh "$MACHINE"
        else
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/pansophy.sh -o pansophy.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/backup.sh -o backup.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/check-cron.sh -o check-cron.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/firewall.sh -o firewall.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/restore-backup.sh -o restore-backup.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/secure-os.sh -o secure-os.sh
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.txt -o prophylaxis.txt
    	    curl -H 'Cache-Control: no-cache, no-store' -k -L https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/palo-alto/prophylaxis.sh -o prophylaxis.sh

	        chmod 700 pansophy.sh
	        chmod 700 backup.sh
	        chmod 700 check-cron.sh
	        chmod 700 firewall.sh
        	chmod 700 restore-backup.sh
        	chmod 700 secure-os.sh
        	chmod 700 propylaxis.sh

        	# check cron now!
        	./check-cron.sh

        	#./pansophy.sh "$MACHINE" "stage1"
            git config --global http.sslVerify False
        	git clone https://github.com/CedarvilleCyber/CCDC.git --depth 1

        	printf "\n\nBasics secured. Now,   cd ./work/CCDC/linux-scripts
and run pansophy.sh like normal\n\n\n"
        fi
    fi

fi

exit 0
