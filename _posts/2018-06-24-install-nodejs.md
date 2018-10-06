---
layout: post
title: "Install last Node.js and avoid permissions errors"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/node_js.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine. As an asynchronous event driven JavaScript runtime, Node is designed to build scalable network applications.
  </div>
</div>



## Install Node.js and npm
<b>Reference:</b>
 * [Node.js GitHub repo](https://github.com/nodesource/distributions)
 * [Node.js official website](https://nodejs.org/en/)

Update the system and install necessary packages
```bash
yum install curl
```

We will install Node.js v6 LTS and npm from the NodeSource repository which depend on the EPEL repository being available.

To enable the EPEL repository on your CentOS 7 VPS, issue the following command:
```bash
yum install epel-release
```

Once the EPEL repository is enabled run the following command to add the Node.js v10 repository:
```bash
curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
```

Once the NodeSource repository is enabled we can proceed with the Node.js v10 LTS and npm installation:
```bash
# development tools to build native addons
sudo yum install gcc-c++ make
# install the Yarn package manager
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo yum install yarn
```

To verify if the Node.js installation was successful, issue the following command:
```bash
node -v
```

The output should be like the following:
```bash
v10.11.0
```

To verify if the npm installation was successful, issue the following command:
```bash
npm -v
```

The output should be like the following:
```bash
6.4.1
```

If you want to test the installation, create a test file:
```bash
vi hello_world.js
```

and then add the following content:
```js
const http = require('http');
const port = 3000;
const ip = '0.0.0.0';

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World');
}).listen(port, ip);

console.log(`server is running on ${ip}:${port}`);
```

Start the node web server by issuing the following command:
```bash
node hello_world.js
```

the output should be like the following:
```bash
server is running on 0.0.0.0:3000
```

If you now visit http://your_server_IP:3000 from your browser, you will see ‘Hello World’.

## Prevent Permissions Errors: Change npm's Default Directory
**Source:** [How to Prevent Permissions Errors](https://docs.npmjs.com/getting-started/fixing-npm-permissions)

To minimize the chance of permissions errors, you can configure npm to use a different directory. In this example, it will be a hidden directory on your home folder.

Make a directory for global installations:
```bash
mkdir ~/.npm-global
```

Configure npm to use the new directory path:
```bash
npm config set prefix '~/.npm-global'
```

Open or create a ~/.bashrc file and add this line:
```bash
export PATH=$PATH:~/.npm-global/bin
```
Back on the command line, update your system variables:
```bash
source ~/.bashrc
```
Test: Download a package globally without using sudo.
```bash
npm install -g express
```
