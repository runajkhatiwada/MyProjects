DECLARE @_sql VARCHAR(MAX),
		@_deal_date_from VARCHAR(10),
		@_deal_date_to VARCHAR(10),
		@_status VARCHAR(10)


IF '@deal_date_from' <> 'NULL'
    SET @_deal_date_from = '@deal_date_from'

IF '@deal_date_to' <> 'NULL'
    SET @_deal_date_to = '@deal_date_to'

IF '@status' <> 'NULL'
    SET @_status = '@status'

SET @_sql = '
	SELECT trade_id,
		   status, 
		   error_code,
		   error_description,
		   action,
		   message_type,
		   message_received_timestamp,
		   processed_timestamp,
		   transaction_type,		   
		   source_file_name,
		   ''@deal_date_from'' deal_date_from,
		   ''@deal_date_to'' deal_date_to
	--[__batch_report__]
	FROM source_emir_audit sea
	LEFT JOIN source_deal_header sdh
		ON sdh.deal_id = sea.trade_id
	WHERE 1 = 1
'
+
CASE WHEN @_status IS NOT NULL THEN ' AND sea.status = ''' + @_status + '''' ELSE '' END
 + 
CASE 
	WHEN @_deal_date_from IS NOT NULL AND @_deal_date_to IS NULL THEN ' AND CONVERT(VARCHAR(10), sdh.deal_date, 120) = ''' + @_deal_date_from + '''' ELSE ''
END + 
CASE 
	WHEN @_deal_date_to IS NOT NULL AND @_deal_date_from IS NULL THEN ' AND CONVERT(VARCHAR(10), sdh.deal_date, 120) <= ''' + @_deal_date_to + '''' ELSE ''
END + 
CASE 
	WHEN @_deal_date_to IS NOT NULL AND @_deal_date_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), sdh.deal_date, 120) BETWEEN ''' + @_deal_date_from + ''' AND ''' + @_deal_date_to + '''' ELSE ''
END 

EXEC(@_sql)