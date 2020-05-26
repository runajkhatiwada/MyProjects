--ALTER TABLE [adiha_process].[dbo].[shaped_volume_hourly_dst] ADD import_file_name VARCHAR(100)


IF OBJECT_ID(N'tempdb..#temp_table') IS NOT NULL    
DROP TABLE #temp_table 

SELECT *
INTO #temp_table 
FROM [temp_process_table]

DELETE FROM [temp_process_table]

INSERT INTO [temp_process_table]([Deal Ref ID], [Term Date], [Hour], [IS DST], [Volume], [Actual Volume], [Schedule Volume], [Price], [Leg], [import_file_name])
SELECT t.[Deal Ref ID], 
	   t.[Term Date],
	   CASE WHEN COALESCE(sdh.profile_granularity, sdht.profile_granularity, IIF(sdd.deal_volume_frequency = 'h', 982, NULL)) = 982 THEN
			   IIF(LEN(t.[hour] - 1) = 2, CAST(t.[hour] - 1 AS VARCHAR(10)), '0' + CAST(t.[hour] - 1 AS VARCHAR(10))) + ':00'			    
			WHEN COALESCE(sdh.profile_granularity, sdht.profile_granularity, IIF(sdd.deal_volume_frequency = 'd', 981, NULL)) = 981 THEN
				'01:00'
			ELSE 
				IIF(LEN(CAST(IIF(t.[minute] = 0, t.[hour] - 1, t.[hour]) AS VARCHAR(10))) = 2, 
						CAST(IIF(t.[minute] = 0, t.[hour] - 1, t.[hour]) AS VARCHAR(10)), 
						'0' + CAST(IIF(t.[minute] = 0, t.[hour] - 1, t.[hour]) AS VARCHAR(10))
					) + ':' + 
				IIF(LEN(CAST(REPLACE((t.[minute] - 15), -15, 45)AS VARCHAR(10))) = 2, 
						CAST(REPLACE((t.[minute] - 15), -15, 45)AS VARCHAR(10)), 
						'0' + CAST(REPLACE((t.[minute] - 15), -15, 45)AS VARCHAR(10))
					)
	   END [Hour],  
	   t.[IS DST], 
	   t.[Volume], 
	   t.[Actual Volume], 
	   t.[Schedule Volume],
	   t.[Price], 
	   t.[Leg], 
	   t.[import_file_name]
FROM #temp_table t
LEFT JOIN source_deal_header sdh
	ON sdh.deal_id = t.[Deal Ref ID]
LEFT JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = sdh.source_deal_header_id
		AND t.[term date] BETWEEN sdd.term_start AND sdd.term_end
		AND sdd.leg = t.leg
LEFT JOIN source_deal_header_template sdht
	ON sdht.source_deal_header_id = sdh.source_deal_header_id
	

