#!/bin/bash

if [ "$EUID" -ne 0 ]
	then echo "Must be root, run sudo -i before running that script."
	exit
fi

apt-get update
apt-get install nginx
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/default_nginx -O /etc/nginx/sites-enabled/default
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/index.php -O  /var/www/html/index.php
apt-get install dnsmasq
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dhcpcd.conf -O /etc/dhcpcd.conf
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dnsmasq.conf -O /etc/dnsmasq.conf
update-rc.d dnsmasq defaults
apt-get install hostapd
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hostapd.conf -O /etc/hostapd/hostapd.conf
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd
iptables -t nat -A PREROUTING -s 192.168.24.0/24 -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1:80
iptables -t nat -A POSTROUTING -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -y install iptables-persistent
update-rc.d hostapd defaults
