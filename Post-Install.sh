#Intro
echo "Welcome to the Spot Communication's Arch Linux installer and configurator"
echo "This is the post-install script meant to be run after doing a base install"
echo "This script has yet to be tested, stuff might go very, very wrong"
echo "Ctrl+C within 10 seconds if you do not want to end up troubleshooting your system or have to attempt to recover lost files"
sleep 10

#Connect to the network
echo "START OF NETWORK CONFIG"
echo "Do you plan on using Wi-Fi for this install? Answering no will auto connect on all ethernet interfaces"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo wifi-menu; break;;
        No ) sudo systemctl start dhcpcd.service; break;;
    esac
done
echo "END OF NETWORK CONFIG"
sleep 3

#Configure pacman
echo "START OF PACMAN CONFIGURATION"
sudo sed -i 's/#\[testing\]/\[testing\]/' /etc/pacman.conf
sudo sed -i 's/#\[community-testing\]/\[community-testing\]/' /etc/pacman.conf
sudo sed -i 's/#\[multilib-testing\]/\[multilib-testing\]/' /etc/pacman.conf
sudo sed -i 's/#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sudo sed -i 's/#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
sudo pacman -Syyu
echo "END OF PACMAN CONFIGURATION"
sleep 3

#Configure makepkg
echo "START OF MAKEPKG CONFIGURATION"
sudo sed -i 's/CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fstack-check"/CFLAGS="-march=native -mtune=native -O3 -pipe -fstack-protector-strong -fstack-check --param=ssp-buffer-size=4"/' /etc/makepkg.conf
sudo sed -i 's/CXXFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fstack-check"/CXXFLAGS="${CFLAGS}"/' /etc/makepkg.conf
echo "How many threads do you have?"
read strAmtThreads
sudo sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j${strAmtThreads}\"/" /etc/makepkg.conf
#TODO: Change packager name here
sudo sed -i 's/(xz -c -z -)/(xz -T 0 -c -z -)/' /etc/makepkg.conf
echo "END OF MAKEPKG CONFIGURATION"
sleep 3

#Install and configure yaourt
echo "START OF YAOURT INSTALLATION"
cd /tmp
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query-git.tar.gz
tar -xzvf package-query-git.tar.gz
cd package-query-git
makepkg -s
sudo pacman -U package-query-git-*.tar.xz
cd ..
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt-git.tar.gz
tar -xzvf yaourt-git.tar.gz
cd yaourt-git
makepkg -s
sudo pacman -U yaourt-git-*.tar.xz
cd ~
echo "END OF YAOURT INSTALLATION"
sleep 3

#Install and configure X-org
echo "START OF X-ORG INSTALLATION"
sudo pacman -S xorg-server xorg xorg-xinit libvdpau-va-gl libvdpau lib32-libvdpau lib32-mesa-vdpau libva-vdpau-driver mesa-vdpau libva-intel-driver
wget https://raw.githubusercontent.com/SpotComms/Arch_Install_Commands/master/home/.xinitrc
wget https://raw.githubusercontent.com/SpotComms/Arch_Install_Commands/master/home/.Xresources
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' > ~/.bash_profile
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' > ~/.zprofile
sudo /bin/bash -c $'echo \'Section "InputClass"\' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf'
sudo /bin/bash -c $'echo \'	Identifier "My Mouse"\' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf'
sudo /bin/bash -c $'echo \'	MatchIsPointer "yes"\' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf'
sudo /bin/bash -c $'echo \'	Option "AccelerationProfile" "-1"\' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf'
sudo /bin/bash -c $'echo \'	Option "AccelerationScheme" "none"\' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf'
sudo /bin/bash -c $'echo \'	Option "AccelSpeed" "-1"\' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf'
sudo /bin/bash -c $'echo \'EndSection\' >> /etc/X11/xorg.conf.d/50-mouse-acceleration.conf'
echo "Do you need NVIDIA Optimus drivers? (Bumblebee)" 
select yn in "Yes" "No"; do
        case $yn in
                Yes ) 
			sudo pacman -S bumblebeed primus lib32-primus virtualgl lib32-virtualgl bbswitch mesa lib32-mesa mesa-libgl lib32-mesa-libgl mesa-vdpau lib32-mesa-vdpau xf86-video-intel xf86-video-nv lib32-nvidia-utils nvidia-utils lib32-opencl-nvidia opencl-nvidia nvidia;
			sudo systemctl enable bumblebeed.service;
			sudo gpasswd -a $USER bumblebee;
			sudo sed -i 's/MODULES="/MODULES="i915 bbswitch /' /etc/mkinitcpio.conf;
			sudo mkinitcpio -p linux;
			break;;
                No ) break;;
        esac
done
echo "Do you need NVIDIA drivers?"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) sudo pacman -S nvidia-utils opencl-nvidia lib32-nvidia-libgl lib32-mesa-vdpau nvidia; break;;
		No ) break;;
	esac
done
#TODO Add support for older NVIDIA cards, AMD cards and AMD cards with Intel (PRIME)
echo "END OF X-ORG CONFIGURATION"
sleep 3

#Infinality
echo "START OF INFINALITY INSTALLATION"
echo "Do you want Infinality? (Makes fonts look glorious)"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) 
			sudo /bin/bash -c $'echo "[infinality-bundle]" >> /etc/pacman.conf';
			sudo /bin/bash -c $'echo "Server = http://bohoomil.com/repo/$arch" >> /etc/pacman.conf';
			sudo /bin/bash -c $'echo "[infinality-bundle-multilib]" >> /etc/pacman.conf';
			sudo /bin/bash -c $'echo "Server = http://bohoomil.com/repo/multilib/$arch" >> /etc/pacman.conf';
			sudo /bin/bash -c $'echo "[infinality-bundle-fonts]" >> /etc/pacman.conf';
			sudo /bin/bash -c $'echo "Server = http://bohoomil.com/repo/fonts" >> /etc/pacman.conf' ;
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
echo "END OF INFINALITY INSTALLATION"
sleep 3

#Cinnamon
echo "START OF CINNAMON INSTALLATION"
sudo pacman -S cinnamon nemo-fileroller nemo-preview networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc
sudo systemctl enable NetworkManager.service
sudo systemctl enable NetworkManager-dispatcher.service
echo "END OF CINNAMON INSTALLATION"
sleep 3

#Frameworks
echo "START OF FRAMEWORKS INSTALLATION"
sudo pacman -S gcc-multilib jdk7-openjdk jdk8-openjdk jre7-openjdk jre7-openjdk-headless jre8-openjdk jre8-openjdk-headless python python-pip python2-virtualenv
sudo archlinux-java set java-8-openjdk
echo "END OF FRAMEWORKS INSTALLATION"
sleep 3

#Applications
echo "START OF APPLICATIONS INSTALLATION"
echo "Do you want applications from the basics group??"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
			sudo pacman -S --needed bleachbit calibre cdrkit cheese chromium cpupower eog evince evolution expac gedit gimp git gksu gnome-calculator gnome-calendar gnome-disk-utility gnome-keyring gnome-screenshot gnome-so
und-recorder gnome-system-log gnome-system-monitor gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly hdparm hexchat htop keepass libreoffice-fresh lib32-alsa-plugins linux-headers mumb
le ntfs-3g openssh parted pigz pulseaudio-alsa pulseaudio-equalizer pulseaudio-gconf redshift rhythmbox seahorse syncthing-gtk totem transmission-gtk unrar wine wine-mono wine_gecko winetricks wget xfce4-termina
l yubikey-neo-manager yubikey-personalization-gui zip zsh acpi acpi_call ethtool smartmontools linux-tools intel-ucode gparted btrfs-progs dosfstools e2fsprogs exfat-utils f2fs-tools jfsutils ntfs-3g reiserfsprogs xfsprogs mtools gpart nilfs-utils pigz pixz lbzip2 gdmap bind-tools simplescreenrecorder lib32-simplescreenrecorder gperf lm_sensors;
			yaourt -S alsi chromium-pepper-flash downgrade filebot nano-syntax-highlighting-git notepadqq-git obs-studio-git oh-my-zsh-git pithos-git android-udev-git;
			sudo pip install doge speedtest-cli;
			wget https://raw.githubusercontent.com/SpotComms/Arch_Install_Commands/master/home/.zshrc;
			chsh -s $(which zsh)
			sudo /bin/bash -c $'echo \'ACTION!="add|change", GOTO="u2f_end"\' >> /etc/udev/rules.d/70-u2f.rules';
			sudo /bin/bash -c $'echo \'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"\' >> /etc/udev/rules.d/70-u2f.rules';
			sudo /bin/bash -c $'echo \'LABEL="u2f_end"\' >> /etc/udev/rules.d/70-u2f.rules';
			break;;
                No ) break;;
        esac
done
echo "Do you want applications from the development group?"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) 
			sudo pacman -S abs android-tools apache-ant bc ccache eclipse-java intellij-idea-community-edition lib32-readline perl-switch proguard schedtool squashfs-tools;
			yaourt -S android-apk-tool android-sdk android-sdk-build-tools android-sdk-platform-tools android-studio arduino dex2jar jd-gui launch4j libtinfo repo;
			break;;
                No ) break;;
        esac
done
echo "Do you want applications from the games group?"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) 
			sudo pacman -S steam;
			yaourt -S multimc5-git;
			break;;
                No ) break;;
        esac
done
echo "Do you want applications from the l33t hax0ring group?"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) sudo pacman -S nmap wireshark-cli wireshark-gtk; break;;
                No ) break;;
        esac
done
echo "Do you want applications from the remote access group?"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) sudo pacman -S filezilla remmina freerdp libvncserver nxproxy xorg-server-xephyr; break;;
                No ) break;;
        esac
done
echo "Do you want applications from the security group?"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) 
			sudo pacman -S clamav haveged;
			yaourt -S clamtk pgl;
			sudo /bin/bash -c $'echo \'SafeBrowsing Yes\' >> /etc/clamav/freshclam.conf';
			sudo systemctl enable haveged.service;
			sudo systemctl enable pgl.service;
			break;;
                No ) break;;
        esac
done
echo "Do you want applications from the theming group?"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
			sudo pacman -S numix-themes;
			yaourt -S numix-icon-theme-git numix-circle-icon-theme-git;
			break;;
                No ) break;;
        esac
done
echo "Do you want applications from the virtulization group?"
select yn in "Yes" "No"; do
        case $yn in
                Yes )
			sudo pacman -S ebtables libvirt openbsd-netcat qemu virt-manager;
			sudo systemctl enable libvirtd.service;
			sudo /bin/bash -c $'echo "polkit.addRule(function(action, subject) {" >> /etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules';
			sudo /bin/bash -c $'echo \'    if (action.id == "org.libvirt.unix.manage" &&\' >> /etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules';
			sudo /bin/bash -c $'echo \'        subject.isInGroup("kvm")) {\' >> /etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules';
			sudo /bin/bash -c $'echo \'            return polkit.Result.YES;\' >> /etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules;
			sudo /bin/bash -c $'echo \'    }\' >> /etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules;
			sudo /bin/bash -c $'echo \'});\' >> /etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules;
			sudo gpasswd -a $USER kvm;
			sudo sed -i 's/MODULES="/MODULES="kvm kvm_intel /' /etc/mkinitcpio.conf;#TODO AMD CPU SUPPORT
			break;;
                No ) break;;
        esac
done
echo "END OF APPLICATIONS INSTALLATION"
sleep 3

#Network Tweaks
echo "START OF NETWORK TWEAKS"
sudo pacman -S dnsmasq
sudo sed -i 's/listen-address=/listen-address=127.0.0.1' /etc/dnsmasq.conf
sudo sed -i 's/dns=default/dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf
sudo /bin/bash -c $'echo "net.ipv4.neigh.default.gc_thresh1=256" >> /etc/sysctl.d/99-sysctl.conf'
sudo /bin/bash -c $'echo "net.ipv4.neigh.default.gc_thresh2=2048" >> /etc/sysctl.d/99-sysctl.conf'
sudo /bin/bash -c $'echo "net.ipv4.neigh.default.gc_thresh3=2048" >> /etc/sysctl.d/99-sysctl.conf'
sudo /bin/bash -c $'echo "net.ipv4.tcp_ecn=1" >> /etc/sysctl.d/99-sysctl.conf'
sudo /bin/bash -c $'echo "net.ipv4.tcp_sack=1" >> /etc/sysctl.d/99-sysctl.conf'
sudo /bin/bash -c $'echo "net.ipv4.tcp_dsack=1" >> /etc/sysctl.d/99-sysctl.conf'
sudo /bin/bash -c $'echo "net.netfilter.nf_conntrack_max=1048576" >> /etc/sysctl.d/99-sysctl.conf'
echo "END OF NETWORK TWEAKS"
sleep 3

#Finish up
echo "FINISHING UP"
echo "After reboot please login and enjoy your system"
sleep 10
reboot now

#TODO Finish the rest and actually test this jazz