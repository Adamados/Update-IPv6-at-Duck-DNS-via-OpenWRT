#!/bin/sh

# Configuring
# MacAddr: is the MAC Address of device
# TrafficRuleName: is the Traffic Rule Name at Network -> Firewall -> Traffic Rules
MacAddr=aa:aa:aa:aa:aa:aa
TrafficRuleName=RULE.NAME
# END of Configuring

printf "\n"
printf "Getting your IPv6 address... \n"
getIPv6=$(ip -6 neigh | grep "$MacAddr" | grep -v "fe80" | grep -v "fdd9" | cut -d" " -f1)

if [ "$getIPv6" = "" ]
then
    printf "Failed to get IP."
    exit 0
fi

printf "Your current IPv6: {$getIPv6} \n"

changed=0
index=0
LFRuleName=$(uci get firewall.@rule[$index].name 2> /dev/null)

while [ "$LFRuleName" != "" ]
do

    if [ "$LFRuleName" == "$TrafficRuleName" ]
    then
        dest_ip=$(uci get firewall.@rule[$index].dest_ip 2> /dev/null)
        printf "Your stored IPv6:  {$dest_ip} \n"

        if [ "$dest_ip" != "$getIPv6" ]
        then
            printf "The IP has changed! \n"
            printf "Updating...\n"
            changed=1
			printf "Answear from DuckDNS: "
			curl --silent "https://www.duckdns.org/update?domains=indigoha&token=32e50cbd-b600-46e3-abff-13f2890c25a8&ipv6=${getIPv6}"
			uci set firewall.@rule[$index].dest_ip=$getIPv6
            uci commit firewall
        else
            printf "IP is the same, no changes made.\n\n"
        fi

        break 2
	fi
	
    index=$(expr $index + 1)
    LFRuleName=$(uci get firewall.@rule[$index].name 2> /dev/null)

done

if [ "$LFRuleName" = "" ]
then
	printf "\n"
	printf "Failed to find Rule name \n\n"
fi

if [ $changed -eq 1 ] 
then
    printf "\nRestarting firewall... \n"
    /etc/init.d/firewall reload 2> /dev/null
    printf "All up to date. \n\n"
fi

exit 0
