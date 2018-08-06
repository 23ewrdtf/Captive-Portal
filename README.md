## Raspberry-Pie

### Setting up a simple Captive Portal

Tested on without updating the system first 2018-06-27-raspbian-stretch.zip

Flash microsd card with etcher

Put an empty file called ssh with no extension onto the boot partition, this will enable ssh at first boot. No need for screen and keyboard.

Connect Pi to the ethernet network and boot.

Connect to the SSH and run below command. You can get the IP address from IP scanner.

```
curl -sSL https://raw.githubusercontent.com/tretos53/Captive-Portal/master/captiveportal.sh | sudo bash $0
```
