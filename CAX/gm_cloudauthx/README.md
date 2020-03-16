CloudAuthX
=================

A Windows and Linux compatible version of CloudAuthX.

Status
------

* CryptoPP is currently statically linking and the module works with it.
* Bootil is currently statically linking and the module works with it.

Linux
------

Ubuntu 14.04

```
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install gcc-4.7 g++-4.7
sudo apt-get install gcc-4.7-multilib g++-4.7-multilib
// sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7
sudo update-alternatives --config gcc
sudo apt-get install premake4
sudo apt-get install upx
```