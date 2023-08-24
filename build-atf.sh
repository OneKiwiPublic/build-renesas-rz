#!/bin/bash

ROOTDIR=`pwd`
ATF_DIR=atf-renesas-rz
PLATFORM=g2l

read_setting() {
    if [ -e "$SETTINGS_FILE" ] ; then
        source "$SETTINGS_FILE"
    else
        echo -e "\nERROR: Settings file ($SETTINGS_FILE) not found."
        exit
    fi
}

build_atf(){
    cd $ATF_DIR
    make O=build PLAT=g2l BOARD=smarc_1 all
    cd ../
}

create_bootparams() {
    # Create bootparams.bin
    # - bootparams.bin totls size is 512 bytes
    # - First 4 bytes is the size of bl2.bin (4-byte aligned)
    # - Last 2 bytes are 0x55, 0xAA
    # - Middle of the file is 0xFF

    #if [ "$TFA_DEBUG" == "1" ] ; then
        #cd build/${PLATFORM}/debug
    #else
        #cd build/${PLATFORM}/release
    #fi

    cd $ATF_DIR/build/${PLATFORM}/release

    echo -e "\n[Creating bootparams.bin]"
    SIZE=$(stat -L --printf="%s" bl2.bin)
    SIZE_ALIGNED=$(expr $SIZE + 3)
    SIZE_ALIGNED2=$((SIZE_ALIGNED & 0xFFFFFFFC))
    SIZE_HEX=$(printf '%08x\n' $SIZE_ALIGNED2)
    echo "  bl2.bin size=$SIZE, Aligned size=$SIZE_ALIGNED2 (0x${SIZE_HEX})"
    STRING=$(echo \\x${SIZE_HEX:6:2}\\x${SIZE_HEX:4:2}\\x${SIZE_HEX:2:2}\\x${SIZE_HEX:0:2})
    printf "$STRING" > bootparams.bin
    for i in `seq 1 506` ; do printf '\xff' >> bootparams.bin ; done
    printf '\x55\xaa' >> bootparams.bin

    # Combine bootparams.bin and bl2.bin into single binary
    # Only if a new version of bl2.bin is created
    if [ "bl2.bin" -nt "bl2_bp.bin" ] || [ ! -e "bl2_bp.bin" ] ; then
        echo -e "\n[Adding bootparams.bin to bl2.bin]"
        cat bootparams.bin bl2.bin > bl2_bp.bin
    fi

    cd ../../../..
}

##############################
create_fip_and_copy() {

    #if [ "$TFA_DEBUG" == "1" ] ; then
        #BUILD_DIR=debug
    #else
        #BUILD_DIR=release
    #fi
    BUILD_DIR=release
    OUT_DIR=${ROOTDIR}/${OUTPUT_BUILD}

    # Build the Fip Tool
    echo -e "\n[Building FIP tool]"
    cd $ATF_DIR/tools/fiptool
    make PLAT=${PLATFORM}
    cd ../..

    #EXTRA=""

    # RZ/G2L PMIC board have _pmic at the end of the filename
    #if [ "$MACHINE" == "smarc-rzg2l" ] && [ "$BOARD_VERSION" == "PMIC" ] ; then
    #EXTRA="_pmic"
    #fi

    # RZ/V2L PMIC board have _pmic at the end of the filename
    #if [ "$MACHINE" == "smarc-rzv2l" ] && [ "$BOARD_VERSION" == "PMIC" ] ; then
    #EXTRA="_pmic"
    #fi

    echo -e "[Create fip.bin]"
    tools/fiptool/fiptool create --align 16 --soc-fw build/${PLATFORM}/$BUILD_DIR/bl31.bin --nt-fw $OUT_DIR/u-boot.bin fip.bin
    cp fip.bin $OUT_DIR/fip-${BOARD}.bin

    echo -e "[Copy BIN file]"
    cp -v build/${PLATFORM}/$BUILD_DIR/bl2_bp.bin $OUT_DIR/bl2_bp-${BOARD}.bin

    echo -e "[Copy BIN file (no boot parameters)]"
    cp -v build/${PLATFORM}/$BUILD_DIR/bl2.bin $OUT_DIR/bl2-${BOARD}.bin

    echo -e "[Copy boot parameters]"
    cp -v build/${PLATFORM}/$BUILD_DIR/bootparams.bin $OUT_DIR/bootparams-${BOARD}.bin

    echo -e "[Convert BIN to SREC format]"
    #<BL2>
    ${CROSS_COMPILE}objcopy -I binary -O srec --adjust-vma=0x00011E00 --srec-forceS3 build/${PLATFORM}/$BUILD_DIR/bl2_bp.bin $OUT_DIR/bl2_bp-${BOARD}.srec

    #<FIP>
    ${CROSS_COMPILE}objcopy -I binary -O srec --adjust-vma=0x00000000 --srec-forceS3 fip.bin $OUT_DIR/fip-${BOARD}.srec
}

### Start ###

source ./build-common.sh
export CC=${CROSS_COMPILE}gcc
export AS=${CROSS_COMPILE}as
export LD=${CROSS_COMPILE}ld
export AR=${CROSS_COMPILE}ar
export OBJDUMP=${CROSS_COMPILE}objdump
export OBJCOPY=${CROSS_COMPILE}objcopy
read_setting
build_atf
create_bootparams
create_fip_and_copy

#make solidrun-rzg2lc_defconfig
#make menuconfig
#make savedefconfig
#make DEVICE_TREE=solidrun-rzg2lc -j8