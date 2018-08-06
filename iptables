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
