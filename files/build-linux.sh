#!/bin/sh

set -ex

cd /home/vagrant
virtualenv --system-site-packages build
cd build
. ./bin/activate

hg clone /vagrant/libyaml
hg clone /vagrant/pyyaml

cd libyaml
./bootstrap
./configure
make dist dist-zip
tar -xzvf yaml-*.*.*.tar.gz
mv yaml-*.*.*.tar.gz yaml-*.*.*.zip /vagrant/dist/linux
cd yaml-*.*.*
./configure --prefix=/home/vagrant/build
make
make install

cd ../../pyyaml
python setup.py --with-libyaml build_ext -I ../include -L ../lib build test sdist --formats=gztar,zip
cp dist/* /vagrant/dist/linux


