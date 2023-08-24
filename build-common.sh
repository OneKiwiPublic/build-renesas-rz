#!/bin/bash

ROOTDIR=`pwd`
export PATH=${ROOTDIR}/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf/bin:$PATH
export CROSS_COMPILE=aarch64-none-elf-
export ARCH=arm64
SETTINGS_FILE=board.ini