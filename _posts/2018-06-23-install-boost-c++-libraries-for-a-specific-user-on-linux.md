---
layout: post
comments: true
title: "Install Boost C++ Libraries for a Specific User on Linux"
categories: post
author: "Benjamin Berhault"
description: Boost provides free peer-reviewed portable C++ source libraries. Libraries are intended to work well with the C++ Standard Library. Boost libraries are intended to be widely useful, and usable across a broad spectrum of applications. The Boost license encourages both commercial and non-commercial use.
image: images/boost.png
---

<b>Reference:</b> [https://www.boost.org/](https://www.boost.org/)

<h3>Prerequisite</h3> 
* GCC installed

<h3>Installation</h3>
Check the last archive of Boost C++ libraries available from: [https://www.boost.org/users/download/](https://www.boost.org/users/download/)

Download it on your machine.
```bash
cd ~/Downloads
wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.bz2
tar jxf boost_1_70_0.tar.bz2
```

Some <code>tar</code> options are:
* `x` - extract
* `v` - verbose output (lists all files as they are extracted)
* `j` - deal with bzipped file
* `f` - read from a file, rather than a tape device

Build Boost
```bash
cd ./boost_1_70_0
mkdir ~/.local/boost-libs
./bootstrap.sh --prefix=$HOME/.local/boost-libs
./b2 install
```

Make Boost available for your environment:
```bash
vi ~/.bashrc
```

Add at the end of <b>~/.bashrc</b>:
```bash
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:~/.local/boost-libs/include
export LIBRARY_PATH=$LIBRARY_PATH:~/.local/boost-libs/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.local/boost-libs/lib
```

<b>LD_LIBRARY_PATH</b> is used by your program to search directories containing shared libraries after it has been successfully compiled and linked.
<code>LD_LIBRARY_PATH</code> is for dynamically linked (<code>.so</code>) libraries.

<b>LIBRARY_PATH</b> is used by gcc before compilation to search directories containing static libraries that need to be linked to your program.
<code>LIBRARY_PATH</code> for static (<code>.a</code>) libraries.

Reload <b>~/.bashrc</b>:
```bash
source ~/.bashrc
```

or you can also use the shorter version of the command:
```bash
. ~/.bashrc
```

<h3>Test it</h3>

Edit a script <b>`Hello.cpp`</b> to check if Boost has been properly installed
```cpp
#include <iostream>
#include <boost/format.hpp>

using namespace std;
using namespace boost;

int main()
{
    unsigned int arr[5] = { 0x05, 0x04, 0xAA, 0x0F, 0x0D };
    cout << format("%02X-%02X-%02X-%02X-%02X")
            % arr[0]
            % arr[1]
            % arr[2]
            % arr[3]
            % arr[4]
         << endl;
}
```

Compile and run this script
```bash
g++ --std=c++14 Hello.cpp -o run
./run
```

Should return
```bash
05-04-AA-0F-0D
```
