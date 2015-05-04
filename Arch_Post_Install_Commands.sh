#Kernel Tweaks
sudo nano /etc/mkinitcpio.conf #Add "lz4 lz4_compress kvm kvm_intel" to modules and "shutdown resume" to hooks
sudo mkinitcpio -p linux #Regenerate the kernel


#Account Creation
useradd -m -G wheel -s /bin/bash [USERNAME]
usermod -aG games,rfkill, users,uucp,wheel [USERNAME]
chfn [USERNAME]
passwd [USERNAME]
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
sudo pacman -Syyu
sudo pacman -S xorg-server xorg xorg-xinit
sudo pacman -S nvidia nvidia-utils opencl-nvidia lib32-nvidia-libgl lib32-mesa-vdpau #Install Nvidia drivers
sudo reboot now #Reboot to load Nvidia drivers
sudo pacman -S ttf-dejavu ttf-liberation ttf-ubuntu-font-family #Install fonts
sudo pacman -S cinnamon nemo-fileroller nemo-preview nemo-seahorse networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc #Install 
Cinnamon
sudo systemctl enable NetworkManager.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo pacman -S android-tools audacity bc bleachbit cheese chromium clamav conky cpupower eclipse empathy eog evince evolution filezilla freerdp gcc-multilib gedit gimp git gksudo 
gnome-calculator gnome-calendar gnome-disk-utility gnome-keyring gnome-screenshot gnome-sound-recorder gnome-system-log gnome-system-monitor gtkmm hexchat htop 
intellij-idea-community-edition jdk7-openjdk jdk8-openjdk jre7-openjdk jre7-openjdk-headless jre8-openjdk jre8-openjdk-headless keepass lib32-alsa-plugins lib32-readline 
libreoffice-fresh linux-headers mumble numix-themes parted perl-switch proguard python python-pip python2-virtualenv remmina 
rhythmbox schedtool seahorse squashfs-tools steam telepathy-gabble telepathy-idle telepathy-rakia telepathy-salut totem transmission-gtk vlc wget wireshark-cli wireshark-gtk 
xfce4-terminal zip #Install applications
sudo pip install doge speedtest-cli
sudo yaourt -S alsi android-sdk android-sdk-build-tools android-sdk-platform-tools android-studio archey arduino chromium-pepper-flash clamtk filebot launch4j libtinfo minecraft 
networkmanager-l2tp numix-circle-icon-theme-git obs-studio-git repo
sudo yaourt -S plex-media-server-plexpass
sudo systemctl enable plexmediaserver.service
sudo systemctl start plexmediaserver.service


#Configure X-Org
sudo cp /etc/X11/xinit/xinitrc ~/.xinitrc
sudo chown [USERNAME] .xinitrc
nano ~/.xinitrc #Remove the last five lines and add "exec cinnamon-session"


#Network Tweaks for Games
sudo sysctl net.ipv4.tcp_ecn=1
sudo sysctl net.ipv4.tcp_sack=1 
sudo sysctl net.ipv4.tcp_dsack=1
sudo ip link set enp6s0 qlen 50


#Misc Tweaks
# - Add conky to startup applications in Cinnamon 
# - Disable mouse acceleration: https://wiki.archlinux.org/index.php/Mouse_acceleration#Disabling_mouse_acceleration