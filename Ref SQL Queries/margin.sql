DECLARE @_sql_string VARCHAR(MAX), 
                              @_margin_call_date_from VARCHAR(10),
                              @_margin_call_date_to VARCHAR(10), 
                              @_counterparty_id VARCHAR(MAX)

--IF '@margin_call_date_from' <> 'NULL'
--    SET @_margin_call_date_from = '@margin_call_date_from'

--IF '@margin_call_date_to' <> 'NULL'
--    SET @_margin_call_date_to = '@margin_call_date_to'

--IF '@source_counterparty_id' <> 'NULL'
--    SET @_counterparty_id = '@source_counterparty_id'

IF '2017-11-21' <> 'NULL'
    SET @_margin_call_date_from = '2017-11-21'

--IF '@margin_call_date_to' <> 'NULL'
--    SET @_margin_call_date_to = '@margin_call_date_to'

--IF '5705' <> 'NULL'
--    SET @_counterparty_id = '5705'

IF OBJECT_ID ('tempdb..#check_multiple_cpty') IS NOT NULL
	DROP TABLE #check_multiple_cpty

CREATE TABLE #check_multiple_cpty (
	source_counterparty_id INT,
	num_cpty INT
)

SET @_sql_string  = '	
INSERT INTO #check_multiple_cpty
SELECT sc.source_counterparty_id, COUNT(mpi.counterparty_id) num_cpty
FROM margin_payment_info mpi
INNER JOIN source_counterparty sc
	ON sc.counterparty_id = mpi.counterparty_id
WHERE 1 = 1' +
CASE WHEN @_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @_counterparty_id + ')' ELSE '' END 
+ ' 
GROUP BY source_counterparty_id
'

EXEC (@_sql_string)


SET @_sql_string  = '
--[__batch_report__]
SELECT 
    ISNULL(MAX(mcd.ice_payment), 0) ice_payment,
    SUM(ipi.payment_amount) Initial_Payment,
    mcc.counterparty_id source_counterparty_id,
    MAX(sc.counterparty_name) counterparty_name,
    MAX(sc.counterparty_id) counterparty_id,
    mpi.payment_date,
    CASE WHEN m.num_cpty > 1 THEN SUM(DISTINCT mpi.payment_amount) ELSE MAX(mpi.payment_amount) END payment_amount,
    MAX(ISNULL (NULLIF(mpi.payment_status, ''''), ''n'')) payment_status,
    mcc.margin_call_date margin_call_date_from,
    MAX(mcc.net_threshold) net_threshold,
    MAX(mcc.net_position) net_position,
    MAX(mcc.margin_call_amount) margin_call_amount,
    MAX(mcc.currency) currency,
    CASE WHEN MAX(mcc.margin_call) = ''y'' THEN ''Yes'' 
                                ELSE ''No'' 
    END margin_call,
    ' +                          
    CASE WHEN @_margin_call_date_to IS NOT NULL THEN '''' + @_margin_call_date_to + '''' ELSE 'NULL' END + ' [margin_call_date_to]
FROM margin_calculation_counterparty mcc 
INNER JOIN source_counterparty sc 
    ON mcc.counterparty_id = sc.source_counterparty_id
LEFT JOIN margin_calculation_deal mcd 
	ON mcd.counterparty = sc.source_counterparty_id
		AND mcd.run_date = mcc.margin_call_date
LEFT JOIN initial_payment_info ipi
	ON ipi.counterparty_id = sc.counterparty_id
LEFT JOIN margin_payment_info mpi
    ON sc.counterparty_id = mpi.counterparty_id
LEFT JOIN #check_multiple_cpty m
	ON m.source_counterparty_id = sc.source_counterparty_id
WHERE 1 = 1
' + 
CASE 
	WHEN @_counterparty_id IS NOT NULL THEN ' AND sc.source_counterparty_id IN (' + @_counterparty_id + ')'
	ELSE ''
END + 
CASE 
	WHEN @_margin_call_date_from IS NOT NULL AND @_margin_call_date_to IS NULL THEN ' AND CONVERT(VARCHAR(10), mcc.margin_call_date, 120) = ''' + @_margin_call_date_from + ''''
	ELSE ''
END + 
CASE 
    WHEN @_margin_call_date_to IS NOT NULL AND @_margin_call_date_from IS NULL THEN ' AND CONVERT(VARCHAR(10), mcc.margin_call_date, 120) < ''' + @_margin_call_date_to + ''''
    ELSE ''
END + 
CASE 
    WHEN @_margin_call_date_to IS NOT NULL AND @_margin_call_date_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), mcc.margin_call_date, 120) BETWEEN ''' + @_margin_call_date_from + ''' AND ''' + @_margin_call_date_to + ''''
    ELSE ''
END

SET @_sql_string = @_sql_string + ' GROUP BY mpi.payment_date, mcc.counterparty_id, mcc.margin_call_date, m.num_cpty'

EXEC(@_sql_string)

