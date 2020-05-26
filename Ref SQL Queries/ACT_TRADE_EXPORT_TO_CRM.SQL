SET NOCOUNT ON

DECLARE @msg NVARCHAR(MAX), 
		@process_table NVARCHAR(100),
		@process_id VARCHAR(350)


SET @process_id = REPLACE(NEWID(), '-', '_')
SET @process_table = 'adiha_process.dbo.export_to_crm_trade_' + @process_id

IF OBJECT_ID('tempdb..#udf_values') IS NOT NULL
	DROP TABLE #udf_values

SELECT source_deal_header_id, [Initial Margin], [Threshold]
INTO #udf_values
FROM (
	SELECT sdh.source_deal_header_id, udft.field_label, uddf.udf_value
	FROM source_deal_header sdh
	INNER JOIN user_defined_deal_fields uddf
	  ON uddf.source_deal_header_id = sdh.source_deal_header_id
	   AND NULLIF(uddf.udf_value, '') IS NOT NULL
	INNER JOIN user_defined_deal_fields_template uddft
	  ON uddft.udf_template_id = uddf.udf_template_id
	INNER JOIN user_defined_fields_template udft
	  ON udft.field_id = uddft.field_id
) AS a
PIVOT (MAX(a.udf_value) FOR a.Field_label IN ([Initial Margin], [Threshold])) AS p

EXEC('
	SELECT IIF(sc.counterparty_name = ''Market Maker'', RIGHT(ssbm.logical_name, LEN(ssbm.logical_name) - 3), ssbm.logical_name) book_id1,
		   sdd.buy_sell_flag buy_sell_flag,
		   sc.counterparty_id counterparty,
		   NULLIF(st.trader_name, '''') counterparty_trader,
		   CONVERT(NVARCHAR(10), sdh.deal_date, 120) deal_date,
		   sdt.source_deal_type_name deal_type,
		   dbo.FNARemoveTrailingZero(sdd.total_volume) deal_volume,
		   CONVERT(NVARCHAR(10), sdd.contract_expiration_date, 120) expiration_date,
		   sdh.header_buy_sell_flag hdr_buysell_flag,
		   NULLIF(uv.[Initial Margin], '''') Initial_margin,
		   NULLIF(sdh.option_excercise_type, '''') option_excercise_type,
		   sdd.option_strike_price option_strike_price,
		   NULLIF(sdh.option_type, '''') option_type,
		   dbo.FNARemoveTrailingZero(sdd.fixed_price) price,
		   scu.currency_name price_currency,
		   scom.commodity_name Product_id,
		   spcd.curve_name source_curve_id,
		   sdh.deal_id source_deal_id,
		   CONVERT(NVARCHAR(10), sdh.entire_term_end, 120) term_end,
		   CONVERT(NVARCHAR(10), sdh.entire_term_start, 120) term_start,
		   uv.Threshold,
		   st1.trader_id trader,
		   su.uom_name volume_uom,
		   CAST(sdd.deal_detail_description AS FLOAT) Rate,
		   sdh.source_deal_header_id trade_identifier,
		   sub.entity_name [legalEntity]   
	INTO ' + @process_table + '
	FROM source_deal_header sdh
	INNER JOIN source_system_book_map ssbm
		ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN portfolio_hierarchy book
		ON book.entity_id = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy stra
		ON book.parent_entity_id = stra.entity_id
	INNER JOIN portfolio_hierarchy sub
		ON stra.parent_entity_id = sub.entity_id
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc
		ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN source_traders st
		ON st.source_trader_id = sdh.trader_id2
	LEFT JOIN source_deal_type sdt
		ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN source_currency scu
		ON scu.source_currency_id = sdd.fixed_price_currency_id
	LEFT JOIN source_commodity scom
		ON scom.source_commodity_id = sdh.commodity_id
	LEFT JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = sdd.curve_id
	LEFT JOIN source_traders st1
		ON st1.source_trader_id = sdh.trader_id
	LEFT JOIN source_uom su
		ON su.source_uom_id = sdd.deal_volume_uom_id
	LEFT JOIN #udf_values uv
		ON uv.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN adiha_process.dbo.alert_position_process_id_ad pt
		ON pt.source_deal_header_id = sdh.source_deal_header_id
')

EXEC('
	DELETE a
	FROM source_deal_header sdh
	INNER JOIN ' + @process_table + ' a
		ON sdh.source_deal_header_id = a.trade_identifier
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_price_curve_def spcd
		ON spcd.source_curve_def_id = sdd.curve_id
	INNER JOIN source_counterparty sc
		ON sc.source_counterparty_id = sdh.counterparty_id
	WHERE (sc.counterparty_name IN (''Prop Desk'', ''Market Maker'',''RTFC Accumulation'',''White Accumulation'',''Italian White Accumulation'',''Polish Accumulation'') AND sdh.deal_id NOT LIKE ''%_Copy%'')
	OR (sc.counterparty_id NOT IN (''ICE'', ''CME'',''EEX'') AND sc.counterparty_name NOT IN (''Market Maker'',''Prop Desk'',''RTFC Accumulation'',''White Accumulation'',''Italian White Accumulation'',''Polish Accumulation''))
	OR (spcd.curve_name LIKE ''% TAS'' AND (CONVERT(VARCHAR(10), sdh.create_ts, 120) = CONVERT(VARCHAR(10), sdh.update_ts, 120) OR sdh.update_ts IS NULL))
')

INSERT INTO [dbo].[act_trade_service_call_staging] (process_table, process, status)
SELECT @process_table, 'process_id', 0
Go