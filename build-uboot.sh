#!/bin/bash

ROOTDIR=`pwd`
UBOOT_DIR=uboot-renesas-rz
export KBUILD_OUTPUT=${ROOTDIR}/${UBOOT_DIR}/build

NPROC=2
if [ "$(which nproc)" != "" ] ; then  # make sure nproc is installed
    NPROC=$(nproc)
fi
BUILD_THREADS=$(expr $NPROC + $NPROC)

build_uboot(){
    cd $UBOOT_DIR
    make $UBOOT_DEFCONFIG
    make DEVICE_TREE=$UBOOT_DEVICE_TREE -j$BUILD_THREADS
    cd ../
}

make_menuconfig_uboot(){
    cd $UBOOT_DIR
    make $UBOOT_DEFCONFIG
    make menuconfig
    make savedefconfig
    echo "output build/defconfig"
    cd ../
}

#make solidrun-rzg2lc_defconfig
#make menuconfig
#make savedefconfig
#make DEVICE_TREE=solidrun-rzg2lc -j8