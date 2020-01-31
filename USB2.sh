#! /usr/bin/bash

echo "Part 2"
#16.Install Grub @2
dhcpcd
systemctl enable dhcpcd

echo "Install Grub EFI"
read -p "1-EFI ROOT / 2-Storage EFI ROOT :" PARTED
if [[ ${PARTED} = 1 ]]; then
  read -p "Choose Your USB Disk" DISK
  mount /dev/${DISK}2 /mnt
  mount /dev/${DISK}1 /mnt/boot/efi
elif [[ ${PARTED} = 2 ]]; then
  mount /dev/${DISK}3 /mnt
  mount /dev/${DISK}2 /mnt/boot/efi
else
  exit
fi

arch-chroot /mnt

grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable

exit
umount /mnt/boot/efi
umount /mnt

echo "All Done ,Just Enjoy Your ArchLinux"
read -p "Do You Want Poweroff? Enter Y to Shutdown" BX
if [[ ${BX} = Y ]]; then
  poweroff
fi
