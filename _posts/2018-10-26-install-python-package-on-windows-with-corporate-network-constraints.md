---
layout: post
comments: true
title: "Install Python on Windows and Deal with Corporate Network Constraints"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/python.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    Using Python in a Microsoft corporate environment can rise various issues. This article introduce 3 different options hoping that one of them will fit to your situation.
  </div>
</div>

## Install Python with Anaconda on Windows
<b>Reference:</b> [Conda documentation](https://conda.io/docs/user-guide/install/windows.html)

Read the Anaconda documentation to see what the [difference between Anaconda and Miniconda](https://conda.io/docs/user-guide/install/download.html#anaconda-or-miniconda)

Choose, download and install the one that fits best for your needs:
* Miniconda download page: [https://conda.io/miniconda.html](https://conda.io/miniconda.html)
* Prefer Anaconda under an entreprise network constraint (having a bunch of package already installed will save you lot of time), Anaconda download page: [https://www.anaconda.com/download/#linux](https://www.anaconda.com/download/#linux)

## Deal with corporate network constraints

Let's say that we would like to install the `pandas_profiling` package. 

#### Solve proxy problems
Trying to install a Python package with the `conda` command line tool, you could end up with a corporate proxy problem and being stuck with something like:

```console
conda install -c conda-forge pandas_profiling
Fetching package metadata:
``` 

To tackle that problem contact your network administrator and ask for details on the proxy.

With it edit your `.condarc` config file.

* with credentials:

```bash
proxy_servers:
  http: http://user:pass@corp.com:8080
  https: https://user:pass@corp.com:8080

ssl_verify: False
``` 

* without credentials:

```bash
proxy_servers:
  http: http://corp.com:8080
  https: https://corp.com:8080

ssl_verify: False
```

Once the proxy information has been updated, you will be able to update conda and install new packages. 

#### Install a Python package with pip without internet access neither administrator permissions

On a machine where you have internet access, download from [https://pypi.org](https://pypi.org) or any other relevant source the .whl file of the package you want to install.

The .whl for pandas_profiling is downloadable from [https://pypi.org/project/pandas-profiling/#files](https://pypi.org/project/pandas-profiling/#files)

Move this .whl file on the destination machine, the one that does not have or restricted internet access, and run the following command (replacing the .whl filename by one you just get):

```bash
pip install pandas_profiling-1.4.1-py2.py3-none-any.whl
```

You could probably face a red warning as:

```bash
xxxxxx xx.x.x requires xxxxxx>=xx.x.x, which is not installed.
```

This message indicates tha you have to follow this process first for each missing Python package before being able to install the initial desired package. 

#### Install a Python package manually

* Download the package source files
* Unzip it if it is
* cd into the directory containing setup.py
* If there is any installation instruction contained in the documentation, read it and follow the instructions OTHERWISE
* Type in 
```python
python setup.py install
```

You may need administrator privileges for the last step.