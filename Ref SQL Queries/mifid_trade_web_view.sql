DECLARE @_sql VARCHAR(MAX),
		@_counterparty_id VARCHAR(MAX), 
		@_action_type CHAR(4),
		@_create_ts_from VARCHAR(10),
		@_create_ts_to VARCHAR(10),
		@_deal_id VARCHAR(MAX),
		@_deal_date_from VARCHAR(10),
		@_deal_date_to VARCHAR(10)

--IF '@deal_date_from' <> 'NULL'
--    SET @_deal_date_from = '@deal_date_from'

--IF '@deal_date_to' <> 'NULL'
--    SET @_deal_date_to = '@deal_date_to'

--IF '@create_ts_from' <> 'NULL'
--    SET @_create_ts_from = '@create_ts_from'
	
--IF '@create_ts_to' <> 'NULL'
--    SET @_create_ts_to = '@create_ts_to'

--IF '@source_deal_header_id' <> 'NULL'
--    SET @_deal_id = '@source_deal_header_id'

--IF '@counterparty_id' <> 'NULL'
--    SET @_counterparty_id = '@counterparty_id'



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
	--AND ('@sub_id' = 'NULL' OR sub.entity_id IN (@sub_id)) 
	--AND ('@stra_id' = 'NULL' OR stra.entity_id IN (@stra_id)) 
	--AND ('@book_id' = 'NULL' OR book.entity_id IN (@book_id))
	--AND ('@sub_book_id' = 'NULL' OR ssbm.book_deal_type_map_id IN (@sub_book_id))

SET @_sql = '
--[__batch_report__]
SELECT smt.source_deal_header_id,
	   smt.deal_id,
	   ssbm.sub_name sub_id,
	   ssbm.stra_name stra_id,
	   ssbm.book_name book_id,
	   ssbm.logical_name sub_book_id,
	   sdh.deal_date [deal_date_from],
	   trading_date_and_time,
	   instrument_identification_code_type,
	   instrument_identification_code,
	   dbo.FNARemoveTrailingZeroes(ROUND(price, 4)) [price],
	   venue_of_execution,
	   price_notation,
	   price_currency,
	   notation_quantity_measurement_unit,
	   dbo.FNARemoveTrailingZeroes(ROUND(quantity_measurement_unit, 4)) [quantity_in_measurement_unit],
	   dbo.FNARemoveTrailingZeroes(ROUND(quantity, 4)) [quantity],
	   dbo.FNARemoveTrailingZeroes(ROUND(notional_amount, 4)) [notional_amount],
	   notional_currency,
	   [type],
	   publication_date_and_time,
	   transaction_identification_code,
	   transaction_to_be_cleared,
	   flags,
	   supplimentary_deferral_flags,
	   trade_report_id,
	   trade_version,
	   trade_report_type,
	   trade_report_reject_reason,
	   CASE WHEN trade_report_trans_type = 0 THEN ''New''
			WHEN trade_report_trans_type = 1 THEN ''Cancel'' 
			WHEN trade_report_trans_type = 2 THEN ''Modified'' 
	   END [trade_report_trans_type],
	   package_id,
	   trade_number,
	   total_num_trade_reports,
	   security_id,
	   security_id_source,
	   unit_of_measure,
	   contract_multiplier,
	   reporting_party_lei,
	   submitting_party_lei,
	   submitting_party_si_status,
	   asset_class,
	   contract_type,
	   asset_sub_class,
	   maturity_date,
	   freight_size,
	   specific_route_or_time_charter_average,
	   settlement_location,
	   reference_rate,
	   ir_term_of_contract,
	   parameter,
	   notional_currency2,
	   series,
	   version,
	   roll_months,
	   next_roll_date,
	   CASE WHEN smt.option_type = 1 THEN ''Call''
			WHEN smt.option_type = 2 THEN ''Put'' 
	   END [option_type],
	   strike_price,
	   strike_currency,
	   exercise_style,
	   delivery_type,
	   smt.transaction_type,
	   final_price_type,
	   floating_rate_of_leg2,
	   ir_term_of_contract_leg2,
	   issue_date,
	   settl_currency,
	   notional_schedule,
	   valuation_method_trigger,
	   return_or_payout_trigger,
	   debt_seniority,
	   dsb_use_case,
	   no_underlyings,
	   underlying_symbol,
	   underlying_security_type,
	   underlying_issuer,
	   underlying_maturity_date,
	   underlying_issue_date,
	   underlying_security_id,
	   underlying_security_id_source,
	   underlying_index_name,
	   underlying_issuer_type,
	   underlying_index_term,
	   underlying_further_sub_product,
	   underlying_other_security_type,
	   underlying_other_further_sub_product,
	   error_validation_message,
	   smt.create_ts create_ts_from,
	   ''@create_ts_to'' create_ts_to,
	   ''@deal_date_to'' deal_date_to,
	   ''@counterparty_id'' counterparty_id
FROM source_mifid_trade smt
INNER JOIN source_deal_header sdh
	ON sdh.source_deal_header_id = smt.source_deal_header_id
INNER JOIN source_counterparty sc
	ON sc.source_counterparty_id = sdh.counterparty_id
INNER JOIN #books ssbm
	ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
INNER JOIN static_data_value sdv
	ON sdv.value_id = smt.submission_status
	AND sdv.type_id = 39500
WHERE sdv.value_id = 39502'

+
CASE WHEN @_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @_counterparty_id + ')' 
	 ELSE ''
END
+
CASE 
	WHEN @_create_ts_from IS NOT NULL AND @_create_ts_to IS NULL THEN ' AND CONVERT(VARCHAR(10), smt.create_ts, 120) = ''' + CONVERT(VARCHAR(10), @_create_ts_from, 120) + ''''
	ELSE ''
END 
+ 
CASE 
	WHEN @_create_ts_to IS NOT NULL AND @_create_ts_from IS NULL THEN ' AND CONVERT(VARCHAR(10), smt.create_ts, 120) < ''' + CONVERT(VARCHAR(10), @_create_ts_to, 120) + ''''
	ELSE ''
END 
+ 
CASE 
	WHEN @_create_ts_to IS NOT NULL AND @_create_ts_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), smt.create_ts, 120) BETWEEN ''' + CONVERT(VARCHAR(10), @_create_ts_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @_create_ts_to, 120) + ''''
	ELSE ''
END
+ 
CASE 
	WHEN @_deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @_deal_id + ')'
	ELSE ''
END
+
CASE WHEN @_action_type IS NOT NULL THEN ' AND smt.action_type = ''' + @_action_type + '''' 
	 ELSE ''
END
+
CASE 
	WHEN @_deal_date_from IS NOT NULL AND @_deal_date_to IS NULL THEN ' AND CONVERT(VARCHAR(10), sdh.deal_date, 120) = ''' + CONVERT(VARCHAR(10), @_deal_date_to, 120) + ''''
	ELSE ''
END
+ 
CASE 
	WHEN @_deal_date_to IS NOT NULL AND @_deal_date_from IS NULL THEN ' AND CONVERT(VARCHAR(10), sdh.deal_date, 120) < ''' + CONVERT(VARCHAR(10), @_deal_date_to, 120) + ''''
	ELSE ''
END
+ 
CASE 
	WHEN @_deal_date_to IS NOT NULL AND @_deal_date_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), sdh.deal_date, 120) BETWEEN ''' + CONVERT(VARCHAR(10), @_deal_date_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @_deal_date_to, 120) + ''''
	ELSE ''
END

EXEC(@_sql)

