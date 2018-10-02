---
layout: post
---

In case of a GROUP BY query, to get the value of one column based on the MAX value of another, you can do:

```sql
SELECT
		CASE 
             WHEN MAX(col_C) > 0 THEN MAX(col_D)
             ELSE NULL 
        END		AS col_D_value_when_col_C_MAX
FROM table 
GROUP BY col_A, col_B
``
