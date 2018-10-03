---
layout: post
comments: true
title: "Install MetaTrader under CentOS 7"
categories: post
author: "Benjamin Berhault"
tags: ["metatrader"]
---


<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ site.baseurl | replace: '//', '/' }}images/metatrader4.png" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    MetaTrader can be installed and run on computers with Linux using Wine. Wine is a free software that allows users of the Unix-based systems to run an application developed for the Microsoft Windows systems. Even if the documentation explains <a href="https://www.metatrader4.com/en/trading-platform/help/userguide/install_linux">how to install it on Ubuntu</a>, it seems to be more tricky on some other Linux distributions. This post focuses on how to have MeatTrader 4 operational on CentOS 7.
  </div>
</div>

2 steps are involved: 
* &bull; Installing Wine
* &bull; Solving Specify the Proxy problem during the MT4 installation on Linux


### Install Wine on CentOS 7‎‎

<p style="text-align: right"><b>Source:</b> <i><a href="https://www.systutorials.com/239913/install-32-bit-wine-1-8-centos-7/">How to Install Wine 32-bit on CentOS</a></i></p>

We have today only x86-64 Wine versions. However, many Windows .exe files are 32-bit and with 64-bit versions, some software have installation file in 32-bit. And other such as Office 2007, even 32-bit wine is preferred.

#### One single script to build and install Wine

The whole process in this post has already been written as a shell script.
* &bull; Erase old wine versions installed.
```bash
yum erase wine wine-*
```

* &bull; Download this script: <a href="{{ site.url }}/scripts/install-wine-i686-centos7.sh">install-wine-i686-centos7.sh</a>.
* &bull; Give execute permission to it
```bash
chmod +x ./install-wine-i686-centos7.sh
```

* &bull; And execute it
```bash
sudo ./install-wine-i686-centos7.sh
```

#### Step by step process

Erase old wine versions installed

If you ever installed wine packages, erase them first as we will build wine from the source.

```bash
yum erase wine wine-*
```

Install packages needed to build wine

```bash
yum install samba-winbind-clients -y
yum groupinstall 'Development Tools' -y
yum install libjpeg-turbo-devel libtiff-devel freetype-devel -y
yum install glibc-devel.{i686,x86_64} libgcc.{i686,x86_64} libX11-devel.{i686,x86_64} freetype-devel.{i686,x86_64} gnutls-devel.{i686,x86_64} libxml2-devel.{i686,x86_64} libjpeg-turbo-devel.{i686,x86_64} libpng-devel.{i686,x86_64} libXrender-devel.{i686,x86_64} alsa-lib-devel.{i686,x86_64} -y 

# ... and more ...
# Check the `install-wine-i686-centos7.sh` script for more packages needed.
```

Download and unpack the source package

```bash
ver=2.0.2 # We will use this as the example. 
vermajor=$(echo ${ver} | cut -d'.' -f1)
verurlstr=$(echo ${ver} | cut -d'.' -f1,2)

cd /usr/src
if [[ "${vermajor}" == "1" ]]; then
  wget http://dl.winehq.org/wine/source/${verurlstr}/wine-${ver}.tar.bz2 -O wine-${ver}.tar.bz2
  tar xjf wine-${ver}.tar.bz2
elif [[ "${vermajor}" == "2" ]]; then
  wget http://dl.winehq.org/wine/source/${verurlstr}/wine-${ver}.tar.xz -O wine-${ver}.tar.xz
  tar xf wine-${ver}.tar.xz
fi
```

Build wine 32-bit and 64-bit versions

Make directories for building wine 32-bit and 64-bit versions.

```bash
cd wine-${ver}/
mkdir -p wine32 wine64
```

Build the 64-bit version first as 32-bit version building depends on it.

```bash
cd wine64
../configure --enable-win64
make -j 4
```

Build the 32-bit version now.

```bash
cd ../wine32
PKG_CONFIG_PATH=/usr/lib/pkgconfig ../configure --with-wine64=../wine64
make -j 4
```

Install wine 32-bit and 64-bit versions

Now, we can install Wine. The trick is to install 32-bit version first and then the 64-bit version.

As we are still in the win32 directory, run

```bash
make install
```

Install the 64-bit version:

```bash
cd ../wine64
make install
```

By now, if everything goes well, you have successfully installed the Wine 32-bit and 64-bit versions. You may double-check it with the file command:

```bash
$ file `which wine`
/usr/local/bin/wine: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.32, BuildID[sha1]=a83b9f0916e6c0d5427e2c38a172c93bd8023d98, not stripped
$ file `which wine64`
/usr/local/bin/wine64: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.32, BuildID[sha1]=4d8e8468402bc63bd2a72c59c57fcad332235d41, not stripped
```

Note the “ELF 32-bit” and “ELF 64-bit” in the file type strings.

Now you can run your 32-bit Windows application on CentOS 7. Enjoy :-)

### Solving Specify the Proxy problem during the MT4 installation on Linux

<p style="text-align: right"><b>Source:</b> <i><a href="https://www.techiediaries.com/trading/how-to-solve-specify-the-proxy-problem-when-installing-mt4-under-ubuntu-linux/">How to solve Specify The Proxy problem when installing MT4 on Ubuntu (Linux)</a></i></p>

#### Problem

After downloading the MT4 setup file designed for Windows with Wine on Linux and after running it, you suddenly stumble upon this little problem related to some proxy information no one knows.

```bash
 Specify the Proxy Server
```

#### Solution

So the solution is simple you just need to install MT4 under a computer with Windows then just look for MT4 files under Program Files and import them on your Linux computer :

<ol>
  <li>Install MT4 on a Windows machine</li>
  <li>Zip MT4 files under Program Files</li>
  <li>Extract your zipped MT4 files on your Linux machine</li>
  <li>Run MT4 with Wine
      <ol>
        <li><code>wine terminal.exe</code> for MetaTrader</li>
        <li><code>wine metaeditor.exe</code> for MetaEditor</li>
      </ol>
  </li>
  <li>Specify the information of your broker</li>

</ol>


