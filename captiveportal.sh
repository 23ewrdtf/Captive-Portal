#!/bin/bash

:<<"USAGE"
$0 Filename captiveportal.sh
$1 SSID

MODE OF OPERATION NOT YET IMPLEMENTED.
$2 Mode of operation:
  - default: it will display the default page after connecting to the captiev portal. No internet access.
  - offline: it will display a button that will close the CP browser but keep connection to the Raspbery pi. No internet access.
  - online: it will display a button that will close the CP browser but keep connection to the Raspbery pi and allow internet access.
USAGE

if [ "$EUID" -ne 0 ]
	then echo "Must be root, run sudo -i before running this script."
	exit
fi

SSID=${1:-CaptivePortal01}
MODE=${2:-default}

echo "┌─────────────────────────────────────────"
echo "|This script might take a while,"
echo "|so if you dont see much progress,"
echo "|wait till you see --all done-- message."
echo "└─────────────────────────────────────────"
read -p "Press enter to continue"

echo "┌─────────────────────────────────────────"
echo "|Updating repositories"
echo "└─────────────────────────────────────────"
apt-get update -yqq

# echo "┌─────────────────────────────────────────"
# echo "|Upgrading packages, this might take a while|"
# echo "└─────────────────────────────────────────"
# apt-get upgrade -yqq

echo "┌─────────────────────────────────────────"
echo "|Installing and configuring nginx"
echo "└─────────────────────────────────────────"
apt-get install nginx -yqq
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/default_nginx -O /etc/nginx/sites-enabled/default
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/index.php -O  /var/www/html/index.php

echo "┌─────────────────────────────────────────"
echo "|Installing dnsmasq"
echo "└─────────────────────────────────────────"
apt-get install dnsmasq -yqq

echo "┌─────────────────────────────────────────"
echo "|Configuring wlan0"
echo "└─────────────────────────────────────────"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dhcpcd.conf -O /etc/dhcpcd.conf

echo "┌─────────────────────────────────────────"
echo "|Configuring dnsmasq"
echo "└─────────────────────────────────────────"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dnsmasq.conf -O /etc/dnsmasq.conf

echo "┌─────────────────────────────────────────"
echo "|configuring dnsmasq to start at boot"
echo "└─────────────────────────────────────────"
update-rc.d dnsmasq defaults

echo "┌─────────────────────────────────────────"
echo "|Installing hostapd"
echo "└─────────────────────────────────────────"
apt-get install hostapd -yqq

echo "┌─────────────────────────────────────────"
echo "|Configuring hostapd"
echo "└─────────────────────────────────────────"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hostapd.conf -O /etc/hostapd/hostapd.conf
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd
sed -i -- "s/CaptivePortal01/${SSID}/g" /etc/hostapd/hostapd.conf

echo "┌─────────────────────────────────────────"
echo "|Configuring iptables"
echo "└─────────────────────────────────────────"
iptables -t nat -A PREROUTING -s 192.168.24.0/24 -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1:80
iptables -t nat -A POSTROUTING -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -y install iptables-persistent

echo "┌─────────────────────────────────────────"
echo "|configuring hostapd to start at boot"
echo "└─────────────────────────────────────────"
systemctl unmask hostapd.service
systemctl enable hostapd.service

echo "┌─────────────────────────────────────────"
echo "|Installing PHP7"
echo "└─────────────────────────────────────────"
apt-get install php7.3-fpm php7.3-mbstring php7.3-mysql php7.3-curl php7.3-gd php7.3-curl php7.3-zip php7.3-xml -yqq > /dev/null

echo "┌─────────────────────────────────────────"
echo "|Please reboot your pi and test."
echo "└─────────────────────────────────────────"
