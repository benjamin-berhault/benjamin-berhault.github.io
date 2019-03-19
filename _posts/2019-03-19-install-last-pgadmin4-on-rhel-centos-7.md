---
layout: post
comments: true
title: "Install Last PgAdmin 4 on RHEL/CentOS 7"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <center><img src="{{ '/images/pgadmin.png' | relative_url }}" class="responsive-img"></center>
  </div>
  <div class="col grid s12 m6 l9 ">
    PgAdmin 4 is a rewrite of the popular pgAdmin3 management tool for the PostgreSQL (<a href="http://www.postgresql.org">http://www.postgresql.org</a>) database. Installing the last version under CentOS 7 can be a bit tricky, here it is one way to do it.
  </div>
</div>

Download the Python wheel for the last pgAdmin release listed on the following page : [https://www.pgadmin.org/download/pgadmin-4-python-wheel/](https://www.pgadmin.org/download/pgadmin-4-python-wheel/).
```console
cd ~/Downloads
wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v4.3/pip/pgadmin4-4.3-py2.py3-none-any.whl
```

The pgAdmin 4 team advices to use a virtual environment therefore create one dedicated to pgAdmin.
```console
conda create -n pgadmin4 python=3.6
```

Activate this new environment.
```console
source activate pgadmin4
```

Install the Python wheel you just download.
```console
pip install pgadmin4-4.3-py2.py3-none-any.whl
```

Check the pgAdmin4 installation location.
```console
sudo find / -name pgAdmin4.py
```

It should return something like:
```console
/home/username/anaconda3/envs/pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py
```

Edit a `config_local.py` in the same directory.
```console
vi /home/username/anaconda3/envs/pgadmin4/lib/python3.5/site-packages/pgadmin4/config_local.py
```

Insert (`i`) in it the following content: 
```bash
import os
DATA_DIR = os.path.realpath(os.path.expanduser(u'~/.pgadmin/'))
LOG_FILE = os.path.join(DATA_DIR, 'pgadmin4.log')
SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')
SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions') 
STORAGE_DIR = os.path.join(DATA_DIR, 'storage')
SERVER_MODE = False
```

Save and close this configuration file (`:wq`).

Run pgAdmin 4.
```console
python $(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib() + '/pgadmin4/pgAdmin4.py')")
```

Open the given to address ([http://127.0.0.1:5050](http://127.0.0.1:5050)) to access the PgAdmin 4 interface.

#### Create a shortcut

Create a dedicated folder for your shortcuts.
```console
mkdir ~/.shortcuts
touch ~/.shortcuts/pgadmin4
chmod +x ~/.shortcuts/pgadmin4
```

Edit in it a bash script for pgadmin4 
```console
vi ~/.shortcuts/pgadmin4
```

..with the following content: 
```bash
#!/bin/bash
source activate pgadmin4
python /home/username/anaconda3/envs/pgadmin4/lib/python3.5/site-packages/pgadmin4/pgAdmin4.py
```

Save and close it (`:wq`).

Add the `~/.shortcuts` directory to your `~/.bashrc` file.
```console
echo 'export PATH="/home/username/.shortcuts:$PATH"' >> ~/.bashrc
```

In a new terminal window, you will now be able to launch pgAdmin 4 just by typing the `pgadmin4` command.
