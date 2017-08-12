#!/bin/bash
# This file is meant to be included by the parent cppbuild.sh script
if [[ -z "$PLATFORM" ]]; then
    pushd ..
    bash cppbuild.sh "$@" gsl
    popd
    exit
fi

DJVULIBRE_VERSION=3.5.27

mkdir -p $PLATFORM
cd $PLATFORM
INSTALL_PATH=`pwd`

#download https://managedway.dl.sourceforge.net/project/djvu/DjVuLibre/$DJVULIBRE_VERSION/djvulibre-$DJVULIBRE_VERSION.tar.gz djvulibre-$DJVULIBRE_VERSION.tar.gz
#tar -xzvf ../gsl-$GSL_VERSION.tar.gz
#cd gsl-$GSL_VERSION

# Using an alternative source, probably a little better maintained:
git clone --depth=1 https://github.com/barak/djvulibre.git djvulibre-$DJVULIBRE_VERSION
cd djvulibre-$DJVULIBRE_VERSION

# Flags to pass to `./configure`
CONFIGURE_FLAGS="-disable-desktopfiles"

case $PLATFORM in
    android-arm)
        export AR="$ANDROID_BIN-ar"
        export RANLIB="$ANDROID_BIN-ranlib"
        export CPP="$ANDROID_BIN-cpp"
        export CC="$ANDROID_BIN-gcc"
        export STRIP="$ANDROID_BIN-strip"
        export CPPFLAGS="--sysroot=$ANDROID_ROOT -DANDROID"
        export CFLAGS="$CPPFLAGS -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300 -Dlog2\(x\)=\(log\(x\)/1.44269504088896340736\)"
        export LDFLAGS="-nostdlib -Wl,--fix-cortex-a8 -z text"
        export LIBS="-lgcc -ldl -lz -lm -lc"
        export GSL_LDFLAGS="-Lcblas/.libs/ -lgslcblas"
        ./autogen.sh --prefix=$INSTALL_PATH --host="arm-linux-androideabi" --with-sysroot="$ANDROID_ROOT" $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
     android-x86)
        export AR="$ANDROID_BIN-ar"
        export RANLIB="$ANDROID_BIN-ranlib"
        export CPP="$ANDROID_BIN-cpp"
        export CC="$ANDROID_BIN-gcc"
        export STRIP="$ANDROID_BIN-strip"
        export CPPFLAGS="--sysroot=$ANDROID_ROOT -DANDROID"
        export CFLAGS="$CPPFLAGS -fPIC -ffunction-sections -funwind-tables -mssse3 -mfpmath=sse -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300 -Dlog2\(x\)=\(log\(x\)/1.44269504088896340736\)"
        export LDFLAGS="-nostdlib -z text"
        export LIBS="-lgcc -ldl -lz -lm -lc"
        export GSL_LDFLAGS="-Lcblas/.libs/ -lgslcblas"
        ./autogen.sh --prefix=$INSTALL_PATH --host="i686-linux-android" --with-sysroot="$ANDROID_ROOT" $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    linux-x86)
        ./autogen.sh --prefix=$INSTALL_PATH $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    linux-x86_64)
#	tar -zxf ../../quickbuild.tar.gz
        ./autogen.sh --prefix=$INSTALL_PATH $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    linux-armhf)
        ./autogen.sh --prefix=$INSTALL_PATH --host=arm-linux-gnueabihf $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    linux-ppc64le)
        sed -i s/elf64ppc/elf64lppc/ configure
        ./autogen.sh --prefix=$INSTALL_PATH $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    macosx-*)
        ./autogen.sh --prefix=$INSTALL_PATH $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    windows-x86)
        ./autogen.sh --prefix=$INSTALL_PATH CC="gcc -m32 -static-libgcc" $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    windows-x86_64)
        ./autogen.sh --prefix=$INSTALL_PATH CC="gcc -m64 -static-libgcc" $CONFIGURE_FLAGS
        make -j $MAKEJ
        make install-strip
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        ;;
esac

cd ../..
