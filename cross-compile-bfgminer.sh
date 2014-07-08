#!/bin/bash

# Warn / error on unbound variables
set -u

# Specifies the platform for the OpenWrt SDK
image_platform="mips_34kc"

# Repos should be cloned to the following locations
# Or edit these variables
uthash_source="${HOME}/uthash/src"
bfgminer_source="${HOME}/bfgminer"

# OpenWrt SDK should be cloned and installed to ~/openwrt
# OpenWrt SDK should also be updated (make menuconfig) to
# include libusb-1.0 and jansson
# Or edit these variables
openwrt_sdk="${HOME}/openwrt"

# Specifies library versions used to build the above
# May need editing for future OpenWrt builds
gcc_version="4.8"
uclibc_version="0.9.33.2"

# Below should not need editing
openwrt_staging="${openwrt_sdk}/staging_dir"
openwrt_toolchain="${openwrt_staging}/toolchain-${image_platform}_gcc-${gcc_version}-linaro_uClibc-${uclibc_version}"
openwrt_target="${openwrt_staging}/target-${image_platform}_uClibc-${uclibc_version}"

# Below depends on $openwrt_toolchain and $openwrt_target being set above
openwrt_toolsbin="${openwrt_toolchain}/bin"
openwrt_toolsusrbin="${openwrt_toolchain}/usr/bin"
openwrt_toolslib="${openwrt_toolchain}/lib"
openwrt_toolsusrlib="${openwrt_toolchain}/usr/lib"
openwrt_targetlib="${openwrt_target}/lib"
openwrt_targetusrlib="${openwrt_target}/usr/lib"
openwrt_toolsinclude="${openwrt_toolchain}/include"
openwrt_toolsusrinclude="${openwrt_toolchain}/usr/include"
openwrt_targetinclude="${openwrt_target}/include"
openwrt_targetusrinclude="${openwrt_target}/usr/include"

bfgminer_output="${bfgminer_source}/output/openwrt"

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd $openwrt_toolchain

export AR=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-ar"
export AS=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-as"
export LD=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-ld"
export NM=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-nm"
export CC=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-gcc"
export CPP=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-cpp"
export GCC=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-gcc"
export CXX=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-g++"
export RANLIB=${openwrt_toolsbin}"/mips-openwrt-linux-uclibc-ranlib"

export LDFLAGS="-L${openwrt_targetusrlib} -L${openwrt_targetlib} -L${openwrt_toolsusrlib} -L${openwrt_toolslib} -Wl,-rpath-link=${openwrt_targetusrlib}"

export CFLAGS="-DMIPSEB -Os -pipe -mno-branch-likely -mips32r2 -mtune=34kc -fno-caller-saves -fhonour-copts -Wno-error=unused-but-set-variable -msoft-float -I${uthash_source}"

export CPPFLAGS="-I${openwrt_targetusrinclude} -I${openwrt_targetinclude} -I${openwrt_toolsusrinclude} -I${openwrt_toolsinclude}"

export JANSSON_CFLAGS="-I${openwrt_targetusrinclude}"
export JANSSON_LIBS="-L${openwrt_targetusrlib} -ljansson"

export LIBUSB_CFLAGS="-I${openwrt_targetusrinclude}/libusb-1.0"
export LIBUSB_LIBS="-L${openwrt_targetusrlib} -lusb-1.0"

export STAGING_DIR=$openwrt_staging

cd $bfgminer_source

./autogen.sh
./configure --prefix=${bfgminer_output} --host=mips-openwrt-linux --enable-scrypt --enable-cpumining
make clean
make
make install
cd output/
tar zcvf bfgminer_openwrt.tar.gz openwrt/
cd openwrt/
cp -r * "${HOME}/openwrt-imagebuilder/files/usr/"
