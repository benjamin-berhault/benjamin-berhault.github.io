-- =============================================
-- Authors : Mubin M. Shaikh (https://www.codeproject.com/Articles/647950/Create-and-Populate-Date-Dimension-for-Data-Wareho), Benjamin Berhault
--
-- Date de création : 11/09/2018
--
-- Description: T-SQL script to create a French version of a dimension "Dim_Time" under the dbo SCHEMA 
-- =============================================

IF OBJECT_ID('dbo.[BI_Dim_Date]', 'U') IS NOT NULL 
  DROP TABLE dbo.[BI_Dim_Date]; 
GO
/**********************************************************************************/

CREATE TABLE	[BI_Dim_Date]
	(	[idDate] INT NOT NULL UNIQUE, 
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
		CONVERT (CHAR(8),@CurrentDate,112) AS idDate,		-- 112 : yyyymmdd
		@CurrentDate AS Date,
		FORMAT(@CurrentDate, 'yyyy-MM-dd') AS [Date texte],	-- yyyy-mm-dd
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
SET		[Jour équivalent mois précédent] = dbo.GetNthWeekDay(
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