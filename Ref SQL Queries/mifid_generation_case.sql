IF OBJECT_ID('tempdb..#temp_deals') IS NOT NULL
	DROP TABLE #temp_deals

SELECT * 
INTO #temp_deals 
FROM source_deal_header
WHERE source_deal_header_id = 3330

IF OBJECT_ID('tempdb..#mifid_log_status') IS NOT NULL
	DROP TABLE #mifid_log_status

SELECT a.deal_id, 
	   a.response_status, 
	   a.create_ts,
	   RANK() OVER(PARTITION BY a.deal_id ORDER BY a.create_ts DESC) [rank]
INTO #mifid_log_status
FROM source_mifid_audit_log a
INNER JOIN #temp_deals sdh
	ON sdh.deal_id = a.deal_id
ORDER BY a.deal_id
		
IF OBJECT_ID('tempdb..#source_mifid') IS NOT NULL
	DROP TABLE #source_mifid

SELECT sm.deal_id, 
	   sm.report_status,
	   sm.create_ts,
	   RANK() OVER(PARTITION BY sm.deal_id ORDER BY sm.create_ts DESC) [rank]
INTO #source_mifid
FROM source_mifid sm
INNER JOIN #temp_deals sdh
	ON sdh.source_deal_header_id = sm.source_deal_header_id
ORDER BY deal_id


SELECT a.deal_id, sdv.code, sm.report_status, response_status
FROM #temp_deals a
INNER JOIN #mifid_log_status b
	ON a.deal_id = b.deal_id
INNER JOIN static_data_value sdv
	ON sdv.value_id = a.deal_status
		AND sdv.[type_id] = 5600
LEFT JOIN #source_mifid sm
	ON a.deal_id = b.deal_id
WHERE b.[rank] = 1
	AND sm.[rank] = 1
	AND (
		(sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'ACPT')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'ACPD')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'PDNG')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'WARN')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'NEWT' AND response_status = 'RCVD')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'PDNG')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'RJCT')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'RJPD')	
		OR (sdv.code IN ('New', 'Amended') AND sm.report_status = 'CANC' AND response_status = 'RCVD')
		OR (sdv.code = 'Cancelled' AND sm.report_status IS NULL AND response_status IS NULL)	
		OR (sdv.code = 'Cancelled' AND sm.report_status = 'NEWT' AND response_status = 'RJCT')	
		OR (sdv.code = 'Cancelled' AND sm.report_status = 'NEWT' AND response_status = 'RJPD')	
		OR (sdv.code = 'Cancelled' AND sm.report_status = 'CANC' AND response_status = 'ACPT')	
		OR (sdv.code = 'Cancelled' AND sm.report_status = 'CANC' AND response_status = 'ACPD')	
		OR (sdv.code = 'Cancelled' AND sm.report_status = 'CANC' AND response_status = 'PDNG')	
		OR (sdv.code = 'Cancelled' AND sm.report_status = 'CANC' AND response_status = 'WARN')	
		OR (sdv.code = 'Cancelled' AND sm.report_status = 'CANC' AND response_status = 'RCVD')	
	)
	
	
	
	
	
	
	
