#!/bin/bash

set -e

# Download Cmake installer file
echo "Downloading CMake files"
wget http://www.cmake.org/files/v3.13/cmake-3.13.0.tar.gz -q --show-progress --no-clobber
# extract and change permissions
echo "Extracting CMake files"
tar xpvf cmake-3.13.0.tar.gz cmake-3.13.0/

# Compile 
# change directory
cd cmake-3.13.0/
echo "Compiling..."
./bootstrap --no-system-curl
make -j4

# update the bash profile
echo "Exporting CMake path..."
echo 'export PATH=/nvdli-nano/jetson_demos/cmake-3.13.0/bin/:$PATH' >> ~/.bashrc
source ~/.bashrc

echo "Installing protobuf compiler..."
folder=${HOME}/src
mkdir -p $folder

echo "** Install requirements"
# apt-get install -y autoconf libtool

echo "** Install autoconf from m4"
wget http://ftp://ftp.gnu.org/gnu/m4/m4-1.4.9.tar.gz -q --show-progress --no-clobber
tar xvfz m4-1.4.9.tar.gz
cd m4-1.4.9
./configure --prefix=/usr/local/m4/1_4_9
make
make check
make install

echo "** create symbolic link for m4..."
ln -s /usr/local/m4/1_4_9/bin/m4 /usr/local/bin

echo "** set Environment Variable..."
echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" >> ~/.bashrc
source ~/.bashrc

echo "m4 installation done!"

echo "** Install autoconf from source"
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz -q --show-progress --no-clobber
tar xvfz autoconf-2.69.tar.gz
cd autoconf-2.69
./configure --prefix=/usr/local/autoconf/2_69
make
make install

echo "** create symbolic link for autoconf..."
ln -s /usr/local/autoconf/2_69/bin/autoconf /usr/local/bin/
ln -s /usr/local/autoconf/2_69/bin/autoheader /usr/local/bin/
ln -s /usr/local/autoconf/2_69/bin/autom4te /usr/local/bin/
ln -s /usr/local/autoconf/2_69/bin/autoreconf /usr/local/bin/
ln -s /usr/local/autoconf/2_69/bin/autoscan /usr/local/bin/
ln -s /usr/local/autoconf/2_69/bin/autoupdate /usr/local/bin/
ln -s /usr/local/autoconf/2_69/bin/ifnames /usr/local/bin/

echo "** set Environment Variable..."
echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" >> ~/.bashrc
source ~/.bashrc

echo "autoconf installation done!"
# echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf 
# ldconfig
# ldconfig -v

echo "** Install libtool from source"
wget http://ftp.jaist.ac.jp/pub/GNU/libtool/libtool-2.4.6.tar.gz -q --show-progress --no-clobber
tar xvfz libtool-2.4.6.tar.gz
cd libtool-2.4.6
./configure --prefix=/usr/local/libtool/2_4_6
make
make install

# /usr/local/include
echo "** create symbolic link for libtool"
# /usr/local/bin
ln -s /usr/local/libtool/2_4_6/bin/libtool /usr/local/bin/
ln -s /usr/local/libtool/2_4_6/bin/libtoolize /usr/local/bin/
ln -s /usr/local/libtool/2_4_6/include/libltdl /usr/local/include/
ln -s /usr/local/libtool/2_4_6/include/ltdl.h /usr/local/include/

# /usr/local/lib
ln -s /usr/local/libtool/2_4_6/lib/libltdl.a /usr/local/lib/
ln -s /usr/local/libtool/2_4_6/lib/libltdl.la /usr/local/lib/
ln -s /usr/local/libtool/2_4_6/lib/libltdl.so /usr/local/lib/
ln -s /usr/local/libtool/2_4_6/lib/libltdl.so.7 /usr/local/lib/
ln -s /usr/local/libtool/2_4_6/lib/libltdl.so.7.3.1 /usr/local/lib/

# /usr/local/share/aclocal
ln -s /usr/local/libtool/2_4_6/share/aclocal/libtool.m4 /usr/local/share/aclocal/
ln -s /usr/local/libtool/2_4_6/share/aclocal/ltargz.m4 /usr/local/share/aclocal/
ln -s /usr/local/libtool/2_4_6/share/aclocal/ltdl.m4 /usr/local/share/aclocal/
ln -s /usr/local/libtool/2_4_6/share/aclocal/lt~obsolete.m4 /usr/local/share/aclocal/
ln -s /usr/local/libtool/2_4_6/share/aclocal/ltoptions.m4 /usr/local/share/aclocal/
ln -s /usr/local/libtool/2_4_6/share/aclocal/ltsugar.m4 /usr/local/share/aclocal/
ln -s /usr/local/libtool/2_4_6/share/aclocal/ltversion.m4 /usr/local/share/aclocal/

echo "** set environment variable for libtool"
echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" > ~/.bashrc
echo "PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" > ~/.bashrc
echo "ACLOCAL_PATH=/usr/local/share/aclocal:$ACLOCAL_PATH" > ~/.bashrc
source ~/.bashrc

echo "libool installation done!"


echo "** Download protobuf-3.8.0 sources"
cd $folder
if [ ! -f protobuf-python-3.8.0.zip ]; then
  echo "Downloading protobuf python..."
  wget https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protobuf-python-3.8.0.zip
fi
if [ ! -f protoc-3.8.0-linux-aarch_64.zip ]; then
  echo "Downloading protobuf-linux-aarch_64"
  wget https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protoc-3.8.0-linux-aarch_64.zip
fi

echo "** Install protoc"
unzip protobuf-python-3.8.0.zip
unzip protoc-3.8.0-linux-aarch_64.zip -d protoc-3.8.0
cp protoc-3.8.0/bin/protoc /usr/local/bin/protoc

echo "** Build and install protobuf-3.8.0 libraries"
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
cd protobuf-3.8.0/
./autogen.sh
./configure --prefix=/usr/local
make -j$(nproc)
make check
make install
ldconfig

echo "** Update python3 protobuf module"
# remove previous installation of python3 protobuf module
pip3 uninstall -y protobuf
pip3 install Cython
cd python/
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
python3 setup.py install --cpp_implementation

echo "** Build protobuf-3.8.0 successfully"