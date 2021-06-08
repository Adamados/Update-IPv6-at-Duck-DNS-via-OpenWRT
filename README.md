# Update-IPv6-via-OpenWRT-to-DuckDNS
Script to update the IPv6 at DuckDNS via OpwnWRT 19.07

I just edit the script that found here https://forum.openwrt.org/t/get-ipv6-address-of-server-for-ddns-update/71425/31 and modify it to fit my needs

# How to Use it
Create a Rule at Network -> Firewall -> Traffic Rules -> Add

## GENERAL Settings
Protocol: TCP, UDP

Source Zone: wan, wan6

Destination Zone: lan

Destination port:

Action: accept

## ADVANCED Settings
Restrict to address family: IPv6 only

# Script
Put it somewhere e.g /root/ via WinSCP

Create a cronjob at OpenWRT System -> Scheduled Tasks

### To run the script every 5 min
*/5 * * * * /root/ipv6.sh
