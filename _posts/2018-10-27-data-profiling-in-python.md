---
layout: post
title: "Data profiling in Python"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/data_profiling.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
Data profiling is intended to help understand data leading to a better data prepping and data quality.<br>
<br>
<i>Data profiling is the systematic up front analysis of the content of a data source, all the way from counting the bytes and checking cardinalities up to the most thoughtful diagnosis of whether the data can meet the high level goals of the data warehouse.</i> Ralph Kimball
  </div>
</div>

<b>pandas-profiling</b> Python package is a great tool to create HTML profiling reports. For a given dataset it computes the following statistics:

* Essentials: type, unique values, missing values
* Quantile statistics like minimum value, Q1, median, Q3, maximum, range, interquartile range
* Descriptive statistics like mean, mode, standard deviation, sum, median absolute deviation, coefficient of variation, kurtosis, skewness
* Most frequent values
* Histogram
* Correlations highlighting of highly correlated variables, Spearman and Pearson matrixes

## Prerequisites
* Install Python and the Jupyter Notebook
  - [On Linux]({% post_url 2018-07-11-install-python-jupyter-notebook-on-rhel-centos-7 %})
  - [On Windows]({% post_url 2018-10-26-install-python-package-on-windows-with-corporate-network-constraints %})
* Install pandas-profiling module
  - <b>GitHub repo:</b> <a href="https://github.com/pandas-profiling/pandas-profiling">https://github.com/pandas-profiling/pandas-profiling</a>
  - With Anaconda: 
```bash
conda install -c conda-forge pandas-profiling
```	

## Profiling data from a CSV file

Let's see how to use pandas-profiling package on a dataset from the University of California, Irvine: [Communities and Crime Data Set]({{ '/data/crime_and_communities.csv' | relative_url }})

Start Jupyter Notebook
```console
jupyter notebook
```

Create a new notebook

Load pandas and pandas_profiling
```python
import pandas as pd
import pandas_profiling
```

Load data into a DataFrame object and cast categorical numeric columns
```python
df=pd.read_csv("./data/communities.csv" , sep=',', na_values=["?"])
# Some other useful read_csv parameters
# encoding='UTF-8'
# low_memory=False
# parse_dates=["date_column_name"]

# Change Pandas DataFrame column data type
# df["y"] = pd.to_numeric(df["y"])
# df["z"] = pd.to_datetime(df["z"]) 
df['state'] = df['state'].astype('category')
df['community'] = df['community'].astype('category')
df['fold'] = df['fold'].astype('category')
```

Display the data profiling report in a Jupyter notebook
```python
pandas_profiling.ProfileReport(df)
```
<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="400" width="100%" src="{{ '/html/data_profiling/data_profiling.html' | relative_url }}"></iframe>

Or export it in an HTML file
```python
profile = pandas_profiling.ProfileReport(df)
profile.to_file(outputfile="./report.html")
```

## Profiling data from SQL Server database 

```python
## From SQL to DataFrame Pandas
import pandas as pd
import pyodbc

sql_conn = pyodbc.connect('DRIVER={SQL Server Native Client 11.0}; \
                            SERVER=server_name; \
                            DATABASE=db_name; \
                            Trusted_Connection=yes') 
query = "SELECT [BusinessEntityID],[FirstName],[LastName],
                 [PostalCode],[City] FROM [Sales].[vSalesPerson]"
df = pd.read_sql(query, sql_conn)

pandas_profiling.ProfileReport(df)
```
With credentials replace pyodbc.connect instruction with the following

```python
sql_conn = pyodbc.connect('DRIVER={SQL Server Native Client 11.0}; \
                            SERVER=server_name; \
                            DATABASE=db_name; \
                            uid=User; \
                            pwd=password') 
```
As alternative you could consider the [pymssql module](http://www.pymssql.org/en/stable/pymssql_examples.html).

## Other data profiling commands


```python
df.head()
```
<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="300" width="100%" src="{{ '/html/data_profiling/head.html' | relative_url }}"></iframe>

```python
df.describe()
```

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="300" width="100%" src="{{ '/html/data_profiling/describe.html' | relative_url }}"></iframe>


```python
df.isnull().any()
```

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="300" width="100%" src="{{ '/html/data_profiling/isnull_any.html' | relative_url }}"></iframe>


```python
df.isnull().sum()
```

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="300" width="100%" src="{{ '/html/data_profiling/isnull_sum.html' | relative_url }}"></iframe>


```python
null_columns=df.columns[df.isnull().any()]
df[null_columns].isnull().sum()
```

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="300" width="100%" src="{{ '/html/data_profiling/null_columns.html' | relative_url }}"></iframe>

```python
df.isnull().any().any()
```

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="30" width="100%" src="{{ '/html/data_profiling/isnull_any_any.html' | relative_url }}"></iframe>

```python
df.info()
```

<iframe frameborder="no" border="0" marginwidth="0" marginheight="0" height="100" width="100%" src="{{ '/html/data_profiling/info.html' | relative_url }}"></iframe>

Plot a hierarchical clustering as a dendrogram.
```python
%matplotlib notebook
import matplotlib.pyplot as plt
from scipy.cluster import hierarchy as hc

corr = 1 - df.corr() 
corr_condensed = hc.distance.squareform(corr) # convert to condensed
z = hc.linkage(corr_condensed, method='average')
dendrogram = hc.dendrogram(z, labels=corr.columns)
```
<img src="{{ '/images/05-data-profiling-in-python/01-data-profiling-in-python.png' | relative_url }}" class="responsive-img">

Principal Component Analysis (PCA) in Python ([https://stackoverflow.com/a/50572561/9489744](https://stackoverflow.com/a/50572561/9489744))
```python
%matplotlib notebook
import numpy as np
import matplotlib.pyplot as plt
from sklearn import datasets
from sklearn.decomposition import PCA
import pandas as pd
from sklearn.preprocessing import StandardScaler

iris = datasets.load_iris()
X = iris.data
y = iris.target
X = iris.data
y = iris.target
#In general a good idea is to scale the data
scaler = StandardScaler()
scaler.fit(X)
X=scaler.transform(X)    

pca = PCA()
x_new = pca.fit_transform(X)

def myplot(score,coeff,labels=None):
    xs = score[:,0]
    ys = score[:,1]
    n = coeff.shape[0]
    scalex = 1.0/(xs.max() - xs.min())
    scaley = 1.0/(ys.max() - ys.min())
    plt.scatter(xs * scalex,ys * scaley, c = y)
    for i in range(n):
        plt.arrow(0, 0, coeff[i,0], coeff[i,1],color = 'r',alpha = 0.5)
        if labels is None:
            plt.text(coeff[i,0]* 1.15, coeff[i,1] * 1.15, "Var"+str(i+1), color = 'g', ha = 'center', va = 'center')
        else:
            plt.text(coeff[i,0]* 1.15, coeff[i,1] * 1.15, labels[i], color = 'g', ha = 'center', va = 'center')
plt.xlim(-1,1)
plt.ylim(-1,1)
plt.xlabel("PC{}".format(1))
plt.ylabel("PC{}".format(2))
plt.grid()

#Call the function. Use only the 2 PCs.
myplot(x_new[:,0:2],np.transpose(pca.components_[0:2, :]))
plt.show()
```
<img src="{{ '/images/05-data-profiling-in-python/02-data-profiling-in-python.png' | relative_url }}" class="responsive-img">

<!--

## More on data profiling

####  SQL Server Data Profiler Task 
<b>Source:</b> https://www.databasejournal.com/features/mssql/introduction-to-the-sql-server-data-profiler-task-part-1.html

CSV data profiling in R

SQL Server data profiling 

#### T-SQL
<b>Source:</b> http://www.sqlservercentral.com/articles/Data+Profiling/96398/

-->