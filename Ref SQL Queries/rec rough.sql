SET NOCOUNT ON;

DECLARE @_certificate_expiration_date_from VARCHAR(1000),
		@_certificate_expiration_date_to VARCHAR(1000),
		@_vintage_year_id VARCHAR(1000),
		@_tier_id VARCHAR(1000),
		@_jurisdiction_id VARCHAR(1000),
		@_sql_string VARCHAR(MAX)

--IF '@certificate_expiration_date_from' <> 'NULL'
--    SET @_certificate_expiration_date_from = '@certificate_expiration_date_from'

--IF '@certificate_expiration_date_to' <> 'NULL'
--    SET @_certificate_expiration_date_to = '@certificate_expiration_date_to'

--IF '@vintage_year_id' <> 'NULL'
--	SET @_vintage_year_id = '@vintage_year_id'

--IF '@tier_id' <> 'NULL'
--	SET @_tier_id = '@tier_id'

--IF '@jurisdiction_id' <> 'NULL'
--	SET @_jurisdiction_id = '@jurisdiction_id'

IF OBJECT_ID('tempdb..#books') IS NOT NULL
	DROP TABLE #books

IF OBJECT_ID('tempdb..#source_deal_header') IS NOT NULL
	DROP TABLE #source_deal_header

SELECT sub.[entity_id] sub_id,
       stra.[entity_id] stra_id,
       book.[entity_id] book_id,
       sub.[entity_name] sub_name,
       stra.[entity_name] stra_name,
       book.[entity_name] book_name,
       ssbm.source_system_book_id1,
       ssbm.source_system_book_id2,
       ssbm.source_system_book_id3,
       ssbm.source_system_book_id4,
       ssbm.logical_name sub_book_name,  
       ssbm.book_deal_type_map_id [sub_book_id]
INTO #books
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.[entity_id]
INNER JOIN portfolio_hierarchy sub(NOLOCK) ON  stra.parent_entity_id = sub.[entity_id]
INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.[entity_id]
AND ('39' = 'NULL' OR sub.[entity_id] IN (39)) 
--AND ('@sub_id' = 'NULL' OR sub.[entity_id] IN (@sub_id)) 
--AND ('@stra_id' = 'NULL' OR stra.[entity_id] IN (@stra_id)) 
--AND ('@book_id' = 'NULL' OR book.[entity_id] IN (@book_id))
--AND ('@sub_book_id' = 'NULL' OR ssbm.book_deal_type_map_id IN (@sub_book_id))	

SELECT sdh.source_deal_header_id,
	   sdh.deal_id,
	   sdh.source_system_book_id1,
	   sdh.source_system_book_id2,
	   sdh.source_system_book_id3,
	   sdh.source_system_book_id4,
	   sdh.state_value_id,
	   sdh.tier_value_id,
	   sdh.generator_id,
	   book.sub_id,
	   book.stra_id,
	   book.book_id,
	   book.sub_book_id,
	   book.sub_name sub,
	   book.stra_name stra,
	   book.book_name book,
	   book.sub_book_name sub_book
INTO #source_deal_header
FROM source_deal_header sdh
INNER JOIN #books book
	ON book.source_system_book_id1 = sdh.source_system_book_id1
	   AND book.source_system_book_id2 = sdh.source_system_book_id2
	   AND book.source_system_book_id3 = sdh.source_system_book_id3
	   AND book.source_system_book_id4 = sdh.source_system_book_id4

IF OBJECT_ID('tempdb..#tmp_state_properties') IS NOT NULL
	DROP TABLE #tmp_state_properties

SELECT sp.state_value_id AS jurisdiction_id, 
	   t.item region_id,
	   spd.tier_id
INTO #tmp_state_properties
FROM state_properties sp
OUTER APPLY (
	SELECT item 
	FROM dbo.SplitCommaSeperatedValues(sp.region_id)
) t
INNER JOIN state_properties_details spd
	ON spd.state_value_id = sp.state_value_id

CREATE INDEX idx_state_prop ON #tmp_state_properties (jurisdiction_id)

IF OBJECT_ID('tempdb..#tmp_gis_product') IS NOT NULL
	DROP TABLE #tmp_gis_product

SELECT td.source_deal_header_id, 
	   gp.tier_id,
	   gp.jurisdiction_id,
	   region_id,
	   gp.technology_id,
	   gp.in_or_not,
	   vin.code AS vintage
INTO #tmp_gis_product
FROM #source_deal_header td
INNER JOIN gis_product gp
	ON gp.source_deal_header_id = td.source_deal_header_id
LEFT JOIN static_data_value vin
	ON vin.value_id = gp.vintage
		AND vin.type_id = 10092

CREATE INDEX idx_gis_prod ON #tmp_gis_product (source_deal_header_id)

IF OBJECT_ID('tempdb..#tmp_state_properties_in') IS NOT NULL 
	DROP TABLE #tmp_state_properties_in

SELECT tgp.source_deal_header_id,
	   sp.tier_id,
	   sp.jurisdiction_id,
	   sp.region_id,
	   tgp.technology_id,
	   tgp.in_or_not,
	   tgp.vintage
INTO #tmp_state_properties_in
FROM #tmp_gis_product tgp
INNER JOIN #tmp_state_properties sp
	ON sp.region_id = tgp.region_id
UNION
SELECT source_deal_header_id,
	   tier_id,
	   jurisdiction_id,
	   region_id,
	   technology_id,
	   in_or_not,
	   vintage 
FROM #tmp_gis_product 
WHERE jurisdiction_id IS NOT NULL 
	OR COALESCE(jurisdiction_id, region_id) IS NULL

CREATE INDEX idx_st_prop_in ON #tmp_state_properties_in (source_deal_header_id)

IF OBJECT_ID ('tempdb..#header_collection') IS NOT NULL
	DROP TABLE #header_collection

CREATE TABLE #header_collection (
	source_deal_header_id INT,
	deal_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
	state_value_id INT,
	tier_value_id INT,
	vintage INT
)

INSERT INTO #header_collection
SELECT DISTINCT
	   sdh.source_deal_header_id,
	   sdh.deal_id,
	   COALESCE(cer.state_value_id, pro.state_value_id, deal.state_value_id, gen.state_value_id, al.jurisdiction_id) state_value_id,
	   COALESCE(cer.tier_value_id, pro.tier_value_id, deal.tier_value_id, gen.tier_value_id, al.tier_id) tier_value_id,
	   COALESCE(cer.vintage, pro.vintage, deal.vintage, gen.vintage) vintage
FROM #source_deal_header sdh	
INNER JOIN source_deal_detail sdd
	ON sdd.source_deal_header_id = sdh.source_deal_header_id
OUTER APPLY (
	SELECT DISTINCT 1 cnt 
	FROM Gis_Certificate gc 
	WHERE gc.source_deal_header_id = sdd.source_deal_detail_id
) gc
OUTER APPLY (
	SELECT DISTINCT 
		   1 AS total,
		   gc.state_value_id,
		   gc.tier_type AS tier_value_id,
		   gc.year AS vintage
	FROM Gis_Certificate gc
	LEFT JOIN state_properties_details spd
		ON spd.tier_id = gc.tier_type
			AND spd.state_value_id = gc.state_value_id
	LEFT JOIN static_data_value vin
		ON vin.value_id = gc.year
			AND vin.type_id = 10092
	WHERE gc.source_deal_header_id = sdd.source_deal_detail_id
) cer
OUTER APPLY (
	SELECT DISTINCT 1 cnt 
	FROM #tmp_state_properties_in tspn 
	WHERE tspn.source_deal_header_id = sdh.source_deal_header_id
) gis
OUTER APPLY(
	SELECT DISTINCT 
		   1 AS total,
		   gp.jurisdiction_id AS state_value_id,
		   gp.tier_id AS tier_value_id,
		   gp.vintage AS vintage
	FROM #tmp_state_properties_in gp
	LEFT JOIN #tmp_state_properties_in gp1
		ON gp1.jurisdiction_id = gp.jurisdiction_id
			AND gp1.tier_id = gp.tier_id
			AND ISNULL(gp.in_or_not, -1) <> ISNULL(gp1.in_or_not, -1)
	WHERE gp.source_deal_header_id = sdh.source_deal_header_id		
		AND gc.cnt IS NULL
		AND gp.in_or_not = 1		
		AND gp1.in_or_not IS NULL		
) pro
OUTER APPLY(
	SELECT 1 cnt 
	FROM #source_deal_header sdhh 
	WHERE sdhh.source_deal_header_id = sdh.source_deal_header_id
		AND COALESCE(sdhh.state_value_id, sdhh.tier_value_id) IS NOT NULL
) head
OUTER APPLY(
	SELECT DISTINCT 1 AS total,
		   sd.state_value_id,
		   sd.tier_value_id,
		   sdd.vintage
	FROM #source_deal_header sd
	LEFT JOIN state_properties_details spd
		ON spd.tier_id = sd.tier_value_id
			AND spd.state_value_id = sd.state_value_id
	LEFT JOIN static_data_value vin
		ON vin.value_id = sdd.vintage
			AND vin.type_id = 10092
	WHERE sd.source_deal_header_id = sdh.source_deal_header_id
		AND COALESCE(gc.cnt, gis.cnt) IS NULL
		AND COALESCE(sd.state_value_id, sd.tier_value_id) IS NOT NULL
) deal
OUTER APPLY(
	SELECT DISTINCT 1 AS total,
		   emtd.state_value_id,
		   emtd.tier_id AS tier_value_id,
		   vin.value_id vintage
	FROM rec_generator rg
	LEFT JOIN eligibility_mapping_template_detail emtd
		ON emtd.template_id = rg.eligibility_mapping_template_id
	LEFT JOIN static_data_value vin
		ON vin.code = YEAR(sdd.term_start)
			AND vin.type_id = 10092
	WHERE rg.generator_id = sdh.generator_id
		AND COALESCE(gc.cnt, gis.cnt, head.cnt) IS NULL
) gen
OUTER APPLY (
	SELECT sp.state_value_id jurisdiction_id, spd.tier_id 
	FROM state_properties sp
	LEFT JOIN  state_properties_details spd
		ON sp.state_value_id = spd.state_value_id	
) al
WHERE sdh.source_deal_header_id = 6342

CREATE INDEX idx_final_table ON #header_collection (source_deal_header_id)

SELECT ft.source_deal_header_id,
		ft.deal_id,		
		ISNULL(sdv.code, ft.vintage) vintage_year,
		ft.vintage vintage_year_id,
		tier_type.code tier_type,
		ft.tier_value_id tier_id,
		jurisdiction.code jurisdiction,
		ft.state_value_id jurisdiction_id	
INTO #final_header_collection	
FROM #header_collection ft
INNER JOIN #source_deal_header sdh
	ON sdh.source_deal_header_id = ft.source_deal_header_id
LEFT JOIN static_data_value sdv
	ON sdv.value_id = ft.vintage
		AND sdv.type_id = 10092
LEFT JOIN gis_product gp
	ON gp.source_deal_header_id = ft.source_deal_header_id
LEFT JOIN static_data_value jurisdiction
	ON jurisdiction.value_id = ft.state_value_id
		AND jurisdiction.type_id = 10002
LEFT JOIN static_data_value tier_type
	ON tier_type.value_id = ft.tier_value_id
		AND tier_type.type_id = 15000

SELECT hc.source_deal_header_id,
	   sdd.source_deal_detail_id,
	   hc.deal_id,		
	    vintage_year,	
	   hc.tier_type,	  
	   jurisdiction	   ,
	   sdd.term_start,
	   gc.gis_certificate_number_from,
	   gc.gis_certificate_number_to,
	   gc.certificate_number_from_int,
	   gc.certificate_number_to_int,
	   gc.gis_cert_date,
	   gc.contract_expiration_date
FROM source_deal_detail sdd
INNER JOIN #final_header_collection	hc ON hc.source_deal_header_id = sdd.source_deal_header_id
LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
	AND gc.state_value_id = jurisdiction_id
