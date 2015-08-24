#Intro
echo "Welcome to the Spot Communication's Arch Linux installer and configurator"
echo "This is the post-install script meant to be run after doing a base install"
echo "This script has yet to be tested, stuff might go very, very wrong"
echo "Ctrl+C within 10 seconds if you do not want to end up troubleshooting your system or have to attempt to recover lost files"
sleep 10

#Connect to the network
echo "Do you plan on using Wi-Fi for this install? Answering no will auto connect on all ethernet interfaces"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo menu; break;;
        No ) sudo systemctl start dhcpcd.service; break;;
    esac
done

#Configure pacman
sudo sed -i 's/#[testing]/[testing]' /etc/pacman.conf
sudo sed -i 's/#[community-testing]/[community-testing]' /etc/pacman.conf
sudo sed -i 's/#[multilib-testing]/[multilib-testing]' /etc/pacman.conf
sudo sed -i 's/#[multilib]/[multilib]' /etc/pacman.conf
sudo sed -i 's~#Include = /etc/pacman.d/mirrorlist~Include = /etc/pacman.d/mirrorlist' /etc/pacman.conf
sudo pacman -Syyu

#Configure makepkg
sudo sed -i 's/CFLAGS="-march=generic -O2 -pipe -fstack-protector-strong --param=ssp-buffer-size=4"/CFLAGS="-march=native -mtune=native -O3 -pipe -fstack-protector-strong --param=ssp-buffer-size=4"' /etc/makepkg.conf
sudo sed -i 's/CXXFLAGS="-march=generic -O2 -pipe -fstack-protector-strong --param=ssp-buffer-size=4"/CXXFLAGS="${CFLAGS}"' /etc/makepkg.conf
#TODO: Change packager name here
sudo sed -i 's/COMPRESSXZ="(xz -c -z -)/(xz -T 0 -c -z -)"' /etc/makepkg.conf

#Install and configure yaourt
cd /tmp
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query-git.tar.gz
tar -xzvf package-query-git.tar.gz
cd package-query-git
makepkg -s
sudo pacman -U package-query-git-*.tar.xz
cd ..
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt-git.tar.gz
tar =xzvf yaourt-git.tar.gz
cd yaourt-git
makepkg -s
sudo pacman -U yaourt-git-*.tar.xz
cd ~

#Install and configure X-org
sudo pacman -S xorg-server xorg xorg-xinit
cp /etc/X11/xinit/xinitrc ~/.xinitrc
echo "Remove the last five lines and add 'exec cinnamon-session'"
sleep 5
nano ~/.xinitrc #TODO automate this
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' > ~/.bash_profile
echo "Do you need NVIDIA drivers?" #Add support for older cards, bumblebee and AMD cards
select yn in "Yes" "No"; do
	case $yn in
		Yes ) sudo pacman -S nvidia-utils opencl-nvidia lib32-nvidia-libgl lib32-mesa-vdpau nvidia; break;;
		No ) break;;
	esac
done

#Infinality
echo "Do you want infinality? (Makes fonts look glorious)"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) 
			sudo echo "[infinality-bundle]" >> /etc/pacman.conf;
			sudo echo "Server = http://bohoomil.com/repo/$arch" >> /etc/pacman.conf;
			sudo echo "[infinality-bundle-multilib]" >> /etc/pacman.conf;
			sudo echo "Server = http://bohoomil.com/repo/multilib/$arch" >> /etc/pacman.conf;
			sudo echo "[infinality-bundle-fonts]" >> /etc/pacman.conf;
			sudo echo "Server = http://bohoomil.com/repo/fonts" >> /etc/pacman.conf;
			sudo dirmngr;
			sudo pacman-key -r 962DDE58;
			sudo pacman-key -f 962DDE58;
			sudo pacman-key --lsign-key 962DDE58;
			sudo pacman -Syyu;
			sudo pacman -S infinality-bundle-multilib infinality-bundle ibfonts-meta-base;
			break;;
                No ) break;;
        esac
done

#Cinnamon
sudo pacman -S cinnamon nemo-fileroller nemo-preview networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc
sudo systemctl enable NetworkManager.service
sudo systemctl enable NetworkManager-dispatcher.service

#Frameworks
sudo pacman -S gcc-multilib jdk7-openjdk jdk8-openjdk jre7-openjdk jre7-openjdk-headless jre8-openjdk jre8-openjdk-headless python python-pip python2-virtualenv
sudo archlinux-java set java-8-openjdk

#TODO Finish the rest and actually test this jazz
