IF OBJECT_ID(N'tempdb..#books') IS NOT NULL
    DROP TABLE #books

DECLARE @_sql VARCHAR(MAX),
		@_source_counterparty_id VARCHAR(100),
		@_contract_id VARCHAR(100), 
		@_as_of_date VARCHAR(200), 
		@_deal_id VARCHAR(100)

IF '@as_of_date' <> 'NULL'
    SET @_as_of_date = '@as_of_date'

IF '@source_counterparty_id' <> 'NULL'
    SET @_source_counterparty_id = '@source_counterparty_id'

IF '@contract_id' <> 'NULL'
    SET @_contract_id = '@contract_id'

IF '@deal_id' <> 'NULL'
    SET @_deal_id = '@deal_id'


SELECT sub.[entity_id] sub_id,
       stra.[entity_id] stra_id,
       book.[entity_id] book_id,
       sub.[entity_name] sub_name,
       stra.[entity_name] stra_name,
       book.[entity_name] book_name,
       ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4,
       ssbm.logical_name,
       ssbm.fas_deal_type_value_id,
       ssbm.book_deal_type_map_id [sub_book_id],
	   ssbm.sub_book_group1,
	   ssbm.sub_book_group2,
	   ssbm.sub_book_group3,
	   ssbm.sub_book_group4
INTO #books
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK)
	ON book.parent_entity_id = stra.[entity_id]
INNER JOIN portfolio_hierarchy sub(NOLOCK)
	ON stra.parent_entity_id = sub.[entity_id]
INNER JOIN source_system_book_map ssbm
	ON ssbm.fas_book_id = book.[entity_id]
	AND ('@sub_id' = 'NULL' OR sub.[entity_id] IN (@sub_id)) 
	AND ('@stra_id' = 'NULL' OR stra.[entity_id] IN (@stra_id)) 
	AND ('@book_id' = 'NULL' OR book.[entity_id] IN (@book_id))
	AND ('@sub_book_id' = 'NULL' OR ssbm.book_deal_type_map_id IN (@sub_book_id))


IF OBJECT_ID('tempdb..#temp_table') IS NOT NULL
	DROP TABLE #temp_table

CREATE TABLE #temp_table(
	source_counterparty_id INT,
	counterparty_name VARCHAR(200),
	contract_id VARCHAR(200),
	contract_name VARCHAR(200),
	deal_id VARCHAR(200),
	deal_ref_id VARCHAR(200),
	as_of_date VARCHAR(20),
	deal_date VARCHAR(20),
	contract_value INT,
	currency_id VARCHAR(20),
	collateral_requirement VARCHAR(200),
	Collateral_type_id INT,
	Collateral_type VARCHAR(200),
	collateral_posted NUMERIC(38,20),
	total_collateral_recieved NUMERIC(38,20),
	outstanding_collateral NUMERIC(38,20),
	past_due VARCHAR(200),
	int_ext_flag VARCHAR(150),
	Delivery_date VARCHAR(20),
	Validity_Date VARCHAR(20)
)


SET @_sql = '
	INSERT INTO #temp_table(
		source_counterparty_id, counterparty_name, contract_id, contract_name, deal_id, deal_ref_id,
		as_of_date, deal_date, contract_value, currency_id, collateral_requirement, collateral_type_id,
		Collateral_type, collateral_posted, total_collateral_recieved, outstanding_collateral, past_due,
		int_ext_flag, Delivery_date, Validity_Date
	)
	SELECT sc.source_counterparty_id, sc.counterparty_name, cg.contract_id, cg.contract_name, sdh.source_deal_header_id [deal_id],
		   sdh.deal_id [deal_ref_id], '''+ @_as_of_date +''' [as_of_date], CAST(sdh.deal_date AS DATE) [deal_date], sdp.contract_value,
		   scu.currency_id, sdh.collateral_amount [collateral_requirement], cce.enhance_type, sdv.code, cce.amount [collateral_posted],
		   cce1.tcr [total_collateral_recieved], sdh.collateral_amount - cce1.tcr [outstanding_collateral],
		   CASE WHEN ISNULL(sdh.collateral_amount,0) - ISNULL(cce1.tcr,0) > 0 THEN DATEDIFF ( dd , '''+ @_as_of_date +''' , sdh.deal_date) ELSE NULL END [past_due],
		   sc.int_ext_flag, CONVERT(VARCHAR(10), CASE  WHEN (sc.int_ext_flag = ''i'' OR sdt.source_deal_type_name= ''VIOP'') THEN NULL ELSE sdh.entire_term_start - 3 END, 120) [ Delivery_date],
		   CONVERT(VARCHAR(10), CASE  WHEN (sc.int_ext_flag = ''i'' OR sdt.source_deal_type_name = ''VIOP'') THEN NULL ELSE DATEADD(m, 2, DATEADD(month, DATEDIFF(month, 0, sdh.entire_term_end), 9))  END, 120) [Validity_Date]
	FROM source_deal_header sdh
	INNER JOIN source_counterparty sc
		ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN source_deal_type sdt
		ON sdt.source_deal_type_id=sdh.source_deal_type_id
	INNER JOIN contract_group cg
		ON cg.contract_id = sdh.contract_id
	OUTER APPLY(
		SELECT fixed_price_currency_id,
			   SUM(fixed_price*total_volume) amount
		FROM source_deal_detail
		WHERE source_deal_header_id = sdh.source_deal_header_id
		GROUP BY fixed_price_currency_id
	) sdd
	OUTER APPLY(
		SELECT COALESCE(SUM(sdp.contract_value), sdd.amount) [contract_value]
		FROM source_deal_pnl sdp
		WHERE sdp.source_deal_header_id = sdh.source_deal_header_id
			AND CAST(sdp.pnl_as_of_date AS DATE) = ''' + @_as_of_date +'''
		GROUP BY sdp.source_deal_header_id,sdp.pnl_as_of_date
	) sdp
	LEFT JOIN source_currency scu
		ON scu.source_currency_id = sdd.fixed_price_currency_id
	LEFT JOIN counterparty_credit_enhancements cce
		ON cce.deal_id = sdh.source_deal_header_id
	OUTER APPLY(
		SELECT SUM(amount) [tcr] 
		FROM counterparty_credit_enhancements cce1
		INNER JOIN counterparty_credit_info cci
			ON cci.counterparty_credit_info_id = cce1.counterparty_credit_info_id
		WHERE cce1.deal_id = sdh.source_deal_header_id
			AND cci.counterparty_id = sdh.counterparty_id
		GROUP BY cce1.deal_id
	) cce1
	LEFT JOIN static_data_value sdv on
		sdv.value_id=cce.enhance_type
	WHERE 1 = 1 ' +
	CASE WHEN @_deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @_deal_id + ')' ELSE '' END +
	CASE WHEN @_contract_id IS NOT NULL THEN ' AND cg.contract_id IN (' + @_contract_id + ')' ELSE '' END +
	CASE WHEN @_source_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @_source_counterparty_id + ')' ELSE '' END

EXEC(@_sql)

SELECT tt.source_counterparty_id,
	   tt.counterparty_name ,
	   tt.contract_id,
	   tt.contract_name,
	   tt.deal_id,
	   tt.deal_ref_id,
	   tt.as_of_date [as_of_date],
	   tt.deal_date [deal_date],
	   tt.contract_value,
	   tt.currency_id,
	   a.collateral_requirement,
	   tt.collateral_type_id,
	   tt.collateral_type,
	    tt.collateral_posted,
	   tt.total_collateral_recieved,
	   CASE WHEN (a.collateral_requirement-tt.total_collateral_recieved) > 0 THEN (a.collateral_requirement - tt.total_collateral_recieved) 
			ELSE 0 
	   END outstanding_collateral,
	   tt.past_due,
	   books.stra_id stra_id,
	   books.sub_id sub_id,
	   books.sub_book_id,
	   books.book_id book_id,
	   books.sub_name sub,
	   books.stra_name stra,
	   books.book_name book,
	   tt.Delivery_date,
	   tt.Validity_Date
	--[__batch_report__]
FROM #temp_table tt
INNER JOIN source_deal_header sdh 
	ON sdh.source_deal_header_id = tt.deal_id
INNER JOIN source_deal_type sdt 
	ON sdh.source_deal_type_id=sdt.source_deal_type_id
INNER JOIN #books books 
	ON  books.source_system_book_id1 = sdh.source_system_book_id1
		AND books.source_system_book_id2 = sdh.source_system_book_id2
		AND books.source_system_book_id3 = sdh.source_system_book_id3
		AND books.source_system_book_id4 = sdh.source_system_book_id4
CROSS APPLY (
	SELECT sdh.source_deal_header_id,
		   ROUND (
				CASE WHEN tt.int_ext_flag = 'i' OR sdt.source_deal_type_name = 'VIOP' THEN '0' 
					 WHEN sdt.source_deal_type_name = 'CFD' THEN
						CASE WHEN (DATEDIFF(day, sdh.entire_term_start, sdh.entire_term_end) + 1) > 60 THEN 60 * 24 * AVG(sdd.deal_volume) * AVG(sdd.fixed_price) * 1.18 * 0.10
							 ELSE (DATEDIFF(day,  sdh.entire_term_start, sdh.entire_term_end) + 1) * 24 * AVG(sdd.deal_volume) * AVG(sdd.fixed_price) * 1.18 * 0.10
						END	
					WHEN sdt.source_deal_type_name <> 'CFD' THEN 
	  					CASE WHEN (DATEDIFF(day,  sdh.entire_term_start, sdh.entire_term_end) + 1) > 60 THEN 60 * 24 * AVG(sdd.deal_volume) * AVG(sdd.fixed_price) * 1.18
						ELSE (DATEDIFF(day,  sdh.entire_term_start, sdh.entire_term_end) + 1) * 24 * AVG(sdd.deal_volume) * AVG(sdd.fixed_price)  * 1.18
					END	
					ELSE '1' 
				END,
			2) collateral_requirement
	FROM dbo.source_deal_detail sdd
	WHERE sdh.source_deal_header_id = sdd.source_deal_header_id
	GROUP BY sdd.source_deal_header_id
) a