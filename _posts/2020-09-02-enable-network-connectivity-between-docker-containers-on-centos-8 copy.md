---
layout: post
comments: true
title: "Monitor SSIS job and package executions"
categories: post
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <center><img src="{{ '/images/13-SSIS/03-monitoring-ssis.png' | relative_url }}" class="responsive-img"></center>
  </div>
  <div class="col grid s12 m6 l9 ">
    How to monitor SSIS job and package executions.
  </div>
</div>

The SSIDB database for <b>Microsoft SQL Server Integration Services</b> provides us everything we need to correctly monitor SSIS jobs and packages without having to reinvent the wheel so take advantage of it.

Here we will see how to query the SSISDB database to monitor SSIS jobs and packages allow us the ability to build reports of the form: 

<div class="row">
  <div class="col grid s12 m6 l6">
    <center><img src="{{ '/images/13-SSIS/01-monitoring-ssis-jobs.png' | relative_url }}" class="responsive-img"></center>
  </div>
  <div class="col grid s12 m6 l6 ">
    <center><img src="{{ '/images/13-SSIS/02-monitoring-ssis-operations.png' | relative_url }}" class="responsive-img"></center>
  </div>
</div>

### Create some dimension tables

References:
* [Microsoft Docs - catalog.operation_messages (SSISDB Database)](https://docs.microsoft.com/en-us/sql/integration-services/system-views/catalog-operation-messages-ssisdb-database)
* [Microsoft Docs - catalog.executions (SSISDB Database)](https://docs.microsoft.com/en-us/sql/integration-services/system-views/catalog-executions-ssisdb-database)
* [Microsoft Docs - dbo.sysjobhistory](https://docs.microsoft.com/en-us/sql/relational-databases/system-tables/dbo-sysjobhistory-transact-sql)

First we will add some dimension tables to the SSISDB database to describe:
* Message types 
* Message source types
* Operation status
* Job status

Message types:
```sql
IF OBJECT_ID('dim_message_type') IS NOT NULL DROP TABLE dim_message_type
GO

CREATE TABLE dim_message_type
(
	[Id Message type] SMALLINT IDENTITY PRIMARY KEY,
	[Message type] VARCHAR(128) NOT NULL
)

SET IDENTITY_INSERT dim_message_type ON
GO
INSERT INTO dim_message_type ([Id Message type], [Message type])
VALUES 
	(-1, 'Unknown')
	,(120, 'Error')
	,(110, 'Warning')
	,(70, 'Information')
	,(10, 'Pre-validate')
	,(20, 'Post-validate')
	,(30, 'Pre-execute')
	,(40, 'Post-execute')
	,(60, 'Progress')
	,(50, 'StatusChange')
	,(100, 'QueryCancel')
	,(130, 'TaskFailed')
	,(90, 'Diagnostic')
	,(200, 'Custom')
	,(140, 'DiagnosticEx')
	,(400, 'NonDiagnostic')
	,(80, 'VariableValueChanged')


SET IDENTITY_INSERT dim_message_type OFF
GO
```

Message source types:
```sql
IF OBJECT_ID('dim_message_source_type') IS NOT NULL DROP TABLE dim_message_source_type
GO

CREATE TABLE dim_message_source_type
(
	[Id Message source type] SMALLINT IDENTITY PRIMARY KEY,
	[Message source type] VARCHAR(128) NOT NULL
)

SET IDENTITY_INSERT dim_message_source_type ON
GO
INSERT INTO dim_message_source_type ([Id Message source type], [Message source type])
VALUES 
	(-1, 'Unknown')
	,(10, 'Entry APIs, such as T-SQL and CLR Stored procedures')
	,(20, 'External process used to run package (ISServerExec.exe)')
	,(30, 'Package-level objects')
	,(40, 'Control Flow tasks')
	,(50, 'Control Flow containers')
	,(60, 'Data Flow task')

SET IDENTITY_INSERT dim_message_source_type OFF
GO
```

Operation status:
```sql
IF OBJECT_ID('dim_operation_status') IS NOT NULL DROP TABLE dim_operation_status
GO

CREATE TABLE dim_operation_status
(
	[Id Operation status] SMALLINT IDENTITY PRIMARY KEY,
	[Operation status] VARCHAR(128) NOT NULL
)

SET IDENTITY_INSERT dim_operation_status ON
GO
INSERT INTO dim_operation_status ([Id Operation status], [Operation status])
VALUES 
	(-1, 'Unknown')
	,(1, 'Created') 
	,(2, 'Running ')
	,(3, 'Canceled')
	,(4, 'Failed')
	,(5, 'Pending')
	,(6, 'Ended unexpectedly')
	,(7, 'Succeeded')
	,(8, 'Stopping')
	,(9, 'Completed')

SET IDENTITY_INSERT dim_operation_status OFF
GO
```

Job status:
```sql
IF OBJECT_ID('dim_job_status') IS NOT NULL DROP TABLE dim_job_status
GO

CREATE TABLE dim_job_status
(
	[Id Job status] SMALLINT IDENTITY PRIMARY KEY,
	[Job status] VARCHAR(128) NOT NULL
)

SET IDENTITY_INSERT dim_job_status ON
GO
INSERT INTO dim_job_status ([Id Job status], [Job status])
VALUES 
	(-1, 'Unknown')
	,(0, 'Failed') 
	,(1, 'Succeeded ')
	,(2, 'Retry')
	,(3, 'Canceled')
	,(4, 'In Progress')

SET IDENTITY_INSERT dim_job_status OFF
GO
```

### Queries to monitor SSIS jobs and operations

Jobs
```sql
SELECT 
	CONCAT(a1.run_date,RIGHT('000000'+ISNULL(CAST(a1.run_time As varchar(6)),''),6),a1.job_id) As [Id]
	, cast(left(a1.run_date,8) as datetime) + CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a1.run_time As varchar(6)),''),6),5,0,':'),3,0,':') AS datetime) As [Datetime]
	, cast(left(a1.run_date,8) as date) As [Date]
	, CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a1.run_time As varchar(6)),''),6),5,0,':'),3,0,':') AS time(0)) As [Start time]
	, a1.job_id As [Id Job]
	, a1.name As [Job name]
	, IIF(MIN(a2.run_status) = 1, MAX(a2.run_status), MIN(a2.run_status)) As [Id Status]
	, CASE IIF(MIN(a2.run_status) = 1, MAX(a2.run_status), MIN(a2.run_status))
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Canceled'
		WHEN 4 THEN 'In Progress'
		ELSE 'Unknown'
	END As [Status]
	, CONVERT(time(0), DATEADD(SECOND, 
		SUM(
			DATEDIFF(second,0,cast(CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a2.run_duration As varchar(6)),''),6),5,0,':'),3,0,':') AS time) as datetime))
		)
		, 0)
	) As [Execution time (HH:MM:SS)]
	, SUM(DATEDIFF(second,0,cast(CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a2.run_duration As varchar(6)),''),6),5,0,':'),3,0,':') AS time) as datetime))) As [Execution time (in seconds)]
FROM (
	SELECT
		b1.job_id
		,b2.name As name
		,b1.run_date
		,b1.run_time 
		,LEAD(b1.run_time,1) OVER ( ORDER BY run_date, run_time) As next_run_time
		,MIN(b1.run_status) As run_status
	FROM [msdb].[dbo].[sysjobhistory] b1 WITH (NOLOCK)
		LEFT JOIN [msdb].[dbo].[sysjobs] b2 WITH (NOLOCK)
		ON b1.job_id = b2.job_id
	WHERE
		b1.step_id = 1
		-- To avoid a bunch of unrelevant jobs
		-- You can filter by a specific keyword common to all your jobs and/or username used to execute them 
		-- AND (name LIKE '%common_token_between_your_job_names%' OR message LIKE '%user_account_use_to_execute_jobs%')
		-- Or you simply exclude jobs using a unique identifier as name
		AND TRY_CONVERT(UNIQUEIDENTIFIER,b2.name) IS NULL
	GROUP BY b1.job_id, b2.name, b1.run_date, b1.run_time
) a1
LEFT JOIN [msdb].[dbo].[sysjobhistory] a2 WITH (NOLOCK)
	ON 
		a2.job_id = a1.job_id 
		AND a2.run_date = a1.run_date 
		AND a1.run_time >= a1.run_time 
		AND a2.run_time < IIF(a1.next_run_time <= a1.run_time, 999999, ISNULL(a1.next_run_time, 999999)) 
WHERE 
	a2.job_id = a1.job_id 
	AND a2.run_date = a1.run_date 
	AND a2.run_time >= a1.run_time 
	AND a2.run_time < IIF(a1.next_run_time <= a1.run_time, 999999, ISNULL(a1.next_run_time, 999999))
	AND a2.step_id <> 0
	-- To avoid a bunch of unrelevant jobs
	-- You can filter by a specific keyword common to all your jobs and/or username used to execute them 
	-- AND (name LIKE '%common_token_between_your_job_names%' OR message LIKE '%user_account_use_to_execute_jobs%')
	-- Or you simply exclude jobs using a unique identifier as name
	AND TRY_CONVERT(UNIQUEIDENTIFIER,a1.name) IS NULL

GROUP BY a1.job_id,  a1.run_date, a1.run_time, a1.name, a1.next_run_time
ORDER BY a1.run_date DESC, a1.run_time DESC
```

Retrieve informations on executed jobs:
```sql
SELECT 
	CONCAT(a1.run_date,RIGHT('000000'+ISNULL(CAST(a1.run_time As varchar(6)),''),6),a1.job_id) As [Id]
	, CAST(LEFT(a1.run_date,8) As DATETIME) + CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a1.run_time As varchar(6)),''),6),5,0,':'),3,0,':') As DATETIME) As [Datetime]
	, CAST(LEFT(a1.run_date,8) As date) As [Date]
	, CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a1.run_time As varchar(6)),''),6),5,0,':'),3,0,':') As TIME(0)) As [Start time]
	, a1.job_id As [Id Job]
	, a1.name As [Job name]
	, IIF(MIN(a2.run_status) = 1, MAX(a2.run_status), MIN(a2.run_status)) As [Id Status]
	, CASE IIF(MIN(a2.run_status) = 1, MAX(a2.run_status), MIN(a2.run_status))
		WHEN 0 THEN 'Failed'
		WHEN 1 THEN 'Succeeded'
		WHEN 2 THEN 'Retry'
		WHEN 3 THEN 'Canceled'
		WHEN 4 THEN 'In Progress'
		ELSE 'Unknown'
	END As [Status]
	, CONVERT(TIME(0), DATEADD(SECOND, 
		SUM(
			DATEDIFF(SECOND,0,CAST(CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a2.run_duration As varchar(6)),''),6),5,0,':'),3,0,':') As TIME) As DATETIME))
		)
		, 0)
	) As [Execution time (HH:MM:SS)]
	, SUM(DATEDIFF(SECOND,0,CAST(CAST(STUFF(STUFF(RIGHT('000000'+ISNULL(CAST(a2.run_duration As varchar(6)),''),6),5,0,':'),3,0,':') As TIME) As DATETIME))) As [Execution time (in seconds)]

FROM (
	SELECT
		b1.job_id
		,b2.name As name
		,b1.run_date
		,b1.run_time 
		,LEAD(b1.run_time,1) OVER ( ORDER BY run_date, run_time) As next_run_time
		,MIN(b1.run_status) As run_status
	FROM [msdb].[dbo].[sysjobhistory] b1 WITH (NOLOCK)
		LEFT JOIN [msdb].[dbo].[sysjobs] b2 WITH (NOLOCK)
		ON b1.job_id = b2.job_id
	WHERE
		b1.step_id = 1
		-- To avoid a bunch of unrelevant jobs
		-- You can filter by a specific keyword common to all your jobs and/or username used to execute them 
		-- AND (name LIKE '%common_token_between_your_job_names%' OR message LIKE '%user_account_use_to_execute_jobs%')
		-- Or you simply exclude jobs using a unique identifier As name
		AND TRY_CONVERT(UNIQUEIDENTIFIER,b2.name) IS NULL
	GROUP BY b1.job_id, b2.name, b1.run_date, b1.run_time
) a1
LEFT JOIN [msdb].[dbo].[sysjobhistory] a2 WITH (NOLOCK)
	ON 
		a2.job_id = a1.job_id 
		AND a2.run_date = a1.run_date 
		AND a1.run_time >= a1.run_time 
		AND a2.run_time < IIF(a1.next_run_time <= a1.run_time, 999999, ISNULL(a1.next_run_time, 999999)) 
WHERE 
	a2.job_id = a1.job_id 
	AND a2.run_date = a1.run_date 
	AND a2.run_time >= a1.run_time 
	AND a2.run_time < IIF(a1.next_run_time <= a1.run_time, 999999, ISNULL(a1.next_run_time, 999999))
	AND a2.step_id <> 0
	-- To avoid a bunch of unrelevant jobs
	-- You can filter by a specific keyword common to all your jobs and/or username used to execute them 
	-- AND (name LIKE '%common_token_between_your_job_names%' OR message LIKE '%user_account_use_to_execute_jobs%')
	-- Or you simply exclude jobs using a unique identifier As name
	AND TRY_CONVERT(UNIQUEIDENTIFIER,a1.name) IS NULL

GROUP BY a1.job_id,  a1.run_date, a1.run_time, a1.name, a1.next_run_time
ORDER BY a1.run_date DESC, a1.run_time DESC
```

Retrieve informations on executed operations:
```sql
SELECT
	o.operation_id As [Id Operation]
	, dos.[Operation status] As [Operation status]
	, FORMAT(o.start_time, 'yyyy-MM-dd')  As [Date]
	, FORMAT(o.start_time, 'yyyy-MM-dd hh:mm:ss') As [Start time]
	, FORMAT(o.end_time, 'yyyy-MM-dd hh:mm:ss') As [End time]
	, CONVERT(time(0), DATEADD(SECOND, DATEDIFF(SECOND, o.start_time, o.end_time), 0)) As [Execution time]
	, ei.folder_name As [Folder name]
	, o.Object_Name As [Project name]
	, ei.package_name As [Package name]
	, environment_name As [Environment]
	, o.caller_name As [Caller]
	, p.deployed_by_name As [Deployed by]
	, FORMAT(p.last_deployed_time, 'yyyy-MM-dd hh:mm:ss') As [Last deployed time]

FROM [SSISDB].[internal].[operations] o WITH (NOLOCK)
LEFT JOIN [SSISDB].[internal].[projects] p WITH (NOLOCK)
	ON o.object_id = p.project_id 
LEFT JOIN  [SSISDB].[internal].[execution_info] ei WITH (NOLOCK)
	ON o.operation_id = ei.execution_id
LEFT JOIN [SSISDB].[dbo].[dim_operation_status] dos WITH (NOLOCK)
	ON o.status = dos.[Id Operation status]

WHERE ei.folder_name IS NOT NULL
ORDER BY o.operation_id DESC
```

Get messages for a given operation:
```sql
DECLARE @operation_id INT
SET @operation_id = 672328

SELECT
	-- Global infos
	-- o.operation_id 'Id Operation'
	-- , s.[Operation status]
	-- , DATEDIFF(second, o.start_time, o.end_time) As 'Time (in seconds)'
	-- , FORMAT(o.start_time, 'yyyy-MM-dd hh:mm:ss')  As 'Start time'
	-- , FORMAT(o.end_time, 'yyyy-MM-dd hh:mm:ss')  As 'End time'
	-- , o.caller_name As 'Caller'
	-- Details
	m.operation_message_id As 'Id Message'
	, mt.[Message type]
	, FORMAT(m.message_time, 'yyyy-MM-dd hh:mm:ss')  As [Message time]
	, m.message As 'Message'
	, e.message_source_name As 'Message source'
	, ISNULL(e.subcomponent_name,'') As 'Subcomponent name'
	, e.execution_path As 'Execution path'

FROM [SSISDB].[internal].[operations] o
LEFT JOIN [SSISDB].[internal].[projects] p
	ON o.object_id = p.project_id 
LEFT JOIN [SSISDB].[internal].[folders] f
	ON p.folder_id = f.folder_id
LEFT JOIN  [SSISDB].[internal].[execution_info] ei
	ON o.operation_id = ei.execution_id
LEFT JOIN SSISDB.internal.operation_messages m  
	ON o.operation_id = m.operation_id  
LEFT JOIN SSISDB.internal.event_messages e  
	ON m.operation_id = e.operation_id AND m.operation_message_id = e.event_message_id  
LEFT JOIN [SSISDB].dbo.dim_message_type mt
	ON m.message_type = mt.[Id Message type]
LEFT JOIN [SSISDB].dbo.dim_message_source_type mst
	ON m.message_source_type = mst.[Id Message source type]
LEFT JOIN [SSISDB].dbo.dim_operation_status s
	ON o.status = s.[Id Operation status]

WHERE o.operation_id = @operation_id
ORDER BY m.message_time DESC, m.operation_message_id DESC
```