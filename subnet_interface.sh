#!/bin/sh

#flush all previous commands
sudo iptables -t filter -F
sudo iptables -t filter -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X

echo -e "Please, specify the internet interface one more time"
read input

echo -e "Please insert the Lan interface"
read lan
#forward traffic to subnet
sudo iptables -A FORWARD -i ${lan} -o ${input} -j ACCEPT
sudo iptables -A FORWARD -i ${input} -o ${lan} -m state --state ESTABLISHED,RELATED -j ACCEPT
echo "Do you want to add another LAN interface?(Y/N)"
read answer
while [ "$answer" = "Y" ] || [ "$answer" = "y" ]
do
    echo Please insert the LAN interface
    read lan
    sudo iptables -A FORWARD -i ${lan} -o ${input} -j ACCEPT
    sudo iptables -A FORWARD -i ${input} -o ${lan} -m state --state ESTABLISHED,RELATED -j ACCEPT
    echo "Do you want to add another LAN interface?(Y/N)"
    read answer
done

sudo iptables -t nat -A POSTROUTING -o ${input} -j MASQUERADE

#Default Policy
sudo iptables -A FORWARD -j DROP
sudo iptables -t nat -A POSTROUTING -j DROP


