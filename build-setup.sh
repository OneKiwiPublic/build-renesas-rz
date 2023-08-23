#!/bin/bash

UBOOT_REPO=uboot-renesas-rz
UBOOT_BRANCH=onekiwi-bsp-3.0.3-v2021.10/rz
ATF_REPO=atf-renesas-rz
ATF_BRANCH=onekiwi-bsp-3.0.3-v2.7/rz

git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

fetch_toolchain(){
    echo "check toolchain"
    if [ ! -d "gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf" ] ; then
        echo "fetch: GNU Toolchain by ARM, Version 10.2-2020.11"
        wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz
        tar xvf gcc-arm-10.2-2020.11-x86_64-aarch64-none-elf.tar.xz
    fi
}

fetch_uboot(){
    echo "check uboot"
    if [ ! -d "${UBOOT_REPO}" ]; then
        echo "fetch: ${UBOOT_REPO}"
        #git clone https://github.com/OneKiwiPublic/${UBOOT_REPO}.git -b ${UBOOT_BRANCH}
        git clone git@github.com:OneKiwiPublic/${UBOOT_REPO}.git -b ${UBOOT_BRANCH}
    else
        cd ${UBOOT_REPO}
        temp=$(git branch | grep "*")
        BRANCH=${temp:2} 
        echo "    branch: $BRANCH"
        if [ ${BRANCH} != ${UBOOT_BRANCH} ]; then
            git checkout ${UBOOT_BRANCH}
        fi
        cd ../
    fi
}

fetch_atf(){
    echo "check atf"
    if [ ! -d "${ATF_REPO}" ] ; then
        echo "fetch: ${ATF_REPO}"
        #git clone https://github.com/OneKiwiPublic/${ATF_REPO}.git -b ${ATF_BRANCH}
        git clone git@github.com:OneKiwiPublic/${ATF_REPO}.git -b ${ATF_BRANCH}
    else
        cd ${ATF_REPO}
        temp=$(git branch | grep "*")
        BRANCH=${temp:2} 
        echo "    branch: $BRANCH"
        if [ ${BRANCH} != ${ATF_BRANCH} ]; then
            git checkout ${ATF_BRANCH}
        fi
        cd ../
    fi
}

fetch_toolchain
fetch_uboot
fetch_atf