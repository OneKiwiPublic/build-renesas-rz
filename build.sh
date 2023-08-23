#!/bin/bash

ROOTDIR=`pwd`
export PATH=${ROOTDIR}/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin:$PATH
export CROSS_COMPILE=aarch64-none-elf-
export ARCH=arm64
#export KBUILD_OUTPUT=./build
SETTINGS_FILE=board.ini

# $1 = env variable to save
# $2 = value
# Remember, we we share this file with other scripts, so we only want to change
# the lines used by this script
save_setting() {
    if [ ! -e $SETTINGS_FILE ] ; then
        touch $SETTINGS_FILE # create file if does not exit
    fi

    # Do not change the file if we did not make any changes
    grep -q "^$1=$2$" $SETTINGS_FILE
        if [ "$?" == "0" ] ; then
    return
    fi

    sed '/^'"$1"'=/d' -i $SETTINGS_FILE
    echo  "$1=$2" >> $SETTINGS_FILE

    # Delete empty or blank lines
    sed '/^$/d' -i $SETTINGS_FILE

    # Sort the file to keep the same order
    sort -o $SETTINGS_FILE $SETTINGS_FILE
}

read_setting() {
    if [ -e "$SETTINGS_FILE" ] ; then
        source "$SETTINGS_FILE"
    else
        echo -e "\nERROR: Settings file ($SETTINGS_FILE) not found."
        exit
    fi
}

source build-setup.sh

read_setting
echo "read: $BOARD"

CHOICE=$(
whiptail --title "OneKiwi Board Selection" --menu "You may use ESC+ESC to cancel." 0 75 0 \
	"01" "soildrun-rzg2lc - SoildRun RZ/G2LC" \
	"02" "smarc-rzg2lc - Renesas SMARC RZ/G2LC" \
	3>&2 2>&1 1>&3)

BOARD=""
echo "select: $CHOICE"

case $CHOICE in
    "01")
        BOARD="soildrun-rzg2lc"
        UBOOT_DEVICE_TREE=$BOARD
        UBOOT_DEFCONFIG="solidrun-rzg2lc_defconfig"
    ;;
    "02")
        BOARD="smarc-rzg2lc"
        UBOOT_DEFCONFIG="smarc-rzg2lc_defconfig"
    ;;
esac

echo "$BOARD"
save_setting BOARD $BOARD
save_setting UBOOT_DEFCONFIG $UBOOT_DEFCONFIG
save_setting UBOOT_DEVICE_TREE $UBOOT_DEVICE_TREE