---
layout: post
comments: true
title: "SQL Notebook"
categories: [notebook, post]
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ site.baseurl | replace: '//', '/' }}images/sql.png" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    Microsoft SQL Server queries memo.
    <ul>
        <li>&bull; Get the value of one column based on the MAX value of another with a GROUP BY query</li>
        <li>&bull; Space used by tables</li>
        <li>&bull; ...</li>
    </ul>  
  </div>
</div>

Get the value of one column based on the MAX value of another with a GROUP BY query:

```sql
SELECT
        CASE 
             WHEN MAX(col_C) > 0 THEN MAX(col_D)
             ELSE NULL 
        END     AS col_D_value_when_col_C_MAX
FROM table 
GROUP BY col_A, col_B
```

Space used by tables 

```sql
SELECT 
    t.NAME AS TableName,
    s.Name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB, 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB, 
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255
	AND t.NAME IN ('My First Table','My Second Table')
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) DESC
```
