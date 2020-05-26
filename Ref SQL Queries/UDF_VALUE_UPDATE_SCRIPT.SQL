DECLARE @folder_location VARCHAR(1000),
		@csv_file_name VARCHAR(1000) = 'UDF Header.csv', --Copy the source file to temp note of shared docs
		@process_id VARCHAR(100) = dbo.FNAGetNewID(),
		@process_table_name VARCHAR(1000),
		@result VARCHAR(10),
		@header_detail CHAR(1) = 'h',--d for detail UDF, h for header UDF
		@sql_query VARCHAR(MAX)

SET @process_table_name = 'adiha_process.dbo.Deal_Detail_UDF_' + @process_id

SELECT @folder_location = document_path + '\temp_Note\' + @csv_file_name
FROM connection_string

EXEC spa_import_from_csv @csv_file_path = @folder_location,
						 @process_table_name = @process_table_name,
						 @delimeter = ',',
						 @row_terminator = '\n',
						 @has_column_headers = 'y',
						 @has_fields_enclosed_in_quotes = 'n',
						 @include_filename = 'n',
						 @result = @result OUTPUT,
						 @format_column_header_for_xml = 'n'

IF @result <> 'success'
BEGIN
	PRINT 'CSV File not found, or Permission issue.'
	RETURN
END

IF OBJECT_ID('tempdb..#temp_udf_values') IS NOT NULL
	DROP TABLE #temp_udf_values

CREATE TABLE #temp_udf_values (
	deal_id VARCHAR(1000) COLLATE DATABASE_DEFAULT,
	udf_name VARCHAR(1000) COLLATE DATABASE_DEFAULT,
	term_start VARCHAR(10) COLLATE DATABASE_DEFAULT,
	term_end VARCHAR(10) COLLATE DATABASE_DEFAULT,
	leg CHAR(1) COLLATE DATABASE_DEFAULT,
	[value] VARCHAR(100) COLLATE DATABASE_DEFAULT
)

EXEC ('
	INSERT INTO #temp_udf_values
	SELECT * FROM ' + @Process_table_name
)

BEGIN TRY
	BEGIN TRANSACTION
	SET NOCOUNT ON
	
	SET @sql_query = '
		UPDATE udf
		SET udf.udf_value = p.[Value]
		--SELECT sdh.deal_id, udf.udf_value, p.[Value]
		FROM #temp_udf_values p 
		INNER JOIN source_deal_header sdh
			ON sdh.deal_id = p.deal_id
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id '
		+ CASE WHEN @header_detail = 'd' THEN '
			AND CONVERT(VARCHAR(10), CAST(p.term_start AS DATE), 120) = CONVERT(VARCHAR(10), sdd.term_start, 120)
			AND CONVERT(VARCHAR(10), CAST(p.term_end AS DATE), 120) = CONVERT(VARCHAR(10), sdd.term_end, 120)
			AND p.leg = sdd.leg' ELSE '' END + '
		INNER JOIN source_deal_header_template sdht
			ON sdht.template_id = sdh.template_id
		LEFT JOIN ' + IIF(@header_detail = 'h', 'user_defined_deal_fields', 'user_defined_deal_detail_fields') + ' udf
			ON ' + IIF(@header_detail = 'h', 'udf.source_deal_header_id = sdh.source_deal_header_id', 'udf.source_deal_detail_id = sdd.source_deal_detail_id') + '
		INNER JOIN user_defined_fields_template udft
			ON udft.field_label = p.udf_name
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.field_id = udft.field_id
				AND uddft.udf_template_id = udf.udf_template_id
				AND uddft.template_id = sdh.template_id
				AND uddft.udf_type = ''' + @header_detail + '''		
		LEFT JOIN deal_type_pricing_maping dtpm
			ON dtpm.template_id = sdh.template_id
				AND dtpm.source_deal_type_id = sdh.source_deal_type_id
				AND ((sdh.pricing_type IS NULL AND dtpm.pricing_type IS NULL) OR dtpm.pricing_type = sdh.pricing_type)
				AND ((dtpm.[commodity_id] IS NULL AND sdh.commodity_id IS NULL) OR ISNULL(dtpm.[commodity_id], sdh.commodity_id) = sdh.commodity_id)
		LEFT JOIN maintain_field_template mft
			ON mft.field_template_id = sdht.field_template_id
		WHERE 1 = CASE WHEN dtpm.enable_cost_tab IS NOT NULL AND IIF(dtpm.enable_cost_tab = 1, ''y'', ''n'') = ''y'' AND ISNULL(mft.show_cost_tab, ''n'') = ''y'' THEN 1
					   WHEN dtpm.enable_cost_tab IS NULL AND ISNULL(mft.show_cost_tab,''n'') = ''y'' THEN 1
				  END
			AND udf.udf_deal_id IS NOT NULL 
	'

	--PRINT @sql_query
	EXEC(@sql_query)
	
	SET @sql_query = '
		INSERT INTO ' + IIF(@header_detail = 'h', 'user_defined_deal_fields(source_deal_header_id', 'user_defined_deal_detail_fields(source_deal_detail_id') + ' , udf_template_id, udf_value)
		SELECT DISTINCT ' + IIF(@header_detail = 'h', 'sdh.source_deal_header_id', 'sdd.source_deal_detail_id') + ', uddft.udf_template_id, p.[Value]
		FROM #temp_udf_values p 
		INNER JOIN source_deal_header sdh
			ON sdh.deal_id = p.deal_id
		INNER JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id'
		+ CASE WHEN @header_detail = 'd' THEN '
			AND CONVERT(VARCHAR(10), CAST(p.term_start AS DATE), 120) = CONVERT(VARCHAR(10), sdd.term_start, 120)
			AND CONVERT(VARCHAR(10), CAST(p.term_end AS DATE), 120) = CONVERT(VARCHAR(10), sdd.term_end, 120)
			AND p.leg = sdd.leg
		' ELSE '' END + '
		INNER JOIN source_deal_header_template sdht
			ON sdht.template_id = sdh.template_id
		LEFT JOIN ' + IIF(@header_detail = 'h', 'user_defined_deal_fields', 'user_defined_deal_detail_fields') + ' udf
			ON ' + IIF(@header_detail = 'h', 'udf.source_deal_header_id = sdh.source_deal_header_id', 'udf.source_deal_detail_id = sdd.source_deal_detail_id') + '
		INNER JOIN user_defined_deal_fields_template uddft
			ON uddft.template_id = sdh.template_id
				AND uddft.udf_type = ''' + @header_detail + '''
		INNER JOIN user_defined_fields_template udft
			ON udft.field_id = uddft.field_id
				AND udft.field_label = p.udf_name
		LEFT JOIN deal_type_pricing_maping dtpm
			ON dtpm.template_id = sdh.template_id
				AND dtpm.source_deal_type_id = sdh.source_deal_type_id
				AND ((sdh.pricing_type IS NULL AND dtpm.pricing_type IS NULL) OR dtpm.pricing_type = sdh.pricing_type)
				AND ((dtpm.[commodity_id] IS NULL AND sdh.commodity_id IS NULL) OR ISNULL(dtpm.[commodity_id], sdh.commodity_id) = sdh.commodity_id)
		LEFT JOIN maintain_field_template mft
			ON mft.field_template_id = sdht.field_template_id
		WHERE 1 = CASE WHEN dtpm.enable_cost_tab IS NOT NULL AND IIF(dtpm.enable_cost_tab = 1, ''y'', ''n'') = ''y'' AND ISNULL(mft.show_cost_tab, ''n'') = ''y'' THEN 1
					   WHEN dtpm.enable_cost_tab IS NULL AND ISNULL(mft.show_cost_tab,''n'') = ''y'' THEN 1
				  END
			AND udf.udf_deal_id IS NULL
	'

	--PRINT @sql_query
	EXEC(@sql_query)
	
	COMMIT

	SELECT 'Update success for given list of deals.' [Status]
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1
		ROLLBACK;

	SELECT 'Update failed with following error:' + ERROR_MESSAGE() [Error Message]
END CATCH
GO