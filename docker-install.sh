#!/bin/bash

QEMU_VERSION="2.9.0"
QEMU_URL="https://download.qemu.org/qemu-2.9.0.tar.xz"
QEMU_MD5="86c95eb3b24ffea3a84a4e3a856b4e26"

echo "================================================="
echo "                kAFL setup script                "
echo "================================================="

#echo
#echo "[*] Downloading QEMU $QEMU_VERSION ..."
#wget -O qemu-$QEMU_VERSION.tar.xz $QEMU_URL 2> /dev/null

echo "[*] Checking signature of QEMU $QEMU_VERSION ..."
CHKSUM=`md5sum qemu-$QEMU_VERSION.tar.xz | cut -d' ' -f1`

if [ "$CHKSUM" != "$QEMU_MD5" ]; then
  echo "[-] Error: signature mismatch..."
  exit 1
fi

echo "[*] Unpacking QEMU $QEMU_VERSION ..."
tar xJf qemu-$QEMU_VERSION.tar.xz

echo "[*] Patching QEMU $QEMU_VERSION ..."
patch qemu-$QEMU_VERSION/hmp-commands.hx < QEMU-PT/hmp-commands.hx.patch
patch qemu-$QEMU_VERSION/monitor.c < QEMU-PT/monitor.c.patch
patch qemu-$QEMU_VERSION/hmp.c < QEMU-PT/hmp.c.patch
patch qemu-$QEMU_VERSION/hmp.h < QEMU-PT/hmp.h.patch
patch qemu-$QEMU_VERSION/Makefile.target < QEMU-PT/Makefile.target.patch
patch qemu-$QEMU_VERSION/kvm-all.c < QEMU-PT/kvm-all.c.patch
patch qemu-$QEMU_VERSION/vl.c < QEMU-PT/vl.c.patch
patch qemu-$QEMU_VERSION/configure < QEMU-PT/configure.patch
patch qemu-$QEMU_VERSION/linux-headers/linux/kvm.h < QEMU-PT/linux-headers/linux/kvm.h.patch
patch qemu-$QEMU_VERSION/include/qom/cpu.h < QEMU-PT/include/qom/cpu.h.patch

mkdir qemu-$QEMU_VERSION/pt/
cp QEMU-PT/compile.sh qemu-$QEMU_VERSION/
cp QEMU-PT/hmp-commands-pt.hx qemu-$QEMU_VERSION/
cp QEMU-PT/pt.c qemu-$QEMU_VERSION/
cp QEMU-PT/pt.h qemu-$QEMU_VERSION/

cp QEMU-PT/pt/tmp.objs qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/decoder.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/hypercall.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/logger.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/khash.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/memory_access.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/tnt_cache.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/interface.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/interface.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/memory_access.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/logger.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/decoder.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/filter.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/hypercall.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/tnt_cache.h qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/filter.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/disassembler.c qemu-$QEMU_VERSION/pt/
cp QEMU-PT/pt/disassembler.h qemu-$QEMU_VERSION/pt/

patch -p1 qemu-$QEMU_VERSION/hw/misc/applesmc.c < QEMU-PT/applesmc_patches/v1-1-3-applesmc-cosmetic-whitespace-and-indentation-cleanup.patch
patch -p1 qemu-$QEMU_VERSION/hw/misc/applesmc.c < QEMU-PT/applesmc_patches/v1-2-3-applesmc-consolidate-port-i-o-into-single-contiguous-region.patch
patch -p1 qemu-$QEMU_VERSION/hw/misc/applesmc.c < QEMU-PT/applesmc_patches/v1-3-3-applesmc-implement-error-status-port.patch

echo "[*] Compiling QEMU $QEMU_VERSION ..."
cd qemu-$QEMU_VERSION
echo "-------------------------------------------------"
sh compile.sh 
echo "-------------------------------------------------"
cd ..

echo 
echo "[*] Done!"
