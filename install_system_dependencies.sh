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
cd /nvdli-nano/jetson_demos

echo "** Install automake..."
wget http://ftp.gnu.org/gnu/automake/automake-1.9.6.tar.gz
tar automake-1.9.6.tar.gz
cd automake-1.9.6
./configure --prefix=/usr/local/automake/1_9_6
make
make install

echo "** Create Symbolic Link"
ln -s /usr/local/automake/1_9_6/bin/aclocal /usr/local/bin/
ln -s /usr/local/automake/1_9_6/bin/aclocal-1.9.6 /usr/local/bin/
ln -s /usr/local/automake/1_9_6/bin/automake /usr/local/bin/
ln -s /usr/local/automake/1_9_6/bin/automake-1.9.6 /usr/local/bin/

echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH" >> ~/.bashrc
source ~/.bashrc
cd /nvdli-nano/jetson_demos

echo "Copy protoc installation files into jetson_demos"
cp -r /nvdli-nano/data/protoc-3.13.0 /nvdli-nano/jetson_demos/protoc-3.13.0
cp -r /nvdli-nano/data/protobuf-3.13.0 /nvdli-nano/jetson_demos/protobuf-3.13.0

cp /nvdli-nano/jetson_demos/protoc-3.13.0/bin/protoc /usr/local/bin/protoc

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