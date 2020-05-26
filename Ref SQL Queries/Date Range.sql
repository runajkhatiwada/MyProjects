DECLARE @start_date_time DATETIME
DECLARE @end_date_time DATETIME

SET @start_date_time = '2015-01-01'
SET @end_date_time = '2015-01-12';

WITH date_range(date_data) AS 
(
    SELECT @start_date_time as Date
    UNION ALL
    SELECT DATEADD(d, 1, date_data)
    FROM date_range 
    WHERE date_data < @end_date_time
)
SELECT date_data
FROM date_range
OPTION (MAXRECURSION 0)
GO