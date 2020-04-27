#!/bin/bash

#First, let's configure our network interfaces
sudo ./networkInterfaces.sh

#fail2ban
sudo apt-get install -y fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

#iptable rules for the subnets interface
sudo ./subnet_interface.sh

#ddos attacks ruleset
sudo ./DDoSrules.sh

#useful rules for the iptables
sudo ./usefulRules.sh

echo "Your router is ready"
echo "For banning all the ips permanently that fail2ban bans you can run logthebans.sh"
echo "For banning the ips from the server log files you can run banServerIps.sh"

#Execute scripts for logging and banning ips every day
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "00 01 * * *  ./logthebans.sh" >> mycron
echo "00 02 * * *  ./banServerIps.sh" >> mycron
#install new cron file
crontab mycron
rm mycron