#! /usr/bin/bash
dhcpcd
systemctl enable dhcpcd

#8.Timezone Setting
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#9.Hardware Time Setting
hwclock --systohc --localtime
echo "Time Set Done"

#10.Hostname Setting
read -p "Enter Your Hostname:" HOSTNAME
echo ${HOSTNAME} > /etc/hostname

#11.Language Setting
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#12 Passwd Setting
echo "Root Passwd Setting"
passwd

#13.Initramfs
sed -i '/^HOOKS/cHOOKS=(base udev block keyboard autodetect modconf filesystems fsck)' /etc/mkinitcpio.conf
mkinitcpio -P
echo "Create New Initramfs Done"

#14.Install Grub
echo "Install Grub"
lsblk
read -p "Select Your USB Disk:" DISK
pacman -S grub efibootmgr
grub-install --target=i386-pc /dev/${DISK}
grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable --recheck
grub-mkconfig -o /boot/grub/grub.cfg
echo "Install Grub Done"

read -p "Do you want to poweroff? Enter Y to shutdown:" CX

if [[ ${CX} = Y ]]; then
  poweroff
else
  exit
fi
