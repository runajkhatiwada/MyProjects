--Change Deal IDS


DECLARE @deal_ids VARCHAR(MAX) = NULL

SELECT @deal_ids = ISNULL(@deal_ids + ',', '') + CAST(sdh.source_deal_header_id AS VARCHAR(10))
FROM source_deal_header sdh 
LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
WHERE sdd.source_deal_header_id IS NULL

IF OBJECT_ID('tempdb..#source_deal_header_temp') IS NOT NULL
	DROP TABLE #source_deal_header_temp
	
CREATE TABLE #source_deal_header_temp (
	source_deal_header_id INT
)

INSERT INTO #source_deal_header_temp
SELECT * FROM dbo.SplitCommaSeperatedValues(@deal_ids)

BEGIN TRY
	BEGIN TRANSACTION
	DELETE assign
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN assignment_audit assign
		ON assign.source_deal_header_id = sdd.source_deal_detail_id
	INNER JOIN #source_deal_header_temp d
		ON sdh.source_deal_header_id = d.source_deal_header_id
    
		
	DELETE unassign
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN unassignment_audit unassign
		ON unassign.source_deal_header_id = sdd.source_deal_detail_id
	INNER JOIN #source_deal_header_temp d
		ON sdh.source_deal_header_id = d.source_deal_header_id
    
		
	DELETE g
	FROM gis_certificate g
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_detail_id = g.source_deal_header_id
	INNER JOIN #source_deal_header_temp d
		ON sdd.source_deal_header_id = d.source_deal_header_id
     
	DELETE g
	FROM deal_exercise_detail g
	INNER JOIN source_deal_detail sdd
		ON sdd.source_deal_detail_id = g.source_deal_detail_id
	INNER JOIN #source_deal_header_temp d
		ON sdd.source_deal_header_id = d.source_deal_header_id
    
	DELETE g
	FROM confirm_status_recent g
	INNER JOIN #source_deal_header_temp d
		ON g.source_deal_header_id = d.source_deal_header_id

	DELETE g
	FROM confirm_status g
	INNER JOIN #source_deal_header_temp d
		ON g.source_deal_header_id = d.source_deal_header_id
		
	DELETE g
	FROM first_day_gain_loss_decision g
	INNER JOIN #source_deal_header_temp d
		ON g.source_deal_header_id = d.source_deal_header_id

	DELETE g
	FROM deal_tagging_audit g
	INNER JOIN #source_deal_header_temp d
		ON g.source_deal_header_id = d.source_deal_header_id

	IF OBJECT_ID('tempdb..#tmp_gen_hedge_group_id') IS NOT NULL
		DROP TABLE #tmp_gen_hedge_group_id	

	SELECT ghg.[gen_hedge_group_id] 
	INTO #tmp_gen_hedge_group_id
	FROM gen_hedge_group ghg
	INNER JOIN gen_fas_link_header gflh
	ON ghg.[gen_hedge_group_id] = gflh.[gen_hedge_group_id]
	INNER JOIN gen_fas_link_detail gfld
	ON gflh.gen_link_id = gfld.gen_link_id
	INNER JOIN #source_deal_header_temp dd
	ON gfld.deal_number = dd.source_deal_header_id

	DELETE d
	FROM gen_transaction_status d
	INNER JOIN #tmp_gen_hedge_group_id f
		ON d.gen_hedge_group_id = f.gen_hedge_group_id
	
	DELETE d
	FROM gen_fas_link_detail_dicing d
	INNER JOIN gen_fas_link_header z
		ON d.link_id = z.gen_link_id
	INNER JOIN #tmp_gen_hedge_group_id f
		ON f.gen_hedge_group_id = z.gen_hedge_group_id

	DELETE d
	FROM gen_fas_link_detail d
	INNER JOIN gen_fas_link_header z
		ON d.gen_link_id = z.gen_link_id
	INNER JOIN #tmp_gen_hedge_group_id f
		ON f.gen_hedge_group_id = z.gen_hedge_group_id

	DELETE d
	FROM gen_fas_link_header d
	INNER JOIN #tmp_gen_hedge_group_id f
		ON d.gen_hedge_group_id = f.gen_hedge_group_id

	DELETE d
	FROM gen_hedge_group_detail d
	INNER JOIN #tmp_gen_hedge_group_id f
		ON d.gen_hedge_group_id = f.gen_hedge_group_id

	DELETE d
	FROM gen_hedge_group d
	INNER JOIN #tmp_gen_hedge_group_id f
		ON d.gen_hedge_group_id = f.gen_hedge_group_id
	DELETE s
	FROM user_defined_deal_fields s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
		
	DELETE s
	FROM user_defined_deal_detail_fields s
	INNER JOIN source_deal_detail sdd
		ON s.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN #source_deal_header_temp d
		ON sdh.source_deal_header_id = d.source_deal_header_id
		
	UPDATE dvie
	SET tran_status = 'd'
	FROM deal_voided_in_external dvie
	INNER JOIN #source_deal_header_temp d
		ON dvie.source_deal_header_id = d.source_deal_header_id
	
	DELETE s
	FROM source_deal_pnl_eff s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
	
	DELETE s
	FROM source_deal_pnl_settlement s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
		
	DELETE s
	FROM source_deal_pnl_arch2 s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id --Nondelete deal backup 
	
	DELETE s
	FROM source_deal_pnl_arch1 s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
		
	DELETE s
	FROM source_deal_pnl s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
	
	DELETE s
	FROM deal_position_break_down s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
	
	DELETE s
	FROM source_deal_detail s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
		
	DELETE s
	FROM source_deal_header s
	INNER JOIN #source_deal_header_temp d
		ON s.source_deal_header_id = d.source_deal_header_id
		
	COMMIT
	EXEC spa_ErrorHandler 0
		, 'Delete_Deals_Links'
		, 'spa_delete_deals_links_mtm'
		, 'Success'
		, 'Successfully deleted.'
		, ''
END TRY
BEGIN CATCH
	ROLLBACK
	DECLARE @error_message VARCHAR(MAX), @line_number INT, @msg VARCHAR(MAX)

	SET @error_message = ERROR_MESSAGE();
	SET @line_number = ERROR_LINE();
	SET @msg = 'Error on Deal deletion :- ' + @error_message

	EXEC spa_ErrorHandler 0
		, 'Delete_Deals_Links'
		, 'spa_delete_deals_links_mtm'
		, 'Error'
		, @msg
		, ''
END CATCH