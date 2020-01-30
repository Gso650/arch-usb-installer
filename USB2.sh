#! /usr/bin/bash

echo "Part 2"
#16.Install Grub @2
dhcpcd
systemctl enable dhcpcd

echo "Install Grub EFI"
lsblk
read -p "Choose Your USB Disk" DISK

mount /dev/${DISK}2 /mnt
mount /dev/${DISK} /mnt/boot/efi
arch-chroot /mnt
grub-install --target=x86_64-efi --edi-directory=/boot/efi --removable

exit
umount /dev/${DISK}1
umount /dev/${DISK}2

echo "All Done ,Just Enjoy Your ArchLinux"
read -p "Do You Want Poweroff? Enter Y to Shutdown" BX
if [[ ${BX} = Y ]]; then
  poweroff
fi
