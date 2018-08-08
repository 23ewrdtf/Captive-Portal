#!/bin/bash
#
# From 
# https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390
# https://andrewwippler.com/2016/03/11/wifi-captive-portal/
# https://www.raspberrypi.org/forums/viewtopic.php?t=161715
# and other places.

if [ "$EUID" -ne 0 ]
	then echo "Must be root, run sudo -i before running that script."
	exit
fi

echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "|This script might take a while so if you dont see much progress wait till you see all done message.|"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────┘"

echo "┌─────────────────────┐"
echo "|Updating repositories|"
echo "└─────────────────────┘"
apt-get update -yqq

# echo "┌───────────────────────────────────────────┐"
# echo "|Upgrading packages, this might take a while|"
# echo "└───────────────────────────────────────────┘"
# apt-get upgrade -yqq

echo "┌────────────────────────────────┐"
echo "|Installing and configuring nginx|"
echo "└────────────────────────────────┘"
apt-get install nginx -yqq
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/default_nginx -O /etc/nginx/sites-enabled/default
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/index.php -O  /var/www/html/index.php

echo "┌──────────────────┐"
echo "|Installing dnsmasq|"
echo "└──────────────────┘"
apt-get install dnsmasq -yqq

echo "┌──────────────────┐"
echo "|Configuring wlan0 |"
echo "└──────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dhcpcd.conf -O /etc/dhcpcd.conf

echo "┌────────────────────┐"
echo "|Configuring dnsmasq |"
echo "└────────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dnsmasq.conf -O /etc/dnsmasq.conf

echo "┌─────────────────────────────────────────┐"
echo "|configuring dnsmasq to start at boot	|"
echo "└─────────────────────────────────────────┘"
update-rc.d dnsmasq defaults

echo "┌──────────────────┐"
echo "|Installing hostapd|"
echo "└──────────────────┘"
apt-get install hostapd -yqq

echo "┌────────────────────┐"
echo "|Configuring hostapd |"
echo "└────────────────────┘"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hostapd.conf -O /etc/hostapd/hostapd.conf
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

echo "┌─────────────────────────────────────────┐"
echo "|configuring hostapd to start at boot	|"
echo "└─────────────────────────────────────────┘"
update-rc.d hostapd defaults

echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo "|Installing PHP7								|"
echo "└─────────────────────────────────────────────────────────────────────────┘"
echo "┌─────────────────────────────────────────────────────────────────────────┐"
echo "|Once PHP is installed, reboot and run below commands after the reboot	|"
echo "|Disconnect the Ethernet cable before connecting to WiFi!!!		|"
echo "|Connect to wifi once done and test if redirect works			|"
echo "|If sucessfull you should see a Redirect Worked message and PHP info page	|"
echo "|service nginx stop							|"
echo "|service nginx start							|"
echo "|service hostapd stop							|"
echo "|service hostapd start							|"
echo "|service dnsmasq stop							|"
echo "|service dnsmasq start							|"
echo "└─────────────────────────────────────────────────────────────────────────┘"
apt-get install php7.0-fpm
