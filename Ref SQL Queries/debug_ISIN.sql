SELECT sdh.source_deal_header_id,sdh.option_type,sdd.contract_expiration_date,gmv1.clm5_value,gmv1.clm7_value,
instrument_id_code = IIF(deal_status.code IN ('New', 'Amended'), 
						IIF(
							IIF(scn.counterparty_id = gmv.clm7_value, gmv.clm4_value, 'XOFF') <> 'XXXX', 
									gmv1.clm1_value
								, NULL)
							, NULL
						),
instrument_name = IIF(deal_status.code IN ('New', 'Amended'), gmv1.clm2_value, NULL),
instrument_classification = IIF(deal_status.code IN ('New', 'Amended'), gmv1.clm3_value, NULL),
gmv1.clm8_value		   
FROM
source_deal_header sdh
INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
LEFT JOIN (
	SELECT gmvx.mapping_table_id,
			gmvx.clm1_value,
			gmvx.clm2_value,
			gmvx.clm3_value,
			gmvx.clm4_value,
			gmvx.clm5_value,
			gmvx.clm6_value,
			gmvx.clm7_value,
			gmvx.clm8_value
	FROM generic_mapping_values gmvx
	INNER JOIN generic_mapping_header gmh1
		ON gmh1.mapping_table_id = gmvx.mapping_table_id
	WHERE gmh1.mapping_name = 'Instrument Detail'
) gmv1 ON gmv1.clm6_value = CAST(sdd.curve_id AS VARCHAR(10))
	AND MONTH(gmv1.clm5_value) = MONTH(sdd.contract_expiration_date)
	AND YEAR(gmv1.clm5_value) = YEAR(sdd.contract_expiration_date)
	AND CASE WHEN sdh.counterparty_id IN (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE', 'CME', 'EEX')) THEN sdh.counterparty_id ELSE (SELECT source_counterparty_id FROM source_counterparty WHERE counterparty_id IN ('ICE')) END = gmv1.clm7_value	
	AND ISNULL(NULLIF(sdh.option_type, ' '), '$') = ISNULL(gmv1.clm8_value, '$')
LEFT JOIN static_data_value deal_status
			ON sdh.deal_status = deal_status.value_id
LEFT JOIN source_counterparty scn
			ON scn.source_counterparty_id = sdh.counterparty_id
LEFT JOIN (
	SELECT gmva.mapping_table_id,
			gmva.clm1_value,
			gmva.clm2_value,
			gmva.clm3_value,
			gmva.clm4_value,
			gmva.clm5_value,
			gmva.clm6_value,
			gmva.clm7_value,
			gmva.clm8_value,
			gmva.clm9_value,
			gmva.clm10_value,
			gmva.clm11_value,
			gmva.clm12_value,
			gmva.clm13_value,
			gmva.clm14_value
	FROM generic_mapping_values gmva
	INNER JOIN generic_mapping_header gmh
		ON gmh.mapping_table_id = gmva.mapping_table_id
	WHERE gmh.mapping_name = 'Venue of Execution'
) gmv ON gmv.clm7_value = scn.counterparty_id
	

where sdh.source_deal_header_id in (
958
--,959
--,960
--,961
--,962
--,963
)

--select distinct option_type from source_deal_header 
