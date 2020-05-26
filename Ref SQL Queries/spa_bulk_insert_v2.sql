IF OBJECT_ID(N'spa_bulk_insert_v2', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_bulk_insert_v2]
GO

CREATE PROCEDURE spa_bulk_insert_v2
	@table_name VARCHAR(250),
	@field_terminator VARCHAR(250),
	@row_terminator VARCHAR(250),
	@has_column_header CHAR(1),
	@is_enclosed_with_quotes BIT = 0,
	@csv_file VARCHAR(1000)
AS

/************************************
DECLARE @table_name VARCHAR(250),
		@field_terminator VARCHAR(250),
		@row_terminator VARCHAR(250),
		@has_column_header CHAR(1),
		@is_enclosed_with_quotes BIT = 0,
		@csv_file VARCHAR(1000)

SELECT @table_name = 'adiha_process.dbo.emir_feed_back_test', 
	   @field_terminator = ',', 
	   @row_terminator = '\n', 
	   @has_column_header = 'y', 
	   @is_enclosed_with_quotes = 1, 
	   @csv_file = '\\psdl12\Shared\bcpfmt.csv'
--**********************************/

DECLARE @sql VARCHAR(MAX), @first_row INT

SET @first_row = IIF(@has_column_header = 'n', 1, 2)
SET @field_terminator = IIF(@is_enclosed_with_quotes = 0, @field_terminator, '","')
SET @sql = '
	BULK INSERT ' + @table_name + ' FROM ''' + @csv_file + '''
	WITH ( FIELDTERMINATOR = ''' + @field_terminator + ''', ROWTERMINATOR = ''' + @row_terminator + ''', FIRSTROW = ' + CAST(@first_row AS VARCHAR(10)) + ')
	
	'

PRINT (@sql)
EXEC (@sql)



DECLARE @first_column VARCHAR(255), 
		@last_column VARCHAR(255)

SELECT @first_column = COLUMN_NAME 
FROM adiha_process.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = REPLACE(@table_name, 'adiha_process.dbo.', '')
	AND ORDINAL_POSITION = 1

SELECT @last_column = COLUMN_NAME 
FROM (
	SELECT TOP 1 COLUMN_NAME
	FROM adiha_process.INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_NAME = REPLACE(@table_name, 'adiha_process.dbo.', '')
	ORDER BY ORDINAL_POSITION DESC
) a

EXEC ('
UPDATE ' + @table_name + '
SET ' + @first_column + ' = REPLACE(' + @first_column + ', ''"'', '''')
')

EXEC ('
UPDATE ' + @table_name + '
SET ' + @last_column + ' = REPLACE(' + @last_column + ', ''"'', '''')
')

EXEC ('SELECT * FROM ' + @table_name)