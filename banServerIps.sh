#!/bin/bash


sudo sh -c "grep  \"SRC=\" ~/MyScripts/serverLogs.log* " | awk '{print $5}' | cut -d '=' -f 2 |sort --unique > ipsForBanFromServer.log

ip=($(awk '{print $15}' ipsForBanFromServer.log))

for i in "${!ip[@]}"
do
        :
        if [ ${ip[$i]} != "0.0.0.0" ]
        then
                isBanned=$(iptables -nL INPUT | grep  ${ip[$i]})
                if [[ -z "$isBanned" ]]
                then
                        echo **Banning ${ip[$i]}...
                        iptables -I INPUT 1 -s ${ip[$i]} -j DROP
                        iptables -I FORWARD 1 -s ${ip[$i]} -j DROP
                        iptables -I LOGGING 1 -s ${ip[$i]} -j DROP
                fi
        fi
done
echo Done
echo Ips that are banned will be logged in the ipsForBanFromServer.log file