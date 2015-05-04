#Connect to WiFi Network
wifi-menu


#Partition a 500GB Drive
lsblk #Identify your drives
parted /dev/sdX #Start parted on your drive
list #List all partitions
rm [1-X] #Delete all partitions
mklabel [msdos/gpt] #Create the partition table
mkpart [primary/ESP] [ext4/fat32] 1MiB 1GiB #Create the /boot partition
set 1 boot on #Set /boot to be bootable
mkpart primary ext4 1GiB 128GiB #Create the / partition
mkpart primary linux-swap 128GiB [128+1.5x RAM]GiB #Create the swap partition
mkpart primary ext4 [END SWAP SIZE]GiB 100% #Create the /home partition


#Format partitions
mkfs.[ext4/vfat -F32] /dev/sdX1 #Format /boot
mkfs.ext4 /dev/sdX2 #Format /
mkswap /dev/sdX3 #Format swap
swapon /dev/sdX3 #Enable swap
mkfs.ext4 /dev/sdX4 #Format /home


#Mount partitions
mount /dev/sdX2 /mnt
mkdir -p /mnt/boot
mount /dev/sdX1 /mnt/boot
mkdir -p /mnt/home
mount /dev/sdX4 /mnt/home


#Install the base system
pacstrap -i /mnt base base-devel


#Generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab


#Chroot into new system
arch-chroot /mnt /bin/bash


#Set locale
nano nano /etc/locale.gen #Uncomment "en_US.UTF-8 UTF-8"
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8


#Set time zone
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc --utc

#NOT FINISHED