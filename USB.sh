#!/usr/bin/bash
#1.Network Test
dhcpcd
timedatectl set-ntp true

echo "ArchLinux to USB Flash Disk Auto Install"
echo "Ver:1.6"
echo "github.com/Gso650/arch-usb-installer"

#2.Disk Partition
echo "Select Partition Mode:"
read -p "1-EFI ROOT / 2-Storage EFI ROOT :" PARTED

lsblk
read -p "Select Your USB Disk:" DISK
if [[ ${PARTED} = 1 ]]; then
  read -p "EFI Size(M):" EFI
elif [[ ${PARTED} = 2 ]]; then
  read -p "Storage Size(G):" STORAGE
  read -p "EFI Size(M):" EFI
else
  exit
fi

read -p "Are you sure your choice is correct? Enter N to restart: " AX

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

echo "Partition USB Disk Done"

#3.Wipe And Mount Disk
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
echo "Wipe And Mount USB Disk Done"


#4.Using China Mirrorlist
cd /etc/pacman.d
cp mirrorlist mirrorlist.bk
cat mirrorlist.bk | grep China -A 1 | grep -v '-' > mirrorlist
sed -i '/neusoft/d;/cqu/d;/redrock/d;/lzu/d;/zju/d' mirrorlist
cd
echo "Change China Source Done"

#5.Install System
if [[ ${PARTED} = 1 ]]; then
  pacstrap /mnt base base-devel linux linux-firmware dhcpcd dialog nano wireless_tools wpa_supplicant net-tools
elif [[ ${PARTED} = 2 ]]; then
  pacstrap /mnt base base-devel linux linux-firmware dhcpcd ntfs-3g dialog nano wireless_tools wpa_supplicant net-tools dosfstools
fi
echo "Install Package Done"

#6.FSTAB
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

cp USB2.sh /mnt

#7.Enter New System
arch-chroot /mnt
