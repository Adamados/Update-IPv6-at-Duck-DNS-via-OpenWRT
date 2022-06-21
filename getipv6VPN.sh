#!/bin/sh

# Configuring
# DevID: is the 192.168.1.X where the x is the statis address number
# TrafficRuleName: is the Traffic Rule Name at Network -> Firewall -> Traffic Rules
# DuckDNSToken: find it at your DuckDNS account e.g aaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaa
# DuckDnsDomain: your domain only, without .duckdns.com
# IPv6ULAPrefix: Network -> Interface -> Global network options (tab)
DevID=
# MacAddr=
TrafficRuleName=
DuckDNSToken=
DuckDnsDomain=
IPv6ULAPrefix=
# END of Configuring

printf "\n"
printf "Getting your IPv6 address... \n"
# getIPv6=$(ip -6 neigh | grep "$MacAddr" | grep -v "STALE" | grep -v "fe80" | grep -v "$IPv6ULAPrefix" | cut -d" " -f1)
# getIPv6=$(ip -6 neigh | grep "$MacAddr" | grep -v "fe80" | grep -v "$IPv6ULAPrefix" | cut -d" " -f1)
getIPv6=$(ubus call dhcp ipv6leases | grep 2a02 | grep "$DevID" | grep -v "$IPv6ULAPrefix" | cut -f 4 -d ' ' -d '"')

if [ "$getIPv6" = "" ]
then
    printf "Failed to get IP.\n\n"
	logger "[VPN] - Failed to get IP..."
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

#        if [ "$dest_ip" != "$getIPv6" ]
#        then
#            printf "The IP has changed! \n"
            printf "Updating...\n"
            changed=1
			printf "Answear from DuckDNS: "
			curl --silent "https://www.duckdns.org/update?domains=${DuckDnsDomain}&token=${DuckDNSToken}&ipv6=${getIPv6}"
			uci set firewall.@rule[$index].dest_ip=$getIPv6
            uci commit firewall			
#        else
#            printf "IP is the same, no changes made.\n\n"
#        fi

        break 2
	fi
	
    index=$(expr $index + 1)
    LFRuleName=$(uci get firewall.@rule[$index].name 2> /dev/null)

done

if [ "$LFRuleName" = "" ]
then
	printf "\n"
	printf "Failed to find Rule name \n\n"
	logger "[VPN] - Failed to find Rule name..."
fi

if [ $changed -eq 1 ] 
then
    printf "\nRestarting firewall... \n"
    /etc/init.d/firewall reload 2> /dev/null
    printf "All up to date. \n\n"
	logger "[VPN] - All up to date..."
fi

exit 0
