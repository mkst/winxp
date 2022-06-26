#!/bin/sh

echo "Creating system partition...\n"
qemu-img create -f qcow2 /root/system.qcow2 4G

echo "Installing Windows XP...\n"
echo "NOTE: This can take up to 10 minutes... VNC available on port 5900 if you want to watch along...\n"

qemu-system-x86_64 \
        -accel kvm \
        -accel tcg,thread=multi \
        -machine pc \
        -smp 2 \
        -m 512M \
        -vnc :0 \
        -drive media=disk,file=/root/system.qcow2,format=qcow2,if=virtio,cache=none,aio=native \
        -drive media=cdrom,file=/root/install.iso \
        -boot once=d \
        -rtc base=utc \
        -usb \
        -device usb-tablet \
        -vga std \
        -nic user,model=e1000,restrict=on

if [ -d /out ]; then
    pv /root/system.qcow2 | lz4 -z -f - /out/system.qcow2.lz4
fi
