## Captive Portal on Rapsberry Pi

[![Join the chat at https://gitter.im/Captive-Portal/Lobby](https://badges.gitter.im/Captive-Portal/Lobby.svg)](https://gitter.im/Captive-Portal/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Below script will create an open wifi network and when you connect to it, it will automatically open the browser. Make sure you don't have the internet on your device you are connecting it from.

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

If your device automatically didnt show the sign in page, you might want to edit /etc/nginx/sites-enabled/default and add some more logic. Basically the requirmeents for each device are different. 

Hostnames of each below sites needs to be public IPs

Those IPs needs to be NATed to the pi

Found on the internet:

```
For iOS
1.DNS request for http://www.apple.com must not fail
2.HTTP request for http://www.apple.com/library/test/success.html with special user agent CaptiveNetworkSupport/1.0 wispr must not return Success.

Windows Phone 8 and 8.1 are WISP-r capable https://msdn.microsoft.com/en-us/library/windows/hardware/dn408679.aspx

They also do this:
To determine Internet connectivity and captive portal status when a client first connects to a network, Windows performs a series of network tests. The destination site of these tests is msftncsi.com, which is a reserved domain that is used exclusively for connectivity testing. When a captive portal is detected, these tests are periodically repeated until the captive portal is released.

To avoid false positive or false negative test results, your captive portal should not do the following:
• Allow access to http://www.msftncsi.com when the user does not have access to the Internet.

• Change the captive portal behavior that is displayed to clients. For example, do not redirect some requests and drop other requests; you should continue to redirect all requests until authentication succeeds.

Android does this:
Android's captive portal detection, as of AOSP 4.0.1, tries to contact http://clients3.google.com/generate_204 or http://www.google.com/blank.html.
TonyJr
```
