---
layout: post
comments: true
title: "SQL Notebook"
categories: [notebook, post]
author: "Benjamin Berhault"
---

<div class="row">
  <div class="col grid s12 m6 l3">
    <img src="{{ '/images/sql.png' | relative_url }}" class="responsive-img">
  </div>
  <div class="col grid s12 m6 l9 ">
    Microsoft SQL Server queries memo.
    <ul>
        <li>&bull; Get the value of one column based on the MAX value of another with a GROUP BY query</li>
        <li>&bull; Space used by tables</li>
        <li>&bull; BI Dimension Date & Time</li>
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

<h4>Date dimension</h4>
<div class="row">
    <div class="col s12">
        <b><ul class="tabs">
            <li class="tab col s3"><a class="active" href="#description_date">Description</a></li>
            <li class="tab col s3"><a href="#code_date">Code</a></li>
        </ul></b>
    </div>
    <div id="description_date" class="col s12">
        <pre><code class="language-sql">-- =============================================
-- Authors: 
--  - Mubin M. Shaikh (https://www.codeproject.com/Articles/647950/Create-and-Populate-Date-Dimension-for-Data-Wareho)
--  - Benjamin Berhault
--
-- Description: T-SQL script to create a French version of a Date dimension
-- =============================================</code></pre>
    </div>
    <div id="code_date" class="col s12">
        <pre class="language-sql"><code class="language-sql">IF OBJECT_ID('dbo.[BI_Dim_Date]', 'U') IS NOT NULL 
  DROP TABLE dbo.[BI_Dim_Date]; 
GO
/**********************************************************************************/

CREATE TABLE    [BI_Dim_Date]
    (   [idDate] INT NOT NULL UNIQUE, 
        [Date] DATE NOT NULL,
        [Date texte] CHAR(10) NOT NULL,
        [Année] CHAR(4) NOT NULL,
        [Mois] VARCHAR(2) NOT NULL,
        [Jour de la semaine] CHAR(1) NOT NULL,
        [Jour du mois] VARCHAR(2) NOT NULL,
        [Jour de l année] VARCHAR(3) NOT NULL,
        [Jour de la semaine (nom)] VARCHAR(9) NOT NULL,
        [Semaine du mois 365] VARCHAR(2) NOT NULL, --1st Monday or 2nd Monday in month
        [Semaine du mois] VARCHAR(1) NOT NULL,-- Week Number of month 
        [Semaine du trimestre 365] VARCHAR(3),
        [Semaine de l année 365] VARCHAR(2) NOT NULL,
        [Semaine de l année] VARCHAR(2) NOT NULL,--Week Number of the year
        [Mois (nom)] VARCHAR(9) NOT NULL,--January, February etc
        [Mois du trimestre] VARCHAR(2) NOT NULL,-- Month Number belongs to trimester
        [Trimestre] CHAR(1) NOT NULL,
        [Trimestre (nom)] VARCHAR(9) NOT NULL,--Premier,Second..
        [MMAAAA] CHAR(6) NOT NULL,
        [Mois abrégé - Année] CHAR(10) NOT NULL, --Jan-2013,Feb-2013
        [Premier jour du mois] DATE NOT NULL,
        [Dernier jour du mois] DATE NOT NULL,
        [Premier jour du trimestre] DATE NOT NULL,
        [Dernier jour du trimestre] DATE NOT NULL,
        [Premier jour de l année] DATE NOT NULL,
        [Dernier jour de l année] DATE NOT NULL,
        [Est jour de semaine] BIT NOT NULL,-- 0=Week End ,1=Week Jour
        [Jour férié] VARCHAR(50) Null, --Name of Holiday in UK
        [Jour équivalent mois précédent] DATE Null,
        [Jour équivalent année précédent] DATE Null
        CONSTRAINT [PK_BI_Dim_Date] PRIMARY KEY CLUSTERED -- SQL Server orders the rows based on the column: idDate
            ([idDate] ASC)
        WITH (
        PAD_INDEX = OFF, -- the pages of intermediate levels are completed to the almost maximum capacity
        STATISTICS_NORECOMPUTE = OFF, -- the automatic update of the statistics is active
        IGNORE_DUP_KEY = OFF, -- an error message will be triggered when key values are duplicated within the index and the insertion will be canceled
        ALLOW_ROW_LOCKS = ON, -- row locks are allowed when you access the index. The database engine sets when row locks are used
        ALLOW_PAGE_LOCKS = ON -- Lock pages are allowed when you access the index. The database engine sets when page locks are used
    ) ON [PRIMARY]
)
ON [PRIMARY]

GO

-- Creation of a function returning the date of Easter for a given year in parameter
-- Ascension: 40 days after Easter counting Easter day
-- Pentecost: 50 days after Easter counting Easter day
IF object_id(N'dbo.dateDePaques', N'FN') IS NOT NULL
    DROP FUNCTION dbo.dateDePaques
GO

CREATE FUNCTION dbo.dateDePaques(@year INT) RETURNS DATE AS
BEGIN
    DECLARE @G INT, @C INT,@C_4 INT;
    DECLARE @E INT,@H INT, @K INT;
    DECLARE @P INT,@Q INT, @I INT;
    DECLARE @B INT,@J1 INT, @J2 INT;
    DECLARE @R INT;
    DECLARE @EasterDay DATE;

    SET @G=@year%19;
    SET @C=@year/100;
    SET @C_4=@C/4;
    SET @E=(8*@c+13)/25;
    SET @H=(19*@g+ @C-@C_4-@E+15)%30;

    IF (@H=29) SET @H=@H-1;
    ELSE IF (@H=28 AND @G>10) SET @H=@H-1;

    SET @K=@H/28;
    SET @P=29/(@H+1);
    SET @Q=(21-@G)/11;
    SET @I=(@K*@P*@Q-1)*@K+@H;
    SET @B=@year/4+@year;
    SET @J1=@B+@I+2+@C_4-@C;
    SET @J2=@J1%7;
    SET @R=28+@I-@J2;
    SET @EasterDay='01/03/'+convert(CHAR(4),@year);
    SET @EasterDay=dateadd(dd,@r-1,@EasterDay);

    RETURN @EasterDay;
END

GO

IF object_id(N'dbo.GetNthWeekDay', N'FN') IS NOT NULL
    DROP FUNCTION dbo.GetNthWeekDay

GO

CREATE FUNCTION [dbo].[GetNthWeekDay]
(
    @Input DATETIME,
    @WeekDay INT,
    @N INT
) RETURNS DATETIME AS
BEGIN
    DECLARE @cd as INT
    DECLARE @sunday as DATETIME
    DECLARE @CurrWeekDayDate as DATETIME

    SET @cd = datepart(w, @Input)
    SET @sunday = DateAdd(DD, 1-@cd, @Input)

    SELECT @CurrWeekDayDate = DateAdd(DD, @WeekDay-1, @sunday)

    RETURN CAST(Dateadd(wk, @n, @CurrWeekDayDate) AS DATE)
END

GO

/********************************************************************************************/
-- Specify Start Date and End date here

DECLARE @StartDate DATETIME = '01/01/1990' -- Date range starting value
DECLARE @EndDate DATETIME = '19/01/2038'   -- Date Range end value (timestamp limit)


--Temporary Variables To Hold the Values During Processing of Each Date of year
DECLARE
    @WeekMonth365 INT,
    @WeekYear365 INT,
    @WeekTrimester365 INT,
    @WeekMonth INT,
    @CurrentYear INT,
    @CurrentMonth INT,
    @CurrentTrimester INT

/* Table Data type to store the day of week count for the month and year */
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, TrimesterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

-- Extract and assign part of Values from Current Date to Variables
DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentTrimester = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
-- Proceed only if Start Date(Current date) is less than End date you specified above
WHILE @CurrentDate < @EndDate
BEGIN

/*Begin day of week logic*/

    /* Check to Change in month of the Current date if month changed then 
    Change variable value */
    IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
    BEGIN
        UPDATE @DayOfWeek
        SET MonthCount = 0
        SET @CurrentMonth = DATEPART(MM, @CurrentDate)
    END

    /* Check to Change in trimester of the Current date if trimester changed then change 
     Variable value*/
    IF @CurrentTrimester != DATEPART(QQ, @CurrentDate)
    BEGIN
        UPDATE @DayOfWeek
        SET TrimesterCount = 0
        SET @CurrentTrimester = DATEPART(QQ, @CurrentDate)
    END
       
    /* Check to Change in year of the Current date if year changed then change 
     Variable value*/
    IF @CurrentYear != DATEPART(YY, @CurrentDate)
    BEGIN
        UPDATE @DayOfWeek
        SET YearCount = 0
        SET @CurrentYear = DATEPART(YY, @CurrentDate)
    END
    
    -- Set values in table data type created above from variables 
    UPDATE @DayOfWeek
    SET 
        MonthCount = MonthCount + 1,
        TrimesterCount = TrimesterCount + 1,
        YearCount = YearCount + 1
    WHERE DOW = DATEPART(DW, @CurrentDate)

    SELECT
        @WeekMonth365 = MonthCount,
        @WeekTrimester365 = TrimesterCount,
        @WeekYear365 = YearCount
    FROM @DayOfWeek
    WHERE DOW = DATEPART(DW, @CurrentDate)
    
/* End day of week logic*/


/* Populate the Dimension Table */

    INSERT INTO [BI_Dim_Date]
    SELECT
        CONVERT (CHAR(8),@CurrentDate,112) AS idDate,       -- 112 : yyyymmdd
        @CurrentDate AS Date,
        FORMAT(@CurrentDate, 'yyyy-MM-dd') AS [Date texte], -- yyyy-mm-dd
        DATEPART(YEAR, @CurrentDate) AS Année,
        DATEPART(MM, @CurrentDate) AS Mois,
        DATEPART(DW, @CurrentDate) AS [Jour de la semaine],
        DATEPART(DD, @CurrentDate) AS [Jour du mois],
        DATEPART(DY, @CurrentDate) AS [Jour de l année],
        DATENAME(DW, @CurrentDate) AS [Jour de la semaine (nom)],
        @WeekMonth365 AS [Semaine du mois 365],
        DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, '1/' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)) + '/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS [Semaine du mois],
        @WeekTrimester365 AS [Semaine du trimestre 365],
        @WeekYear365 AS [Semaine de l année 365],
        DATEPART(WW, @CurrentDate) AS [Semaine de l année],
        DATENAME(MM, @CurrentDate) AS [Mois (nom)],
        CASE
            WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
            WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
            WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
            END AS [Mois du trimestre],
        DATEPART(QQ, @CurrentDate) AS Trimestre,
        CASE DATEPART(QQ, @CurrentDate)
            WHEN 1 THEN 'Premier'
            WHEN 2 THEN 'Deuxième'
            WHEN 3 THEN 'Troisième'
            WHEN 4 THEN 'Quatrième'
            END AS [Trimestre (nom)],
        RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMAAAA,
        LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS [Mois abrégé - Année],
        CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, @CurrentDate) - 1), @CurrentDate))) AS [Premier jour du mois],
        CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, (DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, @CurrentDate)))) AS [Dernier jour du mois],
        DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS [Premier jour du trimestre],
        DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS [Dernier jour du trimestre],
        CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS [Premier jour de l année],
        CONVERT(DATETIME, '31/12/' + CONVERT(VARCHAR, DATEPART(YY, @CurrentDate))) AS [Dernier jour de l année],
        CASE DATEPART(DW, @CurrentDate)
            WHEN 1 THEN 0
            WHEN 2 THEN 1
            WHEN 3 THEN 1
            WHEN 4 THEN 1
            WHEN 5 THEN 1
            WHEN 6 THEN 1
            WHEN 7 THEN 0
            END AS [Est jour de semaine],
        NULL AS [Jour férié],
        Null AS [Jour équivalent mois précédent],
        Null AS [Jour équivalent année précédent] 
    SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END


/* French holidays */
-- New Tear's Day
    UPDATE [BI_Dim_Date]
        SET [Jour férié]  = 'Jour de l''an'
    WHERE [Mois] = 1 AND [Jour du mois] = 1 
-- Labour day
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Fête du travail'
    WHERE [Mois] = 5 AND [Jour du mois]  = 1
-- 8 Mai 1945
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = '8 Mai 1945'
    WHERE [Mois] = 5 AND [Jour du mois]  = 8
-- National day 
   UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Fête Nationale'
    WHERE [Mois] = 7 AND [Jour du mois]  = 14
-- Assumption
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Assomption'
    WHERE [Mois] = 8 AND [Jour du mois]  = 15
-- All Saints'' Day 
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'La Toussaint'
    WHERE [Mois] = 11 AND [Jour du mois]  = 1
-- Armistice    
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Armistice'
    WHERE [Mois] = 11 AND [Jour du mois]  = 11  
-- Christmas
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Noël'
    WHERE [Mois] = 12 AND [Jour du mois]  = 25


DECLARE @year INT;
SET @year = DATEPART(YEAR, @StartDate);
WHILE @year < DATEPART(YEAR, @EndDate) BEGIN
    SET @year = @year + 1;
-- Easter
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Pâques'
    WHERE Date = dbo.dateDePaques(@year)
-- Ascension
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Ascension'
    WHERE Date = DATEADD(DAY,39,dbo.dateDePaques(@year))
-- Pentecost
    UPDATE [BI_Dim_Date]
        SET [Jour férié] = 'Pentecôte'
    WHERE Date = DATEADD(DAY,50,dbo.dateDePaques(@year))
END

GO

UPDATE [staging].[dbo].[BI_Dim_Date]
SET     [Jour équivalent mois précédent] = dbo.GetNthWeekDay(
            dateadd(mm,-1,Date), 
            DATEPART ( weekday ,Date), 
            0
        ),
        [Jour équivalent année précédent] = dbo.GetNthWeekDay(
            dateadd(yy,-1,Date), 
            DATEPART ( weekday ,Date), 
            0
        )
GO

-- Delete functions created earlier
DROP FUNCTION dbo.dateDePaques
DROP FUNCTION dbo.GetNthWeekDay
        </code></pre>
    </div>
</div>

<h4>Time dimension</h4>
<div class="row">
    <div class="col s12">
        <b><ul class="tabs">
            <li class="tab col s3"><a class="active" href="#description_time">Description</a></li>
            <li class="tab col s3"><a href="#code_time">Code</a></li>
        </ul></b>
    </div>
    <div id="description_time" class="col s12">
        <pre><code class="language-sql">-- =============================================
-- Authors: 
--  - Mubin M. Shaikh (https://www.codeproject.com/Tips/642912/Create-Populate-Time-Dimension-with-Hourplus-Va)
--  - Benjamin Berhault
--
-- Description: T-SQL script to create a French version of a Time dimension
-- =============================================</code></pre>
    </div>
    <div id="code_time" class="col s12">
        <pre><code class="language-sql">IF OBJECT_ID('dbo.[BI_Dim_Time]', 'U') IS NOT NULL 
  DROP TABLE dbo.[BI_Dim_Time]; 

GO

CREATE TABLE BI_Dim_Time(
        [idTime] [int]  NOT NULL UNIQUE,
        [idAltTime] [int] NOT NULL UNIQUE,
        [Heure] [varchar](8) NOT NULL,
        [Heures (nombre)] [tinyint] NOT NULL,
        [Minutes (nombre)] [tinyint] NOT NULL,
        [Secondes (nombre)] [tinyint] NOT NULL,
        [Heure en secondes] [int] NOT NULL,
        [Tranche horaire] varchar(15)not null,
        [Tranche horaire (index)] int not null,
        [Tranche horaire (description)] varchar(100) not null,
        [Jour - nuit (6H - 22H)] BIT NOT NULL DEFAULT(0)
        CONSTRAINT [PK_BI_Dim_Time] PRIMARY KEY CLUSTERED -- SQL Server will sort rows according to the idTime column
            ([idTime] ASC)
        WITH (
        PAD_INDEX = OFF, -- The intermediate-level pages are filled to near capacity, leaving sufficient space for at least one row of the maximum size the index can have, considering the set of keys on the intermediate pages.
        STATISTICS_NORECOMPUTE = OFF,
        IGNORE_DUP_KEY = OFF,
        ALLOW_ROW_LOCKS = ON,
        ALLOW_PAGE_LOCKS = ON
    ) ON [PRIMARY]
)
ON [PRIMARY]

GO
 
DECLARE @Size INTEGER
Set @Size=23

DECLARE @hour INTEGER
DECLARE @minute INTEGER
DECLARE @second INTEGER
DECLARE @k INTEGER
DECLARE @TimeAltKey INTEGER
DECLARE @TimeInSeconds INTEGER
DECLARE @Time30 varchar(25)
DECLARE @Hour30 varchar(4)
DECLARE @Minute30 varchar(4)
DECLARE @Second30 varchar(4)
DECLARE @HourBucket varchar(15)
DECLARE @HourBucketGroupKey int
DECLARE @DayTimeBucketDescription varchar(100)
DECLARE @DayTimeBucket int

SET @hour = 0
SET @minute = 0
SET @second  = 0
SET @k  = 0
SET @TimeAltKey  = 0

WHILE(@hour<= @Size ) 
BEGIN
    
    if (@hour <10 )
            begin
            set @Hour30 = '0' + cast( @hour as varchar(10))
            end
    else
            begin
            set @Hour30 = @hour 
            end
    --Create Hour Bucket Value   
    set @HourBucket= @Hour30+':00' +'-' +@Hour30+':59'  
    
    WHILE(@minute <= 59) 
    BEGIN
        WHILE(@second  <= 59)
            BEGIN   
     
            set @TimeAltKey = @hour *10000 +@minute*100 +@second 
            set @TimeInSeconds =@hour * 3600 + @minute *60 +@second 
        
            If @minute  <10 
            begin
            set @Minute30  = '0' + cast ( @minute as varchar(10) )
            end
            else
            begin
            set @Minute30  = @minute 
            end
         
            if @second   <10 
            begin
            set @Second30   = '0' + cast ( @second as varchar(10) )
            end
            else
            begin
            set @Second30  = @second 
            end
    -- Concatenates values for Time30 column     
    set @Time30 = @Hour30 +':'+@Minute30 +':'+@Second30 
         
    --DayTimeBucket can be used in Sorting of DayTime Bucket In proper Order
    SELECT @DayTimeBucket =
        CASE
                WHEN (@TimeAltKey >= 00000 AND  @TimeAltKey <= 25959) THEN 0 
                WHEN (@TimeAltKey >= 30000 AND  @TimeAltKey <= 65959) THEN 1 
                WHEN (@TimeAltKey >= 70000 AND @TimeAltKey <= 85959)  THEN 2
                WHEN (@TimeAltKey >= 90000 AND @TimeAltKey <= 115959) THEN 3
                WHEN (@TimeAltKey >= 120000 AND @TimeAltKey <= 135959)THEN 4
                WHEN (@TimeAltKey >= 140000 AND @TimeAltKey <= 155959)THEN 5
                WHEN (@TimeAltKey >= 50000 AND @TimeAltKey <= 175959) THEN 6 
                WHEN (@TimeAltKey >= 180000 AND @TimeAltKey <= 235959)THEN 7 
                WHEN (@TimeAltKey >= 240000) THEN  8
        END              

    -- DayTimeBucketDescription Time Divided in Specific Time Zone So Data can Be Grouped as per Bucket for Analyzing as per time of day
    SELECT @DayTimeBucketDescription =
        CASE 
                WHEN (@TimeAltKey >= 00000 AND  @TimeAltKey <= 25959) THEN  N'Tard la nuit (00:00 à 02:59)' 
                WHEN (@TimeAltKey >= 30000 AND  @TimeAltKey <= 65959) THEN  N'Petit matin (03:00 à 6:59)' 
                WHEN (@TimeAltKey >= 70000 AND @TimeAltKey <= 85959) THEN   N'Heure de pointe du matin (7:00 à 8:59)'
                WHEN (@TimeAltKey >= 90000 AND @TimeAltKey <= 115959) THEN  N'Milieu de matinée (9:00 à 11:59)' 
                WHEN (@TimeAltKey >= 120000 AND @TimeAltKey <= 135959) THEN N'Déjeuner (12:00 à 13:59)'
                WHEN (@TimeAltKey >= 140000 AND @TimeAltKey <= 155959)THEN  N'Milieu d''après-midi (14:00 à 15:59)'
                WHEN (@TimeAltKey >= 50000 AND @TimeAltKey <= 175959)THEN   N'Heure de pointe après-midi (16:00 à 17:59)' 
                WHEN (@TimeAltKey >= 180000 AND @TimeAltKey <= 235959)THEN  N'Soirée (18:00 à 23:59)' 
                WHEN (@TimeAltKey >= 240000) THEN                           N'Tard la nuit jour précédent (Minuit à ' +cast( @Size as varchar(10))  + N':00 )'
            END  
      
        INSERT INTO BI_Dim_Time (idTime,idAltTime,[Heure] ,[Heures (nombre)] ,[Minutes (nombre)],[Secondes (nombre)],[Heure en secondes],[Tranche horaire],[Tranche horaire (index)],[Tranche horaire (description)]) 
        VALUES (@TimeAltKey,@k,@Time30 ,@hour ,@minute,@Second , @TimeInSeconds,@HourBucket,@DayTimeBucket,@DayTimeBucketDescription )
        
        SET @second  = @second + 1      
        SET @k = @k  + 1    
    END
        SET @minute = @minute + 1       
        SET @second = 0     
    END
    
        SET @hour = @hour + 1
        SET @minute = 0
    END

GO

    UPDATE [BI_Dim_Time]
    SET [Jour - nuit (6H - 22H)] = 1
      WHERE idAltTime >= 21600 AND idAltTime < 79200

GO
        </code></pre>
    </div>
</div>
