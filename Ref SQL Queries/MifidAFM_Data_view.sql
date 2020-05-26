DECLARE @_sql VARCHAR(MAX),
		@_counterparty_id VARCHAR(MAX), 
		@_action_type CHAR(4),
		@_create_ts_from VARCHAR(10),
		@_create_ts_to VARCHAR(10),
		@_deal_id VARCHAR(MAX),
		@_deal_date_from VARCHAR(10),
		@_deal_date_to VARCHAR(10)

IF '@deal_date_from' <> 'NULL'
    SET @_deal_date_from = '@deal_date_from'

IF '@deal_date_to' <> 'NULL'
    SET @_deal_date_to = '@deal_date_to'

IF '@create_ts_from' <> 'NULL'
    SET @_create_ts_from = '@create_ts_from'
	
IF '@create_ts_to' <> 'NULL'
    SET @_create_ts_to = '@create_ts_to'

IF '@source_deal_header_id' <> 'NULL'
    SET @_deal_id = '@source_deal_header_id'

IF '@counterparty_id' <> 'NULL'
    SET @_counterparty_id = '@counterparty_id'

IF '@action_type' <> 'NULL'
    SET @_action_type = '@action_type'

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

SET @_sql = '
	--[__batch_report__]
	SELECT sm.source_mifid_id,
		   sm.source_deal_header_id,
		   sm.deal_id,
		   ssbm.sub_name sub_id,
		   ssbm.stra_name stra_id,
		   ssbm.book_name book_id,
		   ssbm.logical_name sub_book_id,
		   sdh.deal_date deal_date_from,
		   sm.[report_status] action_type,
		   sm.[trans_ref_no] AS [transaction_reference_number],
		   sm.[trading_trans_id] AS [Trading_Venue_Transaction_ID_Code],
		   sm.[exec_entity_id] AS [Executing_Entity_ID_Code],
		   sm.[covered_by_dir] AS [Investment_Firm_Covered_by_Directive_2014_65_EU],
		   sm.[submitting_entity_id_code] AS [Submitting_Entity_ID_Code],
		   sm.[buyer_id] AS [Buyer_ID_Code],
		   sm.[buyer_country],
		   sm.[buyer_fname] AS [Buyer_First_Name],
		   sm.[buyer_sname] AS [Buyer_Surname],
		   sm.[buyer_dob] AS [Buyer_Date_of_Birth],
		   sm.[buyer_decision_maker_code] AS [Buyer_Decision_Maker_Code],
		   sm.[buyer_decision_maker_fname] AS [Buyer_Decision_Maker_First_Name],
		   sm.[buyer_decision_maker_sname] AS [Buyer_Decision_Maker_Surname],
		   CONVERT(VARCHAR(10), sm.[buyer_decision_maker_dob], 120) AS [Buyer_Decision_Maker_Date_of_Birth],
		   sm.[seller_id] AS [Seller_ID_Code],
		   sm.[seller_country],
		   sm.[seller_fname] AS [Seller_First_Name],
		   sm.[seller_sname] AS [Seller_Surname_],
		   sm.[seller_dob] AS [Seller_Date_of_Birth],
		   sm.[seller_decision_maker_code] AS [Seller_Decision_Maker_Code],
		   sm.[seller_decision_maker_fname] AS [Seller_Decision_Maker_First_Name],
		   sm.[seller_decision_maker_sname] AS [Seller_Decision_Maker_Surname],
		   CONVERT(VARCHAR(10), sm.[seller_decision_maker_dob], 120) AS [Seller_Decision_Maker_Date_of_Birth],
		   sm.[order_trans_indicator] AS [Transmission_of_Order_Indicator],
		   sm.[buyer_trans_firm_id] AS [Buyer_Transmitting_Firm_ID_Code],
		   sm.[seller_trans_firm_id] AS [Seller_Transmitting_Firm_ID_Code],
		   sm.[trading_date_time] AS [Trading_Date_Time],
		   sm.[trading_capacity] AS [Trading_Capacity],
		   sm.[quantity] AS [Quantity],
		   sm.[quantity_currency] AS [Quantity_Currency],
		   sm.[der_notional_incr_decr] AS [Derivative_Notional_Increase_Decrease],
		   sm.[price] AS [Price],
		   sm.[price_currency] AS [Price_Currency],
		   sm.[net_amount] AS [Net_Amount],
		   sm.[venue] AS [Venue],
		   sm.[branch_membership_country] AS [Country_of_the_Branch_Membership],
		   sm.[upfront_payment] AS [Upfront_Payment],
		   sm.[upfront_payment_currency] AS [Upfront_Payment_Currency],
		   sm.[complex_trade_component_id] AS [Complex_Trade_Component_ID],
		   sm.[instrument_id_code] AS [Instrument_ID_Code],
		   sm.[instrument_name] AS [Instrument_Full_Name],
		   sm.[instrument_classification] AS [Instrument_Classification],
		   sm.[notional_currency_1],
		   sm.[notional_currency_2],
		   sm.[price_multiplier],
		   sm.[underlying_instrument_code],
		   sm.[underlying_index_name],
		   sm.[underlying_index_term] AS [Term_of_the_Underlying_Index],
		   sm.[option_type],
		   sm.[strike_price],
		   sm.[strike_price_currency],
		   sm.[option_exercise_style],
		   CONVERT(VARCHAR(10), sm.[maturity_date], 120) maturity_date,
		   CONVERT(VARCHAR(10), sm.[expiry_date], 120) expiry_date,
		   sm.[delivery_type],
		   sm.[firm_invest_decision] AS [Investment_Decision_within_Firm],
		   sm.[decision_maker_country] AS [Decision_Maker_Country_of_the_Branch],
		   sm.[firm_execution] AS [Execution_within_Firm],
		   sm.[supervising_execution_country] AS [Supervising_Execution_Country_of_the_Branch],
		   sm.[waiver_indicator] AS [Waiver_Indicator],
		   sm.[short_selling_indicator] AS [Short_Selling_Indicator],
		   sm.[otc_post_trade_indicator] AS [OTC_Post_Trade_Indicator],
		   sm.[commodity_derivative_indicator] AS [Commodity_Derivative_Indicator],
		   sm.[securities_financing_transaction_indicator] AS [Securities_Financing_Transaction_Indicator],
		   sm.report_type,
		   sm.create_date_from,
		   sm.create_date_to,
		   sdv.code AS [Submission_Status],
		   sm.submission_date,
		   sm.confirmation_date,
		   sm.process_id,
		   sm.error_validation_message,
		   sm.file_export_name,
		   sm.hash_of_concatenated_values,
		   sm.progressive_number,
		   sm.create_user,
		   sm.create_ts create_ts_from,
		   sm.update_user,
		   sm.update_ts,
		   sc.source_counterparty_id counterparty_id,
		   ''@deal_date_to'' deal_date_to,
		   ''@create_ts_to'' create_ts_to
	FROM source_mifid sm
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = sm.source_deal_header_id
	INNER JOIN source_counterparty sc
		ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN #books ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN static_data_value sdv
		ON sdv.value_id = sm.submission_status
		AND sdv.type_id = 39500
	WHERE sdv.value_id = 39502 '
+
CASE WHEN @_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @_counterparty_id + ')' ELSE '' END
+
CASE WHEN @_action_type IS NOT NULL THEN ' AND sm.report_status = ''' + @_action_type + '''' ELSE '' END
+
CASE 
	WHEN @_create_ts_from IS NOT NULL AND @_create_ts_to IS NULL THEN ' AND CONVERT(VARCHAR(10), sm.create_ts, 120) = ''' + CONVERT(VARCHAR(10), @_create_ts_from, 120) + ''''
	ELSE ''
END + 
CASE 
	WHEN @_create_ts_to IS NOT NULL AND @_create_ts_from IS NULL THEN ' AND CONVERT(VARCHAR(10), sm.create_ts, 120) < ''' + CONVERT(VARCHAR(10), @_create_ts_to, 120) + ''''
	ELSE ''
END + 
CASE 
	WHEN @_create_ts_to IS NOT NULL AND @_create_ts_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), sm.create_ts, 120) BETWEEN ''' + CONVERT(VARCHAR(10), @_create_ts_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @_create_ts_to, 120) + ''''
	ELSE ''
END
 + 
CASE 
	WHEN @_deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @_deal_id + ')'
	ELSE ''
END
+
CASE WHEN @_action_type IS NOT NULL THEN ' AND sm.report_status = ''' + @_action_type + '''' ELSE '' END
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

EXEC (@_sql)


