yum groupinstall "Development Tools"
yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel xz-libs cmake libffi-devel

# gcc on older centos versions
#cd /etc/yum.repos.d
#wget http://people.centos.org/tru/devtools-1.1/devtools-1.1.repo
#yum --enablerepo=testing-1.1-devtools-6 install devtoolset-1.1-gcc devtoolset-1.1-gcc-c++
#export CC=/opt/centos/devtoolset-1.1/root/usr/bin/gcc
#export CPP=/opt/centos/devtoolset-1.1/root/usr/bin/cpp
#export CXX=/opt/centos/devtoolset-1.1/root/usr/bin/c++

# python 2.7 on older centos versions
# https://www.digitalocean.com/community/tutorials/how-to-set-up-python-2-7-6-and-3-3-3-on-centos-6-4
#
#mkdir /tmp/python/
#cd /tmp/python/
#wget http://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz
#xz -d Python-2.7.6.tar.xz
#tar -xvf Python-2.7.6.tar
#cd Python-2.7.6
#./configure --prefix=/usr
#make && make altinstall


# VERSION=3.7.0 changed to cmake, need to redo the recipe!
VERSION=3.6.2

mkdir -p /tmp/llvm
cd /tmp/llvm

wget http://llvm.org/releases/${VERSION}/llvm-${VERSION}.src.tar.xz
wget http://llvm.org/releases/${VERSION}/cfe-${VERSION}.src.tar.xz
wget http://llvm.org/releases/${VERSION}/compiler-rt-${VERSION}.src.tar.xz

tar -xf llvm-${VERSION}.src.tar.xz -C .
cd llvm-*

tar -xf ../cfe-${VERSION}.src.tar.xz -C tools
tar -xf ../compiler-rt-${VERSION}.src.tar.xz -C projects

mv tools/cfe-${VERSION}.src tools/clang
mv projects/compiler-rt-${VERSION}.src projects/compiler-rt

# needed for prior versions
# sed -e "s:/docs/llvm:/share/doc/llvm-${VERSION}:" -i Makefile.config.in

./configure --prefix=/usr        \
--sysconfdir=/etc                \
--enable-libffi                  \
--enable-optimized               \
--enable-shared                  \
--with-python=/usr/bin/python2.7 \
--disable-assertions &&
make

sudo make install
