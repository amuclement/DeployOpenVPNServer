#!/bin/bash
userPassword=$1

#download the packages
cd /tmp
wget -c http://swupdate.openvpn.org/as/openvpn-as-2.6.1-Ubuntu18.amd_64.deb

#install the software
sudo dpkg -i openvpn-as-2.6.1-Ubuntu18.amd_64.deb

#update the password for user openvpn
sudo echo "openvpn:$userPassword"|sudo chpasswd

#configure server network settings
PUBLICIP=$(curl -s ifconfig.me)
sudo apt-get install sqlite3
sudo sqlite3 "/usr/local/openvpn_as/etc/db/config.db" "update config set value='$PUBLICIP' where name='host.name';"

#configure PAM authentication
cd /usr/local/openvpn_as/scripts/
sudo ./sacli --key "auth.module.type" --value "pam" ConfigPut
sudo ./sacli start

#configure the server to listen only to TCP port:
./sacli --key "vpn.server.daemon.enable" --value "false" ConfigPut
./sacli --key "vpn.daemon.0.listen.protocol" --value "tcp" ConfigPut
./sacli --key "vpn.server.port_share.enable" --value "true" ConfigPut
./sacli start

#restart OpenVPN AS service
sudo systemctl restart openvpnas
