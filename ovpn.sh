#!/bin/bash

if [[ $USER != "root" ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
#MYIP=$(wget -qO- ipv4.icanhazip.com);

# get the VPS IP
#ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
#MYIP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)

if [ "$MYIP" = "" ]; then
	MYIP=$(wget -qO- ipv4.icanhazip.com)
fi
MYIP2="s/xxxxxxxxx/$MYIP/g";
ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [[ $ether = "" ]]; then
        ether=eth0
fi

#vps="zvur";
vps="aneka";

#if [[ $vps = "zvur" ]]; then
	#source="http://"
#else
	source="https://raw.githubusercontent.com/brantbell/cream/mei"
#fi

# go to root
cd

# check registered ip
wget -q -O IP $source/brantbell/cream/mei/IP.txt
if ! grep -w -q $MYIP IP; then
	echo "Maaf, hanya IP yang terdaftar yang bisa menggunakan script ini!"
	if [[ $vps = "zvur" ]]; then
		echo "Hubungi: editor YUSUF-ARDIANSYAH atau (082139743432)"
	else
		echo "Hubungi: editor YUSUF-ARDIANSYAH atau (082139743432)"
	fi
	rm /root/IP
	rm -f /root/IP
	exit
  fi

apt-get -y --purge remove openvpn*;
# install openvpn
#myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
apt-get install openvpn -y
wget -O /etc/openvpn/openvpn.tar $source/brantbell/cream/mei/openvpn-debian.tar
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf $source/brantbell/cream/mei/1194.conf
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -O /etc/iptables.conf $source/cream/mei/iptables.conf
sed -i '$ i\iptables-restore < /etc/iptables.conf' /etc/rc.local


sed -i 's/ipserver/$MYIP/g' /etc/iptables.conf

iptables-restore < /etc/iptables.conf
service openvpn restart

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/client.ovpn $source/brantbell/cream/mei/1194-client.conf

cp /etc/openvpn/client.ovpn /home/vps/public_html/client.ovpn
sed -i 's/ipserver/$MYIP/g' /home/vps/public_html/client.ovpn
sed -i 's/ports/55/' /home/vps/public_html/client.ovpn
rm /root/ovpn.sh
