DECLARE @_report_group INT = '@report_group',
		@_report_level CHAR(1),
		@_time_stamp_from VARCHAR(10),
		@_time_stamp_to VARCHAR(10), 
		@_submission_status INT,
		@_sql_string VARCHAR(MAX),
		@_deal_id VARCHAR(MAX)

IF '@report_level' <> 'NULL'
    SET @_report_level = '@report_level'
				
IF '@submission_status' <> 'NULL'
    SET @_submission_status = '@submission_status'

IF '@time_stamp_from' <> 'NULL'
    SET @_time_stamp_from = '@time_stamp_from'

IF '@time_stamp_to' <> 'NULL'
    SET @_time_stamp_to = '@time_stamp_to'

IF '@deal_id' <> 'NULL'
    SET @_deal_id = '@deal_id'

IF OBJECT_ID(N'tempdb..#books') IS NOT NULL
	DROP TABLE #books
	
SELECT sub.[entity_id] sub_id,
	   stra.[entity_id] stra_id,
	   book.[entity_id] book_id,
	   sub.[entity_name] AS sub_name,
	   stra.[entity_name] AS stra_name,
	   book.[entity_name] AS book_name,
	   ssbm.source_system_book_id1, 
	   ssbm.source_system_book_id2, 
	   ssbm.source_system_book_id3, 
	   ssbm.source_system_book_id4,
	   ssbm.logical_name,
	   ssbm.book_deal_type_map_id [sub_book_id],
	   ssbm.fas_deal_type_value_id [transaction_type],
	   sdv.code [transaction_type_name],
	   ssbm.sub_book_group1,
	   ssbm.sub_book_group2,
	   ssbm.sub_book_group3,
	   ssbm.sub_book_group4,
	   fs.counterparty_id 
INTO #books
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) 
	ON book.parent_entity_id = stra.[entity_id]
INNER JOIN portfolio_hierarchy sub (NOLOCK)
	ON stra.parent_entity_id = sub.[entity_id]
INNER JOIN source_system_book_map ssbm
	ON ssbm.fas_book_id = book.[entity_id]
INNER JOIN fas_subsidiaries fs
	ON fs.fas_subsidiary_id = sub.[entity_id]
LEFT JOIN static_data_value sdv 
	ON sdv.[type_id] = 400 
		AND ssbm.fas_deal_type_value_id = sdv.value_id
WHERE 1 = 1 
	AND ('@sub_id' = 'NULL' OR sub.entity_id IN (@sub_id)) 
	AND ('@stra_id' = 'NULL' OR stra.entity_id IN (@stra_id)) 
	AND ('@book_id' = 'NULL' OR book.entity_id IN (@book_id))
	AND ('@sub_book_id' = 'NULL' OR ssbm.book_deal_type_map_id IN (@sub_book_id))
EXEC(@_sql_string)

IF OBJECT_ID('tempdb..#source_emir') IS NOT NULL
	DROP TABLE #source_emir

SELECT source_deal_header_id,
	   create_ts,
	   submission_status
INTO #source_emir
FROM 
(
	SELECT source_deal_header_id,
		   create_ts,
		   submission_status,
		   RANK() OVER(PARTITION BY source_deal_header_id ORDER  BY create_ts) AS [rank]
	FROM source_emir
) a
WHERE [rank] = 1


IF OBJECT_ID('tempdb..#source_mifid') IS NOT NULL
	DROP TABLE #source_mifid

SELECT source_deal_header_id,
	   create_ts,
	   submission_status
INTO #source_mifid
FROM 
(
	SELECT source_deal_header_id,
		   create_ts,
		   submission_status,
		   RANK() OVER(PARTITION BY source_deal_header_id ORDER  BY create_ts) AS [rank]
	FROM source_mifid
) a
WHERE [rank] = 1

IF OBJECT_ID('tempdb..#source_emir_collateral') IS NOT NULL
	DROP TABLE #source_emir_collateral

SELECT source_deal_header_id,
	   create_ts,
	   submission_status
INTO #source_emir_collateral
FROM 
(
	SELECT source_deal_header_id,
		   create_ts,
		   submission_status,
		   RANK() OVER(PARTITION BY source_deal_header_id ORDER  BY create_ts) AS [rank]
	FROM source_emir_collateral
) a
WHERE [rank] = 1

IF OBJECT_ID('tempdb..#source_mifid_trade') IS NOT NULL
	DROP TABLE #source_mifid_trade

SELECT source_deal_header_id,
	   create_ts,
	   submission_status
INTO #source_mifid_trade
FROM 
(
	SELECT source_deal_header_id,
		   create_ts,
		   submission_status,
		   RANK() OVER(PARTITION BY source_deal_header_id ORDER  BY create_ts) AS [rank]
	FROM source_mifid_trade
) a
WHERE [rank] = 1

IF OBJECT_ID ('tempdb..#master_collection') IS NOT NULL
	DROP TABLE #master_collection

SELECT a.*
INTO #master_collection
FROM (
SELECT *, CAST('MiFID' AS VARCHAR(500)) report_group_code, 'Transaction (AFM)' report_level_code FROM #source_mifid UNION ALL
SELECT *, 'EMIR', 'Trade/MTM/Position' FROM #source_emir UNION ALL
SELECT *, 'EMIR', 'Collateral' FROM #source_emir_collateral UNION ALL
SELECT *, 'MiFID', 'TradeWeb' FROM #source_mifid_trade
) a
INNER JOIN source_deal_header sdh
	ON sdh.source_deal_header_id = a.source_deal_header_id
INNER JOIN #books book
	ON book.source_system_book_id1 = sdh.source_system_book_id1
		AND book.source_system_book_id2 = sdh.source_system_book_id2
		AND book.source_system_book_id3 = sdh.source_system_book_id3
		AND book.source_system_book_id4 = sdh.source_system_book_id4

SET @_sql_string = '
	--[__batch_report__]
	SELECT ' + CASE 
					WHEN @_report_group = 44703 THEN '''EMIR''' 
					WHEN @_report_group = 44704 THEN '''MiFID'''
					ELSE 'ISNULL(se.report_group_code, ''Not Generated'')'
			   END + ' report_group_code,
		   ' + CASE 
					WHEN @_report_level = 'X' THEN '''Transaction (AFM)'''
					WHEN @_report_level = 'T' THEN '''Trade'''
					WHEN @_report_level = 'W' THEN '''TradeWeb'''
					WHEN @_report_level = 'M' THEN '''MTM'''
					WHEN @_report_level = 'P' THEN '''Position'''
					WHEN @_report_level = 'C' THEN '''Collateral'''
					ELSE 'ISNULL(se.report_level_code, ''Not Generated'')'
			   END + ' report_level_code,
		   book.sub_name + '' | '' + book.stra_name + '' | '' + book.book_name + '' | '' + book.logical_name AS [portfolio_hierarchy],
		   ISNULL(sdv.code, ''Not Generated'') submisison_status_code,
		   sdh.source_deal_header_id,
		   sdh.deal_id,
		   sdh.deal_date,
		   sdh.entire_term_start,
		   sdh.entire_term_end,
		   sc.counterparty_name counterparty,
		   st.trader_name,
		   IIF(sdh.header_buy_sell_flag = ''b'', ''Buy'', ''Sell'') buy_sell,
		   deal_status.code deal_status,
		   scm.commodity_name commodity,
		   sdt.source_deal_type_name deal_type,
		   ISNULL(dbo.FNAUserDateTimeFormat(se.create_ts, 1, dbo.FNADBUser()), '''') time_stamp_from,
		   ''@time_stamp_to'' [time_stamp_to],
		   ''@report_group'' [report_group],
		   ''@report_level'' [report_level],
		   ''@submission_status'' [submission_status],
		   ''@sub_id'' [sub_id],
		   ''@stra_id'' [stra_id],
		   ''@book_id'' [book_id],
		   ''@sub_book_id'' [sub_book_id]
	FROM source_deal_header sdh
	INNER JOIN #books book
		ON book.source_system_book_id1 = sdh.source_system_book_id1
			AND book.source_system_book_id2 = sdh.source_system_book_id2
			AND book.source_system_book_id3 = sdh.source_system_book_id3
			AND book.source_system_book_id4 = sdh.source_system_book_id4
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN source_traders st
		ON st.source_trader_id = sdh.trader_id
	LEFT JOIN static_data_value deal_status
		ON deal_status.value_id = sdh.deal_status
			AND deal_status.[type_id] = 5600
	LEFT JOIN source_commodity scm
		ON scm.source_commodity_id = sdh.commodity_id
	LEFT JOIN source_deal_type sdt
		ON sdt.source_deal_type_id = sdh.source_deal_type_id
	'
+
CASE WHEN @_report_group = 44703 AND @_report_level IN ('C', 'T', 'M') THEN '
									LEFT JOIN #source_emir se 
										ON se.source_deal_header_id = sdh.source_deal_header_id 
									'
	 WHEN @_report_group = 44703 AND @_report_level = 'C' THEN '
									LEFT JOIN #source_emir_collateral se 
										ON se.source_deal_header_id = sdh.source_deal_header_id
									'
	 WHEN @_report_group = 44704 AND @_report_level = 'X' THEN '
									LEFT JOIN #source_mifid se 
										ON se.source_deal_header_id = sdh.source_deal_header_id											
									'
	 WHEN @_report_group = 44704 AND @_report_level = 'W' THEN '
									LEFT JOIN #source_mifid_trade se 
										ON se.source_deal_header_id = sdh.source_deal_header_id
									'
	WHEN @_report_group = -1 AND @_report_level IS NULL THEN '
									LEFT JOIN #master_collection se 
										ON se.source_deal_header_id = sdh.source_deal_header_id
								   '
	WHEN @_report_group = 44703 AND @_report_level IS NULL THEN '
									LEFT JOIN #master_collection se 
										ON se.source_deal_header_id = sdh.source_deal_header_id
											AND se.report_group_code = ''EMIR''
								   '
	WHEN @_report_group = 44704 AND @_report_level IS NULL THEN '
									LEFT JOIN #master_collection se 
										ON se.source_deal_header_id = sdh.source_deal_header_id
											AND se.report_group_code = ''MiFID''
								   '
	ELSE '
									INNER JOIN #master_collection se 
										ON 1 = 2
								   '
END

SET @_sql_string = @_sql_string + '
					LEFT JOIN static_data_value sdv 
						ON sdv.value_id = se.submission_status 
							AND sdv.type_id = 39500
					WHERE 1 = 1' + 
 
CASE 
	WHEN @_time_stamp_from IS NOT NULL AND @_time_stamp_to IS NULL THEN ' AND CONVERT(VARCHAR(10), se.create_ts, 120) = ''' + CONVERT(VARCHAR(10), @_time_stamp_from, 120) + ''''
	ELSE ''
END + 
CASE 
	WHEN @_time_stamp_to IS NOT NULL AND @_time_stamp_from IS NULL THEN ' AND CONVERT(VARCHAR(10), se.create_ts, 120) < ''' + CONVERT(VARCHAR(10), @_time_stamp_to, 120) + ''''
	ELSE ''
END + 
CASE 
	WHEN @_time_stamp_to IS NOT NULL AND @_time_stamp_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), se.create_ts, 120) BETWEEN ''' + CONVERT(VARCHAR(10), @_time_stamp_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @_time_stamp_to, 120) + ''''
	ELSE ''
END
 + 
CASE 
	WHEN @_deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @_deal_id + ')'
	ELSE ''
END

IF @_submission_status = -1 
BEGIN
	SET @_sql_string = @_sql_string + ' AND se.submission_status IS NULL' 
END
ELSE IF @_submission_status IS NULL
BEGIN
	SET @_sql_string = @_sql_string
END
ELSE
BEGIN
	SET @_sql_string = @_sql_string + ' AND se.submission_status = ' + CAST(@_submission_status AS VARCHAR(10))
END

SET @_sql_string = @_sql_string + ' ORDER BY sdh.source_deal_header_id, sdh.deal_id'

EXEC(@_sql_string)



