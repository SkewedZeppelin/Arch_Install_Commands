#Arch Post Installation Commands


##Bootloader Tweaks
###Grub
1. Add "resume=[SWAP PARTITION]" to 'GRUB_CMDLINE_LINUX_DEFAULT'
```shell
nano /etc/default/grub #1
grub-mkconfig -o /boot/grub/grub.cfg
```
###Gummiboot
Add "resume=[SWAP PARTITION]" to 'options'
```shell
nano /boot/loader/entries/arch.conf
```


##Account Creation
1. Add yourself after root
```shell
useradd -m -G wheel -s /bin/bash [USERNAME]
usermod -aG audio,games,rfkill,users,uucp,video,wheel [USERNAME]
chfn [USERNAME]
EDITOR=nano visudo
passwd [USERNAME] #1
logout
```


##Configure pacman and makepkg
1. Uncomment out all default repos
2. Change 'CFLAGS' to "-march=native -mtune=native -O3 -pipe -fstack-protector-strong --param=ssp-buffer-size=4"
3. Change 'CXXFLAGS' to "${CFLAGS}"
4. Change 'MAKEFLAGS' to "-j[AMOUNT OF CORES]"
5. Change 'PACKAGER' to your name/email
6. Change 'COMPRESSXZ' to "(xz -T 0 -c -z -)"
```shell
sudo nano /etc/pacman.conf #1
sudo nano /etc/makepkg.conf #2-6
sudo pacman -Syyu wget
```


##Install and Configure yaourt
1. Change 'AURURL' to "https://aur4.archlinux.org" after you finish this guide
2. Change 'EXPORT' to "2"
```shell
wget https://aur.archlinux.org/packages/pa/package-query-git/package-query-git.tar.gz
tar -xzvf package-query-git.tar.gz
cd package-query-git
makepkg -s
sudo pacman -U package-query-git-1.5.9.g4692c67-1-x86_64.pkg.tar.xz
cd ..
rm -rf package-query-git*
wget https://aur.archlinux.org/packages/ya/yaourt-git/yaourt-git.tar.gz
tar -xzvf yaourt-git.tar.gz
cd yaourt
makepkg -s
sudo pacman -U yaourt-git-1.5-1-any.pkg.tar.xz
cd ..
rm -rf yaourt*
yaourt
sudo nano /etc/yaourtrc #1-2
```


##Install and Configure Packages
###X-Org
1. Remove the last five lines and add "exec cinnamon-session"
```shell
sudo pacman -S xorg-server xorg xorg-xinit
cp /etc/X11/xinit/xinitrc ~/.xinitrc
nano ~/.xinitrc #1
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' > ~/.bash_profile
```
####Nvidia Drivers
1. Add "nvidia" to 'HOOKS'
```shell
yaourt -S nvidia-dkms nvidia-hook
sudo pacman -S nvidia-utils opencl-nvidia lib32-nvidia-libgl lib32-mesa-vdpau
sudo nano /etc/mkinitcpio.conf #1
sudo mkinitcpio -p linux
nvidia-xconfig
```
####AMD Drivers
[To Be Added]
###Fonts
```shell
sudo pacman -S ttf-anonymous-pro ttf-dejavu ttf-droid ttf-liberation ttf-tahoma ttf-ubuntu-font-family
```
###Cinnamon
```shell
sudo pacman -S cinnamon nemo-fileroller nemo-preview networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc
yaourt -S networkmanager-l2tp
sudo systemctl enable NetworkManager.service
sudo systemctl enable NetworkManager-dispatcher.service
```
###Frameworks
```shell
sudo pacman -S gcc-multilib jdk7-openjdk jdk8-openjdk jre7-openjdk jre7-openjdk-headless jre8-openjdk jre8-openjdk-headless python python-pip python2-virtualenv
sudo archlinux-java set java-8-openjdk
```
###Basics
```shell
sudo pacman -S --needed abs audacity bleachbit calibre cdrkit cheese chromium cpupower eog evince evolution expac gedit gimp git gksu gnome-calculator gnome-calendar gnome-disk-utility gnome-keyring gnome-screenshot gnome-sound-recorder gnome-system-log gnome-system-monitor gst-libav gst-plugins-bad gst-plugins-base gst-plugins-good gst-plugins-ugly hdparm hexchat htop keepass libreoffice-fresh lib32-alsa-plugins linux-headers mumble ntfs-3g openssh parted pigz pulseaudio-alsa pulseaudio-equalizer pulseaudio-gconf redshift rhythmbox seahorse syncthing-gtk totem transmission-gtk unrar wine wine-mono wine_gecko winetricks wget xfce4-terminal yubikey-neo-manager yubikey-personalization-gui zip zsh
yaourt -S alsi chromium-pepper-flash downgrade filebot nano-syntax-highlighting-git notepadqq-git obs-studio-git oh-my-zsh-git pithos-git raccoon
sudo pip install doge speedtest-cli
cp /usr/share/oh-my-zsh/zshrc ~/.zshrc
chsh -s $(which zsh)
```
###Development
```shell
sudo pacman -S android-tools apache-ant bc ccache eclipse eclipse-cdt intellij-idea-community-edition lib32-readline perl-switch proguard schedtool squashfs-tools
yaourt -S android-apk-tool android-sdk android-sdk-build-tools android-sdk-platform-tools android-studio arduino dex2jar jd-gui launch4j libtinfo repo
```
###Gaming
```shell
sudo pacman -S steam
yaourt -S amidst desura feedthebeast mcedit minecraft minecraft-technic-launcher multimc5-git
```
###L33t Hax0ring
```shell
sudo pacman -S nmap wireshark-cli wireshark-gtk
```
###Remote
```shell
sudo pacman -S filezilla remmina freerdp libvncserver nxproxy xorg-server-xephyr
```
###Security
```shell
sudo pacman -S clamav haveged
yaourt -S clamtk pgl
sudo echo 'SafeBrowsing Yes' > /etc/clamav/freshclam.conf
sudo systemctl enable freshclamd.service
sudo systemctl enable haveged.service
sudo systemctl enable pgl.service
```
###Theming
```shell
sudo pacman -S conky numix-themes
yaourt -S numix-icon-theme-git numix-circle-icon-theme-git
```
###Network Tweaks
1. Uncomment "listen-address=127.0.0.1"
2. Change 'dns' to "dnsmasq"
3. Add the following
```
net.ipv4.neigh.default.gc_thresh1=256
net.ipv4.neigh.default.gc_thresh2=2048
net.ipv4.neigh.default.gc_thresh3=2048
net.ipv4.tcp_ecn=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_dsack=1
net.netfilter.nf_conntrack_max=1048576
```
```shell
sudo pacman -S dnsmasq
sudo systemctl enable dnsmasq.service
sudo nano /etc/dnsmasq.conf #1
sudo nano /etc/NetworkManager/NetworkManager.conf #2
sudo nano /etc/sysctl.d/99-sysctl.conf #3
```
###Virtualization
1. Add the following
```
polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" &&
        subject.isInGroup("kvm")) {
            return polkit.Result.YES;
    }
});
```
```shell
sudo pacman -S ebtables libvirt openbsd-netcat qemu virt-manager
sudo systemctl enable libvirtd.service
sudo nano /etc/polkit-1/rules.d/49-org.libvirt.unix.manager.rules #1
```


##Tweaks
###Kernel
1. Add "lz4 lz4_compress kvm kvm_intel virtio-net virtio-blk virtio-scsi virtio-balloon" to 'MODULES'
2. Add "shutdown resume" to 'HOOKS'
```shell
nano /etc/mkinitcpio.conf #1-2
sudo mkinitcpio -p linux
```
###Misc Tweaks
####Disable mouse acceleration
1. Add the following
```
Section "InputClass"
	Identifier "My Mouse"
	MatchIsPointer "yes"
	Option "AccelerationProfile" "-1"
	Option "AccelerationScheme" "none"
	Option "AccelSpeed" "-1"
EndSection
```
```shell
sudo nano /etc/X11/xorg.conf.d/50-mouse-acceleration.conf #1
```
####ClamAV Scan in nemo
1. Add the following
```
[Nemo Action]
Name=Clam Scan
Comment=Clam Scan
Exec=gnome-terminal -x sh -c "clamscan -r %F | less"
Icon-Name=bug-buddy
Selection=Any
Extensions=dir;exe;dll;zip;gz;7z;rar;
```
```shell
nano $HOME/.local/share/nemo/actions/clamscan.nemo_action #1
```
####YubiKey udev Rules
1. Add the following
```
ACTION!="add|change", GOTO="u2f_end"
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"
LABEL="u2f_end"
```
```shell
sudo nano /etc/udev/rules.d/70-u2f.rules #1
```


##Finishing up
```shell
sudo reboot now
```

##Things to be added
- Plex Server, Sickrage, ZSH, and some forgotten stuff
