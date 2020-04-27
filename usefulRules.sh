#!/bin/sh

#Allow Loopback Connections
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

#Allow Established and Related Incoming Connections
#s network traffic generally needs to be 
#two-way—incoming and outgoing—to work properly
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Allow Established Outgoing Connections
sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Internal to External
sudo iptables -A FORWARD -i enp1s5 -o enp0s10 -j ACCEPT
sudo iptables -A FORWARD -i enp1s6 -o enp0s10 -j ACCEPT

#Drop Invalid Packets
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

#Allow incoming SSH
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Allow Outgoing SSH
sudo iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Allow All Incoming HTTP
sudo iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Allow All Incoming HTTPS
sudo iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#Set default policies
sudo iptables -A INPUT -j DROP
sudo iptables -A OUTPUT -j DROP