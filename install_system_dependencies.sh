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

wget https://github.com/protocolbuffers/protobuf/archive/v3.9.0.zip
unzip v3.9.0.zip
cd protobuf-3.9.0
./autogen.sh
./configure --prefix=/usr/local/protobuf/3_9_0
make
make install

// /usr/local/bin
ln -s /usr/local/protobuf/3_9_0/bin/protoc /usr/local/bin/

// /usr/local/include/google
ln -s /usr/local/protobuf/3_9_0/include/google/protobuf /usr/local/include/google/

// /usr/local/lib
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf.a /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf.la /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf-lite.a /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf-lite.la /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf-lite.so /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf-lite.so.20 /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf-lite.so.20.0.0 /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf.so /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf.so.20 /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotobuf.so.20.0.0 /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotoc.a /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotoc.la /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotoc.so /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotoc.so.20 /usr/local/lib/
ln -s /usr/local/protobuf/3_9_0/lib/libprotoc.so.20.0.0 /usr/local/lib/

// /usr/local/lib/pkgconfig
ln -s /usr/local/protobuf/3_9_0/lib/pkgconfig/protobuf-lite.pc /usr/local/lib/pkgconfig/
ln -s /usr/local/protobuf/3_9_0/lib/pkgconfig/protobuf.pc /usr/local/lib/pkgconfig/

echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH' >> ~/.bashrc
source >> ~/.bashrc