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

# Install nodejs and npm
curl -fsSL https://deb.nodesource.com/setup_21.x | bash
apt-get install -y nodejs
npm install -g npm@latest
node -v && npm -v

# Install Signal K server
apt install libnss-mdns avahi-utils libavahi-compat-libdnssd-dev -y
npm install -g signalk-server

# Install RaspAP
curl -sL https://install.raspap.com | bash

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
