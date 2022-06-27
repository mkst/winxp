FROM ubuntu:22.04 as iso
LABEL stage=iso

# 628,168,704
ARG WINDOWS_ISO=en_win_xp_pro_x64_with_sp2_vl_x13-41611.iso
ARG WINDOWS_SHA256=ace108a116ed33ddbfd6b7e2c5f21bcef9b3ba777ca9a8052730138341a3d67d

ARG PRODUCT_KEY
ARG FULL_NAME=Docker
ARG ORG_NAME=Docker
ARG COMPUTER_NAME=windowsxp
ARG SCREEN_WIDTH=1024
ARG SCREEN_HEIGHT=768
ARG SCREEN_DEPTH=32
ARG REFRESH_RATE=60

# 370,821,120
ARG VIRTIO_ISO_URL=https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.164-2/virtio-win-0.1.164.iso
ARG VIRTIO_ISO_SHA256=594678f509ba6827c7b75d076ecfb64d45c6ad95e9fccba7258e6eee9a6a3560
ARG VIRTIO_ARCH=2k3/amd64

RUN apt-get update && apt-get install --no-install-recommends -y \
        7zip \
        ca-certificates \
        genisoimage \
        wget \
    && update-ca-certificates

COPY ${WINDOWS_ISO} /

RUN echo "${WINDOWS_SHA256}  ${WINDOWS_ISO}" | sha256sum -c

RUN 7zz x -o/root/install -- /${WINDOWS_ISO}

RUN wget -O virtio.iso $VIRTIO_ISO_URL

RUN echo "${VIRTIO_ISO_SHA256}  virtio.iso" | sha256sum -c \
    && 7zz x -o/root/virtio virtio.iso \
    && mkdir -p '/root/install/$oem$/$1/drivers' \
    && cp -v /root/virtio/viostor/${VIRTIO_ARCH}/* '/root/install/$oem$/$1/drivers/' \
    && cp -v /root/virtio/NetKVM/${VIRTIO_ARCH}/* '/root/install/$oem$/$1/drivers/'

COPY stage1/provision/winnt.sif /root/install/AMD64/WINNT.SIF
RUN sed -i \
        -e "s#{productKey}#${PRODUCT_KEY}#" \
        -e "s#{fullName}#${FULL_NAME}#" \
        -e "s#{orgName}#${ORG_NAME}#" \
        -e "s#{computerName}#${COMPUTER_NAME}#" \
        -e "s#{screenWidth}#${SCREEN_WIDTH}#" \
        -e "s#{screenHeight}#${SCREEN_HEIGHT}#" \
        -e "s#{screenDepth}#${SCREEN_DEPTH}#" \
        -e "s#{refreshRate}#${REFRESH_RATE}#" \
        /root/install/AMD64/WINNT.SIF

# do we need to remove the final line of TXTSETUP.SIF?
COPY stage1/provision/txtsetup.sif /
RUN cp -v '/root/install/$oem$/$1/drivers/viostor.sys' /root/install/AMD64/ \
    && sed -i '$ d' /root/install/AMD64/TXTSETUP.SIF \
    && cat txtsetup.sif >> /root/install/AMD64/TXTSETUP.SIF

# install provision provision files
COPY stage1/provision/once.bat '/root/install/$oem$/$1/provision/'
COPY stage1/provision/start.bat '/root/install/$oem$/$1/provision/'

RUN genisoimage \
        -eltorito-boot "[BOOT]/Boot-NoEmul.img" \
        -boot-load-seg 1984 \
        -boot-load-size 4 \
        -disable-deep-relocation \
        -full-iso9660-filenames \
        -iso-level 2 \
        -joliet \
        -joliet-long \
        -no-emul-boot \
        -omit-version-number \
        -relaxed-filenames \
        -rock \
        -output /root/install.iso /root/install

# stage1

FROM ubuntu:22.04 as stage1

RUN apt-get update && apt-get install --no-install-recommends -y \
        lz4 \
        pv \
        qemu-system-x86 \
        qemu-utils

COPY --from=iso /root/install.iso /root/install.iso

COPY stage1/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
