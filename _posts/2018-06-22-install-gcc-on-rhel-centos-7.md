---
layout: post
title: "Build and Install the Last GCC on RHEL/CentOS 7"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/gcc.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    The GNU Compiler Collection includes front ends for C, C++, Objective-C, Fortran, Ada, and Go, as well as libraries for these languages (libstdc++,...). GCC was originally written as the compiler for the GNU operating system. The GNU system was developed to be 100% free software, free in the sense that it respects the user's freedom.
  </div>
</div>

<b>Reference:</b> [GCC official website](https://www.gnu.org/software/gcc/)


The default GCC that comes with the CentOS 7.2 is GCC 4.8.5 which does not support the complete C++11 standard, for example, it does not fully support [regular expressions](http://en.cppreference.com/w/cpp/regex). In order to use regular expression functions, [we need to install at least GCC 4.9.0](https://stackoverflow.com/a/8061172/6064933). The following installation procedure is applicable to CentOS 7 and are not tested on other systems.

<h3>Downloading GCC source code</h3>

You can download the GCC source code from the [official GNU ftp](https://ftp.gnu.org/gnu/gcc/). I choose to install [version 8.1.0](https://ftp.gnu.org/gnu/gcc/gcc-8.2.0/).

```bash
cd ~/Downloads
wget https://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz
```

<h3>Build and install</h3>

Unlike other packages, it is recommended to create another build directory outside the GCC source directory where we build GCC.

<b>Reference:</b> https://stackoverflow.com/questions/39854114/set-gcc-version-for-make-in-shell
```bash
tar xzf gcc-8.2.0.tar.gz
cd gcc-8.2.0
./contrib/download_prerequisites
cd ..
mkdir gcc-8.2.0-build
cd gcc-8.2.0-build
../gcc-8.2.0/configure --enable-languages=c,c++ --disable-multilib
make
sudo make install
```

<i>(If you prefer to have GCC in your HOME directory add `--prefix=$HOME/gcc-8.2.0` to the `configure` command)</i>

The last command will end up with message specifying where GCC has been installed. 
```bash
----------------------------------------------------------------------
Libraries have been installed in:
   /usr/local/lib/../lib64

If you ever happen to want to link against installed libraries
in a given directory, LIBDIR, you must either use libtool, and
specify the full pathname of the library, or use the `-LLIBDIR'
flag during linking and do at least one of the following:
   - add LIBDIR to the `LD_LIBRARY_PATH' environment variable
     during execution
   - add LIBDIR to the `LD_RUN_PATH' environment variable
     during linking
   - use the `-Wl,-rpath -Wl,LIBDIR' linker flag
   - have your system administrator add LIBDIR to `/etc/ld.so.conf'

See any operating system documentation about shared libraries for
more information, such as the ld(1) and ld.so(8) manual pages.
----------------------------------------------------------------------
```

The compilation process may take a long time and you need to be patient. It will install GCC under <code>/usr/local</code>. You can change the install dir using <code>--prefix</code> option when you configure.
Post-installation

You should add the install dir of GCC to your <code>PATH</code> and <code>LD_LIBRARY_PATH</code> in order to use the newer GCC. Maybe a restart of your current session is also needed.

To do that edit your shell's rcfile (<code>~/.bashrc</code>) and add :
```bash
export PATH=/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH
```

<h3>Check your GCC installation</h3>

Check GCC location
```bash
whereis gcc
```

Check GCC compiler version
```bash
gcc --version
```

<h3>Test GCC</h3>

Edit a script <b>`Hello.cpp`</b>
```cpp
#include <iostream>
using namespace std;

int main()
{
    	cout << "Hello World!"  << endl;
	return 0;
}
```

Build & run
```console
~]$ g++ --std=c++14 Hello.cpp -o run
~]$ ./run 
Hello World!
```