nginx-static
============

The purpose of this repository is to build a somewhat static nginx binary with the latest
version of OpenSSL for RHEL 5 in order to support TLS 1.1 and 1.2.

### How to build

First we need to install the build dependencies.

    yum -y install gcc gcc-c++ curl perl pam-devel

Then we need to clone this repo and actually run the build.

    git clone https://github.com/jasonwbarnett/nginx-static.git
    cd nginx-static
    ./build.sh

The binary can then be found `./build/nginx-1.8.0/objs/nginx`
