---
layout: post
comments: true
title: "Install Anaconda Python Distribution for all users on RHEL/CentOS 7"
categories: post
author: "Benjamin Berhault"
description: The easiest way to install Python and Jupyter Notebook is probably with Anaconda.<br><br>Anaconda is a free and open source distribution of the Python programming language for data science and machine learning related applications, that aims to simplify package management and deployment. Package versions are managed by the package management system conda.
image: images/anaconda.png
---

First install `bzip2` and `wget` if you do not have those yet
```console
sudo yum install bzip2 wget
```

Download the last Anaconda installer for your environment: [https://repo.continuum.io/miniconda/](https://repo.continuum.io/miniconda/)
```console
cd ~/Downloads
wget https://repo.continuum.io/miniconda/Miniconda3-4.5.12-Linux-x86_64.sh
```

Run it with sudo privileges
```console
sudo sh Miniconda3-4.5.12-Linux-x86_64.sh
```

The installer will then begin and proceed with a series of questions. 
```console
Do you accept the license terms? [yes|no]
 [no] >>>
 Please answer 'yes' or 'no':'
 >>> yes

Anaconda3 will now be installed into this location:
 /root/miniconda3

- Press ENTER to confirm the location
 - Press CTRL-C to abort the installation
 - Or specify a different location below

[/root/anaconda3] >>> /usr/local/miniconda3
 PREFIX=/usr/local/miniconda3
```

I will <b>NOT</b> risk to prepend the Anaconda install location to PATH in your `/root/.bashrc`

All users have now access to Anaconda through:
* conda - /usr/local/miniconda3/bin/conda
* python - /usr/local/miniconda3/bin/python

You can install new packages with through the `conda` command line tool
```console
sudo /usr/local/miniconda3/bin/conda install -c anaconda pip
```

And or with `pip` 
```console
sudo /usr/local/miniconda3/bin/pip install flask
```

Let's update the Python packages
```console
sudo /usr/local/miniconda3/bin/conda upgrade --all -y
```

Remove unused packages
```console
sudo /usr/local/miniconda3/bin/conda clean --yes --all
```

## A bunch of useful commands

List the previous versions of your conda environment
```console
conda list --revisions
```

Rollback your environment to a specific previous version
```console
conda install --revision 18
```

Install all required packages listed in a requirements.txt file
```console
while read requirement; do conda install --yes $requirement; done < requirements.txt
```

Uninstall all unused packages in a conda virtual environment
```
conda clean --yes --all
```