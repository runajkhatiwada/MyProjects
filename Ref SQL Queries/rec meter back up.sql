BEGIN
	EXEC ('
		INSERT INTO #temp_tot_count
		SELECT COUNT(1) AS totcount, 
			   ''' + @table_name + '''
		FROM ' + @import_temp_table_name
	)
	  	
	EXEC('
		INSERT INTO #import_status (temp_id, process_id, error_code, [module], [source], [type], [description], [next_step], [import_file_name])
		SELECT a.temp_id,
			   ''' + @process_id + ''',
			   ''Error'',
			   ''Import Data'',
			   ''' + @table_name + ''',
			   ''Data Error'',
			   ''Meter ID: '' + a.meter_id + '' not found in the system.'',
			   ''Please CHECK your Data'',
			   a.import_file_name
		FROM ' + @import_temp_table_name + ' a
		LEFT JOIN meter_id mi 
				ON mi.recorderid = a.meter_id
		WHERE mi.meter_id IS NULL
	')

	EXEC ('
		DELETE a 
		FROM ' + @import_temp_table_name + ' a
		LEFT JOIN meter_id mi 
			ON mi.recorderid = a.meter_id
		WHERE mi.meter_id IS NULL
	')

	EXEC ('
		INSERT INTO #tmp_staging_table([meter_id], [channel], [date], [hour], [value], [period], [is_dst]) 
		SELECT [meter_id],
			   ISNULL([channel], 1),
			   CONVERT(DATE, [dbo].[FNAClientToSqlDate]([date]), 120),
			   [hour],
			   [volume],
			   [minute],
			   [is_dst]
		FROM ' + @import_temp_table_name
	)

	IF OBJECT_ID('tempdb..#mv90_data_hour') IS NOT NULL
		DROP TABLE #mv90_data_hour
		
	CREATE TABLE #mv90_data_hour (
 		[meter_id] INT,
 		[channel] INT,
 		[prod_date] DATETIME,
 		[Hr1] FLOAT,
 		[Hr2] FLOAT,
 		[Hr3] FLOAT,
 		[Hr4] FLOAT,
 		[Hr5] FLOAT,
 		[Hr6] FLOAT,
 		[Hr7] FLOAT,
 		[Hr8] FLOAT,
 		[Hr9] FLOAT,
 		[Hr10] FLOAT,
 		[Hr11] FLOAT,
 		[Hr12] FLOAT,
 		[Hr13] FLOAT,
 		[Hr14] FLOAT,
 		[Hr15] FLOAT,
 		[Hr16] FLOAT,
 		[Hr17] FLOAT,
 		[Hr18] FLOAT,
 		[Hr19] FLOAT,
 		[Hr20] FLOAT,
 		[Hr21] FLOAT,
 		[Hr22] FLOAT,
 		[Hr23] FLOAT,
 		[Hr24] FLOAT,
 		[Hr25] FLOAT,
 		[period] INT
	)
	
	INSERT INTO [#mv90_data_hour]
 	SELECT [meter_id], [channel], [prod_date], ([0]) Hr1, ([1]) Hr2, ([2]) Hr3, ([3]) Hr4, ([4]) Hr5, 
		   ([5]) Hr6, ([6]) Hr7, ([7]) Hr8, ([8]) Hr9, ([9]) Hr10, ([10]) Hr11, ([11]) Hr12, ([12]) Hr13,
		   ([13]) Hr14, ([14]) Hr15, ([15]) Hr16, ([16]) Hr17, ([17]) Hr18, ([18]) Hr19, ([19]) Hr20, 
		   ([20]) Hr21, ([21]) Hr22, ([22]) Hr23, ([23]) Hr24, ([24]) Hr25, [period]
 	FROM (  
		SELECT mi.[meter_id],
			   tmp.[channel],
			   tmp.[date] [prod_date],
			   IIF(is_dst = 0, CAST(tmp.[hour] AS TINYINT) - 1, 24) [hour],
			   CASE WHEN (tmp.[date] = md.[date] AND CAST(tmp.[hour] AS INT) = md.[hour]) THEN 0
					ELSE CAST(tmp.[value] AS FLOAT) 
			   END [value],
			   [period]
		FROM #tmp_staging_table tmp
		INNER JOIN [meter_id] mi 
			ON mi.[recorderid] = tmp.[meter_id]
		INNER JOIN recorder_properties rp
			ON rp.meter_id = mi.meter_id
				AND tmp.channel = rp.channel
		LEFT JOIN [mv90_DST] md
			ON md.[year] = YEAR(tmp.[date]) 
			AND md.[insert_delete] = 'd'
			AND md.dst_group_value_id = @dst_group_value_id	
 	) p
	PIVOT(
		SUM([value]) FOR [hour] IN (
			[0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12],
			[13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24]
		)
 	) pvt
	
	SELECT @col = 'Hr' + CAST(md.[hour] AS VARCHAR(10)) + ' = Hr' + CAST(md.[hour] AS VARCHAR(10)) + ' + ISNULL(Hr25, 0)'
 	FROM #mv90_data_hour tmp
 	INNER JOIN mv90_DST md
		ON md.[date] = tmp.prod_date
			AND md.insert_delete = 'i'
 
 	SET @sql = '
 		UPDATE tmp
 		SET ' + @col + '
 		FROM #mv90_data_hour tmp
 		INNER JOIN mv90_DST md
 			ON md.date = tmp.prod_date
 				AND md.insert_delete = ''i''
 	'
 	
 	EXEC(@sql)

	IF OBJECT_ID('tempdb..#mv90_data') IS NOT NULL
		DROP TABLE #mv90_data

	SELECT a.meter_id,
 		   CONVERT(VARCHAR(7), a.[prod_date], 120) + '-01' gen_date,
 		   CONVERT(VARCHAR(7), a.[prod_date], 120) + '-01' from_date,
 		   CONVERT(VARCHAR(10), (DATEADD(MONTH, 1, CONVERT(VARCHAR(7), a.[prod_date], 120) + '-01') - 1), 120) to_date,
 		   a.channel,
 		   SUM(
			   ISNULL(a.[Hr1], 0) + ISNULL(a.[Hr2], 0) + ISNULL(a.[Hr3], 0) + ISNULL(a.[Hr4], 0) + 
			   ISNULL(a.[Hr5], 0) + ISNULL(a.[Hr6], 0) + ISNULL(a.[Hr7], 0) + ISNULL(a.[Hr8], 0) + 
			   ISNULL(a.[Hr9], 0) + ISNULL(a.[Hr10], 0) + ISNULL(a.[Hr11], 0) + ISNULL(a.[Hr12], 0) + 
			   ISNULL(a.[Hr13], 0) + ISNULL(a.[Hr14], 0) + ISNULL(a.[Hr15], 0) + ISNULL(a.[Hr16], 0) + 
			   ISNULL(a.[Hr17], 0) + ISNULL(a.[Hr18], 0) + ISNULL(a.[Hr19], 0) + ISNULL(a.[Hr20], 0) + 
			   ISNULL(a.[Hr21], 0) + ISNULL(a.[Hr22], 0) + ISNULL(a.[Hr23], 0) + ISNULL(a.[Hr24], 0) 
			) volume
    INTO #mv90_data
 	FROM #mv90_data_hour a
 	GROUP BY a.meter_id, a.channel, CONVERT(VARCHAR(7), a.[prod_date], 120) + '-01', DATEADD(MONTH, 1, CONVERT(VARCHAR(7), a.[prod_date], 120) + '-01') - 1
	
	EXEC('
		INSERT INTO [mv90_data] ( meter_id, gen_date, from_date, to_date,channel, volume,uom_id,granularity )
 		SELECT t.meter_id,
			   t.gen_date,
			   t.from_date,
			   t.to_date,
			   t.channel,
			   ABS(t.volume),
			   su.source_uom_id,
			   mi.granularity
 		FROM #mv90_data t 
 		INNER JOIN meter_id mi
			ON mi.meter_id = t.meter_id
		INNER JOIN source_uom su
			ON su.source_uom_id = mi.source_uom_id
 		LEFT JOIN mv90_data mv
			ON mv.meter_id = t.meter_id
				AND mv.from_date = t.from_date
				AND mv.channel = t.[channel]
 		WHERE su.source_system_id = (SELECT TOP 1 source_system_id FROM ' + @import_temp_table_name + ')  
 		AND mv.meter_id IS NULL
	')
	
	EXEC('
		UPDATE mv
		SET gen_date = t.gen_date,
			from_date = t.from_date,
			to_date = t.to_date,
			channel = t.channel,
			volume = ABS(t.volume),
			uom_id = su.source_uom_id,
			granularity = mi.granularity
 		FROM #mv90_data t 
 		INNER JOIN meter_id mi
			ON mi.meter_id = t.meter_id
		INNER JOIN source_uom su
			ON su.source_uom_id = mi.source_uom_id
 		LEFT JOIN mv90_data mv
			ON mv.meter_id = t.meter_id
				AND mv.from_date = t.from_date
				AND mv.channel = t.[channel]
 		WHERE su.source_system_id = (SELECT TOP 1 source_system_id FROM ' + @import_temp_table_name + ')  
 		AND mv.meter_id IS NOT NULL
	')
	
	UPDATE t 
	SET t.Hr1 = ABS(t.Hr1), t.Hr2 = ABS(t.Hr2), t.Hr3 = ABS(t.Hr3), t.Hr4 = ABS(t.Hr4), t.Hr5 = ABS(t.Hr5),
		t.Hr6 = ABS(t.Hr6), t.Hr7 = ABS(t.Hr7), t.Hr8 = ABS(t.Hr8), t.Hr9 = ABS(t.Hr9), t.Hr10 = ABS(t.Hr10),
		t.Hr11 = ABS(t.Hr11), t.Hr12 = ABS(t.Hr12), t.Hr13 = ABS(t.Hr13), t.Hr14 = ABS(t.Hr14), t.Hr15 = ABS(t.Hr15),
		t.Hr16 = ABS(t.Hr16), t.Hr17 = ABS(t.Hr17), t.Hr18 = ABS(t.Hr18), t.Hr19 = ABS(t.Hr19), t.Hr20 = ABS(t.Hr20),
		t.Hr21 = ABS(t.Hr21), t.Hr22 = ABS(t.Hr22), t.Hr23 = ABS(t.Hr23), t.Hr24 = ABS(t.Hr24), t.Hr25 = ABS(t.Hr25)
 	FROM #mv90_data_hour t

	UPDATE mdh
	SET mdh.Hr1 = ISNULL(tmdh.Hr1, mdh.Hr1), mdh.Hr2 = ISNULL(tmdh.Hr2, mdh.Hr2), mdh.Hr3 = ISNULL(tmdh.Hr3, mdh.Hr3), 
 		mdh.Hr4 = ISNULL(tmdh.Hr4, mdh.Hr4), mdh.Hr5 = ISNULL(tmdh.Hr5, mdh.Hr5), mdh.Hr6 = ISNULL(tmdh.Hr6, mdh.Hr6), 
 		mdh.Hr7 = ISNULL(tmdh.Hr7, mdh.Hr7), mdh.Hr8 = ISNULL(tmdh.Hr8, mdh.Hr8), mdh.Hr9 = ISNULL(tmdh.Hr9, mdh.Hr9), 
 		mdh.Hr10 = ISNULL(tmdh.Hr10, mdh.Hr10), mdh.Hr11 = ISNULL(tmdh.Hr11, mdh.Hr11), mdh.Hr12 = ISNULL(tmdh.Hr12, mdh.Hr12), 
 		mdh.Hr13 = ISNULL(tmdh.Hr13, mdh.Hr13), mdh.Hr14 = ISNULL(tmdh.Hr14, mdh.Hr14), mdh.Hr15 = ISNULL(tmdh.Hr15, mdh.Hr15), 
 		mdh.Hr16 = ISNULL(tmdh.Hr16, mdh.Hr16), mdh.Hr17 = ISNULL(tmdh.Hr17, mdh.Hr17), mdh.Hr18 = ISNULL(tmdh.Hr18, mdh.Hr18), 
 		mdh.Hr19 = ISNULL(tmdh.Hr19, mdh.Hr19), mdh.Hr20 = ISNULL(tmdh.Hr20, mdh.Hr20), mdh.Hr21 = ISNULL(tmdh.Hr21, mdh.Hr21), 
 		mdh.Hr22 = ISNULL(tmdh.Hr22, mdh.Hr22), mdh.Hr23 = ISNULL(tmdh.Hr23, mdh.Hr23), mdh.Hr24 = ISNULL(tmdh.Hr24, mdh.Hr24), 
 		mdh.Hr25 = ISNULL(tmdh.Hr25, mdh.Hr25) 
 	FROM #mv90_data_hour tmdh
 	INNER JOIN [mv90_data] md
		ON md.[meter_id] = tmdh.[meter_id]
			AND md.[from_date] = CONVERT(VARCHAR(7), tmdh.[prod_date], 120) + '-01'
	INNER JOIN mv90_data_hour mdh
		ON md.meter_data_id = mdh.meter_data_id
 			AND tmdh.prod_date = mdh.prod_date
	
	INSERT INTO [mv90_data_hour] (
		[meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8],
		[Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19],
		[Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [Hr25], [uom_id], [period]
	)
 	SELECT md.[meter_data_id], tmdh.[prod_date], tmdh.[Hr1], tmdh.[Hr2], tmdh.[Hr3], tmdh.[Hr4], 
		   tmdh.[Hr5], tmdh.[Hr6], tmdh.[Hr7], tmdh.[Hr8], tmdh.[Hr9], tmdh.[Hr10], tmdh.[Hr11], 
		   tmdh.[Hr12], tmdh.[Hr13], tmdh.[Hr14], tmdh.[Hr15], tmdh.[Hr16], tmdh.[Hr17], tmdh.[Hr18],
		   tmdh.[Hr19], tmdh.[Hr20], tmdh.[Hr21], tmdh.[Hr22], tmdh.[Hr23], tmdh.[Hr24], tmdh.[Hr25],
		   md.[uom_id], tmdh.[period]
 	FROM #mv90_data_hour tmdh
 	INNER JOIN [mv90_data] md
 		ON md.[meter_id] = tmdh.[meter_id]
 		AND md.[from_date] = CONVERT(VARCHAR(7), tmdh.[prod_date], 120) + '-01'
 		AND tmdh.channel = md.channel
 	LEFT JOIN [mv90_data_hour] mdh
		ON mdh.meter_data_id = md.meter_data_id
			AND tmdh.prod_date = mdh.prod_date
 	WHERE mdh.meter_data_id IS NULL

	DECLARE @meter_check BIT = 0, @flag BIT = 0, @template_ids VARCHAR(MAX)
	
	SELECT @flag = 1 
	FROM source_deal_detail sdd
	INNER JOIN #mv90_data md 
		ON md.meter_id = sdd.meter_id
			AND sdd.term_start = md.from_date
			AND sdd.term_end = md.to_date
			
	UPDATE sdd
	SET sdd.schedule_volume = md.volume * IIF(@flag = 0, rgm.allocation_per, 1.0),
		@meter_check = 1,
		sdd.[status] = IIF(sdd.[status] <> 25004, 25003, sdd.[status])
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN meter_id mi
		ON mi.meter_id = sdd.meter_id
	LEFT JOIN rec_generator rg
		ON rg.generator_id = sdh.generator_id
	LEFT JOIN recorder_generator_map rgm
		ON rgm.generator_id = rg.generator_id
	INNER JOIN #mv90_data md
		ON sdd.term_start = md.from_date
			AND sdd.term_end = md.to_date
	WHERE md.meter_id = IIF(@flag = 1, sdd.meter_id, rgm.meter_id)
	
	UPDATE sdd
	SET sdd.deal_volume = COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.contractual_volume)
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN meter_id mi
		ON mi.meter_id = sdd.meter_id
	LEFT JOIN rec_generator rg
		ON rg.generator_id = sdh.generator_id
	LEFT JOIN recorder_generator_map rgm
		ON rgm.generator_id = rg.generator_id
	INNER JOIN mv90_data md
		ON sdd.term_start = md.from_date
			AND sdd.term_end = md.to_date
	WHERE md.meter_id = IIF(@flag = 1, sdd.meter_id, rgm.meter_id)

	SELECT @template_ids = ISNULL(@template_ids + ',', '') + CAST(deal_template_id AS VARCHAR(10))
	FROM (
		SELECT DISTINCT deal_template_id
		FROM rec_generator rg
		INNER JOIN recorder_generator_map rgm
			ON rgm.generator_id = rg.generator_id
		INNER JOIN mv90_data md
			ON md.meter_id = rgm.meter_id
		WHERE rg.deal_template_id IS NOT NULL
	) a
	
	IF @meter_check = 0 AND EXISTS (SELECT 1 FROM #tmp_staging_table)
	BEGIN
		EXEC [dbo].[spa_create_inventory_assignment_deals] @temp_table_name = @import_temp_table_name, @template_id = @template_ids
		RETURN
	END
END