#Kernel Tweaks
sudo nano /etc/mkinitcpio.conf
sudo mkinitcpio -p linux


#Account Creation
useradd -m -G wheel -s /bin/bash spotcomms
usermod -aG games,rfkill,users,uucp,wheel spotcomms
chfn spotcomms
passwd spotcomms
EDITOR=nano visudo


#Yaourt Installation
wget https://aur.archlinux.org/packages/pa/package-query-git/package-query-git.tar.gz
tar -xzvf package-query-git.tar.gz 
cd package-query-git
makepkg -s
sudo pacman -U package-query-git-1.5.9.g4692c67-1-x86_64.pkg.tar.xz 
cd ..
rm -rf package-query-git*
wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
tar -xzvf yaourt.tar.gz 
cd yaourt
makepkg -s
sudo pacman -U yaourt-1.5-1-any.pkg.tar.xz 
cd ..
rm -rf yaourt*


#Needed Packages
sudo pacman -Syyuu
sudo pacman -S xorg-server xorg nvidia nvidia-utils nvidia-settings opencl-nvidia lib32-nvidia-libgl xorg-xinit lib32-mesa-vdpau cinnamon networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc wget git python python-pip audacity bleachbit cheese cpupower eclipse eog evince filezilla freerdp gcc-multilib gedit hdparm hexchat intellij-idea-community-edition jdk8-openjdk jre8-openjdk jre8-openjdk-headless jdk7-openjdk jre7-openjdk jre7-openjdk-headless keepass lib32-alsa-plugins libreoffice-fresh mesa-demos mumble parted remmina rhythmbox steam transmission-gtk ttf-dejavu ttf-liberation vlc wireshark-cli wireshark-gtk numix-themes chromium ttf-ubuntu-font-family htop xfce4-terminal proguard android-tools gnome-disk-utility schedtool lib32-readline gperf squashfs-tools perl-switch zip python2-virtualenv gnome-system-monitor gnome-keyring gnome-system-log gnome-screenshot gnome-calculator gnome-sound-recorder gnome-calendar evolution empathy telepathy-gabble telepathy-idle telepathy-salut telepathy-rakia seahorse totem zsh zsh-completion gtkmm linux-headers qemu gnome-boxes bc clamav gimp nemo-fileroller nemo-preview nemo-seahorse
sudo pip install doge speedtest-cli
yauort -S alsi archey scrot numix-circle-icon-theme-git networkmanager-l2tp obs-studio-git plex-media-server-plexpass filebot arduino android-studio android-sdk-platform-tools android-sdk-build-tools launch4j android-sdk chromium-pepper-flash repo libtinfo minecraft clamtk pithos-git


#X-Org Configuration
sudo cp /etc/X11/xinit/xinitrc ~/.xinitrc
sudo chown spotcomms .xinitrc 
nano ~/.xinitrc
sudo nvidia-xconfig


#Services
sudo systemctl enable NetworkManager.service
sudo systemctl enable NetworkManager-dispatcher.service
systemctl enable plexmediaserver.service
systemctl start plexmediaserver.service


#ZSH Configuration
zsh
chsh -s $(which zsh)


#Network Tweaks for Games
sudo sysctl net.ipv4.tcp_ecn=1
sudo sysctl net.ipv4.tcp_sack=1 
sudo sysctl net.ipv4.tcp_dsack=1
sudo ip link set enp6s0 qlen 50