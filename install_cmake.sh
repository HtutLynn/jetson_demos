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

