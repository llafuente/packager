#!/bin/sh
# from http://wiki.razuna.com/display/ecp/FFMpeg+Installation+on+CentOS+and+RedHat

rpm -Uhv http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
yum -y update

yum install -y glibc gcc gcc-c++ autoconf automake libtool make nasm pkgconfig \
SDL-devel a52dec a52dec-devel alsa-lib-devel faac faac-devel faad2 faad2-devel \
freetype-devel giflib gsm gsm-devel imlib2 imlib2-devel lame lame-devel libICE-devel libSM-devel libX11-devel \
libXau-devel libXdmcp-devel libXext-devel libXrandr-devel libXrender-devel libXt-devel \
libogg libvorbis vorbis-tools mesa-libGL-devel mesa-libGLU-devel xorg-x11-proto-devel zlib-devel \
libtheora theora-tools \
ncurses-devel \
libdc1394 libdc1394-devel \
amrnb-devel amrwb-devel opencore-amr-devel

# xvid

cd /opt
wget http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
tar xzvf xvidcore-1.3.2.tar.gz
cd xvidcore/build/generic
./configure --prefix="$HOME/ffmpeg_build"
make && make install

# LibOgg

cd /opt
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz
tar xzvf libogg-1.3.1.tar.gz
cd libogg-1.3.1
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install


# Libvorbis

cd /opt
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-shared
make
make install

# Libtheora

cd /opt
wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
tar xzvf libtheora-1.1.1.tar.gz
cd libtheora-1.1.1
./configure --prefix="$HOME/ffmpeg_build" --with-ogg="$HOME/ffmpeg_build" --disable-examples --disable-shared --disable-sdltest --disable-vorbistest
make
make install

# Aacenc

cd /opt
wget http://downloads.sourceforge.net/opencore-amr/vo-aacenc-0.1.2.tar.gz
tar xzvf vo-aacenc-0.1.2.tar.gz
cd vo-aacenc-0.1.2
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

cd /opt
git clone --depth 1 git://git.code.sf.net/p/opencore-amr/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install
#make distclean

# Yasm

yum remove yasm
cd /opt
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzfv yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
make
make install
export "PATH=$PATH:$HOME/bin"


# Libvpx

cd /opt
git clone http://git.chromium.org/webm/libvpx.git
cd libvpx
git checkout tags/v.1.3.0
./configure --prefix="$HOME/ffmpeg_build" --disable-examples
make
make install

# x264

cd /opt
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
make
make install

# Configure Libraries

export LD_LIBRARY_PATH=/usr/local/lib/
echo /usr/local/lib >> /etc/ld.so.conf.d/custom-libs.conf
ldconfig

# Compile FFmpeg

cd /opt
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
git checkout release/2.2
PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
export PKG_CONFIG_PATH
./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" \
--extra-libs=-ldl --enable-version3 --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libvpx --enable-libfaac \
--enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libvo-aacenc --enable-libxvid --disable-ffplay \
--enable-gpl --enable-postproc --enable-nonfree --enable-avfilter --enable-pthreads --enable-libfdk_aac --arch=x86_64
make
make install
