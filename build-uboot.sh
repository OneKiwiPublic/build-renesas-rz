#!/bin/bash

ROOTDIR=`pwd`
UBOOT_DIR=uboot-renesas-rz
#SETTINGS_FILE=board.ini
#export KBUILD_OUTPUT=${ROOTDIR}/${UBOOT_DIR}/build

build_uboot(){
    echo "defconfig: $UBOOT_DEFCONFIG $UBOOT_DEVICE_TREE"
    cd $UBOOT_DIR
    export KBUILD_OUTPUT=./build
    make $UBOOT_DEFCONFIG
    echo "make DEVICE_TREE=$UBOOT_DEVICE_TREE -j$(nproc)"
    make DEVICE_TREE=$UBOOT_DEVICE_TREE -j$(nproc)
    cd ../
    cp -v $UBOOT_DIR/build/u-boot.bin $OUTPUT_BUILD
    cp -v $UBOOT_DIR/build/u-boot.srec $OUTPUT_BUILD
}

make_menuconfig_uboot(){
    cd $UBOOT_DIR
    make $UBOOT_DEFCONFIG
    make menuconfig
    make savedefconfig
    echo "output ${UBOOT_DIR}/build/defconfig"
    cd ../
}

read_setting() {
    if [ -e "$SETTINGS_FILE" ] ; then
        source "$SETTINGS_FILE"
    else
        echo -e "\nERROR: Settings file ($SETTINGS_FILE) not found."
        exit
    fi
}

### Start ###

source ./build-common.sh
read_setting
build_uboot
#make_menuconfig_uboot

#make solidrun-rzg2lc_defconfig
#make menuconfig
#make savedefconfig
#make DEVICE_TREE=solidrun-rzg2lc -j8