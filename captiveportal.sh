#!/bin/bash
#
# From https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390
# https://andrewwippler.com/2016/03/11/wifi-captive-portal/
# and other places.

if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

# echo "┌─────────────────────┐"
# echo "|Updating repositories|"
# echo "└─────────────────────┘"
# apt-get update -yqq

# echo "┌───────────────────────────────────────────┐"
# echo "|Upgrading packages, this might take a while|"
# echo "└───────────────────────────────────────────┘"
# apt-get upgrade -yqq






echo "┌──────────────────┐"
echo "|Installing dnsmasq|"
echo "└──────────────────┘"
apt-get install dnsmasq -yqq	

echo "┌────────────────────┐"
echo "|Copying dnsmasq.conf|"
echo "└────────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dnsmasq.conf -O /etc/dnsmasq.conf

echo "┌─────────────────────────────────────────┐"
echo "|configuring dnsmasq to start at boot|"
echo "└─────────────────────────────────────────┘"
update-rc.d dnsmasq defaults






















echo "┌──────────────────┐"
echo "|Installing hostapd|"
echo "└──────────────────┘"
apt-get install hostapd -yqq

echo "┌────────────────────┐"
echo "|Copying hostapd.conf|"
echo "└────────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hostapd.conf -O /etc/hostapd/hostapd.conf

echo "┌────────────────────────────────┐"
echo "|load that config file by default|"
echo "└────────────────────────────────┘"
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

echo "┌─────────────────────────────────────────┐"
echo "|configuring hostapd to start at boot|"
echo "└─────────────────────────────────────────┘"
update-rc.d hostapd defaults

	
	
	
	
	
	
	
	
	
echo "┌────────────────┐"
echo "|Installing nginx|"
echo "└────────────────┘"
apt-get install nginx -yqq

echo "┌──────────────────────────────┐"
echo "|Making the HTML Document Root.|"
echo "└──────────────────────────────┘"
mkdir /usr/share/nginx/html/portal
useradd nginx
chown nginx:www-data /usr/share/nginx/html/portal
chmod 755 /usr/share/nginx/html/portal

echo "┌────────────────────┐"
echo "|Copying hotspot.conf|"
echo "└────────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/nginx -O /etc/nginx/sites-available/hotspot.conf

echo "┌──────────────────┐"
echo "|Copying index.html|"
echo "└──────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/index.html -O /usr/share/nginx/html/portal/index.html

echo "┌─────────────────────────────────────┐"
echo "|Enabling the website and reload nginx|"
echo "└─────────────────────────────────────┘"
ln -s /etc/nginx/sites-available/hotspot.conf /etc/nginx/sites-enabled/hotspot.conf

















echo "┌──────────────────────────────┐"
echo "|Installing iptables-persistent|"
echo "└──────────────────────────────┘"
apt-get install iptables-persistent -yqq

echo "┌────────────────────┐"
echo "|Installing conntrack|"
echo "└────────────────────┘"
apt-get install conntrack -yqq















echo "┌──────────────────┐"
echo "|Copying hosts file|"
echo "└──────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hosts -O /etc/hosts

echo "┌───────────────────────┐"
echo "|Copying interfaces file|"
echo "└───────────────────────┘"
wget -q https://github.com/tretos53/Captive-Portal/blob/master/interfaces -O /etc/network/interfaces

echo "┌───────────────────┐"
echo "|Copying resolv.conf|"
echo "└───────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/resolv.conf -O /run/dnsmasq/resolv.conf






echo "----------------------Doing something to dhcpcd.sh----------------------"
wget -q https://gist.githubusercontent.com/Lewiscowles1986/390d4d423a08c4663c0ada0adfe04cdb/raw/5b41bc95d1d483b48e119db64e0603eefaec57ff/dhcpcd.sh -O /usr/lib/dhcpcd5/dhcpcd

echo "----------------------Permissions on dhcpcd----------------------"
chmod +x /usr/lib/dhcpcd5/dhcpcd




Reboot













echo "┌───────────────────┐"
echo "|Installing lighttpd|"
echo "└───────────────────┘"
apt-get install lighttpd -yqq


																			   






echo "┌─────────────────────┐"
echo "|Configuring IP Tables|"
echo "└─────────────────────┘"

echo "┌────────────────────────────────────────┐"
echo "|Flushing all connections in the firewall|"
echo "└────────────────────────────────────────┘"
iptables -F

echo "┌───────────────────────────────┐"
echo "|Deleting all chains in iptables|"
echo "└───────────────────────────────┘"
iptables -X

echo "┌────────────────┐"
echo "|Setting up rules|"
echo "└────────────────┘"
iptables -t mangle -N wlan0_Trusted
iptables -t mangle -N wlan0_Outgoing
iptables -t mangle -N wlan0_Incoming
iptables -t mangle -I PREROUTING 1 -i wlan0 -j wlan0_Outgoing
iptables -t mangle -I PREROUTING 1 -i wlan0 -j wlan0_Trusted
iptables -t mangle -I POSTROUTING 1 -o wlan0 -j wlan0_Incoming
iptables -t nat -N wlan0_Outgoing
iptables -t nat -N wlan0_Router
iptables -t nat -N wlan0_Internet
iptables -t nat -N wlan0_Global
iptables -t nat -N wlan0_Unknown
iptables -t nat -N wlan0_AuthServers
iptables -t nat -N wlan0_temp
iptables -t nat -A PREROUTING -i wlan0 -j wlan0_Outgoing
iptables -t nat -A wlan0_Outgoing -d 192.168.24.1 -j wlan0_Router
iptables -t nat -A wlan0_Router -j ACCEPT
iptables -t nat -A wlan0_Outgoing -j wlan0_Internet
iptables -t nat -A wlan0_Internet -m mark --mark 0x2 -j ACCEPT
iptables -t nat -A wlan0_Internet -j wlan0_Unknown
iptables -t nat -A wlan0_Unknown -j wlan0_AuthServers
iptables -t nat -A wlan0_Unknown -j wlan0_Global
iptables -t nat -A wlan0_Unknown -j wlan0_temp

echo "┌───────────────────────────────────────────┐"
echo "|Forwarding new requests to this destination|"
echo "└───────────────────────────────────────────┘"
iptables -t nat -A wlan0_Unknown -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1
iptables -t filter -N wlan0_Internet
iptables -t filter -N wlan0_AuthServers
iptables -t filter -N wlan0_Global
iptables -t filter -N wlan0_temp
iptables -t filter -N wlan0_Known
iptables -t filter -N wlan0_Unknown
iptables -t filter -I FORWARD -i wlan0 -j wlan0_Internet
iptables -t filter -A wlan0_Internet -m state --state INVALID -j DROP
iptables -t filter -A wlan0_Internet -o eth0 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t filter -A wlan0_Internet -j wlan0_AuthServers
iptables -t filter -A wlan0_AuthServers -d 192.168.24.1 -j ACCEPT
iptables -t filter -A wlan0_Internet -j wlan0_Global

echo "┌───────────────────────────────────────────────────────┐"
echo "|Allowing unrestricted access to packets marked with 0x2|"
echo "└───────────────────────────────────────────────────────┘"
iptables -t filter -A wlan0_Internet -m mark --mark 0x2 -j wlan0_Known
iptables -t filter -A wlan0_Known -d 0.0.0.0/0 -j ACCEPT
iptables -t filter -A wlan0_Internet -j wlan0_Unknown

echo "┌───────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|Allowing access to DNS and DHCP. This helps power users who have set their own DNS servers.|"
echo "└───────────────────────────────────────────────────────────────────────────────────────────┘"
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p udp --dport 53 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p tcp --dport 53 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p udp --dport 67 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p tcp --dport 67 -j ACCEPT
iptables -t filter -A wlan0_Unknown -j REJECT --reject-with icmp-port-unreachable

echo "┌────────────────┐"
echo "|Saving iptables.|"
echo "└────────────────┘"
iptables-save > /etc/iptables/rules.v4



echo "┌───────────────────────────────────┐"
echo "|Done, connect to the wifi and test.|"
echo "└───────────────────────────────────┘"
