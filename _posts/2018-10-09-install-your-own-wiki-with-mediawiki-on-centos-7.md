---
layout: post
comments: true
title: "Install Your Own Wiki with Mediawiki on RHEL/CentOS 7"
categories: post
author: "Benjamin Berhault"
description: It does not matter whether you are employed in a real estate company or a restaurant. Every company needs a wiki. A wiki is a tool for managing knowledge. And as a manager you will want to perpetuate and promote the rapid transmission of knowledge among collaborators, so you will need an operational manual aka wiki. A wiki is critical for competitive business but it is also incredibly useful for an individual to manage and organize knowledge.<br><br> In short, whether you are a company or an individual wishing to manage a knowledge a wiki is the tool you have to have.<br><br> Here, we'll see how to install MediaWiki on RHEL/CentOS 7 supported by PostgreSQL and Apache that makes it working like a charm.
image: images/dark_wiki.png
---

#### Page content
<div style="padding-left: 30px">
<a href="#mediawiki_prerequisites">MediaWiki Prerequisites</a>
  <div style="padding-left: 30px">
    &minus; <a href="#install_postgresql">Install PostgreSQL 10 on CentOS 7</a><br>
        &minus; <a href="#install_latest_php">Install the latest PHP</a>
    </div>
<a href="#install_mediawiki">Install MediaWiki</a>
</div>


<span id="mediawiki_prerequisites"></span>
## MediaWiki Prerequisites
<span id="install_postgresql"></span>
### Install PostgreSQL 10 on CentOS 7
<b>Repo:</b> [https://yum.postgresql.org/10/redhat/rhel-7-x86_64/](https://yum.postgresql.org/10/redhat/rhel-7-x86_64/)

Install PostgreSQL repository in your system
```bash
sudo rpm -Uvh https://yum.postgresql.org/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
```

Install PostgreSQL server & development shared library
```bash
sudo yum install postgresql10-server postgresql10 postgresql10-devel
```

Initialize it before using for the first time.
```bash
/usr/pgsql-10/bin/postgresql-10-setup initdb
```

By default, PostgreSQL does not allow password authentication. We will change that by editing its hostbased authentication (HBA) configuration.

Open the HBA configuration with your favorite text editor.
```bash
sudo vi /var/lib/pgsql/10/data/pg_hba.conf
```

Edit the corresponding lines to have:
```bash
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
```

Save and exit. PostgreSQL is now configured to allow password authentication.

#### Start PostgreSQL server
To start PostgreSQL service, run:
```bash
systemctl start postgresql-10
```

To enable PostgreSQL on system startup, run:
```bash
systemctl enable postgresql-10
```

To check the status of PostgreSQL service, run:
```bash
systemctl status postgresql-10
```

#### PostgreSQL setup
we'll create a database named wikidb, owned by a user named wikiuser. From the command-line, as the postgres user
```bash
sudo -i -u postgres
```

... perform the following steps.
```bash
createuser -S -D -R -P -E wikiuser 
# (then enter the password)
createdb -O wikiuser wikidb
```

* <code>-S</code> The new user will not be a superuser. This is the default.
* <code>-D</code> The new user will not be allowed to create databases. This is the default.
* <code>-R</code> The new user will not be allowed to create new roles. This is the default.
* <code>-P</code> If given, createuser will issue a prompt for the password of the new user. This is not necessary if you do not plan on using password authentication.
* <code>-E</code> Encrypts the user's password stored in the database. If not specified, the default password behavior is used.

<span id="install_latest_php"></span>
### Install the latest PHP
#### Install Remi repository
<b>Source:</b> [https://www.if-not-true-then-false.com/2010/install-apache-php-on-fedora-centos-red-hat-rhel](https://www.if-not-true-then-false.com/2010/install-apache-php-on-fedora-centos-red-hat-rhel)

Before we can actually install Remi Dependency, we need to enable the EPEL repository first. In Fedora it should be enabled by default, but under RHEL/CentOS 7 you will need to do:
```bash
# Install epel-release rpm
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# Install epel-release rpm package
sudo yum install epel-release
# Install remi-release rpm
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
# Install remi-release rpm package
sudo yum --enablerepo=remi install remi-release
```

#### Install Apache (httpd) Web server and PHP
Remi will not enabled by default, when you need it just do
```bash
sudo yum --enablerepo=remi,remi-php72 install httpd php php-common
sudo systemctl restart httpd.service
```

#### Install PHP modules
* <b>OPcache (php-opcache)</b> – The Zend OPcache provides faster PHP execution through opcode caching and optimization.
* <b>APCu (php-pecl-apcu)</b> – APCu userland caching
* <b>CLI (php-cli)</b> – Command-line interface for PHP
* <b>PEAR (php-pear)</b> – PHP Extension and Application Repository framework
* <b>PDO (php-pdo)</b> – A database access abstraction module for PHP applications
* <b>MySQL (php-mysqlnd)</b> – A module for PHP applications that use MySQL databases
* <b>PostgreSQL (php-pgsql)</b> – A PostgreSQL database module for PHP
* <b>MongoDB (php-pecl-mongodb)</b> – PHP MongoDB database driver
* <b>Redis (php-pecl-redis)</b> – Extension for communicating with the Redis key-value store
* <b>Memcache (php-pecl-memcache)</b> – Extension to work with the Memcached caching daemon
* <b>Memcached (php-pecl-memcached)</b> – Extension to work with the Memcached caching daemon
* <b>GD (php-gd)</b> – A module for PHP applications for using the gd graphics library
* <b>XML (php-xml)</b> – A module for PHP applications which use XML
* <b>MBString (php-mbstring)</b> – A module for PHP applications which need multi-byte string handling
* <b>MCrypt (php-mcrypt)</b> – Standard PHP module provides mcrypt library support

```bash
sudo yum --enablerepo=remi,remi-php72 install php-pecl-apcu php-cli php-pear php-pdo php-mysqlnd php-pgsql php-pecl-mongodb php-pecl-memcache php-pecl-memcached php-gd php-mbstring php-mcrypt php-xml
sudo systemctl restart postgresql-10
```

#### Start Apache HTTP server (httpd) and autostart Apache HTTP server (httpd) on boot
```bash
sudo systemctl start httpd ## use restart after update
sudo systemctl enable httpd
```

#### Create test PHP page to check that Apache, PHP and PHP modules are working

Give to your current user read write access
```
sudo setfacl -Rm u:username:rwx /var/www
```

Edit a <code>test.php</code> page
```bash
vi /var/www/html/index.php
```

Add to that file a `phpinfo()` function to check your PHP settings.
```php
<?php
    phpinfo();
```

Open the page [http://localhost/test.php](http://localhost/test.php) to see the result.
If you encounter a <b>403 error message</b>, read the below section.

#### Allow access to the web server
<b>Source:</b> [https://www.security-helpzone.com/2017/02/20/centos-7-apache-2-4-resoudre-acces-403-forbidden/](https://www.security-helpzone.com/2017/02/20/centos-7-apache-2-4-resoudre-acces-403-forbidden/)

By default SELinux prevented Apache from serving my files, even in read mode: hence a 403 error, forbidden access.

When you have finished installing Apache, ensures apache (through the apache group) has read-write access. 

```bash
sudo chown -R apache:apache /var/www ## chown defines who owns the file
```

Modify permissions a little bit to ensure that read access is permitted to the general web directory, and all of the files and folders inside, so that pages can be served correctly
```bash
cd /var/www/html
## chmod defines who can do what
sudo find . -type d -exec chmod 0755 {} \;
sudo find . -type f -exec chmod 0644 {} \;
```

SELinux protects web services, check if SELinux is enabled.
```bash
sestatus
```

If SELinux is in "enforce" mode, then SELinux is enabled. To see if it's a problem, turn it off, and then retest your URL.
```bash
sudo setenforce 0
```

If it works, allow Apache to serve web content:
```bash
sudo chcon -R -t httpd_sys_rw_content_t /var/www/
```

Enable SELinux again.
```bash
sudo setenforce 1
```

#### Enable Remote Connection to Apache HTTP Server (httpd)
To enable remote connection to Apache HTTP Server (httpd) open web server port (80) on Iptables Firewall. Follow the 2. from [https://www.if-not-true-then-false.com/2010/install-apache-php-on-fedora-centos-red-hat-rhel/](https://www.if-not-true-then-false.com/2010/install-apache-php-on-fedora-centos-red-hat-rhel/)


<span id="install_mediawiki"></span>
## Install MediaWiki
Check the MediaWiki version you want to install: [https://releases.wikimedia.org/mediawiki](https://releases.wikimedia.org/mediawiki)

Download MediaWiki.
```bash
cd ~/Downloads
wget https://releases.wikimedia.org/mediawiki/1.32/mediawiki-1.32.2.tar.gz
```

Unpack the package.
```bash
tar xzf mediawiki-1.32.2.tar.gz
```

Move MediaWiki files to your webroot directory <code>/var/www/html</code>
```bash
mkdir /var/www/html/mediawiki
mv mediawiki-1.31.0-rc.0/* /var/www/html/mediawiki
```

#### Permit PHP to connect to PostgreSQL
<b>Source:</b> [https://stackoverflow.com/questions/27749691/php-cant-connect-to-postgresql-on-centos-7](https://stackoverflow.com/questions/27749691/php-cant-connect-to-postgresql-on-centos-7)

SELinux could block your database connection.

Make sure that you set the correct boolean to allow your web application to talk to the database:
```bash
sudo setsebool -P httpd_can_network_connect_db 1
```

#### Setup file uploads permissions
<b>Reference:</b> [https://www.mediawiki.org/wiki/Manual:Configuring_file_uploads](https://www.mediawiki.org/wiki/Manual:Configuring_file_uploads)

The following needs to be set in php.ini:
```bash
file_uploads = On
```

Set in LocalSettings.php, `$wgEnableUploads` to `true`: 
```php
$wgEnableUploads = true; # Enable uploads
```

<b>Source:</b> [https://unix.stackexchange.com/questions/179389/mediawiki-error-file-upload-not-working](https://unix.stackexchange.com/questions/179389/mediawiki-error-file-upload-not-working)

And set the proper security context type so that SELinux stops complaining.
```bash
sudo chcon -R -t httpd_sys_script_rw_t /var/www/html/wiki/images/
```

Don't forget to set the directory back to the correct permissions.
```bash
sudo chmod 755 /var/www/html/wiki/images/
```

If I missed something, please let me know!