#!/bin/bash

printf "Automated installer of oracle client for Ubuntu" 

# Install dependencies
sudo apt update
sudo apt install -y alien



# Download files. Example specific to 19.3 
# Some links were not correct on the downloads page
# (still pointing to a license page), but easy enough to
# figure out from working ones      
wget https://download.oracle.com/otn_software/linux/instantclient/19600/oracle-instantclient19.6-basiclite-19.6.0.0.0-1.x86_64.rpm
wget https://download.oracle.com/otn_software/linux/instantclient/19600/oracle-instantclient19.6-sqlplus-19.6.0.0.0-1.x86_64.rpm

sudo alien -i oracle-instantclient19.6-*.rpm
sudo apt install -y libaio1



# Create Oracle environment script
printf "\n\n# Oracle Client environment\n \
export LD_LIBRARY_PATH=/usr/lib/oracle/19.6/client64/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export ORACLE_HOME=/usr/lib/oracle/19.6/client64\n" | sudo tee /etc/profile.d/oracle-env.sh > /dev/null

. /etc/profile.d/oracle-env.sh

printf "Install complete. Please verify"
