## Raspberry-Pie

### Setting up a simple Captive Portal

2018-06-27-raspbian-stretch.zip

Flash microsd card with etcher

put an empty file called ssh with no etension onto the boot partition, this will enable ssh at first boot. No need for screen and keyboard.

Connect Pi to the ethernet network and boot.

sudo apt-get install iptables-persistent -yqq
sudo apt-get install conntrack -yqq
sudo apt-get install dnsmasq -yqq
sudo apt-get install nginx -yqq
sudo apt-get install hostapd -yqq

/etc/dnsmasq.conf
```
# Never forward addresses in the non-routed address spaces.
bogus-priv

# Add other name servers here, with domain specs if they are for
# non-public domains.
server=/localnet/192.168.24.1

# Add local-only domains here, queries in these domains are answered
# from /etc/hosts or DHCP only.
local=/localnet/

# If you want dnsmasq to listen for DHCP and DNS requests only on
# specified interfaces (and the loopback) give the name of the
# interface (eg eth0) here.
# Repeat the line for more than one interface.
interface=wlan0

# Set the domain for dnsmasq. this is optional, but if it is set, it
# does the following things.
# 1) Allows DHCP hosts to have fully qualified domain names, as long
#     as the domain part matches this setting.
# 2) Sets the "domain" DHCP option thereby potentially setting the
#    domain of all systems configured by DHCP
# 3) Provides the domain part for "expand-hosts"
domain=localnet

# Uncomment this to enable the integrated DHCP server, you need
# to supply the range of addresses available for lease and optionally
# a lease time. If you have more than one network, you will need to
# repeat this for each network on which you want to supply DHCP
# service.
dhcp-range=192.168.24.50,192.168.24.250,2h

# Override the default route supplied by dnsmasq, which assumes the
# router is the same machine as the one running dnsmasq.
dhcp-option=3,192.168.24.1

#DNS Server
dhcp-option=6,192.168.24.1

# Set the DHCP server to authoritative mode. In this mode it will barge in
# and take over the lease for any client which broadcasts on the network,
# whether it has a record of the lease or not. This avoids long timeouts
# when a machine wakes up on a new network. DO NOT enable this if there's
# the slightest chance that you might end up accidentally configuring a DHCP
# server for your campus/company accidentally. The ISC server uses
# the same option, and this URL provides more information:
# http://www.isc.org/files/auth.html
dhcp-authoritative
```

/etc/hosts

```
127.0.0.1	localhost 
192.168.24.1	hotspot.localnet
::1		localhost ip6-localhost ip6-loopback
fe00::0		ip6-localnet
ff00::0		ip6-mcastprefix
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters
```

/etc/network/interfaces

```
# The loopback network interface
auto lo eth0
iface lo inet loopback

# The "wan" network interface
iface eth0 inet dhcp

# The "lan" network interface
iface wlan0 inet static
address 192.168.24.1
netmask 255.255.255.0
```
  
/etc/hostapd/hostapd.conf
```
interface=wlan0
ssid=MyOpenAP # name of the WiFi access point
hw_mode=g
channel=6 #use 1, 6, or 11
auth_algs=1
wmm_enabled=0
```

/etc/default/hostapd

```
#DAEMON_CONF=""
to:

DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

iptables 

```
# Turn into root
sudo -i
# Flush all connections in the firewall
iptables -F
# Delete all chains in iptables
iptables -X
# wlan0 is our wireless card. Replace with your second NIC if doing it from a server.
# This will set up our structure
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
# forward new requests to this destination
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
# allow access to my website :)
iptables -t filter -A wlan0_Global -d andrewwippler.com -j ACCEPT
#allow unrestricted access to packets marked with 0x2
iptables -t filter -A wlan0_Internet -m mark --mark 0x2 -j wlan0_Known
iptables -t filter -A wlan0_Known -d 0.0.0.0/0 -j ACCEPT
iptables -t filter -A wlan0_Internet -j wlan0_Unknown
# allow access to DNS and DHCP
# This helps power users who have set their own DNS servers
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p udp --dport 53 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p tcp --dport 53 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p udp --dport 67 -j ACCEPT
iptables -t filter -A wlan0_Unknown -d 0.0.0.0/0 -p tcp --dport 67 -j ACCEPT
iptables -t filter -A wlan0_Unknown -j REJECT --reject-with icmp-port-unreachable
#allow forwarding of requests from anywhere to eth0/WAN
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#save our iptables
iptables-save > /etc/iptables/rules.v4
```

nginx 
```
# Make the HTML Document Root
mkdir /usr/share/nginx/html/portal
chown nginx:www-data /usr/share/nginx/html/portal
chmod 755 /usr/share/nginx/html/portal

# create the nginx hotspot.conf file
cat << EOF > /etc/nginx/sites-available/hotspot.conf
server {
    # Listening on IP Address.
    # This is the website iptables redirects to
    listen       80 default_server;
    root         /usr/share/nginx/html/portal;

    # For iOS
    if ($http_user_agent ~* (CaptiveNetworkSupport) ) {
        return 302 http://hotspot.localnet/hotspot.html;
    }

    # For others
    location / {
        return 302 http://hotspot.localnet/;
    }
 }

 upstream php {
    #this should match value of "listen" directive in php-fpm pool
		server unix:/tmp/php-fpm.sock;
		server 127.0.0.1:9000;
	}

server {
     listen       80;
     server_name  hotspot.localnet;
     root         /usr/share/nginx/html/portal;

     location / {
         try_files $uri $uri/ index.php;
     }

    # Pass all .php files onto a php-fpm/php-fcgi server.
    location ~ [^/]\.php(/|$) {
    	fastcgi_split_path_info ^(.+?\.php)(/.*)$;
    	if (!-f $document_root$fastcgi_script_name) {
    		return 404;
    	}
    	# This is a robust solution for path info security issue and works with "cgi.fix_pathinfo = 1" in /etc/php.ini (default)
    	include fastcgi_params;
    	fastcgi_index index.php;
    	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    	fastcgi_pass php;
    }
}

EOF

# Enable the website and reload nginx
ln -s /etc/nginx/sites-available/hotspot.conf /etc/nginx/sites-enabled/hotspot.conf
systemctl reload nginx
```

We have just set up the path /usr/share/nginx/html/portal to serve web pages if accessed via IP (note the default_server directive) as well as if accessed by the hostname hotspot.localnet. If accessed via IP, it will trigger a 302 redirect to the hostname hotspot.localnet.





```
curl -sSL https://raw.githubusercontent.com/tretos53/Raspberry-Pie/master/rPi3-ap-setup.sh | sudo bash $0 password Nomad01
```
