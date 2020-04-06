#!/bin/bash

DATESTAMP=`date "+%Y-%m-%d-%H-%M-%S"`
CONFIG_BOOT="/boot/config.txt"
MOPIDY_CONFIG="/etc/mopidy/mopidy.conf"
MOPIDY_SUDOERS="/etc/sudoers.d/010_mopidy-nopasswd"
MOPIDY_PIDI_FRONTEND="/usr/local/lib/python3.7/dist-packages/mopidy_pidi/frontend.py"
EXISTING_CONFIG=false
PYTHON_MAJOR_VERSION=3
PIP_BIN=pip3
ROTATE=180
CS=0
DC=25
BL=27
PACKAGES="python3-rpi.gpio python3-spidev python3-pip python3-pil python3-numpy"
PACKAGES_MOPIDY="mopidy mopidy-spotify"
PIP_PACKAGES=""
UPDATED=false
INSTALL_SUCCESS=false

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
	if [ ! -f "/etc/apt/sources.list.d/mopidy.list" ]; then
		inform "Adding Mopidy apt source"
		wget -q -O - https://apt.mopidy.com/mopidy.gpg | apt-key add -
		wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list
		apt update
		UPDATED=true
	fi
	REQ_STATE=$(dpkg -l $PACKAGES | grep "un ")
	if [ -n "$REQ_STATE" ]; then
		inform "Start installing packages."
		if [ "$UPDATED" = false ]; then
			apt update
			UPDATED=true
		fi
		#apt-mark unhold mopidy mopidy-spotify
		apt -y install $PACKAGES
	fi
	REQ_STATE=$(dpkg -l $PACKAGES_MOPIDY | grep "mopidy")
	if [ ! -n "$REQ_STATE" ]; then
			inform "Start installing mopidy packages."
			if [ "$UPDATED" = false ]; then
					apt update
					UPDATED=true
			fi
			#apt-mark unhold mopidy mopidy-spotify
			apt -y install $PACKAGES_MOPIDY
	fi
	REQ_STATE=$(dpkg -l $PACKAGES_MOPIDY | grep "rc ")
	if [ -n "$REQ_STATE" ]; then
			inform "Start installing mopidy packages."
			if [ "$UPDATED" = false ]; then
					apt update
					UPDATED=true
			fi
			#apt-mark unhold mopidy mopidy-spotify
			apt -y install $PACKAGES_MOPIDY
	fi
	REQ_STATE=$(dpkg -l $PACKAGES | grep "un ")
	if [ ! -n "$REQ_STATE" ]; then
		REQ_STATE2=$(dpkg -l $PACKAGES | grep "rc ")
		if [ ! -n "$REQ_STATE2" ]; then
			INSTALL_SUCCESS=true
		fi
	fi
	
}

# Verify python version via pip
function check_pip_version() {
	inform "Verifying python $PYTHON_MAJOR_VERSION.x version"
	PIP_CHECK="$PIP_BIN --version"
	VERSION=`$PIP_CHECK | sed s/^.*\(python[\ ]*// | sed s/.$//`
	RESULT=$?
	if [ "$RESULT" == "0" ]; then
		MAJOR_VERSION=`echo $VERSION | awk -F. {'print $1'}`
		if [ "$MAJOR_VERSION" -eq "$PYTHON_MAJOR_VERSION" ]; then
			success "Found Python $VERSION"
		else
			warning "error: installation requires pip for Python $PYTHON_MAJOR_VERSION.x, Python $VERSION found."
			echo
			exit 1
		fi
	else
		warning "error: \`$PIP_CHECK\` failed to execute successfully"
		echo
		exit 1
	fi
}

# Stop mopidy if running
function stop_mopidy() {
	systemctl status mopidy > /dev/null 2>&1
	RESULT=$?
	if [ "$RESULT" == "0" ]; then
		inform "Stopping Mopidy service..."
		systemctl stop mopidy
	fi
}

function sys_config() {
	# Enable SPI
	raspi-config nonint do_spi 0

	# Add necessary lines to config.txt (if they don't exist)
	#add_to_config_text "gpio=25=op,dh" $CONFIG_BOOT
	sed -i '/^dtoverlay=hifiberry-dacplus/d' $CONFIG_BOOT
	echo "dtoverlay=hifiberry-dacplus" >> $CONFIG_BOOT
}

function backup_mopidy() {
	if [ -f "$MOPIDY_CONFIG" ]; then
		inform "Backing up mopidy config to: $MOPIDY_CONFIG.backup-$DATESTAMP"
		cp "$MOPIDY_CONFIG" "$MOPIDY_CONFIG.backup-$DATESTAMP"
		EXISTING_CONFIG=true
	fi
}

function install_sysreq_python() {
	# Install Mopidy Iris web UI and support plugins
	inform "Installing Iris web UI for Mopidy & Pirate Audio plugins..."
	$PIP_BIN install --upgrade mopidy-iris Mopidy-PiDi pidi-display-pil pidi-display-st7789 mopidy-raspberry-gpio
	$PIP_BIN install --upgrade mopidy-iris Mopidy-PiDi pidi-display-pil pidi-display-st7789 mopidy-raspberry-gpio
	$PIP_BIN install --upgrade mopidy-iris Mopidy-PiDi pidi-display-pil pidi-display-st7789 mopidy-raspberry-gpio
}

# Get location of Iris's system.sh
function config_mopidy_system_sh() {
	MOPIDY_SYSTEM_SH=`python$PYTHON_MAJOR_VERSION - <<EOF
import pkg_resources
distribution = pkg_resources.get_distribution('mopidy_iris')
print(f"{distribution.location}/mopidy_iris/system.sh")
EOF`

	# Add it to sudoers
	if [ "$MOPIDY_SYSTEM_SH" == "" ]; then
		warning "Could not find system.sh path for mopidy_iris using python$PYTHON_MAJOR_VERSION"
		warning "Refusing to edit $MOPIDY_SUDOERS with empty system.sh path!"
	else
		inform "Adding $MOPIDY_SYSTEM_SH to $MOPIDY_SUDOERS"
		echo "mopidy ALL=NOPASSWD: $MOPIDY_SYSTEM_SH" > $MOPIDY_SUDOERS
	fi

	# Reset mopidy.conf to its default state
	if [ $EXISTING_CONFIG ]; then
		warning "Resetting $MOPIDY_CONFIG to package defaults."
		inform "Any custom settings have been backed up to $MOPIDY_CONFIG.backup-$DATESTAMP"
		apt install --reinstall -o Dpkg::Options::="--force-confask,confnew,confmiss" mopidy=$MOPIDY_VERSION > /dev/null 2>&1
	fi
}

function config_mopidy() {
	inform "Configuring Mopidy"
	cat <<EOF >> $MOPIDY_CONFIG

[raspberry-gpio]
enabled = true
bcm5 = volume_up,active_low,250
bcm6 = next,active_low,250
bcm16 = volume_down,active_low,250
bcm20 = play_pause,active_low,250

[file]
enabled = true
media_dirs = /home/pi/Music
show_dotfiles = false
excluded_file_extensions =
  .directory
  .html
  .jpeg
  .jpg
  .log
  .nfo
  .pdf
  .png
  .txt
  .zip
follow_symlinks = false
metadata_timeout = 1000

[pidi]
enabled = true
display = st7789

[mpd]
hostname = 0.0.0.0

[http]
hostname = 0.0.0.0

[audio]
mixer_volume = 40
output = alsasink device=hw:sndrpihifiberry

[spotify]
enabled = false
username =
password =
client_id =
client_secret =
EOF
	usermod -a -G spi,i2c,gpio,video mopidy
	sed -i -e "s/self.rotation =.*/self.rotation = $ROTATE/" $MOPIDY_PIDI_FRONTEND
	sed -i -e "s/self.spi_chip_select_pin =.*/self.spi_chip_select_pin = $CS/" $MOPIDY_PIDI_FRONTEND
	sed -i -e "s/self.spi_data_command_pin =.*/self.spi_data_command_pin = $DC/" $MOPIDY_PIDI_FRONTEND
	sed -i -e "s/self.backlight_pin =.*/self.backlight_pin = $BL/" $MOPIDY_PIDI_FRONTEND
}

function enable_mopidy() {
	inform "Enabling and starting Mopidy"
	sudo systemctl enable mopidy
	sudo systemctl restart mopidy
}

function main() {
	install_sysreq
	if [ "$INSTALL_SUCCESS" = false ]; then
		install_sysreq
	fi
	if [ "$INSTALL_SUCCESS" = false ]; then
		install_sysreq
	fi
	stop_mopidy
	backup_mopidy
	sys_config
	check_pip_version
	install_sysreq_python
	config_mopidy_system_sh
	config_mopidy
	enable_mopidy
	success "All done! Please reboot."
}

# Permission detection
if [ $UID -ne 0 ]; then
	echo "Superuser privileges are required to run this script.\ne.g. \"sudo $0\"" 10 60
    exit 1
fi
pip3 install --upgrade mopidy-iris Mopidy-PiDi pidi-display-pil pidi-display-st7789 mopidy-raspberry-gpio


#main
