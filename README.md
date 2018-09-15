## Captive Portal on Rapsberry Pi

Below script will create an open wifi network and when you connect to it, it will automatically open the browser. Make sure you don't have the internet on your device you are connecting it from.

Sources I used to create this:
```
https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390
https://andrewwippler.com/2016/03/11/wifi-captive-portal/
https://www.raspberrypi.org/forums/viewtopic.php?t=161715
and a few other places.
```

The script also installs php incase you need it.

Tested on, without updating the system first, 2018-06-27-raspbian-stretch.zip

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
