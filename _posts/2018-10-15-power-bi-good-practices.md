---
layout: post
title: "Power BI Good Practices"
categories: post
author: "Benjamin Berhault"
meta: "Power BI"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/power_bi.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
Power BI is a great tool for making reports from a wide variety of data sources accessible to as many people as possible.<br>
By applying a few principles during report design, report response times can be significantly increased and their subsequent maintenance easier.<br>
<br>
Although knowledge of SQL is not necessary for the use of Power BI, the learning of minimal knowledge of this language should nevertheless be seriously considered to fully benefit from the capabilities of Power BI.
  </div>
</div>

## Foreword
Power BI offers 2 ways to connect to data on which the reports will be based:

* <b>Import</b> - Importing a copy of the data into the Power BI report.
* <b>Direct Query</b> - Direct connection to the data source. No data is imported or copied into Power BI.

This choice is to be made when editing a database connection under Power BI.

<img src="{{ '/images/02-power-bi-good-practices/01-power-bi-good-practices.png' | relative_url }}" class="responsive-img">

 
<b>Direct Query mode is preferred when:</b>

* You need query results on data in the database (including the latest insertions and updates)
* You have a large amount of data, too large to be loaded into memory
* You do not need queries to return a result in less than 2 seconds

 
## Optimize the performance of your Power BI reports
Microsoft documentation recommendations:

* [Use filters](https://docs.microsoft.com/en-us/power-bi/power-bi-reports-performance#use-filters-to-limit-report-visuals-to-display-only-whats-needed)
* [Limit the number of visuals on report pages](https://docs.microsoft.com/en-us/power-bi/power-bi-reports-performance#limit-visuals-on-report-pages)
* [Optimize your model](https://docs.microsoft.com/en-us/power-bi/power-bi-reports-performance#optimize-your-model)

 
### Use filters
Use filters based on dimension columns and not from fact tables.

<img src="{{ '/images/02-power-bi-good-practices/02-power-bi-good-practices.png' | relative_url }}" class="responsive-img">

<img src="{{ '/images/02-power-bi-good-practices/03-power-bi-good-practices.png' | relative_url }}" class="responsive-img">

### Limit the number of visual elements on report pages

Limit the number of visual elements and data to the bare minimum.

The extraction pages are made to deepen a given field in more detail, see [https://docs.microsoft.com/en-us/power-bi/power-bi-report-add-filter#add-a-drillthrough-filter](https://docs.microsoft.com/en-us/power-bi/power-bi-report-add-filter#add-a-drillthrough-filter) and for a demo in video: [&#91;YouTube&#93; Drilling into drillthrough in Power BI Desktop](https://www.youtube.com/watch?v=2x9lLHDbtDk)

### Optimize your model
#### Optimize your model under Power BI
* Therefore, restrict the data model supporting the report to the data/columns/fields that are strictly necessary, unused tables and columns should be deleted as much as possible. If it becomes necessary to apply a filter to the entire report: pages and elements, it is that this action should have been done at the level of the data source.
* The closer the measures and columns are to the data source, the higher the probability of performance.

So, privilege pure SQL queries as sources of data
<img src="{{ '/images/02-power-bi-good-practices/04-power-bi-good-practices.png' | relative_url }}" class="responsive-img">

```sql
let
    Source = Sql.Database("SQLINFOSERVICE", "Entrepot", [Query="SELECT [idDate], [jour]
      FROM [Entrepot].[dbo].[BI_Dim_Date] WHERE jour BETWEEN '2016-03-11' AND GETDATE()"])
in
    Source
```

..and avoid extra processing steps in Power BI.

<img src="{{ '/images/02-power-bi-good-practices/08-power-bi-good-practices.png' | relative_url }}" class="responsive-img">


<ul>
  <li>Beware of DAX functions that require testing each row of a table (such as <code>RANKX</code> for example). These functions can, in the worst case, lead to an exponential increase in memory and compute requirements.</li>
  <li>Avoid counting elements with an aggregation of type <b>Number (distinct elements)</b> equivalent to a <code>COUNT DISTINCT</code> in database and prefer <b>Number</b> equivalent to a <code>COUNT</code> in database. <br>
  <img src="{{ '/images/02-power-bi-good-practices/09-power-bi-good-practices.png' | relative_url }}" class="responsive-img">
  </li>
  <li>Feed your reports with data models of type:
    <ul>
      <li><b>Star schema</b>, if only one fact table is needed<br>

  <img src="{{ '/images/02-power-bi-good-practices/05-power-bi-good-practices.png' | relative_url }}" class="responsive-img">

      </li>
      <li><b>Constellation schema</b>, if multiple fact tables are needed<br>

  <img src="{{ '/images/02-power-bi-good-practices/06-power-bi-good-practices.png' | relative_url }}" class="responsive-img">

      </li>
      <li>... and do not use only fact tables.<br>

  <img src="{{ '/images/02-power-bi-good-practices/07-power-bi-good-practices.png' | relative_url }}" class="responsive-img">
      </li>
      <li>Study the execution plans of your queries under SQL Server Management Studio (<a href="https://docs.microsoft.com/en-us/sql/relational-databases/performance/display-the-estimated-execution-plan?view=sql-server-2017">Viewing the Estimated Execution Plan</a>)
      </li>
    </ul>
  </li>
</ul>

#### Optimize your model in database

<ul>
  <li>Prefer the type <code>DATE</code> to type <code>DATETIME</code> to fill a date.</li>
  <li>For timestamp fields, use the <code>SMALLDATETIME</code> types if the precision per minute is sufficient or <code>DATETIME2(3)</code> if the precision per second is needed. A <code>DATETIME2(3)</code> type will only consume 6 bytes, while <code>DATETIME</code> types will consume 8 bytes (see <a href="https://docs.microsoft.com/en-us/sql/t-sql/functions/date-and-time-data-types-and-functions-transact-sql?view=sql-server-2017">&#91;MS DOC&#93; Date and Time Data Types and Functions (Transact-SQL)</a>)</li>
  <li>If the date and time are analysis axes, split this information into 2 foreign key columns (Date Key and Time Key) within the fact table and link these columns with constraints to the corresponding Date and Time dimension tables.</li>
  <li>Consider indexing columns that are heavily used to filter data. For example: create an index on the Date Key and Time Key columns when the data is repeatedly filtered on them.</li>
  <li>Partitioning your data when their volume becomes large will also lead to increase the responsiveness of the reports.</li>
</ul>