#!/bin/bash

# Create a directory for your project
mkdir my_linux_image
cd my_linux_image

# Create the necessary directory structure and scripts
mkdir -p iso/boot/grub

# Create a GRUB configuration
cat > iso/boot/grub/grub.cfg <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_HIDDEN_TIMEOUT_QUIET=false
GRUB_TIMEOUT_STYLE=menu

# Add a custom menu entry
menuentry "Custom Linux Boot" {
    
    echo "Hello, World!"  # Add the echo statement
    boot
}

EOF

# Install necessary packages
sudo apt-get update
sudo apt-get install -y qemu-utils grub-pc-bin

# Create a minimal filesystem
mkdir -p iso/{boot/grub,bin,sbin,dev}
echo '#!/bin/sh' > iso/bin/hello.sh
echo 'echo "Hello, world!"' >> iso/bin/hello.sh
chmod +x iso/bin/hello.sh

# Create a minimal init script
echo '#!/bin/sh' > iso/sbin/init
echo '/bin/hello.sh' >> iso/sbin/init
chmod +x iso/sbin/init

# Create device files
sudo mknod -m 666 iso/dev/null c 1 3
sudo mknod -m 666 iso/dev/tty c 5 0

# Create an empty root filesystem
dd if=/dev/zero of=disk.img bs=1M count=1024
mkfs.ext2 -F disk.img

# Mount the disk image and copy the filesystem
mkdir -p mnt
sudo mount -o loop disk.img mnt
sudo cp -r iso/* mnt/
sudo umount mnt

# Install GRUB
grub-install --target=i386-pc --boot-directory=iso/boot --recheck --modules="normal part_msdos ext2 multiboot" /dev/loop0

# Create an ISO image
grub-mkrescue -o my_linux_image.iso iso

# Run QEMU with the ISO image
qemu-system-x86_64 -boot d -cdrom my_linux_image.iso

# # Clean up
# cd ..
# rm -r my_linux_image
