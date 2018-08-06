#!/bin/bash
#
# From https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390

if [ "$EUID" -ne 0 ]
	then echo "Must be root"
	exit
fi

if [[ $# -lt 1 ]]; 
	then echo "You need to pass a password!"
	echo "Usage:"
	echo "sudo $0 yourChosenPassword [apName]"
	exit
fi

APPASS="$1"
APSSID="rPi3"

if [[ $# -eq 2 ]]; then
	APSSID=$2
fi

# echo "----------------------Removing old hostapd----------------------"

# apt-get remove --purge hostapd -yqq

# echo "----------------------Updating repositories----------------------"

# apt-get update -yqq

# echo "----------------------Upgrading packages, this might take a while----------------------"

# apt-get upgrade -yqq

echo "----------------------Installing hostapd----------------------"

apt-get install hostapd -yqq

echo "----------------------Installing dnsmasq----------------------"

apt-get install dnsmasq -yqq

echo "----------------------Installing lighttpd----------------------"

apt-get install lighttpd -yqq

echo "----------------------Writing to dnsmasq.conf----------------------"

cat > /etc/dnsmasq.conf <<EOF
bogus-priv
server=/localnet/10.0.0.1
local=/localnet/
domain=localnet
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
dhcp-authoritative
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.5,255.255.255.0,12h
address=/#/10.0.0.1
EOF

echo "----------------------Writing to hosts----------------------"

cat > /etc/dnsmasq.conf <<EOF
127.0.0.1	localhost 
10.0.0.1	hotspot.localnet
EOF

echo "----------------------Writing to resolv.conf----------------------"

cat > /run/dnsmasq/resolv.conf <<EOF
nameserver 10.0.0.1
EOF


echo "----------------------Writing to hostapd.conf----------------------"

cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
hw_mode=g
channel=10
auth_algs=1
ssid=$APSSID
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
EOF

echo "----------------------Configuring interfaces----------------------"

sed -i -- 's/allow-hotplug wlan0//g' /etc/network/interfaces
sed -i -- 's/iface wlan0 inet manual//g' /etc/network/interfaces
sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

cat >> /etc/network/interfaces <<EOF
# Added by rPi Access Point Setup
allow-hotplug wlan0
iface wlan0 inet static
	address 10.0.0.1
	netmask 255.255.255.0
	network 10.0.0.0
	broadcast 10.0.0.255
auto eth0
	allow-hotplug eth0
	iface eth0 inet dhcp
EOF

echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf

echo "----------------------Starting up services and configuring to start at boot----------------------"

systemctl enable hostapd
systemctl enable dnsmasq

service hostapd start
service dnsmasq start

update-rc.d dnsmasq defaults
update-rc.d hostapd defaults

echo "----------------------Doing something to dhcpcd.sh----------------------"

wget -q https://gist.githubusercontent.com/Lewiscowles1986/390d4d423a08c4663c0ada0adfe04cdb/raw/5b41bc95d1d483b48e119db64e0603eefaec57ff/dhcpcd.sh -O /usr/lib/dhcpcd5/dhcpcd

echo "----------------------Permissions on dhcpcd----------------------"

chmod +x /usr/lib/dhcpcd5/dhcpcd

echo "----------------------All done! Please reboot----------------------"
