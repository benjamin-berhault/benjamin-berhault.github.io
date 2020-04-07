---
layout: post
comments: true
title: "Setup a GitHub repository to serve your Sphinx documentation"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <center><img src="{{ '/images/11-sphinx-github-pages/01-sphinx-github-pages.png' | relative_url }}" class="responsive-img"></center>
  </div>
  <div class="col grid s12 m6 l9 ">
    Sphinx and GitHub provide an efficient and free way to publish your documentation online. Here we describe how to do so.
  </div>
</div>

On GitHub, create a new repository. For this example `my_sphinx_repo` is taken as **Repository name**.

Once created, somewhere on your local machine.
```console
git clone https://github.com/username/my_sphinx_repo
cd ./my_sphinx_repo
```

Setup a repo dedicated to serve Sphinx documentation
```console
sphinx-quickstart
```
Fill the asked parameters
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

Build Sphinx in a `./docs` subdirectory (This will suit GitHub to serve your documentation).
```console
sphinx-build -b html ./source ./docs
# Add an empty `.nojekyll` file in `docs` repository 
# to make GitHub to not try interpret files as part of a Jekyll site
touch ./docs/.nojekyll
```

Push your Sphinx documentation on GitHub
```console
git add .
git commit -m "First commit"
git push
```

On your GitHub go back to your project repo and in **Settings** > **GitHub Pages** set **Source** as `master branch /docs folder`.

Wait a bit and refresh this **Settings** page, when under **GitHub Pages**you will a green notification **Your site is published at https://xxxx.github.io/my_sphinx_repo/** your Sphinx will be available.

To rebuild locally your HTML Sphinx documentation files after modification reexcute 
```console
sphinx-build -b html ./source ./docs
```

## Check your Sphinx documentation locally

Start an http server
```console
python -m http.server 8080 --directory ./docs
```
Your Sphinx documentation will be serve at `0.0.0.0:8080`

## Install a theme
Get a theme you want install, here we want to install `sphinx_rtd_theme` available with `pip`
```console
pip install sphinx_rtd_theme
```
In `./source/conf.py`, comment the previous theme:
```python
#html_theme = 'alabaster'
```

and declare your new theme
```python
import sphinx_rtd_theme

html_theme = 'sphinx_rtd_theme'

html_theme_path = [sphinx_rtd_theme.get_html_theme_path()] 
```