---
layout: post
comments: true
title: "Install Last PgAdmin 4 on RHEL/CentOS 7"
categories: post
author: "Benjamin Berhault"
description: PgAdmin 4 is a rewrite of the popular pgAdmin3 management tool for the PostgreSQL (<a href="http://www.postgresql.org">http://www.postgresql.org</a>) database. Installing the last version under CentOS 7 can be a bit tricky, here it is one way how to do it.
image: images/pgadmin.png
---

Download the Python wheel for the last pgAdmin release listed on the following page : [https://www.pgadmin.org/download/pgadmin-4-python-wheel/](https://www.pgadmin.org/download/pgadmin-4-python-wheel/).
```console
cd ~/Downloads
wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v4.10/pip/pgadmin4-4.10-py2.py3-none-any.whl
```

The pgAdmin 4 team advices to use a virtual environment therefore create one dedicated to pgAdmin.
```console
conda create -n pgadmin4 python=3.6
```

Activate this new environment.
```console
conda activate pgadmin4
```

Install the Python wheel you just download.
```console
pip install pgadmin4-4.10-py2.py3-none-any.whl
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
vi /home/username/anaconda3/envs/pgadmin4/lib/python3.6/site-packages/pgadmin4/config_local.py
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
eval "$(conda shell.bash hook)"
conda activate pgadmin4
python /home/username/anaconda3/envs/pgadmin4/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py
```

Save and close it (`:wq`).

Add the `~/.shortcuts` directory to your `~/.bashrc` file.
```console
echo 'export PATH="/home/username/.shortcuts:$PATH"' >> ~/.bashrc
```

In a new terminal window, you will now be able to launch pgAdmin 4 just by typing the `pgadmin4` command.


#### Connecting to a PostgreSQL database with pgAdmin4

* Open pgAdmin4
* Under the **Browser** panel right click on **Servers > Create > Server...** 
* Enter any relevant name for your server eg: *Localhost*
* Click on the **Connection** tab
* Enter a **Host** (on your own local system the default is "localhost" otherwise the IP address of the system where the PostgreSQL database is installed)
* Enter the **Port** (the default port for PostgreSQL server is "5432")
* Enter the **Maintenance Database** name (the default is *postgres*)
* Enter the **Username** (the default user is *postgres*)
* Enter the **Password** (the password for the *postgres* user)
* **Save**

Now the server and its objects should appear.