---
layout: post
comments: true
title: "Enable network connectivity between Docker containers on CentOS 8"
categories: post
author: "Benjamin Berhault"
description: Enable a network connectivity between Docker containers on CentOS 8.
image: images/12-docker/docker-networking.png
---

#### Reference
* [No network connectivity to/from Docker CE container on CentOS 8](https://serverfault.com/questions/987686/no-network-connectivity-to-from-docker-ce-container-on-centos-8)


#### Prerequisites
* [Install Docker Engine on CentOS](https://docs.docker.com/engine/install/centos/)
* [Install Docker compose](https://docs.docker.com/compose/install/)

### Firewall setup

To enable network connectivity between Docker containers on CentOS 8, you have to enable masquerading. 

<b>IP masquerading</b> is a process where one computer acts as an IP gateway for a network. All computers on the network send their IP packets through the gateway, which replaces the source IP address with its own address and then forwards it to the internet.

 <center><img src="{{ '/images/12-docker/ip-masquerading.gif' | relative_url }}" class="responsive-img"></center>

A <b>gateway IP</b> refers to a device on a network which sends local network traffic to other networks.

It looks like the docker daemon already did this through iptables, but apparently this needs to be specifically enabled for the firewall zone for iptables masquerading to work:

```bash
# Masquerading allows for docker ingress and egress
firewall-cmd --zone=public --add-masquerade --permanent

# Specifically allow incoming traffic on port 80 and 443
firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --zone=public --add-port=443/tcp

# Reload the firewall to apply permanent rules
firewall-cmd --reload
```

Restart dockerd, and both ingress and egress should work:
```console
sudo systemctl restart docker
```

### Test it

Test the network connectivity between Docker containers with a Wordpress and a MySQL container.  

<b>Docker Compose</b> provides a way to orchestrate multiple containers to work together based on properties described in a docker-compose.yml file.

Edit a `docker-compose.yml` file with the following content:
```yaml
version: '3.7'

volumes: 
    mysql_data:
    wordpress_data:

services: 

  database:
    image: mysql:5.7
    volumes: 
      - mysql_data:/var/lib/mysql
    restart: always
    environment: 
      MYSQL_ROOT_PASSWORD: mypassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpressuser
      MYSQL_PASSWORD: wordpress
    expose:
      - "3306"

  wordpress:
    depends_on: 
      - database
    image: wordpress:latest
    volumes: 
      - wordpress_data:/var/www/html
    ports: 
      - "8080:80"
    restart: always
    environment: 
      WORDPRESS_DB_HOST: database:3306
      WORDPRESS_DB_USER: wordpressuser
      WORDPRESS_DB_PASSWORD: wordpress
```


From the directory where is your docker-compose.yml, start up your application by running:
```console
docker-compose up
```

If you want to force containers recreation:
```bash
docker-compose up --force-recreate
```

In another terminal check that your containers are working:
```console
export FORMAT="\nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n"

docker ps --format $FORMAT
```

Your Wordpress website should be available at:
[http://localhost:8080](http://localhost:8080)