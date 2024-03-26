This is [kAFL](https://github.com/RUB-SysSec/kAFL) reworked to run on modern (2024) Linux systems. The original kAFL work is done in 2017 and is never updated ever since, which renders it obsolete and unusable on modern systems.

This work is done on a best-effort basis, so don't expect it to work without problems.

## Patch the host kernel

kAFL requires a Linux kernel with KVM-PT patches running as the host OS. This repo provides a [patch for Linux kernel v6.5.13](./kAFL-linux-v6.5.13.patch) (which is the default kernel version for Ubuntu 23.10). If this kernel version differs from yours, you may encounter errors while applying the patch, and you may have to manually adjust the patch contents accordingly.

To apply the patch for your kernel source tree:

```sh
cd $KERNEL_SRC
apply -p1 < $KAFL_SRC/kAFL-Linux-v6.5.13.patch
```

After applying the patch, build the kernel with `CONFIG_KVM_VMX_PT` enabled, and replace the host kernel with the newly built one.

### Example: patching Ubuntu 23.10 kernel

Ref: [Ubuntu Wiki](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel)

```sh
# Obtain kernel source and build dependencies
sudo apt build-dep linux linux-image-unsigned-$(uname -r)
sudo apt source linux

# Apply kernel patches
cd linux-6.5.0
apply -p1 < ../kAFL-Linux-v6.5.13.patch

# Edit kernel config
fakeroot debian/rules clean
fakeroot debian/rules editconfigs
# Enable CONFIG_KVM_VMX_PT in the config menu

# Build the kernel
fakeroot debian/rules clean
fakeroot debian/rules binary-headers binary-generic binary-perarch

# Install the new kernel and modules
sudo dpkg -i ../linux-image-*.deb ../linux-modules-*.deb
```

## Setup Docker image

kAFL depends on QEMU 2.9 and Python 2.7, which are too old for modern Linux systems. In order to make sure that kAFL runs properly, we need to build a Ubuntu-16.04-based Docker container.

The container needs to be run in privileged mode in order to access KVM-PT via `/dev/kvm`.

### Example commands to build the Docker image

```sh
# Download QEMU source code package
wget 'https://download.qemu.org/qemu-2.9.0.tar.xz'
# Build the Docker image
docker build -t kafl .

# Run the container.
# Specify `--privileged` to allow the container to access /dev/kvm.
# If this still doesn't work, consider running `sudo chmod 666 /dev/kvm`
# outside the container to allow unrestricted access to KVM.
# (Note that this reduces the security level of the host machine.)
docker run -it --rm --privileged kafl

# If you want to run the unit test `test.py`, forward the host's X11 server
# to the container:
docker run -it --rm --privileged --network=host --env "DISPLAY=$DISPLAY" \
    --volume="$HOME/.Xauthority:/root/.Xauthority:rw" kafl
```

## Start fuzzing

Refer to [README-old.md](./README-old.md) for information about how to:

1. Set up the target VM image
1. Build the kAFL loader agents and fuzz drivers
1. Create VM snapshots ready for kAFL fuzzing
1. Run the kAFL fuzzer on the snapshot
