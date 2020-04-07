---
layout: post
comments: true
title: "Set Up an OSRM Server on Ubuntu 16"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/osrm.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    The Open Source Routing Machine or OSRM is a C++ implementation of a <b>high-performance routing engine</b> for shortest paths in road networks. Licensed under the permissive 2-clause BSD license, OSRM is a free network service hosting the following services: <a href="http://project-osrm.org/docs/v5.5.1/api/#nearest-service">nearest</a>, <a href="http://project-osrm.org/docs/v5.5.1/api/#tile-service">route</a>, <a href="http://project-osrm.org/docs/v5.5.1/api/#table-service">table</a>, <a href="http://project-osrm.org/docs/v5.5.1/api/#match-service">match</a>, <a href="http://project-osrm.org/docs/v5.5.1/api/#trip-service">trip</a>, <a href="http://project-osrm.org/docs/v5.5.1/api/#tile-service">tile</a>.<br>
    <br>
    We will see in this post how to deploy your own OSRM service in case you want to use it on your own data or just to not be limited by the number requests with responses like: <code>{'message': 'Too Many Requests'}</code>.
  </div>
</div>

<b>Sources:</b>
* [https://www.digitalocean.com/community/tutorials/how-to-set-up-an-osrm-server-on-ubuntu-14-04](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-osrm-server-on-ubuntu-14-04)
* [https://github.com/Project-OSRM/osrm-backend/wiki/Running-OSRM](https://github.com/Project-OSRM/osrm-backend/wiki/Running-OSRM)
* [http://project-osrm.org/docs/v5.5.1/api/](http://project-osrm.org/docs/v5.5.1/api/)

<b>OSRM features</b>
<ul>
	<li><a href="http://project-osrm.org/docs/v5.5.1/api/#nearest-service">Nearest service</a> - Snaps a coordinate to the street network and returns the nearest n matches.</li>
	<li><a href="http://project-osrm.org/docs/v5.5.1/api/#tile-service">Route service</a> - Finds the fastest route between coordinates in the supplied order.</li>
	<li><a href="http://project-osrm.org/docs/v5.5.1/api/#table-service">Table service</a> - Computes the duration of the fastest route between all pairs of supplied coordinates.</li>
	<li><a href="http://project-osrm.org/docs/v5.5.1/api/#match-service">Match service</a> - Map matching matches/snaps given GPS points to the road network in the most plausible way.</li>
	<li><a href="http://project-osrm.org/docs/v5.5.1/api/#trip-service">Trip service</a> - The trip plugin solves the Traveling Salesman Problem using a greedy heuristic (farthest-insertion algorithm). The returned path does not have to be the fastest path, as TSP is NP-hard it is only an approximation. </li>
	<li><a href="http://project-osrm.org/docs/v5.5.1/api/#tile-service">Tile service</a> - This service generates Mapbox Vector Tiles that can be viewed with a vector-tile capable slippy-map viewer.</li>
</ul>

You will need at least 2.5GB of RAM (in my case with 1GB of RAM OSRM build failed).

Upgrade all the packages
```console
sudo apt-get update
sudo apt-get upgrade
```

Install dependencies
```console
sudo apt-get install build-essential git cmake pkg-config \
libbz2-dev libxml2-dev libzip-dev libboost-all-dev \
lua5.2 liblua5.2-dev libtbb-dev
```

Create a dedicated directory and move into to keep everything tidy and clean
```console
mkdir osrm
cd osrm
```

Get OSRM from the official GitHub repo
```console
git clone https://github.com/Project-OSRM/osrm-backend.git
```

Compile and install OSRM binaries
```console
cd osrm-backend
mkdir -p build
cd build
cmake ..
cmake --build .
sudo cmake --build . --target install
```

The map pre-processing is quite memory intensive. For this reason, OSRM uses a library called STXXL to map its internal operations on the hard disk. STXXL relies on a configuration file called .stxxl, which lives in the same directory where you are running your software, to determine how much space is dedicated to the STXXL data structures.

Configure STXXL with an `.stxxl` file in your `osrm` folder. 
```console
cd ~/osrm
vi .stxxl
```

Write in it
```console
disk=/tmp/stxxl,10G,syscall
```

Save and close it.

Because the speed profile script might depend on some Lua functions defined in the profiles library, we also create a symbolic link to it in the same directory by running the following two commands.
```console
ln -s osrm-backend/profiles/car.lua profile.lua
ln -s osrm-backend/profiles/lib
```

Get openstreetmap data
```console
wget https://download.geofabrik.de/europe/france/ile-de-france-latest.osm.bz2
bzip2 -d ile-de-france-latest.osm.bz2
```

Pre-process the `.osm` file with the car profile
```console
osrm-extract ile-de-france-latest.osm -p ./osrm-backend/profiles/car.lua
```

Build the contraction hierarchy
```console
osrm-contract ile-de-france-latest.osrm
```

To keep the osrm-routed process running after ending ssh session, use tmux
```console
tmux
```

Start a routing engine HTTP server on port 5000 inside the tmux session
```console
osrm-routed ile-de-france-latest.osrm
```

Leave/detach the `tmux` session by typing `Ctrl`+`b` and then `d`

You have now a high performance routing engine up and running and with your server ip address you can test it:

* Trip service: [http://your_server_ip:5000/trip/v1/driving/2.25975,48.923557;2.248389,48.922695;2.235361,48.916889;2.2255,48.91325;2.225833,48.914028;2.225861,48.914001;2.225833,48.914055;2.225861,48.914055;2.226417,48.914333;2.230083,48.91486;2.23725,48.917557;2.242917,48.920029;2.24775,48.922417;2.249278,48.922749;2.252528,48.922916;2.256556,48.923054;2.261778,48.922779;2.262389,48.922638;2.262333,48.922611;2.262361,48.922611;2.262194,48.922585;2.262194,48.922585;2.262194,48.922585;2.262167,48.922585;2.262139,48.922585;2.262167,48.922585;2.262167,48.922554;2.262194,48.922554?source=first&destination=last](http://your_server_ip:5000/trip/v1/driving/2.25975,48.923557;2.248389,48.922695;2.235361,48.916889;2.2255,48.91325;2.225833,48.914028;2.225861,48.914001;2.225833,48.914055;2.225861,48.914055;2.226417,48.914333;2.230083,48.91486;2.23725,48.917557;2.242917,48.920029;2.24775,48.922417;2.249278,48.922749;2.252528,48.922916;2.256556,48.923054;2.261778,48.922779;2.262389,48.922638;2.262333,48.922611;2.262361,48.922611;2.262194,48.922585;2.262194,48.922585;2.262194,48.922585;2.262167,48.922585;2.262139,48.922585;2.262167,48.922585;2.262167,48.922554;2.262194,48.922554?source=first&destination=last)

* Match service: [http://your_server_ip:5000/match/v1/cars/2.25975,48.923557;2.248389,48.922695;2.235361,48.916889;2.2255,48.91325;2.225833,48.914028;2.225861,48.914001;2.225833,48.914055;2.225861,48.914055;2.226417,48.914333;2.230083,48.91486;2.23725,48.917557;2.242917,48.920029;2.24775,48.922417;2.249278,48.922749;2.252528,48.922916;2.256556,48.923054;2.261778,48.922779;2.262389,48.922638;2.262333,48.922611;2.262361,48.922611;2.262194,48.922585;2.262194,48.922585;2.262194,48.922585;2.262167,48.922585;2.262139,48.922585;2.262167,48.922585;2.262167,48.922554;2.262194,48.922554](http://your_server_ip:5000/match/v1/cars/2.25975,48.923557;2.248389,48.922695;2.235361,48.916889;2.2255,48.91325;2.225833,48.914028;2.225861,48.914001;2.225833,48.914055;2.225861,48.914055;2.226417,48.914333;2.230083,48.91486;2.23725,48.917557;2.242917,48.920029;2.24775,48.922417;2.249278,48.922749;2.252528,48.922916;2.256556,48.923054;2.261778,48.922779;2.262389,48.922638;2.262333,48.922611;2.262361,48.922611;2.262194,48.922585;2.262194,48.922585;2.262194,48.922585;2.262167,48.922585;2.262139,48.922585;2.262167,48.922585;2.262167,48.922554;2.262194,48.922554)

You can check your response with the [Google Interactive Polyline Encoder Utility](https://developers.google.com/maps/documentation/utilities/polylineutility). For that copy the obtained geometry paremeter in the <b>Encoded Polyline</b> field and run <b>Decode polyline</b>. In my case it plot the exact polyline I was looking for:

<center>
	<img src="{{ '/images/08-OSRM/01-OSRM.png' | relative_url }}" class="responsive-img">
</center>


{% comment %}
Monitor TCP Traffic on specific port
tcpdump port 5000 and '(tcp-syn|tcp-ack)!=0'
{% endcomment %}