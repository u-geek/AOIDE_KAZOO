Aodie KAZOO: Audio Line-out for Raspberry Pi Zero

This board is perfect for upgrading an existing hi-fi amp and speakers, or a set of powered monitors, with digital audio from local audio files (MP3, FLAC, etc.) or from streaming services like Spotify. The DAC on Pirate Audio Line-out gives you crisp 24-bit / 192KHz digital audio through its 3.5mm stereo jack.

Pirate Audio is a range of all-in-one audio boards for Raspberry Pi, with high-quality digital audio, beautifully-crisp IPS displays for album art, tactile buttons for playback control, and our custom Pirate Audio software and installer to make setting it all up a breeze.

Features

Line-level digital audio (24-bit / 192KHz) over I2S

PCM5102A DAC chip 

3.5mm stereo jack

1.3" IPS colour LCD (240x240px) (ST7789 driver)

Four tactile buttons

IR Remote (both IR Receive and Send)

Mini HAT-format board

Fully-assembled

Compatible with all 40-pin header Raspberry Pi models

Aoide KAZOO software

Compatible Pirate Audio software

Dimensions: 65x30.5x9.5mm

Software

Our software installs the Python library for the LCD, configures the I2S audio and SPI, and then installs Mopidy and our custom Pirate Audio plugins to display album art and track info, and to use the buttons for playback control.

Here's how to get started:

1.Set an SD card up with the latest version of Raspbian.

2.Connect to Wi-Fi or a wired network.

3.Open a terminal and type the following:

    sudo apt update && sudo apt install git
    
    git clone https://github.com/u-geek/AOIDE_KAZOO
    
    cd AOIDE_KAZOO
    
    sudo ./setup.sh
    
4.Reboot your Pi

Build Your Own

If you're planning to build your own application you'll find some inspiration in examples.

But first you'll need some dependencies:

sudo apt-get update

sudo apt-get install python-rpi.gpio python-spidev python-pip python-pil python-numpy

And then you'll need the st7789 library:

sudo pip install st7789

For more display examples see: https://github.com/u-geek/st7789-python/tree/master/examples
