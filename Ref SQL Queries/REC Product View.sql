DECLARE @_certificate_expiration_date_from VARCHAR(1000),
		@_certificate_expiration_date_to VARCHAR(1000),
		@_vintage_year_id VARCHAR(1000),
		@_tier_id VARCHAR(1000),
		@_jurisdiction_id VARCHAR(1000),
		@_sql_string VARCHAR(MAX)

IF '@certificate_expiration_date_from' <> 'NULL'
    SET @_certificate_expiration_date_from = '@certificate_expiration_date_from'

IF '@certificate_expiration_date_to' <> 'NULL'
    SET @_certificate_expiration_date_to = '@certificate_expiration_date_to'

IF '@vintage_year_id' <> 'NULL'
    SET @_vintage_year_id = '@vintage_year_id'

IF '@tier_id' <> 'NULL'
    SET @_tier_id = '@tier_id'

IF '@jurisdiction_id' <> 'NULL'
    SET @_jurisdiction_id = '@jurisdiction_id'

IF OBJECT_ID('tempdb..#rec_details') IS NOT NULL
	DROP TABLE #rec_details

SELECT DISTINCT 
	   sdh.source_deal_header_id,
	   sdh.deal_id,
	   gis_cert_date,
	   gc.contract_expiration_date certificate_expiration_date, --filter
	   gc.gis_certificate_number_from,
	   gc.gis_certificate_number_to,
	   cert_entity.code certification_entity,
	   gc.certificate_number_from_int sequence_from,
	   gc.certificate_number_To_int sequence_to,
	   COALESCE(gc.[year], gp.vintage, sdd.vintage) vintage_year_id, --filter
	   COALESCE(gc.tier_type, sdh.tier_value_id, gp.tier_id, a.tier_id, emtd.tier_id) tier_id, --filter
	   COALESCE(gc.state_value_id, sdh.state_value_id, gp.jurisdiction_id, b.state_value_id, emtd.state_value_id) jurisdiction_id --filter
INTO #rec_details
FROM source_deal_header sdh
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = sdh.source_deal_header_id
LEFT JOIN gis_product gp
	ON gp.source_deal_header_id = sdh.source_deal_header_id
LEFT JOIN gis_certificate gc
	ON gc.source_deal_header_id = sdd.source_deal_detail_id
LEFT JOIN static_data_value cert_entity
	ON cert_entity.value_id = gc.certification_entity
		AND cert_entity.type_id = 10011
LEFT JOIN rec_generator rg
	ON rg.generator_id = sdh.generator_id
LEFT JOIN eligibility_mapping_template emt
	ON emt.template_id = rg.eligibility_mapping_template_id
LEFT JOIN eligibility_mapping_template_detail emtd
	ON emtd.template_id = emt.template_id
OUTER APPLY(
	SELECT tier_id, technology_id
	FROM state_properties_details
	WHERE technology_id = gp.technology_id
		AND state_value_id = gp.jurisdiction_id
) a
OUTER APPLY(
	SELECT sp.state_value_id
	FROM state_properties sp
	INNER JOIN dbo.SplitCommaSeperatedValues(gp.region_id) i
		ON sp.region_id = i.item
) b
WHERE sdh.deal_id = 'sale 02'

SET @_sql_string = '
	SELECT rd.source_deal_header_id,
		   rd.deal_id,
		   rd.gis_cert_date,
		   rd.certificate_expiration_date certificate_expiration_date_from,
		   rd.gis_certificate_number_from,
		   rd.gis_certificate_number_to,
		   rd.certification_entity,
		   rd.sequence_from,
		   rd.sequence_to,
		   vintage_year.code vintage_year,
		   rd.vintage_year_id,
		   tier_type.code tier_type,
		   rd.tier_id,
		   jurisdiction.code jurisdiction,
		   rd.jurisdiction_id,
		   ''@certificate_expiration_date_to'' certificate_expiration_date_to
	--[__batch_report__]
	FROM #rec_details rd
	LEFT JOIN static_data_value vintage_year
		ON vintage_year.value_id = rd.vintage_year_id
			AND vintage_year.type_id = 10092
	INNER JOIN static_data_value tier_type
		ON tier_type.value_id = rd.tier_id
			AND tier_type.type_id = 15000
	LEFT JOIN static_data_value jurisdiction
		ON jurisdiction.value_id = rd.jurisdiction_id
			AND jurisdiction.type_id = 10002
	WHERE 1 = 1
'
+
CASE 
	WHEN @_certificate_expiration_date_from IS NOT NULL AND @_certificate_expiration_date_to IS NULL THEN ' AND CONVERT(VARCHAR(10), rd.certificate_expiration_date, 120) = ''' + CONVERT(VARCHAR(10), @_certificate_expiration_date_from, 120) + ''''
	ELSE ''
END
+ 
CASE 
	WHEN @_certificate_expiration_date_to IS NOT NULL AND @_certificate_expiration_date_from IS NULL THEN ' AND CONVERT(VARCHAR(10), rd.certificate_expiration_date, 120) < ''' + CONVERT(VARCHAR(10), @_certificate_expiration_date_to, 120) + ''''
	ELSE ''
END
+ 
CASE 
	WHEN @_certificate_expiration_date_to IS NOT NULL AND @_certificate_expiration_date_from IS NOT NULL THEN ' AND CONVERT(VARCHAR(10), rd.certificate_expiration_date, 120) BETWEEN ''' + CONVERT(VARCHAR(10), @_certificate_expiration_date_from, 120) + ''' AND ''' + CONVERT(VARCHAR(10), @_certificate_expiration_date_to, 120) + ''''
	ELSE ''
END
+ 
CASE 
	WHEN @_vintage_year_id IS NOT NULL THEN ' AND rd.vintage_year_id = ' + @_vintage_year_id
	ELSE ''
END
+ 
CASE 
	WHEN @_tier_id IS NOT NULL THEN ' AND rd.tier_id = ' + @_tier_id
	ELSE ''
END
+ 
CASE 
	WHEN @_jurisdiction_id IS NOT NULL THEN ' AND rd.jurisdiction_id = ' + @_jurisdiction_id
	ELSE ''
END

EXEC(@_sql_string)