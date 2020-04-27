#!/bin/bash


sudo sh -c "zgrep -h \"Ban \" /var/log/fail2ban.log* " | awk '{print $NF}' | awk -F\. '{print $1"."$2"."}' |sort |uniq -c | sort -n | tail > ipsForBan.log
declare -a var
declare -a ip

var=($(awk '{print $1f}' ipsForBan.log))
ip=($(awk '{print $2}' ipsForBan.log))

for i in "${!var[@]}"
do
        :
        if [ ${var[$i]} -gt 10 ]
        then
                finalIps=(${ip[$i]}0.0)
                isBanned=$(iptables -nL INPUT | grep $finalIps)
                if [[ -z "$isBanned" ]]
                then
                        echo **Banning $finalIps subnet...
                        iptables -I INPUT 1 -s $finalIps/16 -j DROP
                        iptables -I FORWARD 1 -s $finalIps/16 -j DROP
                        iptables -I LOGGING 1 -s $finalIps/16 -j DROP
                fi
        fi
done
echo Done
echo Subnets that are banned will be logged to ipsForBan.log                                                                                                                                                                                 





