#!/bin/sh

#flush all previous commands
sudo iptables -t filter -F
sudo iptables -t filter -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X

#forward traffic to subnet
sudo iptables -A FORWARD -i enp1s5 -o enp0s10 -j ACCEPT
sudo iptables -A FORWARD -i enp0s10 -o enp1s5 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i enp1s6 -o enp0s10 -j ACCEPT
sudo iptables -A FORWARD -i enp0s10 -o enp1s5 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o enp0s10 -j MASQUERADE

#Default Policy
sudo iptables -A FORWARD -j DROP
sudo iptables -t nat -A POSTROUTING -j DROP


