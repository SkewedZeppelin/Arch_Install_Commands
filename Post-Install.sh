#/bin/bash
#Copyright (c) 2015-2017 Divested Computing Group

#Color codes from https://wiki.archlinux.org/index.php/Color_Bash_Prompt
coloroff='\e[0m'
black='\e[0;30m'
blue='\e[0;34m'
cyan='\e[0;36m'
green='\e[0;32m'
purple='\e[0;35m'
red='\e[0;31m'
white='\e[0;37m'
yellow='\e[0;33m'
infoColor=${green}
questionColor=${red}
outputColor=${yellow}

#Intro
echo -e ${infoColor}"Welcome to the Spot Communication's Arch Linux installer and configurator"
echo -e ${infoColor}"This is the post-install script meant to be run after doing a base install"
echo -e ${infoColor}"This script has yet to be throughly tested, stuff might go very, very wrong"
echo -e ${infoColor}"Ctrl+C within 10 seconds if you do not want to end up troubleshooting your system or have to attempt to recover lost files"
sleep 10

#Connect to the network
echo -e ${infoColor}"START OF NETWORK CONFIG"
echo -e ${questionColor}"Do you plan on using Wi-Fi for this install? Answering no will auto connect on all ethernet interfaces"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo wifi-menu; break;;
        No ) sudo systemctl start dhcpcd.service; break;;
    esac
done
echo -e ${infoColor}"END OF NETWORK CONFIG"
sleep 15

#Configure pacman
echo -e ${infoColor}"START OF PACMAN CONFIGURATION"
sudo sed -i 's/#\[testing\]/\[testing\]/' /etc/pacman.conf
sudo sed -i 's/#\[community-testing\]/\[community-testing\]/' /etc/pacman.conf
sudo sed -i 's/#\[multilib-testing\]/\[multilib-testing\]/' /etc/pacman.conf
sudo sed -i 's/#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sudo sed -i 's/#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
echo -e ${outputColor}
sudo reflector --verbose --latest 50 -p https --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syyu
echo -e ${infoColor}"END OF PACMAN CONFIGURATION"
sleep 3

#Configure makepkg
echo -e ${infoColor}"START OF MAKEPKG CONFIGURATION"
sudo sed -i 's/CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fstack-check"/CFLAGS="-march=native -mtune=native -O3 -pipe -fstack-protector-strong -fstack-check --param=ssp-buffer-size=4"/' /etc/makepkg.conf
sudo sed -i 's/CXXFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fstack-check"/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$*(cat /proc/cpuinfo | grep -c processor)\"/" /etc/makepkg.conf
#TODO: Change packager name here
sudo sed -i 's/(xz -c -z -)/(xz -T 0 -c -z -)/' /etc/makepkg.conf
echo -e ${infoColor}"END OF MAKEPKG CONFIGURATION"
sleep 3

echo "Please run Arch_Linux-Package_Installer.sh before continuing..."
sleep 30

sudo archlinux-java set java-8-openjdk
sudo sed -i 's/#listen-address=/listen-address=127.0.0.1/' /etc/dnsmasq.conf
sudo sed -i 's/dns=default/dns=dnsmasq/' /etc/NetworkManager/NetworkManager.conf
sudo systemctl enable NetworkManager.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl enable rngd.service;
sudo timedatectl set-ntp true
sudo systemctl enable systemd-timesyncd.service
sudo systemctl restart systemd-timesyncd.service
chsh -s $(which zsh);

echo -e ${infoColor}"FINISHING UP"
echo -e ${infoColor}"Please reboot now"
sudo sync
