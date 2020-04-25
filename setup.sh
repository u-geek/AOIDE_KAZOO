#!/bin/bash
PACKAGES_OLD="curl git mpc mpd ncmpc samba samba-common-bin wiringpi dnsmasq hostapd bridge-utils libasound2-dev libudev-dev libibus-1.0-dev libdbus-1-dev fcitx-libs-dev libsndio-dev libx11-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev libxkbcommon-dev libxrandr-dev libxss-dev libxt-dev libxv-dev libxxf86vm-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev libgl1-mesa-dev libglu1-mesa-dev libdrm-dev libgbm-dev devscripts debhelper dh-autoreconf libsdl2-gfx-1.0-0 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-image-dev libmpdclient-dev libmpdclient2"
PACKAGES="curl git mpc mpd ncmpc samba samba-common-bin wiringpi dnsmasq hostapd bridge-utils libsdl2-gfx-1.0-0 libsdl2-image-2.0-0 libsdl2-ttf-2.0-0 libsdl2-gfx-dev libsdl2-ttf-dev libsdl2-image-dev libmpdclient-dev libmpdclient2 fcitx-libs-dev libdrm-dev libgbm-dev"
URL_LIBSDL2="https://files.retropie.org.uk/binaries/buster/rpi1/libsdl2-2.0-0_2.0.10+5rpi_armhf.deb"
URL_LIBSDL2_DEV="https://files.retropie.org.uk/binaries/buster/rpi1/libsdl2-dev_2.0.10+5rpi_armhf.deb"
FILE_RCLOCAL="/etc/rc.local"
FILE_CONFIG="/boot/config.txt"
FILE_MPDCONFIG="/etc/mpd.conf"
UPMPD_URL="http://www.lesbonscomptes.com/upmpdcli/downloads/raspbian/pool/main/u/upmpdcli/upmpdcli_1.2.16-1~ppa1~stretch_armhf.deb"
UPMPD_FILENAME="upmpdcli_1.2.16-1~ppa1~stretch_armhf.deb"
LIBUPNP6_URL="http://www.lesbonscomptes.com/upmpdcli/downloads/raspbian/pool/main/libu/libupnp/libupnp6_1.6.20.jfd5-1~ppa1~stretch_armhf.deb"
LIBUPNP6_FILENAME="libupnp6_1.6.20.jfd5-1~ppa1~stretch_armhf.deb"
LIBUPNPP4_URL="http://www.lesbonscomptes.com/upmpdcli/downloads/raspbian/pool/main/libu/libupnpp4/libupnpp4_0.16.1-1~ppa1~stretch_armhf.deb"
LIBUPNPP4_FILENAME="libupnpp4_0.16.1-1~ppa1~stretch_armhf.deb"
SHAIRPORTSYNCMR_URL="http://repo.volumio.org/Volumio2/Binaries/shairport-sync-metadata-reader-arm.tar.gz"
SHAIRPORTSYNCMR_FILENAME="shairport-sync-metadata-reader-arm.tar.gz"
RETROGAME_URL="https://github.com/adafruit/Adafruit-Retrogame/raw/master/retrogame"

function success() {
	echo -e "$(tput setaf 2)$1$(tput sgr0)"
}

function inform() {
	echo -e "$(tput setaf 6)$1$(tput sgr0)"
}

function warning() {
	echo -e "$(tput setaf 1)$1$(tput sgr0)"
}

# Update apt and install dependencies
function install_sysreq() {
	inform "Updating apt and installing dependencies"
	apt update
	REQ_STATE=$(dpkg -l $PACKAGES | grep "un ")
	if [ ! -n "$REQ_STATE" ]; then
		inform "Start installing packages."
		# if [ "$UPDATED" = false ]; then
			# apt update
			# UPDATED=true
		# fi
		apt -y install $PACKAGES
	fi
    
#    REQ_STATE=$(dpkg -l $PACKAGES | grep "un ")
#    if [ ! -n "$REQ_STATE" ]; then
#        warning "Packages install failed! try to fix."
#	apt -y --fix-broken install
#    else
#        success "Packages install sucessful!"
#    fi

#    REQ_STATE=$(dpkg -l $PACKAGES | grep "un ")
#    if [ ! -n "$REQ_STATE" ]; then
#        warning "Packages install failed again! exit."
#	exit
#    fi


    # echo "Install upnp and airplay support."

	# SOFT=$(dpkg -l libupnpp4 | grep "<none>")
	# if [ -n "$SOFT" ]; then
		# echo "Install libupnpp4."
		# curl -LJ0 -o $LIBUPNPP4_FILENAME $LIBUPNPP4_URL
	# else
		# echo "Libupnpp4 install complete."
	# fi

	# SOFT=$(dpkg -l libupnp6 | grep "<none>")
	# if [ -n "$SOFT" ]; then
		# echo "Install libupnp6."
		# curl -LJ0 -o $LIBUPNP6_FILENAME $LIBUPNP6_URL
	# else
		# echo "Libupnp6 install complete."
	# fi

	# SOFT=$(dpkg -l upmpdcli | grep "<none>")
	# if [ -n "$SOFT" ]; then
		# echo "Install upmpdcli."
		# curl -LJ0 -o $UPMPD_FILENAME $UPMPD_URL
	# else
		# echo "Upmpdcli install complete."
	# fi

	# if [ ! -f "/usr/local/bin/shairport-sync-metadata-reader" ]; then
		# echo "Install shairpot-sync metadata reader."
		# cd /
		# curl -LJ0 -o $SHAIRPORTSYNCMR_FILENAME  $SHAIRPORTSYNCMR_URL
		# tar xf $SHAIRPORTSYNCMR_FILENAME
		# if [ -f "$SHAIRPORTSYNCMR_FILENAME" ]; then
			# rm $SHAIRPORTSYNCMR_FILENAME
		# fi
	# fi
    
	inform "Install hostapd"
    if [ ! -f "/usr/sbin/hostapd-ori" ]; then
		cp /usr/sbin/hostapd /usr/sbin/hostapd-ori
	fi
	
	inform "Install hostapd(edimax)"
	if [ ! -f "/usr/sbin/hostapd-edimax" ]; then
		inform "Install special version of hostapd for edimax dongle."
        if [ -f "packages/hostapd-edimax" ]; then
            cp packages/hostapd-edimax /usr/sbin/
        else
            curl -LJ0 -o /usr/sbin/hostapd-edimax http://repo.volumio.org/Volumio2/Binaries/arm/hostapd-edimax
        fi
		chmod a+x /usr/sbin/hostapd-edimax
	fi
	
	inform "Install libsdl2"
	dpkg -i packages/libsdl2-*.deb
	apt -y --fix-broken install
	
	inform "Install ympd"
    if [ ! -f "/usr/local/bin/ympd" ]; then
        cp packages/ympd /usr/local/bin/
    fi
	
	inform "Install fbcp"
    if [ ! -f "/usr/local/bin/fbcp-ili9341" ]; then
        cp packages/fbcp-ili9341 /usr/local/bin/
    fi
	
	# inform "Install keypad"
    # if [ ! -f "/boot/overlays/keypad.dtbo" ]; then
        # cp packages/keypad.dtbo /boot/overlays
    # fi
}

# config config.txt
function config_config() {
    inform "Modify $FILE_CONFIG"
	sed -i '/^dtparam=audio=on/d' $FILE_CONFIG
    sed -i '/^hdmi_group=/d' $FILE_CONFIG
    sed -i '/^hdmi_mode=/d' $FILE_CONFIG
    sed -i '/^hdmi_cvt=/d' $FILE_CONFIG
    sed -i '/^hdmi_force_hotplug=/d' $FILE_CONFIG
    sed -i '/^dtoverlay=hifiberry-dacplus/d' $FILE_CONFIG
    #sed -i '/^dtoverlay=dtoverlay=keypad/d' $FILE_CONFIG
    #sed -i '/^gpio=20=ip,pu/d' $FILE_CONFIG
    
	cat << EOF >> $FILE_CONFIG
	
dtparam=audio=off
hdmi_group=2
hdmi_mode=87
hdmi_cvt=240 240 60 1 0 0 0
hdmi_force_hotplug=1
dtoverlay=hifiberry-dacplus

EOF
}

# config mpd
function config_mpd() {
	inform "Config MPD"
    systemctl stop mpd
    #cp resources/mpd.conf /etc/mpd.conf
    inform ">Config Music Player Daemon"
	if [ ! -d "/home/pi/Music" ]; then
		sudo -u pi mkdir /home/pi/Music
	fi
	sed -i -e 's/^music_directory.*".*"/music_directory "\/home\/pi\/Music"/' /etc/mpd.conf
	sed -i -e ':a;N;$!ba;s/audio_output.*/}/' $FILE_MPDCONFIG
	cat << EOF >> $FILE_MPDCONFIG
audio_output {
        type            "alsa"
        name            "KAZOO"
        device          "hw:0,0"        # optional
        mixer_type      "hardware"      # optional
        mixer_device    "hw:0"
        mixer_control   "Digital"
#       mixer_index     "0"             # optional
}
EOF
    systemctl start mpd
}

function config_ap(){
	inform "Config AP"
	inform "->Enable DHCPCD-<"
	if [ -f "/etc/dhcpcd.conf" ]; then
		IN_DHCPCD=$(cat /etc/dhcpcd.conf | grep wlan0)
		if [ -z "$IN_DHCPCD" ]; then
			cat << EOF >> /etc/dhcpcd.conf
	interface wlan0
		static ip_address=192.168.20.1/24
EOF
		fi
	fi
	systemctl enable dhcpcd
	systemctl start dhcpcd

	inform "->Enable DNSMASQ<-"
	sed -i 's/^[ \t]*interface.*//g' /etc/dnsmasq.conf
	sed -i 's/^[ \t]*dhcp-range.*//g' /etc/dnsmasq.conf
	cat << EOF >> /etc/dnsmasq.conf
interface=wlan0
  dhcp-range=192.168.20.2,192.168.20.20,255.255.255.0,24h
EOF

	inform "->Enable HOSTAPD-<"
	if [ -f "/etc/hostapd/hostapd.conf" ]; then
		rm /etc/hostapd/hostapd.conf
	fi
	touch /etc/hostapd/hostapd.conf
	cat << EOF >> /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=KAZOO
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=raspberry
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

	sed -i 's/#DAEMON_CONF/DAEMON_CONF/g' /etc/default/hostapd
	sed -i 's/^DAEMON_CONF=\".*\"/DAEMON_CONF=\"\/etc\/hostapd\/hostapd.conf\"/g' /etc/default/hostapd

	cp /usr/sbin/hostapd-ori /usr/sbin/hostapd
	systemctl unmask hostapd
	systemctl enable hostapd
	systemctl start hostapd
	systemctl enable dnsmasq
	systemctl start dnsmasq

	if [ ! -f "/etc/sysctl.conf" ]; then
		touch /etc/sysctl.conf
	fi
	sed -i 's/#net.ipv4.ip_forward=1//g' /etc/default/hostapd
	echo "net.ipv4.ip_forward=1" >>  /etc/sysctl.conf

	iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

	if [ ! -f "/etc/iptables.ipv4.nat" ]; then
		iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
		sh -c "iptables-save > /etc/iptables.ipv4.nat"
	fi

	sed -i 's/iptables-restore.*//g' $FILE_RCLOCAL
	sed -i '/^exit 0/iiptables-restore < \/etc\/iptables.ipv4.nat' $FILE_RCLOCAL
}

# config samba
function config_samba(){
	inform "Config samba"
    systemctl stop smbd
    pass=raspberry
    user=pi
    smbpasswd -x pi
    (echo $pass; echo $pass) | smbpasswd -s -a $user
    
	IN_SMB=$(cat /etc/samba/smb.conf | grep Music)
    
	if [ -z "$IN_SMB" ]; then
		cat << EOF >> /etc/samba/smb.conf
[Music]
comment = Music
path = "/home/pi/Music"
writeable = yes
guest ok = yes
create mask = 0755
directory mask = 0755
force user = pi
EOF
	fi
    systemctl start smbd
}

# config etc/rc.local
function config_rc_local() {
	inform "Config $FILE_RCLOCAL"
    fbcp_configured=$(cat /etc/rc.local | grep "fbcp-ili9341")
    if [ -z "$fbcp_configured" ]; then
		sed -i '/^exit 0/i\/usr\/local\/bin\/fbcp-ili9341 &' $FILE_RCLOCAL
	fi
    ympd_configured=$(cat /etc/rc.local | grep "ympd")
    if [ -z "$ympd_configured" ]; then
		sed -i '/^exit 0/i\/usr\/local\/bin\/ympd --webport 80 &' $FILE_RCLOCAL
	fi
}

function config_input(){
	inform "Config input"
	sed -i '/^uinput/d' $FILE_MODULES
	if [ -e "/etc/udev/rules.d/10-retrogame.rules" ]; then
		rm /etc/udev/rules.d/10-retrogame.rules
	fi
	sed -i '/^\/usr\/local\/bin\/retrogame &/d' $FILE_RCLOCAL
	if [ -f "/boot/retrogame.cfg" ]; then
		rm /boot/retrogame.cfg
	fi
	echo "uinput" >> $FILE_MODULES
	touch /etc/udev/rules.d/10-retrogame.rules
	echo "SUBSYSTEM==\"input\", ATTRS{name}==\"retrogame\", ENV{ID_INPUT_KEYBOARD}=\"1\"" > /etc/udev/rules.d/10-retrogame.rules
	if [ ! -f "/usr/local/bin/retrogame" ]; then
		if [ ! -f "packages/retrogame" ]; then
			curl -LJ0 -o /usr/local/bin/retrogame $RETROGAME_URL
			chmod +x /usr/local/bin/retrogame
		fi
		cp packages/retrogame /usr/local/bin/retrogame
	fi
	sed -i '/^exit 0/i\/usr\/local\/bin\/retrogame &' $FILE_RCLOCAL
	if [ -f "/boot/retrogame.cfg" ]; then
		rm /boot/retrogame.cfg
	fi
	touch /boot/retrogame.cfg
	cat << EOF >> /boot/retrogame.cfg
LEFT      5
RIGHT     16
UP        20
DOWN      21
EOF

}

# Install Player
function install_player() {
	inform "Install AOIDE KAZOO Player"
	if [ ! -d "/home/pi/AOIDE_KAZOO" ]; then
		cd /home/pi/
		git clone https://github.com/howardqiao/AOIDE_KAZOO --depth 1
	fi
	sed -i '/^cd \/home\/pi\/AOIDE_KAZOO/d' $FILE_CONFIG
	sed -i '/^.\/play/d' $FILE_CONFIG
	sed -i '/^exit 0/icd \/home\/pi\/AOIDE_KAZOO' $FILE_RCLOCAL
	sed -i '/^exit 0/i.\/play &' $FILE_RCLOCAL
}

# main loop
function main() {
    install_sysreq
    config_config
    config_rc_local
    config_mpd
    config_samba
    config_ap
	config_input
	install_player
	inform "Sync..."
	sync
	inform "Now reboot..."
	reboot
}

# Permission detection
if [ $UID -ne 0 ]; then
	inform "Superuser privileges are required to run this script.\ne.g. \"sudo $0\"" 10 60
    exit 1
fi

main

