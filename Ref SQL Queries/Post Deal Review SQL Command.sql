IF EXISTS (
	SELECT 1
	FROM source_deal_header sdh
	INNER JOIN staging_table.alert_deal_process_id_ad t
		ON t.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN static_data_value sdv
		ON sdv.value_id = sdh.deal_status
			AND sdv.type_id = 5600
	WHERE sdv.code = 'Reviewed'
)
BEGIN

	DECLARE @deal_ids VARCHAR(MAX), 
			@proc_id VARCHAR(100), 
			@exec_query VARCHAR(1000), 
			@temp_path VARCHAR(500),
			@import_ftp_url VARCHAR(1000),
			@import_ftp_username VARCHAR(100),
			@import_ftp_password VARCHAR(100)

	SELECT @import_ftp_url = import_ftp_url,
		   @import_ftp_username = import_ftp_username,
		   @import_ftp_password = import_ftp_password
	FROM connection_string
	
	SELECT @deal_ids = ISNULL(@deal_ids + ',', '') + CAST(source_deal_header_id AS VARCHAR(10))
	FROM staging_table.alert_deal_process_id_ad
	
	DECLARE @user VARCHAR(100) = dbo.FNADBUser()
	DECLARE @sub_book_ids VARCHAR(MAX)

	SELECT @sub_book_ids = ISNULL(@sub_book_ids + ',', '') + CAST(clm3_value AS VARCHAR(10))
	FROM generic_mapping_values gmv
	INNER JOIN generic_mapping_header gmh
		ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Regulatory Reporting - Book Structure'
		AND gmv.clm1_value = 'M'
		AND gmv.clm2_value = 5
		
	IF NULLIF(@deal_ids, '') IS NULL
	BEGIN
		EXEC TRMTracker_ACT.dbo.spa_message_board 'i', @user, NULL, 'BatchReport', 'No new/updated deals found to process.', '', '', 'e', NULL, '', '5a27mifida69e', ''
		RETURN
	END
	
	EXEC spa_source_emir NULL, NULL, NULL, NULL, NULL, NULL, NULL, @deal_ids, NULL, 'i', NULL, NULL, NULL, NULL, NULL, '44704', NULL, NULL, 0, 'CANC', 'X', @proc_id OUTPUT
		
	IF NULLIF(@proc_id, '') IS NULL
	BEGIN
		EXEC TRMTracker_ACT.dbo.spa_message_board 'i', @user, NULL, 'BatchReport', 'No valid deals found to process.', '', '', 'e', NULL, '', '5a27mifida69e', ''
		RETURN
	END

	SET @exec_query = 'EXEC spa_source_emir NULL, NULL, NULL, NULL, NULL, NULL, '''+ @proc_id +''', NULL, NULL, ''g'', NULL, NULL, NULL, NULL, NULL, ''44704'', NULL, NULL, 0, NULL, ''X'''

	SELECT @temp_path = document_path + '\temp_Note' FROM connection_string

	EXEC batch_report_process  @spa = @exec_query,
							   @flag='i',		
							   @batch_type='mifid',
							   @generate_dynamic_params='0',			
							   @notification_type='751',
							   @send_attachment='n',
							   @batch_unique_id='5a27mifida69e',
							   @temp_notes_path=@temp_path,
							   @compress_file='n',
							   @delim=',',
							   @is_header='1',
							   @xml_format='-100002',
							   @export_file_format='.xml',
							   @is_ftp='1',
							   @ftp_url=@import_ftp_url,
							   @ftp_folder_path='/outgoing',
							   @ftp_username=@import_ftp_username,  
							   @ftp_password=@import_ftp_password 
	SELECT sdh.deal_id [Deal ID], 
		   'Reviewed deal [' + sdh.deal_id +'] has been submitted.' [Submission Details]
	INTO adiha_process.dbo.post_deal_review_process_id_pdr
	FROM staging_table.alert_deal_process_id_ad a
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = a.source_deal_header_id
END
ELSE
BEGIN
	SELECT sdh.deal_id [Deal ID], 
		   sdv.code [Deal Status]
	INTO adiha_process.dbo.post_deal_review_process_id_pdr
	FROM staging_table.alert_deal_process_id_ad a
	INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = a.source_deal_header_id
	LEFT JOIN static_data_value sdv
		ON sdv.value_id = sdh.deal_status
			AND sdv.type_id = 5600
END