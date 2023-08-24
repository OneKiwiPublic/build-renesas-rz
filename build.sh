#!/bin/bash

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

check_setting() {
    if [ -e "$SETTINGS_FILE" ] ; then
        source "$SETTINGS_FILE"
    else
        if [ "$1" != "s" ] ; then
            echo -e "\nERROR: No board selected. Please run \"./build.sh s\"\n"
            exit
        fi
    fi
}

print_help() {
    if [ "$1" == "" ] ; then
    echo "\

Board: $BOARD

Please select what you want to build:

    ./build.sh f        # Build Renesas Flash Writer
    ./build.sh a        # Build Trusted Firmware-A
    ./build.sh u        # Build u-boot
    ./build.sh k        # Build Linux Kernel
    ./build.sh m        # Build Linux Kernel multimedia modules

    ./build.sh s        # Setup - Choose board and build options
    ./build.sh t        # Toolchain - Change just the Toolchain selection
    "
    exit
    fi
}

check_arg() {
    if [ "$1" == "f" ] ; then
        echo "Build Renesas Flash Writer"
        exit
    fi

    if [ "$1" == "a" ] ; then
        echo "Build Trusted Firmware-A"
        ./build-atf.sh
        exit
    fi

    if [ "$1" == "u" ] ; then
        echo "Build u-boot"
        ./build-uboot.sh
        exit
    fi

    if [ "$1" == "s" ] ; then
        echo "Setup - Choose board"
        setup_board
        exit
    fi
}

setup_board() {

    CHOICE=$(
    whiptail --title "OneKiwi Board Selection" --menu "You may use ESC+ESC to cancel." 0 75 0 \
        "01" "solidrun-rzg2lc - SoildRun RZ/G2LC" \
        "02" "smarc-rzg2lc - Renesas SMARC RZ/G2LC" \
        3>&2 2>&1 1>&3)

    BOARD=""
    echo "select: $CHOICE"

    case $CHOICE in
        "01")
            BOARD="solidrun-rzg2lc"
            UBOOT_DEVICE_TREE=$BOARD
            UBOOT_DEFCONFIG="solidrun-rzg2lc_defconfig"
            MACHINE="RZG2LC"
            OUTPUT_BUILD="out_$BOARD"
        ;;
        "02")
            BOARD="smarc-rzg2lc"
            UBOOT_DEVICE_TREE=$BOARD
            UBOOT_DEFCONFIG="smarc-rzg2lc_defconfig"
            MACHINE="RZG2LC"
            OUTPUT_BUILD="out_$BOARD"
        ;;
    esac

    if [ ! -d "${OUTPUT_BUILD}" ]; then
        mkdir $OUTPUT_BUILD
    fi
    save_setting BOARD $BOARD
    save_setting UBOOT_DEFCONFIG $UBOOT_DEFCONFIG
    save_setting UBOOT_DEVICE_TREE $UBOOT_DEVICE_TREE
    save_setting MACHINE $MACHINE
    save_setting OUTPUT_BUILD $OUTPUT_BUILD
}

### Start ###

source ./build-common.sh
source build-setup.sh
check_setting $1
print_help $1
check_arg $1

#read_setting
#echo "read: $BOARD"