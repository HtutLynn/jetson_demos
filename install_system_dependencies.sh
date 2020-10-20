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
apt-get install -y autoconf libtool

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