---
layout: post
comments: true
title: "Install Python and Jupyter Notebook on RHEL/CentOS 7"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/node_js.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    The easiest way to install Python and Jupyter Notebook is probably with Anaconda.
  </div>
</div>

Install Python 3 and pip

Get Anaconda/Miniconda https://conda.io/miniconda.html

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod -R 755 Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh

Accept the licence and prepend the Miniconda3 install location to PATH in your /home/benjamin/.bashrc

Do you wish the installer to prepend the Miniconda3 install location
to PATH in your /home/benjamin/.bashrc ? [yes|no]
[no] >>> yes

Refresh your environment variables

. ~/.bashrc

Check your default python location

which python

Install Ipython notebook

conda install ipython-notebook

Jupyter notebook

From a repository where you want maintain your ipython notebook launch

jupyter notebook

The ipython notebook will be launching then in the web browser 