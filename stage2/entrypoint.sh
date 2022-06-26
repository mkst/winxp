#!/bin/sh

echo "Starting samba/netbios services..."
service smbd start
service nmbd start

echo "Decompressing system partition"
pv /root/system.qcow2.lz4 | lz4 -d -c - > /root/system.qcow2

qemu-system-x86_64 \
  -name ${HOSTNAME} \
  -accel kvm \
  -accel tcg,thread=multi \
  -machine pc \
  -smp 2 \
  -m 512M \
  -vnc :0 \
  -drive media=disk,file=/root/system.qcow2,format=qcow2,if=virtio,cache=none,aio=native \
  -boot order=c \
  -rtc base=utc \
  -usb \
  -device usb-tablet \
  -vga std \
  -device rtl8139,netdev=n0 \
  -netdev user,id=n0,ipv4=on,ipv6=off,net=10.0.2.0/24,host=10.0.2.2,dns=10.0.2.3,dhcpstart=10.0.2.15,hostfwd=tcp::3389-:3389,hostfwd=tcp::8000-:8000
