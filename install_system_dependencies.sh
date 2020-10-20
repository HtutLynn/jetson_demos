#!/bin/bash

set -e
apt-get update
apt-get install -y autoconf libtool automake dh-autoreconf automake
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
cd /nvdli-nano/jetson_demos

echo "Copy protoc installation files into jetson_demos"
cp -r /nvdli-nano/data/protoc-3.13.0 /nvdli-nano/jetson_demos/protoc-3.13.0
cp -r /nvdli-nano/data/protobuf-3.13.0 /nvdli-nano/jetson_demos/protobuf-3.13.0
cp protoc-3.13.0/bin/protoc /usr/local/bin/protoc

echo "** Build and install protobuf-3.13.0 libraries"
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
cd protobuf-3.13.0/
./autogen.sh
./configure --prefix=/usr/local
make -j$(nproc)
make check
make install
ldconfig

cho "** Update python3 protobuf module"
# remove previous installation of python3 protobuf module
python3 -m pip uninstall -y protobuf
python3 -m pip install Cython
cd python/
python3 setup.py build --cpp_implementation
python3 setup.py test --cpp_implementation
python3 setup.py install --cpp_implementation

echo "** Build protobuf-3.13.0 successfully"