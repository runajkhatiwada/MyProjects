DECLARE @apx_monthly_amount NUMERIC(38, 20),
        @sum_hedge_volume NUMERIC(38, 20),
        @monthly_hedge_price INT,
        @allocation_volume NUMERIC(38, 20),
        @fees INT,
		@generic_mapping_id INT

SELECT @generic_mapping_id = mapping_table_id
FROM generic_mapping_header
WHERE mapping_name = 'Contract Meters'

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
	DROP TABLE #temp

IF OBJECT_ID('tempdb..#temp_hedge_vol') IS NOT NULL
	DROP TABLE #temp_hedge_vol

IF OBJECT_ID('tempdb..#temp_allocation') IS NOT NULL
	DROP TABLE #temp_allocation

IF OBJECT_ID('tempdb..#temp_apx') IS NOT NULL
	DROP TABLE #temp_apx

IF OBJECT_ID('tempdb..#temp_final') IS NOT NULL
	DROP TABLE #temp_final
  
IF OBJECT_ID('tempdb..#temp_hedge_vol1') IS NOT NULL
	DROP TABLE #temp_hedge_vol1
  
IF OBJECT_ID('tempdb..#temp_allocation1') IS NOT NULL
	DROP TABLE #temp_allocation1
  
IF OBJECT_ID('tempdb..#temp_hedge_vol2') IS NOT NULL
	DROP TABLE #temp_hedge_vol2

IF OBJECT_ID('tempdb..#mv90_data_hour') IS NOT NULL
	DROP TABLE #mv90_data_hour
  
SELECT sdd.term_start,
       sdd.term_end,
       CASE 
		   WHEN sdt.source_deal_type_id IS NULL THEN 0
		   ELSE sdd.fixed_price
	   END fixed_price,
       CASE 
           WHEN DATEDIFF(DAY, sdd.term_start, sdd.term_end) = 0 THEN 1
           ELSE (DATEDIFF(DAY, sdd.term_start, sdd.term_end) + 1)
       END day_diff,
       CASE 
		   WHEN sdt.source_deal_type_id IS NULL THEN 0
		   ELSE deal_volume
	   END deal_volume
INTO #temp
FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd 
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_deal_type sdt 
		ON sdt.source_deal_type_id = sdh.deal_sub_type_type_id 
			AND sdt.sub_type = 'y'
			AND sdt.source_deal_type_name = 'Physical'
WHERE sdh.counterparty_id = '@counterparty_id'
	AND YEAR(sdd.term_start) = YEAR('@prod_date')
	AND MONTH(sdd.term_start) = MONTH('@prod_date')

SELECT
	CONVERT(DATE, DATEADD(HOUR, n - 1, term_start)) prod_date,
	DATEPART(HOUR, DATEADD(HOUR, n - 1, term_start)) + 1 [hour],
	deal_volume, 
	day_diff
INTO #temp_hedge_vol1
FROM #temp
	CROSS JOIN seq s
WHERE DATEADD(HOUR, n - 1, term_start) < DATEADD(DAY, 1, term_end)

SELECT *
INTO #temp_hedge_vol2
FROM #temp_hedge_vol1
EXCEPT
SELECT prod_date, 
	   t.[hour], 
	   deal_volume, 
	   day_diff
FROM #temp_hedge_vol1 t 
	INNER JOIN mv90_dst mv
		ON t.prod_date = mv.[date]
			AND t.[hour] = (mv.[hour] - 1)
			AND insert_delete = 'd'
UNION ALL
SELECT prod_date, 
	   t.[hour], 
	   deal_volume, 
	   day_diff
FROM #temp_hedge_vol1 t 
	INNER JOIN mv90_dst mv
		ON t.prod_date = mv.[date]
			AND t.[hour] = (mv.[hour] - 1)
			AND insert_delete = 'i'		
ORDER BY prod_date, [hour]

SELECT prod_date, 
	   [hour], 
	   CASE 
			WHEN MONTH(prod_date) = 10 THEN SUM((deal_volume / ((day_diff * 24) + 1))) 
			WHEN MONTH(prod_date) = 3 THEN SUM((deal_volume / ((day_diff * 24) - 1))) 
			ELSE SUM((deal_volume / (day_diff * 24))) 
		END	[Hedge Volume]
INTO #temp_hedge_vol
FROM #temp_hedge_vol2
GROUP BY prod_date, [hour]
ORDER BY prod_date, [hour]


SELECT prod_date, Hr1, (Hr2 - ISNULL(Hr25, 0)) Hr2, Hr3, Hr4, Hr5, 
	   Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, 
	   Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25 
INTO #mv90_data_hour
FROM mv90_data_hour mdh
INNER JOIN mv90_data md 
	ON md.meter_data_id = mdh.meter_data_id
INNER JOIN generic_mapping_values gmv 
	ON gmv.clm4_value = md.meter_id 
		AND mapping_table_id = @generic_mapping_id 
		AND clm1_value = '@counterparty_id' 
		AND gmv.clm3_value = 'MSP'
LEFT JOIN mv90_DST mdst 
	ON mdst.date = mdh.prod_date
		AND mdst.insert_delete = 'i'

SELECT
	CONVERT(date, prod_date) prod_date,
	REPLACE(hrs, 'Hr', '') [hour],
	ISNULL(ABS(p.volume), 0) Allocation 
INTO #temp_allocation
FROM #mv90_data_hour mdh
UNPIVOT (Volume FOR [hrs] IN (
		Hr1, Hr2, Hr3, Hr4, Hr5, 
		Hr6, Hr7, Hr8, Hr9, Hr10, 
		Hr11, Hr12, Hr13, Hr14, Hr15, 
		Hr16, Hr17, Hr18, Hr19, Hr20, 
		Hr21, Hr22, Hr23, Hr24)
	) p
	  
	  
	  
SELECT 
	CONVERT(DATE, spc.maturity_date) prod_date,
	(DATEPART(HOUR, spc.maturity_date) + 1) [Hour],
	spc.curve_value APX 
INTO #temp_apx
FROM source_price_curve spc
INNER JOIN source_price_curve_def spcd
	ON spc.source_curve_def_id = spcd.source_curve_def_id
WHERE spcd.curve_name = 'APXUKSPOT'
	AND YEAR(spc.maturity_date) = YEAR('@prod_date')
	AND MONTH(spc.maturity_date) = MONTH('@prod_date')

SELECT
	thv.prod_date,
	thv.[hour],
	[Hedge Volume],
	[Allocation],
	([Hedge Volume] - [Allocation]) Delta,
	[APX],
	(([Hedge Volume] - [Allocation]) * [APX]) [Amount Of APX] 
INTO #temp_final
FROM #temp_hedge_vol thv
	INNER JOIN #temp_allocation ta
		ON thv.prod_date = ta.prod_date
			AND thv.[hour] = ta.[hour]
	INNER JOIN #temp_apx tap
		ON tap.prod_date = thv.prod_date
			AND tap.[hour] = thv.[hour]
ORDER BY thv.prod_date, thv.[hour]

SELECT
	@apx_monthly_amount = SUM([Amount Of APX]),
	@sum_hedge_volume = SUM([Hedge Volume]),
	@allocation_volume = SUM([Allocation])
FROM #temp_final

SELECT
	@monthly_hedge_price = (a.fixed_price - spc.curve_value),
	@fees = spc.curve_value
FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd
		ON spc.source_curve_def_id = spcd.source_curve_def_id
	CROSS JOIN (SELECT
					SUM(fixed_price * deal_volume) / SUM(deal_volume) fixed_price
				FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
				WHERE sdh.counterparty_id = '@counterparty_id'
	) a
WHERE spcd.curve_name = 'UK Contract- Mars Mgmt Fee'
	AND YEAR(maturity_date) = YEAR('@prod_date')
	AND MONTH(maturity_date) = MONTH('@prod_date')

SELECT
	'@prod_date' [prod_date],
	0 [hr],
	0 [mins],
	ABS(ISNULL((@apx_monthly_amount + (@sum_hedge_volume * ISNULL(@monthly_hedge_price,1))) / (@allocation_volume), 0))[Price]
--[__final_output__]