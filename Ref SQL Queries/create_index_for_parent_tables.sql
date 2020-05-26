SET NOCOUNT ON
DECLARE @referenced_table VARCHAR(100) = 'static_data_value', --To Do change the table name as per requirement
		@sql_query VARCHAR(MAX),
		@no_of_rows VARCHAR(10) = '2000' --To Do change the row count as per requirement

IF OBJECT_ID ('tempdb..#main_table_details') IS NOT NULL
	DROP TABLE #main_table_details

SELECT DISTINCT 
	   OBJECT_NAME(fk.parent_object_id) main_table,
	   c.[name] main_table_col,
	   OBJECT_NAME(fk.referenced_object_id) referenced_tale,
	   cc.[name] referred_col
INTO #main_table_details
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.[object_id] = fkc.constraint_object_id
INNER JOIN sys.columns c ON fkc.parent_object_id = c.[object_id] AND fkc.parent_column_id = c.column_id
INNER JOIN sys.columns cc ON fkc.referenced_object_id = cc.[object_id] AND fkc.referenced_column_id = cc.column_id
WHERE OBJECT_NAME(fk.referenced_object_id) = @referenced_table
	AND NOT EXISTS (
		SELECT 1
		FROM sys.index_columns ic
		INNER JOIN sys.indexes i ON i.[object_id] = ic.[object_id] 
			AND ic.index_id = i.index_id
		CROSS APPLY (
			SELECT MAX(a.key_ordinal) aa
			FROM sys.index_columns a
			WHERE a.[object_id] = ic.[object_id]
				AND ic.index_id = a.index_id
			HAVING MAX(a.key_ordinal) = 1
		) b
		WHERE [type_desc] IN ('CLUSTERED', 'NONCLUSTERED')
			AND ic.[object_id] = c.[object_id]
			AND ic.column_id = c.column_id
	)

DECLARE @count INT

SELECT TOP(1) @count = ROW_NUMBER() OVER (ORDER BY main_table)
FROM #main_table_details
ORDER BY main_table DESC

SELECT @sql_query = ISNULL(@sql_query, '') + 'SELECT COUNT(1) cnt , ''' + main_table + ''' tbl from '+ main_table + CASE WHEN id <> @count THEN ' UNION ALL ' ELSE '' END
FROM (
SELECT ROW_NUMBER() OVER (ORDER BY main_table) id,*
FROM #main_table_details
) a

IF OBJECT_ID ('tempdb..#tbl') IS NOT NULL
	DROP TABLE #tbl

CREATE TABLE #tbl (
	cnt INT,
	tbl VARCHAR(100)
)

EXEC ('
	INSERT INTO #tbl
	SELECT * FROM (
	' +  @sql_query + '
	) a
	WHERE cnt > ' + @no_of_rows + '
	ORDER BY cnt
' )

DECLARE @main_table VARCHAR(1000), @main_table_col VARCHAR(1000), @index_name VARCHAR(1000)
DECLARE db_cursor CURSOR FOR 
	SELECT DISTINCT main_table, main_table_col
	FROM #main_table_details r
	INNER JOIN #tbl t ON r.main_table = t.tbl
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @main_table, @main_table_col

WHILE @@FETCH_STATUS = 0  
BEGIN
	SET @index_name = 'IX_' + @main_table + '_' + @main_table_col
	
	PRINT ('
		--' + @main_table + '|' + @main_table_col + '|' + @index_name + '
		IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = ''' + @index_name + ''' AND [object_id] = OBJECT_ID(''' + @main_table + '''))
		BEGIN
			CREATE NONCLUSTERED INDEX IX_' + @main_table + '_' + @main_table_col + ' ON ' + @main_table + '(' + @main_table_col + ') WITH (ONLINE = ON)
		END
	')
FETCH NEXT FROM db_cursor INTO @main_table, @main_table_col 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 
GO