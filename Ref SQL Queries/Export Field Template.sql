SET NOCOUNT ON
DECLARE @field_template_name VARCHAR(100) = 'FIELD TEMPLATE NAME' --TO DO: Give field template name to be exported (Does not support multiple field template)
DECLARE @exclude_udf CHAR(1) = 'y'  -- TO DO: @exclude_udf 'y' for excluding UDF field from field template 
											--@exclude_udf 'n' for including UDF Field from field template
DECLARE @field_template_id INT 

DECLARE @sql VARCHAR(MAX)

SELECT @field_template_id = field_template_id 
FROM maintain_field_template 
WHERE template_name like @field_template_name



SET @sql = '
IF EXISTS(select 1 FROM maintain_field_template WHERE template_name = ''' + @field_template_name + ''')
BEGIN
	SELECT ''Error'' Status, ''Field template ''''' + @field_template_name + ''''' already exists.'' Message
	RETURN
END 

BEGIN TRY
BEGIN TRAN	
	DECLARE @field_template_id INT ' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
	

SET @sql = @sql + '	--insert field template'+ CHAR(13) + CHAR(10) 
	
SELECT @sql = @sql + '	INSERT INTO  maintain_field_template (template_name, template_description,active_inactive,show_cost_tab, show_detail_cost_tab,is_mobile)
	SELECT ''' + template_name + ''', ''' 
					+ template_description + ''','
					+ ISNULL( CAST('''' + active_inactive + '''' AS VARCHAR(10)), 'NULL') + ',' 
					+ ISNULL( CAST('''' + show_cost_tab + '''' AS VARCHAR(10)), 'NULL') + ',' 
					+ ISNULL( CAST('''' + show_detail_cost_tab + '''' AS VARCHAR(10)), 'NULL') + ',' 
					+ ISNULL( CAST('''' + is_mobile + '''' AS VARCHAR(10)), 'NULL') + CHAR(13) + CHAR(10) 		
FROM maintain_field_template 
WHERE template_name like @field_template_name

SET @sql = @sql + CHAR(13) + CHAR(10)

SET @sql = @sql + '	SELECT @field_template_id = field_template_id FROM maintain_field_template WHERE template_name = ''' +  @field_template_name + '''' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 	


SET @sql = @sql + '	--insert field template group' + CHAR(13) + CHAR(10) 

SELECT @sql = @sql + '	INSERT INTO maintain_field_template_group (field_template_id,group_name,seq_no,	default_tab)
	SELECT @field_template_id, ''' 
				+ group_name + ''', '''
				+ CAST(seq_no AS VARCHAR(10)) + ''','
				+ ISNULL(CAST( default_tab AS VARCHAR(10)), 'NULL') + CHAR(13) + CHAR(10) 				
FROM  maintain_field_template_group
WHERE field_template_id = @field_template_id 

SET @sql = @sql + CHAR(13) + CHAR(10) + '	--insert field template detail' + CHAR(13) + CHAR(10) 

--field template header
SELECT @sql = @sql + '	INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required,field_caption, default_value, udf_or_system, min_value, max_value, validation_id, data_flag, buy_label, sell_label, deal_update_seq_no, update_required, hide_control, display_format, value_required, show_in_form, detail_group_id)
	SELECT @field_template_id, mftg.field_group_id, '
			+ CAST(mftd.field_id AS VARCHAR(10)) + ',' 
			+ CAST(mftd.seq_no AS VARCHAR(10)) + ','
			+ ISNULL(CAST('''' + mftd.is_disable + '''' AS VARCHAR(10)), 'NULL') + ',' 
			+ '''' + mftd.insert_required + '''' + ','
			+ '''' + mftd.field_caption + '''' + ','
			+ ISNULL(CAST('''' + CAST(mftd.default_value AS VARCHAR(50)) + '''' AS VARCHAR(50)), 'NULL') + ',' 
			+ '''' + mftd.udf_or_system + '''' + ','
			+ ISNULL(CAST(mftd.min_value AS VARCHAR(50)), 'NULL') + ',' 
			+ ISNULL(CAST(mftd.max_value AS VARCHAR(50)), 'NULL') + ','
			+ ISNULL(CAST(mftd.validation_id AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.data_flag + '''' AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.buy_label + '''' AS VARCHAR(50)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.sell_label + '''' AS VARCHAR(50)), 'NULL') + ','
			+ ISNULL(CAST(mftd.deal_update_seq_no AS VARCHAR(10)), 'NULL') + ','
			+ '''' + mftd.update_required + '''' + ','
			+ '''' + mftd.hide_control + '''' + ','
			+ ISNULL(CAST(mftd.display_format AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.value_required + '''' AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.show_in_form + '''' AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST(mftd.detail_group_id AS VARCHAR(10)), 'NULL') 
			+ ' 
	FROM maintain_field_template_group mftg 
	WHERE field_template_id = @field_template_id
		AND group_name = ''' + mftg.group_name + ''''  + CHAR(13) + CHAR(10) 	
FROM maintain_field_template_detail mftd
	INNER JOIN maintain_field_template_group mftg
		ON mftd.field_group_id = mftg.field_group_id
WHERE mftd.field_template_id = @field_template_id 
	 AND (mftd.udf_or_system = 's' OR @exclude_udf = 'n')

--field template detail
SELECT @sql = @sql + '	INSERT INTO maintain_field_template_detail(field_template_id, field_group_id, field_id, seq_no, is_disable, insert_required,field_caption, default_value, udf_or_system, min_value, max_value, validation_id, data_flag, buy_label, sell_label, deal_update_seq_no, update_required, hide_control, display_format, value_required, show_in_form, detail_group_id)
	SELECT @field_template_id, NULL, '
			+ CAST(mftd.field_id AS VARCHAR(10)) + ',' 
			+ CAST(mftd.seq_no AS VARCHAR(10)) + ','
			+ ISNULL(CAST('''' + mftd.is_disable + '''' AS VARCHAR(10)), 'NULL') + ',' 
			+ '''' + mftd.insert_required + '''' + ','
			+ '''' + mftd.field_caption + '''' + ','
			+ ISNULL(CAST('''' + CAST(mftd.default_value AS VARCHAR(50)) + '''' AS VARCHAR(50)), 'NULL') + ',' 
			+ '''' + mftd.udf_or_system + '''' + ','
			+ ISNULL(CAST(mftd.min_value AS VARCHAR(50)), 'NULL') + ',' 
			+ ISNULL(CAST(mftd.max_value AS VARCHAR(50)), 'NULL') + ','
			+ ISNULL(CAST(mftd.validation_id AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.data_flag + '''' AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.buy_label + '''' AS VARCHAR(50)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.sell_label + '''' AS VARCHAR(50)), 'NULL') + ','
			+ ISNULL(CAST(mftd.deal_update_seq_no AS VARCHAR(10)), 'NULL') + ','
			+ '''' + mftd.update_required + '''' + ','
			+ '''' + mftd.hide_control + '''' + ','
			+ ISNULL(CAST(mftd.display_format AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.value_required + '''' AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST('''' + mftd.show_in_form + '''' AS VARCHAR(10)), 'NULL') + ','
			+ ISNULL(CAST(mftd.detail_group_id AS VARCHAR(10)), 'NULL') 			 
			+ CHAR(13) + CHAR(10) 	
FROM maintain_field_template_detail mftd		
WHERE mftd.field_template_id = @field_template_id  
	AND mftd.field_group_id IS NULL
	AND (mftd.udf_or_system = 's' OR @exclude_udf = 'n')

SET @sql = @sql + CHAR(13) + CHAR(10) 

SET @sql = @sql + '
	COMMIT
	SELECT ''Success'' Status, ''Field template ''''' + @field_template_name + ''''' is inserted.'' Message
END TRY
BEGIN CATCH 
	IF @@TRANCOUNT > 0
		ROLLBACK
	SELECT ''Error'' Status, ''Field template ''''' + @field_template_name + ''''' is not inserted.'' Message
END CATCH
'
SELECT @sql [processing-instruction(x)] FOR XML PATH('')

