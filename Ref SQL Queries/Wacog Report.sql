DECLARE @_process_id VARCHAR(100) = dbo.FNAGetNewID(), 
		@_process_table VARCHAR(100),
		@_wacog_group_id VARCHAR(MAX) = '@wacog_group_id',
		@_source_deal_header_id VARCHAR(MAX),
		@_counterparty_id VARCHAR(MAX),
		@_contract_id VARCHAR(MAX),
		@_template_id VARCHAR(10),
		@_deal_type_id VARCHAR(10),
		@_trader_id VARCHAR(10),
		@_charge_type_id VARCHAR(MAX),
		@_as_of_date DATETIME,
		@_term_start DATETIME,
		@_term_end DATETIME,
		@_sql VARCHAR(MAX)

SET @_process_table = dbo.FNAProcessTableName('wacog_report', dbo.FNADBUser(), @_process_id)

IF '@source_deal_header_id' <> 'NULL'
	SET @_source_deal_header_id = '@source_deal_header_id'

IF '@counterparty_id' <> 'NULL'
	SET @_counterparty_id = '@counterparty_id'

IF '@contract_id' <> 'NULL'
	SET @_contract_id = '@contract_id'

IF '@trader_id' <> 'NULL'
	SET @_trader_id = '@trader_id'

IF '@template_id' <> 'NULL'
	SET @_template_id = '@template_id'
	
IF '@deal_type_id' <> 'NULL'
	SET @_deal_type_id = '@deal_type_id'

IF '@charge_type_id' <> 'NULL'
	SET @_charge_type_id = '@charge_type_id'

IF '@as_of_date' <> 'NULL'
	SET @_as_of_date = '@as_of_date'

IF '@term_start' <> 'NULL'
	SET @_term_start = '@term_start'

IF '@term_end' <> 'NULL'
	SET @_term_end = '@term_end'

EXEC dbo.spa_wacog_group 'r', @_wacog_group_id, @_as_of_date, @_term_start, @_term_end, 0, @_process_id

SET @_sql = '
	SELECT sdh.source_deal_header_id, 
		   sdh.deal_id ref_id,
		   cwg.term,
		   sc.counterparty_name counterparty,
		   cg.contract_name contract,
		   charge_type.code charge_type,
		   sdht.template_name template,
		   sdt.source_deal_type_name deal_type,
		   wg.wacog_group_name wacog_group,
		   wg.wacog_group_id,
		   sdh.counterparty_id,
		   sdh.contract_id,
		   sdh.template_id,
		   sdh.source_deal_type_id deal_type_id,
		   ifbs.field_id charge_type_id,
		   st.trader_name trader,
		   sdh.trader_id,
		   ''' + ISNULL(CONVERT(VARCHAR(10), @_term_start, 120), '') + ''' term_start,
		   ''' + ISNULL(CONVERT(VARCHAR(10), @_term_end, 120), '') + ''' term_end,
		   ''' + ISNULL(CONVERT(VARCHAR(10), @_as_of_date, 120), '') + ''' as_of_date
	--[__batch_report__] 
	FROM ' + @_process_table + ' a
	INNER JOIN calculate_wacog_group cwg ON cwg.as_of_date = a.as_of_date
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = a.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN contract_group cg ON cg.contract_id = sdh.contract_id
	INNER JOIN source_traders st ON st.source_trader_id = sdh.trader_id
	INNER JOIN source_deal_settlement sds ON sdh.source_deal_header_id = sds.source_deal_header_id
	INNER JOIN index_fees_breakdown_settlement ifbs ON ifbs.source_deal_header_id = sds.source_deal_header_id
	INNER JOIN static_data_value charge_type ON charge_type.value_id = ifbs.field_id AND type_id = 5500
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	INNER JOIN wacog_group wg ON wg.wacog_group_id = cwg.wacog_group_id
	WHERE 1 = 1
'
+ IIF(@_source_deal_header_id IS NOT NULL, ' AND sdh.source_deal_header_id IN (' + @_source_deal_header_id + ')', '')
+ IIF(@_counterparty_id IS NOT NULL, ' AND sdh.counterparty_id IN (' + @_counterparty_id + ')', '')
+ IIF(@_contract_id IS NOT NULL, ' AND sdh.contract_id IN (' + @_contract_id + ')', '')
+ IIF(@_template_id IS NOT NULL, ' AND sdh.template_id = ' + @_template_id, '')
+ IIF(@_deal_type_id IS NOT NULL, ' AND sdh.source_deal_type_id = ' + @_deal_type_id, '')
+ IIF(@_trader_id IS NOT NULL, ' AND sdh.trader_id = ' + @_trader_id, '')

EXEC(@_sql)