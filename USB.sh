#!/usr/bin/bash
#1.Network Test
dhcpcd
timedatectl set-ntp true

echo "ArchLinux to USB Flash Disk Auto Install"
echo "Ver:1.0"
echo "github.com/"

#2.Parted To Disk
echo "Part Disk"
lsblk
read -p "Choose Your Disk:" DISK
read -p "Parted To EFI(M):" EFI
read -p "Parted To Root(G):" ROOT
read -p "Are You Sure About Decssion? Enter N to Restart " AX
if [[ ${AX} = N ]]; then
  exit
fi

fdisk /dev/${DISK} <<EOF
d
o
n
p


+${EFI}M
n
p


+${ROOT}G
n
p



a
1
p
wq
EOF
echo "Partting Disk Done"

#4.Wipe Disk
mkfs.ext4 -O "has_journal" /dev/${DISK}2
mkfs.vfat /dev/${DISK}1
mkfs.vfat /dev/${DISK}3
echo "Wipe Disk Done"


#5.Mount
mount /dev/${DISK}2 /mnt
mkdir /mnt/boot/efi
mount /dev/${DISK}1 /mnt/boot/efi
echo "Mount Done"

#6.Using China Mirrorlist
cd /etc/pacman.d
cp mirrorlist mirrorlist.bk
cat mirrorlist.bk | grep China -A 1 | grep -v '-' > mirrorlist
sed -i '1,2d' mirrorlist
sed -i '5,8d' mirrorlist
sed -i '11,14d' mirrorlist
cd
echo "Change China Source Done"

#7.Install System
pacstrap /mnt base base-devel linux linux-firmware dhcpcd ntfs-3g dialog nano wireless_tools wpa_supplicant  net-tools
echo "Install Software Done"

#8.Get Fstab
genfstab -U /mnt >> /mnt/etc/fstab

#9Into New System
arch-chroot /mnt

#10.Timezone Set
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#11.Hardware Time Set
hwclock --systohc --localtime
echo "Time Set Done"

#12.Hostname
read -p "Enter Your Hostname" HOSTNAME
ehco ${HOSTNAME} > /etc/hostname

#13.Language Set
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#14.5 Passwd Set
echo "Root Passwd Setting"
passwd

#14.Initramfs
sed -i '/^HOOKS/cHOOKS=(base udev block keyboard autodetect modconf filesystems fsck)' mkinitcpio.conf
mkinitcpio -P
echo "Create Initramfs Done"

#15.Install Grub @1
echo "Install Grub Bios"
pacman -S grub efibootmgr
grub-install --target=i386-pc /dev/${DISK}
grub-mkconfig -o /boot/grub/grub.cfg
ehco "Install Grub Bios Done"

exit
umount /dev/${DISK}1
umount /dev/${DISK}2

echo "Please Change VBOX To EFI Then Start Secend Part"
read -p "Do You Want Poweroff? Enter Y to Shutdown" CX
if [[ ${CX} = Y ]]; then
  poweroff
fi
