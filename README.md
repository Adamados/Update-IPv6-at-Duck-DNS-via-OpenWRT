# Update-IPv6-via-OpenWRT-to-DuckDNS
Script to update the IPv6 at DuckDNS via OpwnWRT 19.07

I just edit the script that found here https://forum.openwrt.org/t/get-ipv6-address-of-server-for-ddns-update/71425/31 and modify it to fit my needs

# How to Use it
Put it somewhere e.g /root/

Create a cronjob at OpenWRT System -> Scheduled Tasks: */5 * * * * /root/getipv6.sh
