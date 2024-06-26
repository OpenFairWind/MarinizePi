#! /bin/bash

# Upgrade the system
apt update
apt upgrade -y

# Install VI Improved
apt install vim uuid-runtime -y

if [ -z "${VESSEL_NAME}" ]
then
  echo "Please export the variable VESSEL_NAME containing the vessel's name."
  exit 1
fi

if [ -z "${VESSEL_MMSI}" ]
then
  UUID=`uuidgen`
  VESSEL_UUID="urn:mrn:signalk:uuid:$UUID"
  echo "Using $VESSEL_NAME UUID: $VESSEL_UUID"
  
else
  echo "Using $VESSEL_NAME MMSI: $VESSEL_MMSI"
fi

# Generate the locale
locale-gen en_US.UTF-8
update-locale en_US.UTF-8
cat >/etc/default/locale << EOF
#  File generated by update-locale
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

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

# Start Signal K server setup
mkdir /home/pi/.signalk
mkdir /home/pi/.signalk/plugin-config-data
mkdir /home/pi/.signalk/plugin-config-data/resources-provider
mkdir /home/pi/.signalk/plugin-config-data/resources-provider/resources
mkdir /home/pi/.signalk/plugin-config-data/resources-provider/resources/notes
mkdir /home/pi/.signalk/plugin-config-data/resources-provider/resources/regions
mkdir /home/pi/.signalk/plugin-config-data/resources-provider/resources/routes
mkdir /home/pi/.signalk/plugin-config-data/resources-provider/resources/waypoints
mkdir /home/pi/.signalk/serverState
mkdir /home/pi/.signalk/serverState/course

cat > /home/pi/.signalk/baseDeltas.json << EOF
[
  {
    "context": "vessels.self",
    "updates": [
      {
        "values": [
          {
            "path": "",
            "value": {
              "mmsi": "$VESSEL_MMSI",
              "name": "$VESSEL_NAME"
            }
          }
        ]
      }
    ]
  }
]
EOF

cat > /home/pi/.signalk/package.json << EOF
{
  "name": "signalk-server-config",
  "version": "0.0.1",
  "description": "This file is here to track your plugin and webapp installs.",
  "repository": {},
  "license": "Apache-2.0"
}
EOF

cat > /home/pi/.signalk/plugin-config-data/resources-provider.json << EOF
{
  "configuration": {
    "standard": {
      "routes": true,
      "waypoints": true,
      "notes": true,
      "regions": true
    },
    "custom": [],
    "path": "./resources"
  }
}
EOF

cat >/home/pi/.signalk/settings.json << EOF
{
  "interfaces": {},
  "ssl": false,
  "pipedProviders": [],
  "security": {
    "strategy": "./tokensecurity"
  }
}
EOF

cat >/home/pi/.signalk/signalk-server << EOF
#!/bin/sh
/usr/lib/node_modules/signalk-server/bin/signalk-server -c /home/pi/.signalk/
EOF

chown -R pi:pi /home/pi/.signalk
chmod +x /home/pi/.signalk/signalk-server

cat > /etc/systemd/system/signalk.service << EOF
[Service]
ExecStart=/home/pi/.signalk/signalk-server
Restart=always
StandardOutput=syslog
StandardError=syslog
WorkingDirectory=/home/pi/.signalk
User=pi
Environment=EXTERNALPORT=3000
Environment=NODE_ENV=production
Environment=RUN_FROM_SYSTEMD=true
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/signalk.socket << EOF
[Socket]
ListenStream=3000


[Install]
WantedBy=sockets.target
EOF

systemctl daemon-reload
systemctl enable signalk.service
systemctl enable signalk.socket
systemctl stop signalk.service
systemctl restart signalk.socket
systemctl restart signalk.service

# Install RaspAP
curl -sL https://install.raspap.com | bash -s -- -y -o 0 -a 1 -w 0 -e 0

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
cat >/etc/dnsmasq.d/090_wlan0.conf << EOF
# RaspAP wlan0 configuration
interface=wlan0
dhcp-range=172.24.1.32,172.24.1.96,255.255.255.0,7d
EOF

# Configure the Host Access Point
cat >/etc/hostapd/hostapd.conf << EOF
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
auth_algs=1
wpa_key_mgmt=WPA-PSK
beacon_int=100
ssid=$VESSEL_NAME
channel=6
hw_mode=g
ieee80211n=0
wpa_passphrase=ChangeMe
interface=wlan0
wpa=2
wpa_pairwise=CCMP
country_code=IT
ignore_broadcast_ssid=0
EOF

# Setup user interface
apt install xserver-xorg raspberrypi-ui-mods xcompmgr -y
systemctl set-default graphical.target
ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service

# Install and enable vnc server
apt install realvnc-vnc-server -y
systemctl enable vncserver-x11-serviced

# Install Chromium
apt install chromium-browser -y

# Install the SD Card Clone utility
apt install piclone -y

# Install the QT6 runtime
apt install libnss-mdns avahi-utils libavahi-compat-libdnssd-dev libqt6websockets6 libqt6webenginewidgets6 libqt6webenginecore6 libqt6positioningquick6 libqt6widgets6 libqt6network6 libqt6gui6 libqt6core6 libqt6quickwidgets6 libqt6quickwidgets6 libqt6webchannel6 libqt6qml6 libqt6dbus6 libqt6qmlmodels6 libqt6opengl6 libqt6virtualkeyboard6 qt6-virtualkeyboard-plugin -y

