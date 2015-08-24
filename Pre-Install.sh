#Intro
echo "Welcome to the Spot Communication's Arch Linux installer and configurator"
echo "This is the pre-install script meant to be run from a live media"
echo "This script has yet to be tested, stuff might go very, very wrong"
echo "Ctrl+C within 10 seconds if you do not want to end up troubleshooting your system or have to attempt to recover lost files"
sleep 10

#Connect to the network
echo "Do you plan on using Wi-Fi for this install? Answering no will auto connect on all ethernet interfaces"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) wifi-menu; break;;
        No ) systemctl start dhcpcd.service; break;;
    esac
done

#Partition the drive
lsblk
echo "What drive do you want to install Arch onto? (/dev/sdX)"
read strInstallDrive
echo "Where do you want your /boot partition to end? (Recommend Size: 1GB)"
read strPartitionSizeBoot
echo "Where do you want your / partition to end? (Recommend Size: 32GB)"
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
if [ ${blEFI} == true ]
	then
		parted ${strInstallDrive} mkpart primary fat32 1MiB ${strPartitionSizeBoot}
	else
		parted ${strInstallDrive} mkpart primary fat32 1MiB ${strPartitionSizeBoot}
fi
parted ${strInstallDrive} set 1 boot on
parted ${strInstallDrive} mkpart primary ext4 ${strPartitionSizeBoot} ${strPartitionSizeSystem}
parted ${strInstallDrive} mkpart primary linux-swap ${strPartitionSizeSystem} ${strPartitionSizeSwap}
parted ${strInstallDrive} mkpart primary ext4 ${strPartitionSizeSwap} ${strPartitionSizeHome}

#Format the partitions
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

#Mount the partitions
mount ${strInstallDrive}2 /mnt
mkdir -p /mnt/boot
mkdir -p /mnt/home
mount ${strInstallDrive}1 /mnt/boot
mount ${strInstallDrive}4 /mnt/home

#Install the base system
pacstrap -i /mnt base base-devel wget iw wpa_supplicant

#Generate an fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

#Set locale
echo "What language would you like to use? (en_US.UTF-8)"
read strLanguage
arch-chroot /mnt sed -i 's/#${strLanguage}/${strLanguage}/' /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo LANG=${strLanguage} > /etc/locale.conf
arch-chroot /mnt export LANG=${strLanguage}

#Set timezone
echo "What timezone are you in? (America/New_York)"
read strTimezone
arch-chroot /mnt ln -s /usr/share/zoneinfo/${strTimezone} /etc/localtime
arch-chroot /mnt hwclock --systohc --utc

#Set hostname
echo "What would you like your hostname to be?"
read strHostname
arch-chroot /mnt echo ${strHostname} > /etc/hostname
echo "Please append your hostname to the end of the lines containing 127.0.0.1 and ::1"
sleep 5
arch-chroot /mnt nano /etc/hosts

#Install the bootloader
if [ ${blEFI} == true ]
        then
		arch-chroot /mnt pacman -S dosfstools
		arch-chroot /mnt bootctl --path=/boot install
		arch-chroot /mnt echo "title Arch Linux" >> /boot/loader/entries/arch.conf
		arch-chroot /mnt echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
		arch-chroot /mnt echo "initrc /initramfs-linux.img" >> /boot/loader/entries/arch.conf
		arch-chroot /mnt echo "options root=${strInstallDrive}1 rw resume=${strInstallDrive}3" >> /boot/loader/entries/arch.conf
		arch-chroot /mnt echo "timeout 0" > /boot/loader/loader.conf #There is only 1 > because the file is created on install, and we're overwriting it
		arch-chroot /mnt echo "default arch" >> /boot/loader/loader.conf
        else
		arch-chroot /mnt pacman -S grub os-prober
		arch-chroot /mnt grub-install --target=i386-pc --recheck ${strInstallDrive}
		arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
fi

#Set root password
echo "Please set a password for the root account"
arch-chroot /mnt passwd

#Create a user account
echo "What would you like your username to be? (ObamaLlama)"
read strUsername
arch-chroot /mnt useradd -m -G wheel -s /bin/bash ${strUsername}
arch-chroot /mnt usermod -aG audio,games,rfkill,users,uucp,video,wheel ${strUsername}
arch-chroot /mnt chfn ${strUsername}
echo "Please add your username to the sudoers file after 'root ALL=(ALL) ALL'
sleep 5
arch-chroot /mnt EDITOR=nano visudo
echo "Please set a password for your account"
arch-chroot /mnt passwd ${strUsername}

wget https://raw.githubusercontent.com/SpotComms/Arch_Install_Commands/master/Post-Install.sh
cp Post-Install.sh /mnt/home/${strUsername}/

#Finish up
umount -R /mnt
echo "After reboot please run 'sh Post-Install.sh'"
sleep 5
reboot