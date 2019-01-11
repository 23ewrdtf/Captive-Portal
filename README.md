## Captive Portal on Rapsberry Pi

[![Join the chat at https://gitter.im/Captive-Portal/Lobby](https://badges.gitter.im/Captive-Portal/Lobby.svg)](https://gitter.im/Captive-Portal/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Below script will create an open wifi network and when you connect to it, it will automatically open the browser. Make sure you don't have the internet on your device you are connecting it from. This is originally desinged to only provide local website from the RPI.

The script also installs php incase you need it.

Tested on, without updating the system first, 2018-11-13-raspbian-stretch-lite.zip

Flash microsd card with etcher

Put an empty file called ssh with no extension onto the boot partition, this will enable ssh at first boot. No need for screen and keyboard.

Connect Pi to the ethernet network and boot.

Connect to the SSH and run below command. You can get the IP address from IP scanner.

```
sudo -i
```

```
curl -H 'Cache-Control: no-cache' -sSL https://raw.githubusercontent.com/tretos53/Captive-Portal/master/captiveportal.sh | sudo bash $0
```

#### To Do

Automatically set the location as new RPI hardware requires that before enabling wifi

Add a time limit for each client. Disconnect client after 10minutes.

Disable ssh access on wifi interface

Change the default Website

Test popup on other devices. Already works on Samsung S4, S7, S9, IPhone X and Blackberry

Add wifi name to be configured from the command line

#### Tested

Tested on most modern devices.

Iphone X

Samsung S4, S7, S9

Windows 7, 10

Nexus 5X (Lineage OS)

#### Popup Logic

Below sites needs to be resolvable to public IPs
connectivitycheck.gstatic.com
www.gstatic.com
www.apple.com
captive.apple.com
clients3.google.com

Those IPs needs to be NATed to the pi so basically NAT everything from WiFi to the RPI

Each device got it's own checks (to be updated)

#### Troubleshooting

Install and capture traffic using `tcpdump -i wlan0 -w filename.pcap`

Check nginx logs
