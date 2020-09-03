---
layout: post
comments: true
title: "Get R and RStudio on RHEL/CentOS 7 with Docker"
categories: post
author: "Benjamin Berhault"
description: You can encounter some trouble installing R and RStudio on CentOS/RHEL. One alternative to avoid those troubles is to use Docker. Docker containers aimed to really simplify your life in some situations. It is a tool you have to have in your pocket.
image: images/r_docker.png
---

## Install Docker
<b>Reference:</b> [Get Docker CE for CentOS](https://docs.docker.com/install/linux/docker-ce/centos/)

Uninstall old versions
```bash
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
```

Install required packages
```bash
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
```

Set up the stable Docker repository
```bash
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

Install Docker CE
```bash
sudo yum install docker-ce
```

Start Docker
```bash
sudo service docker start
```

Verify that docker is installed correctly by running the hello-world image.
```bash
sudo docker run hello-world
```

#### Manage Docker as a non-root user
<b>Reference:</b> [Post-installation steps for Linux](https://docs.docker.com/install/linux/linux-postinstall/)

Add your user to the docker group.
```bash
sudo usermod -aG docker $USER
```

<b>Log out</b> of your session completely and then log back in so that your group membership is re-evaluated.

Start Docker
```bash
sudo service docker start
```

Verify that you can run docker commands without sudo.
```bash
docker run hello-world
```

## Install a RStudio Docker container


Search a docker image
```bash
docker search rstudio
```

Check the information on https://hub.docker.com related to image you feel likely to install usually the one having top star rating that is in my case: [rocker/rstudio](https://hub.docker.com/r/rocker/rstudio/)

Everything looking fine, pull this top star Docker image
```bash
docker pull rocker/rstudio
```

Find the relevant installation instruction that was for this one on GitHub : [https://github.com/rocker-org/rocker/wiki/Using-the-RStudio-image](https://github.com/rocker-org/rocker/wiki/Using-the-RStudio-image)

.. and follow the described installation process:
```bash
docker run -d -p 8787:8787 rocker/rstudio
```

Visit [http://localhost:8787/](http://localhost:8787/) in your browser, as the previous command do not specify any username and password, <b>rstudio</b> will be considered by default as password and username.

To define custom ones, instead of the previous command use something like: 
```bash
docker run -d -p 8787:8787 -e USER=my_username -e PASSWORD=my_password rocker/rstudio
```

Retrieve the CONTAINER ID:
```bash
docker ps -a
```

That is for me: abf97894d537

To access to the terminal of your container:
```bash
docker exec -ti abf97894d537 bash
```

From the terminal container, you can update it
```bash
sudo apt-get update
```

To stop the container
```bash
docker stop abf97894d537
```

To start the container
```bash
docker start abf97894d537
```

## Docker maintenance commands

Delete all your containers
```bash
docker rm $(docker ps -a -q)
```

Delete all your  images
```bash
docker rmi $(docker images -q)
```