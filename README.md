# Windows XP + Docker

# Preamble

Place `en_win_xp_pro_x64_with_sp2_vl_x13-41611.iso` in base of this repo.

## Building Image

# Stage 1

Create an image with everything needed to install Windows XP into a QCOW2 file.

```
export PRODUCT_KEY=AAAAA-BBBBB-CCCCC-DDDDD-EEEEE

docker build . -f stage1/Dockerfile \
    -t stage1 \
    --build-arg PRODUCT_KEY=${PRODUCT_KEY}

# optional: clean up intermediate stage ~ 3GB
docker image prune -f --filter label=stage=iso  
```

NOTE: This is a separate step to avoid BSOD during Windows install - `--device /dev/kvm` appears to be required to avoid the crash.

```
docker run \
    --rm -ti \
    -v $(pwd)/out:/out \
    -p 5900:5900 \
    --device /dev/kvm \
    stage1
```

# Stage 2

Create an image using the prebuilt Windows XP QCOW2, ready to spin up with samba etc.

```
docker build . -f stage2/Dockerfile -t xp
```

## Run

Drop any files into `./share` and find them at `\\10.0.2.2\share`

```
docker run \
    --rm -ti \
    -p 5900:5900 \
    -p 8000:8000 \
    -v $(pwd)/share:/mnt/share \
    --device /dev/kvm \
    xp
```

Drop a new `start-node.bat` into `./mnt` and mount it as `/mnt/qemu`:

```
docker run \
    --rm -ti \
    -p 5900:5900 \
    -p 8000:8000 \
    -v $(pwd)/share:/mnt/share \
    -v $(pwd)/mnt:/mnt/qemu \
    --device /dev/kvm \
    xp
```

# References

https://github.com/hectorm/docker-qemu-win2000
https://github.com/sormy/docker-oldie
