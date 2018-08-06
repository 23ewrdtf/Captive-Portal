## Raspberry-Pie

### This will create an open wifi network and when you connect to it, it will automatically open the browser. No internet access.

Tested on without updating the system first 2018-06-27-raspbian-stretch.zip

Flash microsd card with etcher

Put an empty file called ssh with no extension onto the boot partition, this will enable ssh at first boot. No need for screen and keyboard.

Connect Pi to the ethernet network and boot.

Connect to the SSH and run below command. You can get the IP address from IP scanner.

NOT TESTED

```
sudo -i
```

```
curl -sSL https://raw.githubusercontent.com/tretos53/Captive-Portal/master/captiveportal.sh | sudo bash $0
```
