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

sql_conn = pyodbc.connect('DRIVER={ODBC Driver 13 for SQL Server};
                            SERVER=SQLSERVER2017;
                            DATABASE=Adventureworks;
                            Trusted_Connection=yes') 
query = "SELECT [BusinessEntityID],[FirstName],[LastName],
                 [PostalCode],[City] FROM [Sales].[vSalesPerson]"
df = pd.read_sql(query, sql_conn)

pandas_profiling.ProfileReport(df)
```

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

<!--

## More on data profiling

####  SQL Server Data Profiler Task 
<b>Source:</b> https://www.databasejournal.com/features/mssql/introduction-to-the-sql-server-data-profiler-task-part-1.html

CSV data profiling in R

SQL Server data profiling 

#### T-SQL
<b>Source:</b> http://www.sqlservercentral.com/articles/Data+Profiling/96398/

-->