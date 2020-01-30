#!/usr/bin/bash
#1.Network Test
dhcpcd
timedatectl set-ntp true

echo "ArchLinux to USB Flash Disk Auto Install"
echo "Ver:1.3"
echo "github.com/Gso650/arch-usb-installer"

#2.Parted To Disk
echo "Part Disk"
read -p "1-EFI ROOT / 2-Storage EFI ROOT :" PARTED

lsblk
read -p "Choose Your Disk" DISK
if [[ ${PARTED} = 1 ]]; then
  read -p "Parted To EFI(M):" EFI
elif [[ ${PARTED} = 2 ]]; then
  read -p "Parted To Storage(G):" STORAGE
  read -p "Parted To EFI(M):" EFI
else
  exit
fi

read -p "Are You Sure About Decssion? Enter N to Restart " AX

if [[ ${AX} = N ]]; then
  exit
fi

if [[ ${PARTED} = 1 ]]; then
  fdisk /dev/${DISK} <<EOF
  d
  o
  n
  p


  +${EFI}M
  n
  p



  a
  1
  p
  wq
EOF
elif [[ ${PARTED} = 2 ]]; then
  fdisk /dev/${DISK} <<EOF
  d
  o
  n
  p


  +${STORAGE}G
  n
  p


  +${EFI}M
  n
  p



  a
  2
  p
  wq
EOF
fi

echo "Partting Disk Done"

#4.Wipe And MountDisk
mkfs.vfat /dev/${DISK}1

if [[ ${PARTED} = 1 ]]; then
  mkfs.ext4 -O "has_journal" /dev/${DISK}2
  mount /dev/${DISK}2 /mnt
  mkdir -p /mnt/boot/efi
  mount /dev/${DISK}1 /mnt/boot/efi
elif [[ ${PARTED} = 2 ]]; then
  mkfs.ext4 -O "has_journal" /dev/${DISK}3
  mkfs.vfat /dev/${DISK}2
  mount /dev/${DISK}3 /mnt
  mkdir -p /mnt/boot/efi
  mount /dev/${DISK}2 /mnt/boot/efi
fi
echo "Wipe And Mount Disk Done"


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

#8.FSTAB
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

umount /mnt/boot/efi
umont /mnt


echo "Please Change VBOX To EFI Then Start Part 2 "
read -p "Do You Want Poweroff? Enter Y to Shutdown" CX

if [[ ${CX} = Y ]]; then
  poweroff
else
  exit
fi
