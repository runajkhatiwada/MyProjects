DECLARE @_generator_id INT,
		@_compliance_year VARCHAR(10),
		@_jurisdiction INT,
		@_tier_type INT,
		@_sql VARCHAR(MAX)

IF '@generator_id' <> 'NULL'
    SET @_generator_id = '@generator_id'

IF '@compliance_year' <> 'NULL'
    SET @_compliance_year = '@compliance_year'

IF '@jurisdiction' <> 'NULL'
    SET @_jurisdiction = '@jurisdiction'

IF '@tier_type' <> 'NULL'
    SET @_tier_type = '@tier_type'

SET @_sql = '
	SELECT source_deal_header_id, 
		   rg.code generator_id,
		   sdh.compliance_year,
		   status.code status,
		   status_date,
		   assignment_type.code assignment_type,
		   jurisdiction.code jurisdiction,
		   assigned_date,
		   assigned_by,
		   generation_source,
		   tier_type.code tier_type
	--[__batch_report__]
	FROM source_deal_header sdh
	LEFT JOIN static_data_value jurisdiction
		ON jurisdiction.value_id = sdh.state_value_id
			AND jurisdiction.type_id = 10002
	LEFT JOIN static_data_value tier_type
		ON tier_type.value_id = sdh.tier_value_id
			AND tier_type.type_id = 15000
	LEFT JOIN rec_generator rg
		ON rg.generator_id = sdh.generator_id
	LEFT JOIN static_data_value assignment_type
		ON assignment_type.value_id = sdh.assignment_type_value_id
	LEFT JOIN static_data_value status
		ON status.value_id = sdh.status_value_id
	WHERE 1 = 1
' + 
CASE WHEN @_generator_id IS NOT NULL THEN ' AND sdh.generator_id = ' + CAST(@_generator_id AS VARCHAR(10)) ELSE '' END
+ 
CASE WHEN @_compliance_year IS NOT NULL THEN ' AND sdh.compliance_year = ' + CAST(@_compliance_year AS VARCHAR(10)) ELSE '' END
+ 
CASE WHEN @_jurisdiction IS NOT NULL THEN ' AND sdh.state_value_id = ' + CAST(@_jurisdiction AS VARCHAR(10)) ELSE '' END
+ 
CASE WHEN @_tier_type IS NOT NULL THEN ' AND sdh.tier_value_id = ' + CAST(@_tier_type AS VARCHAR(10)) ELSE '' END

EXEC(@_sql)

exec spa_rfx_export_report 'ledger report'