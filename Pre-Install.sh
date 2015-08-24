#Intro
echo "Welcome to the Spot Communication's Arch Linux installer and configurator"
echo "This is the pre-install script meant to be run from a live media"
echo "This script has yet to be throughly tested, stuff might go very, very wrong"
echo "Ctrl+C within 10 seconds if you do not want to end up troubleshooting your system or have to attempt to recover lost files"
sleep 10

#Connect to the network
echo "START OF NETWORK CONFIG"
echo "Do you plan on using Wi-Fi for this install? Answering no will auto connect on all ethernet interfaces"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) wifi-menu; break;;
        No ) systemctl start dhcpcd.service; break;;
    esac
done
echo "END OF NETWORK CONFIG"
sleep 3

#Partition the drive
echo "START OF PARTITIONING"
lsblk
echo "What drive do you want to install Arch onto? (/dev/sdX)"
read strInstallDrive
echo "Where do you want your /boot partition to end? (Recommend Size: 1GiB)"
read strPartitionSizeBoot
echo "Where do you want your / partition to end? (Recommend Size: 32GiB)"
read strPartitionSizeSystem
echo "Where do you want your swap partition to end? (Recommend Size: Amount of RAM installed)"
read strPartitionSizeSwap
echo "Where do you want your /home partition to end? (Recommend Size: 100%)"
read strPartitionSizeHome
echo "Do you have a (U)EFI system or a plain BIOS system?"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) blEFI=true; break;;
		No ) blEFI=false; break;;
	esac
done
parted ${strInstallDrive} rm 1
parted ${strInstallDrive} rm 2
parted ${strInstallDrive} rm 3
parted ${strInstallDrive} rm 4
parted ${strInstallDrive} rm 5
parted ${strInstallDrive} rm 6
if [ ${blEFI} == true ]
	then
		parted ${strInstallDrive} mklabel gpt
		parted ${strInstallDrive} mkpart primary fat32 1MiB ${strPartitionSizeBoot}
	else
		parted ${strInstallDrive} mklabel msdos
		parted ${strInstallDrive} mkpart primary ext4 1MiB ${strPartitionSizeBoot}
fi
parted ${strInstallDrive} set 1 boot on
parted ${strInstallDrive} mkpart primary ext4 ${strPartitionSizeBoot} ${strPartitionSizeSystem}
parted ${strInstallDrive} mkpart primary linux-swap ${strPartitionSizeSystem} ${strPartitionSizeSwap}
parted ${strInstallDrive} mkpart primary ext4 ${strPartitionSizeSwap} ${strPartitionSizeHome}
echo "END OF PARTITIONING"
sleep 3

#Format the partitions
echo "START OF FORMATTING"
if [ ${blEFI} == true ]
	then
		mkfs.vfat -F32 ${strInstallDrive}1
	else
		mkfs.ext4 {$strInstallDrive}1
fi
mkfs.ext4 ${strInstallDrive}2
mkswap ${strInstallDrive}3
swapon ${strInstallDrive}3
mkfs.ext4 ${strInstallDrive}4
sync

#Mount the partitions
mount ${strInstallDrive}2 /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount ${strInstallDrive}1 /mnt/boot
mount ${strInstallDrive}4 /mnt/home
echo "END OF FORMATTING"
sleep 3

#Install the base system
echo "INSTALLING THE BASE SYSTEM"
pacstrap -i /mnt base base-devel wget iw wpa_supplicant
sleep 3

#Generate an fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

#Set locale
echo "START OF SETTING LOCALE"
echo "What language would you like to use? (en_US.UTF-8)"
read strLanguage
arch-chroot /mnt /bin/bash -c "sed -i 's/#${strLanguage}/${strLanguage}/' /etc/locale.gen"
arch-chroot /mnt locale-gen
arch-chroot /mnt /bin/bash -c "echo LANG=${strLanguage} > /etc/locale.conf"
echo "END OF SETTING LOCALE"
sleep 3

#Set timezone
echo "START OF SETTING TIMEZONE"
echo "What timezone are you in? (America/New_York)"
read strTimezone
arch-chroot /mnt /bin/bash -c "ln -s /usr/share/zoneinfo/${strTimezone} /etc/localtime"
arch-chroot /mnt hwclock --systohc --utc
echo "END OF SETTING TIMEZONE"
sleep 3

#Set hostname
echo "START OF SETTING HOSTNAME"
echo "What would you like your hostname to be?"
read strHostname
arch-chroot /mnt /bin/bash -c "echo ${strHostname} > /etc/hostname"
arch-chroot /mnt /bin/bash -c "sed -i 's/localhost /localhost $strHostname/' /etc/hosts"
echo "END OF SETTING HOSTNAME"
sleep 3

#Install the bootloader
echo "START OF BOOTLOADER INSTALLATION"
if [ ${blEFI} == true ]
        then
		arch-chroot /mnt pacman -S dosfstools
		arch-chroot /mnt bootctl --path=/boot install
		arch-chroot /mnt /bin/bash -c 'echo "title Arch Linux" >> /boot/loader/entries/arch.conf\'
		arch-chroot /mnt /bin/bash -c 'echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf\'
		arch-chroot /mnt /bin/bash -c 'echo "initrc /initramfs-linux.img" >> /boot/loader/entries/arch.conf\'
		arch-chroot /mnt /bin/bash -c $'echo "options root=${strInstallDrive}1 rw resume=${strInstallDrive}3" >> /boot/loader/entries/arch.conf\'
		arch-chroot /mnt /bin/bash -c 'echo "timeout 0" > /boot/loader/loader.conf\' #There is only 1 > because the file is created on install, and were overwriting it
		arch-chroot /mnt /bin/bash -c 'echo "default arch" >> /boot/loader/loader.conf\'
        else
		arch-chroot /mnt pacman -S grub os-prober
		arch-chroot /mnt grub-install --target=i386-pc --recheck ${strInstallDrive}
		arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi
echo "END OF BOOTLOADER INSTALLATION"
sleep 3

#Set root password
echo "SETTING ROOT PASSWORD"
echo "Please set a password for the root account"
arch-chroot /mnt passwd
sleep 3

#Create a user account
echo "START OF USER ACCOUNT CREATION"
echo "What would you like your username to be? Must be all lowercase (obamallama)"
read strUsername
arch-chroot /mnt useradd -m -G wheel -s /bin/bash ${strUsername}
arch-chroot /mnt usermod -aG audio,games,rfkill,users,uucp,video,wheel ${strUsername}
arch-chroot /mnt chfn ${strUsername}
echo "Please add your username to the sudoers file after root ALL ALL ALL"
sleep 5
arch-chroot /mnt /bin/bash -c "EDITOR=nano visudo"
echo "Please set a password for your account"
arch-chroot /mnt passwd ${strUsername}
echo "END OF USER ACCOUNT CREATION"
sleep 3

#Post-Install Script
echo "INSTALLING POST INSTALL SCRIPT"
wget https://raw.githubusercontent.com/SpotComms/Arch_Install_Commands/master/Post-Install.sh
cp Post-Install.sh /mnt/home/${strUsername}/
echo "INSTALLED POST INSTALL SCRIPT"
sleep 3

#Finish up
echo "FINISHING UP"
umount -R /mnt
echo "After reboot please login and run 'sh Post-Install.sh'"
sleep 10
reboot now
