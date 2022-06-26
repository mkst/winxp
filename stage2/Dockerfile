FROM ubuntu:22.04 as qemu

RUN apt-get update && apt-get install --no-install-recommends -y \
    lz4 \
    pv \
    qemu-system-x86 \
    qemu-utils \
    samba

COPY out/system.qcow2.lz4 /root/system.qcow2.lz4

RUN mkdir -p /mnt/qemu /share

COPY stage2/smb.conf /etc/samba/smb.conf

COPY stage2/support/start-node.bat /mnt/qemu/

COPY stage2/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3389
EXPOSE 5900
