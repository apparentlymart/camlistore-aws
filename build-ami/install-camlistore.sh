#!/bin/bash

set -ex

# Some stuff we're going to need to build
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential dpkg-dev devscripts wget

mkdir /tmp/golang-install
cd /tmp/golang-install

# Get the go 1.3 packages from Debian unstable
wget http://cloudfront.debian.net/debian/pool/main/g/golang/golang-go_1.3.3-1_amd64.deb
wget http://cloudfront.debian.net/debian/pool/main/g/golang/golang-src_1.3.3-1_amd64.deb
wget http://cloudfront.debian.net/debian/pool/main/g/golang/golang-go-linux-amd64_1.3.3-1_amd64.deb
sudo dpkg -i *.deb

cd
rm -rf /tmp/golang-install

# now that we have go installed, we can build camlistore
wget https://github.com/bradfitz/camlistore/archive/0.8.zip
unzip 0.8.zip
cd camlistore-0.8
go run make.go

cd
sudo mkdir -p /usr/local/bin
sudo cp camlistore-0.8/bin/* /usr/local/bin
sudo mkdir -p /usr/local/lib/camlistore/server/camlistored
sudo mkdir -p /usr/local/lib/camlistore/third_party/closure
sudo cp -r camlistore-0.8/server/camlistored/ui /usr/local/lib/camlistore/server/camlistored/ui
sudo cp -r camlistore-0.8/third_party/closure /usr/local/lib/camlistore/third_party/closure

# We don't need the source files anymore
rm -rf camlistore-0.8 0.8.zip

# Prepare to run camlistore as the user "camlistore", rather than
# as "admin". (camlistore doesn't need to and shouldn't be able to sudo)
sudo adduser --disabled-password --gecos "" camlistore
sudo mkdir -p /home/camlistore/.config/camlistore
sudo chown -R camlistore.camlistore /home/camlistore/.config
