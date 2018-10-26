---
layout: post
comments: true
title: "Install Python and Jupyter Notebook on RHEL/CentOS 7"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/anaconda.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    The easiest way to install Python and Jupyter Notebook is probably with Anaconda.<br>
    <br>
    Anaconda is a free and open source distribution of the Python programming language for data science and machine learning related applications, that aims to simplify package management and deployment. Package versions are managed by the package management system conda.
  </div>
</div>

There is a bunch of reasons why it is preferable to use such a thing as Anaconda instead of a traditional Python distributions. For me the most important reason is clearly that there is no risk of messing up your required system libraries.

## Install Python with Anaconda

Read the Anaconda documentation to see what the [difference between Anaconda and Miniconda](https://conda.io/docs/user-guide/install/download.html#anaconda-or-miniconda)

Choose, download and install the one that fits best for your needs:
* Miniconda download page: [https://conda.io/miniconda.html](https://conda.io/miniconda.html)
* Prefer Anaconda under an entreprise network constraint (having a bunch of package already installed will save you lot of time), Anaconda download page: [https://www.anaconda.com/download/#linux](https://www.anaconda.com/download/#linux)

```bash
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod -R 755 Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```

Accept the licence and to prepend the Miniconda3 install location to PATH in your `/home/username/.bashrc`
```bash
Do you wish the installer to prepend the Miniconda3 install location
to PATH in your /home/username/.bashrc ? [yes|no]
[no] >>> yes
```

Refresh your environment variables
```bash
. ~/.bashrc
```

Check your default python location
```bash
which python
```

Install Ipython Notebook
```bash
conda install ipython-notebook
```

You can now launch the IPython Notebook with:
```bash
ipython notebook
```

The IPython Notebook should open in your web browser.

<i>NB: The IPython Notebook is now known as the Jupyter Notebook, so you can also the command:</i>
```bash
jupyter notebook
```
