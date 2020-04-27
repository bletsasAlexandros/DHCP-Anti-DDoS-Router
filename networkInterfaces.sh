#!/bin/bash

#First write to /etc/network/interfaces
declare -a all_interfaces
declare -a all_addresses

echo -e "Hello let's configure your subnets first"
echo -e "First, declare the internet interface"
read input
final="#the loopback network interface\nauto lo\niface lo inet loopback\n\n"

final+="auto ${input}\niface ${input} inet dhcp\n\n"

echo "Please insert the LAN interface:"
read input
all_interfaces+=( "$input" )
echo "Do you want to add another LAN interface?(Y/N)"
read answer
while [ "$answer" = "Y" ] || [ "$answer" = "y" ]
do
    echo Please insert the LAN interface
    read input
    all_interfaces+=( "$input" )
    echo "Do you want to add another LAN interface?(Y/N)"
    read answer
done

for i in "${!all_interfaces[@]}"
do
    :
    echo "Add start address for the interface: ${all_interfaces[$i]}"
    read input
    address=$input
    all_addresses+=( "$address" )
    interface="auto ${all_interfaces[$i]}\niface enp1s5 inet static\naddress ${address}\nnetmask 255.255.255.0\nnetwork ${address}\nbroadcast 192.168.0.255\n\n"
    final+=$interface
done

echo -e "\n\nThis will be stores to /etc/network/interfaces ${final}"

echo -e "\n\n"

#Then enable forwarding in /etc/sysctl.conf
echo "Write to /etc/sysctl/conf the following: net.ipv4.ip_forward=1"

#Install DHCP package if it is not installed
if [ $(dpkg-query -W -f='${Status}' isc-dhcp-server 2>/dev/null | grep -c "ok installed") ]
then
        echo "isc-dhcp-package already installed"
        
else
        apt-get install isc-dhcp-server
fi

#On what interface should the DCHP server serve requests?
a=""
for i in "${all_interfaces[@]}"
do
    :
    a+="$i "
    
done
sed -i "/INTERFACESv4=\"\"/d" /etc/default/isc-dhcp-server
sed -i "/INTERFACESv6=\"\"/i INTERFACESv4=\" ${a} \"" /etc/default/isc-dhcp-server


#Write to /etc/dhcp/dhcpd.conf 
sed -i "/option definitions common to all supported networks.../a option domain-name \"example.org\"; \n\
option domain-name-servers ns1.example.org, ns2.example.org; \n\
\n\
default-lease-time 600; \n\
max-lease-time 7200;" /etc/dhcp/dhcpd.conf 

sed -i "/# network, the authoritative directive should be uncommented./a authoritative;" /etc/dhcp/dhcpd.conf 

#Configure Subnets
for i in ${all_addresses[@]}
do
    :
    echo "Please enter the ip range you would like for the subnet of ${i}"
    echo "Startig in (for example 192.168.0.50) : "
    read start
    echo "Edning in : "
    read finish
    broadcast=$(echo ${i} | cut -d "." -f 1,2,3)
    broadcast=broadcast.255
    sed -i "/# A slightly different configuration for an internal subnet./a  subnet $i netmask 255.255.255.0 { \n\
  range ${start} ${finish}; \n\
  option domain-name-servers 8.8.8.8, 8.8.4.4; \n\
#  option domain-name "internal.example.org"; \n\
  option subnet-mask 255.255.255.0; \n\
  option routers ${i}; \n\
  option broadcast-address ${broadcast}; \n\
  default-lease-time 600; \n\
  max-lease-time 7200; \n\
}" /etc/dhcp/dhcpd.conf
done

#Start isc-dhcp-server
sudo systemctl start isc-dhcp-server

#Last but not least, install persistant iptable rules
sudo apt-get install iptables-persistent