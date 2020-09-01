---
layout: post
comments: true
title: "Setup a GitHub repository to serve your Sphinx documentation"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <center><img src="{{ '/images/11-sphinx-github-pages/sphinx-documentation.png' | relative_url }}" class="responsive-img"></center>
  </div>
  <div class="col grid s12 m6 l9 ">
    Sphinx and GitHub provide an efficient and free way to publish your documentation online. Here we describe how to do so.
  </div>
</div>


#### Prerequisites
* [Python installed on your local machine](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html#installation)


### Create a Sphinx documentation

Install Sphinx on your local machine:
```console
pip install sphinx
```

On GitHub, create a new repository named for example `my_sphinx_repo`.

Once created, clone it on your machine:
```bash
git clone https://github.com/username/my_sphinx_repo
cd ./my_sphinx_repo
```

Intialize in it a Sphinx documentation:
```console
sphinx-quickstart
```

Enter values according to your project:
```console
> Separate source and build directories (y/n) [n]: y
...
> Project name: your_project_name
...
> Author name(s): your_name
...
> Project release []: 0.0.1
...
> Project language [en]: en
```
Specifying `y`, we choose to store our Sphinx editable files in `./source`.

We will build Sphinx in a `./docs` subdirectory to suit GitHub preset setup to serve a documentation:
```bash
sphinx-build -b html ./source ./docs
# Add an empty `.nojekyll` file in `docs` repository 
# to make GitHub to not try interpret files as part of a Jekyll site
touch ./docs/.nojekyll
```

### Publish your Sphinx documentation

Push your Sphinx documentation on GitHub:
```bash
git add .
git commit -m "First commit"
git push
```

In your GitHub project repo, in <b>Settings</b> > <b>GitHub Pages</b> set <b>Source</b> as:
* Select branch: `master` 
* Select folder: `/docs`

And click <b>Save</b>.

Wait a bit and refresh this <b>Settings</b> page, when under <b>GitHub Pages</b>you will have a green notification <b>Your Sphinx documentation will be serve at https://xxxx.github.io/my_sphinx_repo/</b>..

### Run your Sphinx documentation locally

To rebuild locally your Sphinx documentation files after modification execute: 
```bash
sphinx-build -b html ./source ./docs
```

You can run your documentation locally starting an http server with Python:
```bash
python -m http.server 8080 --directory ./docs
```
It should be serve at [http://localhost:8080](http://localhost:8080).

### Install a theme
Here we want to install the theme <i>sphinx_rtd_theme</i> available with a `pip install`:
```console
pip install sphinx_rtd_theme
```

In `./source/conf.py`, comment the previous theme:
```python
#html_theme = 'alabaster'
```

and declare your new theme:
```python
import sphinx_rtd_theme

html_theme = 'sphinx_rtd_theme'

html_theme_path = [sphinx_rtd_theme.get_html_theme_path()] 
```

Rebuild your Sphinx documentation: 
```bash
sphinx-build -b html ./source ./docs
```
Check it with this new theme at [http://localhost:8080](http://localhost:8080).