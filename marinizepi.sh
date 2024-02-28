#! /bin/bash

# Upgrade the system
apt update
apt upgrade -y

# Install VI Improved
apt install vim -y

# Generate the locale
locale-gen en_US.UTF-8
update-locale en_US.UTF-8

# Configure the Bash Aliases
cat >.bash_aliases << EOF
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
EOF
cp .bash_aliases /home/pi/.bash_aliases
chown pi:pi /home/pi/.bash_aliases

# Install nodejs and npm
curl -fsSL https://deb.nodesource.com/setup_21.x | bash
apt-get install -y nodejs
npm install -g npm@latest
node -v && npm -v

# Install Signal K server
apt install libnss-mdns avahi-utils libavahi-compat-libdnssd-dev -y
npm install -g signalk-server

# Start interactive Signal K server setup
signalk-server-setup

# Install RaspAP
curl -sL https://install.raspap.com | bash

# Chanche the RaspAP port
sed /etc/lighttpd/lighttpd.conf -i -e "s/^server.port                 = 80/server.port                 = 8080/"

# Configure the DHCP
cat >/etc/dhcpcd.conf << EOF
# RaspAP default configuration
hostname
clientid
persistent
option rapid_commit
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
option ntp_servers
require dhcp_server_identifier
slaac private
nohook lookup-hostname

# RaspAP wlan0 configuration
interface wlan0
static ip_address=172.24.1.1/24
static routers=172.24.1.1
nogateway
EOF

# Configure dnsmasq
cat >> /etc/dnsmasq.d/090_wlan0.conf << EOF
# RaspAP wlan0 configuration
interface=wlan0
dhcp-range=172.24.1.32,172.24.1.96,255.255.255.0,7d
EOF

# Configure the Host Acces Point
cat >> /etc/hostapd/hostapd.conf << EOF
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
auth_algs=1
wpa_key_mgmt=WPA-PSK
beacon_int=100
ssid=Dynamo
channel=6
hw_mode=g
ieee80211n=0
wpa_passphrase=Dynamo2024!
interface=wlan0
wpa=2
wpa_pairwise=CCMP
country_code=IT
ignore_broadcast_ssid=0
EOF

# Setup user interface
apt install xserver-xorg raspberrypi-ui-mods -y
systemctl set-default graphical.target
ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
#rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
#sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/#autologin-user=/"
