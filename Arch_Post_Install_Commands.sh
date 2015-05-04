#Kernel Tweaks
nano /etc/mkinitcpio.conf #Add "lz4 lz4_compress kvm kvm_intel" to modules and "shutdown resume" to hooks
mkinitcpio -p linux #Regenerate the kernel


#Bootloader tweaks
nano /etc/default/grub #Add "resume=[SWAP PARTITION]" to GRUB_CMDLINE_LINUX_DEFAULT
grub-mkconfig -o /boot/grub/grub.cfg #Regenerate the GRUB config


#Account Creation
useradd -m -G wheel -s /bin/bash [USERNAME] #Create a new account
usermod -aG games,rfkill, users,uucp,wheel [USERNAME] #Add the new account to some groups
chfn [USERNAME] #Set extra info for the new account
passwd [USERNAME] #Set the password for the new account
EDITOR=nano visudo #Go to the part where it says "root ALL=(ALL) ALL" and add "[USERNAME] ALL=(ALL) ALL" on the next line


#Login to the new account
logout


#Install Yaourt
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


#Install Needed Packages
sudo pacman -Syyu #Download the latest repos and upgrade the system
sudo pacman -S xorg-server xorg xorg-xinit #Install X-Org
sudo pacman -S nvidia nvidia-utils opencl-nvidia lib32-nvidia-libgl lib32-mesa-vdpau #Install Nvidia drivers
sudo reboot now #Reboot to load Nvidia drivers
sudo pacman -S ttf-dejavu ttf-liberation ttf-ubuntu-font-family #Install fonts
sudo pacman -S cinnamon nemo-fileroller nemo-preview nemo-seahorse networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc #Install Cinnamon
sudo systemctl enable NetworkManager.service #Enable the network manager [1/2]
sudo systemctl enable NetworkManager-dispatcher.service #Enable the network manager [2/2]
sudo pacman -S --needed android-tools audacity bc bleachbit cheese chromium clamav conky cpupower eclipse empathy eog evince evolution filezilla freerdp gcc-multilib gedit gimp git gksudo 
gnome-calculator gnome-calendar gnome-disk-utility gnome-keyring gnome-screenshot gnome-sound-recorder gnome-system-log gnome-system-monitor gtkmm hexchat htop 
intellij-idea-community-edition jdk7-openjdk jdk8-openjdk jre7-openjdk jre7-openjdk-headless jre8-openjdk jre8-openjdk-headless keepass lib32-alsa-plugins lib32-readline 
libreoffice-fresh linux-headers mumble numix-themes parted perl-switch proguard python python-pip python2-virtualenv remmina rhythmbox schedtool seahorse squashfs-tools steam telepathy-gabble telepathy-idle telepathy-rakia telepathy-salut totem transmission-gtk vlc wget wireshark-cli wireshark-gtk xfce4-terminal zip #Install official applications
sudo pip install doge speedtest-cli #Install python applications
sudo yaourt -S alsi android-sdk android-sdk-build-tools android-sdk-platform-tools android-studio archey arduino chromium-pepper-flash clamtk filebot launch4j libtinfo minecraft 
networkmanager-l2tp numix-circle-icon-theme-git obs-studio-git repo #Install AUR applications
sudo yaourt -S plex-media-server-plexpass #Install Plex
sudo systemctl enable plexmediaserver.service #Enable Plex


#Configure X-Org
sudo cp /etc/X11/xinit/xinitrc ~/.xinitrc
sudo chown [USERNAME] .xinitrc
nano ~/.xinitrc #Remove the last five lines and add "exec cinnamon-session"
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' > ~/.bash_profile #Start X-Org on login


#Network Tweaks for Games
sudo sysctl net.ipv4.tcp_ecn=1
sudo sysctl net.ipv4.tcp_sack=1 
sudo sysctl net.ipv4.tcp_dsack=1
sudo ip link set enp6s0 qlen 50


#Misc
# - Add conky to startup applications in Cinnamon 
# - Disable mouse acceleration: https://wiki.archlinux.org/index.php/Mouse_acceleration#Disabling_mouse_acceleration
echo 'alias speedtest='speedtest-cli --share --server 2137'' > .bash_profile #Add an alias for the best local Speedtest server
sudo reboot now #Reboot the system