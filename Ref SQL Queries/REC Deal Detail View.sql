SET NOCOUNT ON;

IF OBJECT_ID(N'tempdb..#books') IS NOT NULL
    DROP TABLE #books

DECLARE @_as_of_date DATETIME

-- header filters
DECLARE @_sql VARCHAR(MAX),
		@_term_start VARCHAR(20),
		@_term_end VARCHAR(20),
		@_deal_date_from VARCHAR(20),
		@_deal_date_to VARCHAR(20),
		@_create_ts_from VARCHAR(20),
		@_create_ts_to VARCHAR(20),
		@_update_ts_from VARCHAR(20),
		@_update_ts_to VARCHAR(20),
		@_counterparty_id VARCHAR(1000),
		@_trader_id VARCHAR(1000),
		@_contract_id VARCHAR(1000),
		@_header_physical_financial_flag NCHAR(1),
		@_header_buy_sell_flag NCHAR(1),
		@_source_deal_type_id VARCHAR(500),
		@_deal_sub_type_type_id VARCHAR(500),
		@_template_id VARCHAR(1000),
		@_commodity_id VARCHAR(1000),
		@_source_deal_header_id VARCHAR(100),
		@_counterparty_type CHAR(1),
		@_deal_lock CHAR(1),
		@_block_type VARCHAR(100),
		@_legal_entity VARCHAR(100),
		@_deal_id VARCHAR(200),
		@_block_define_id VARCHAR(100)

-- detail filters
DECLARE @_curve_id VARCHAR(1000),
        @_location_id VARCHAR(1000),
        @_physical_financial_flag VARCHAR(1000),
        @_buy_sell_flag VARCHAR(1000),
        @_detail_phy_fin_flag NCHAR(1),
        @_formula_curve_id NCHAR(1)

--REC filters
DECLARE @_generator_id INT,
		@_compliance_year VARCHAR(10),
		@_jurisdiction INT,
		@_tier_type INT,
		@_technology INT,
		@_certificate_jurisdiction INT,
		@_certificate_tier_type INT,
		@_generation_state INT
--/*
IF '@as_of_date' <> 'NULL'
    SET @_as_of_date = '@as_of_date'

IF '@generator_id' <> 'NULL'
    SET @_generator_id = '@generator_id'

IF '@compliance_year' <> 'NULL'
    SET @_compliance_year = '@compliance_year'

IF '@jurisdiction' <> 'NULL'
    SET @_jurisdiction = '@jurisdiction'

IF '@tier_type' <> 'NULL'
    SET @_tier_type = '@tier_type'

IF '@technology' <> 'NULL'
    SET @_technology = '@technology'

IF '@certificate_jurisdiction' <> 'NULL'
	SET @_certificate_jurisdiction = '@certificate_jurisdiction'

IF '@certificate_tier_type' <> 'NULL'
	SET @_certificate_tier_type = '@certificate_tier_type'

IF '@generation_state' <> 'NULL'
	SET @_generation_state = '@generation_state'	
	
IF '@deal_date_to' <> 'NULL'
    SET @_deal_date_to = '@deal_date_to'

IF '@term_start' <> 'NULL'
    SET @_term_start = '@term_start'

IF '@term_end' <> 'NULL'
    SET @_term_end = '@term_end'

IF '@create_ts_from' <> 'NULL'
    SET @_create_ts_from = '@create_ts_from'

IF '@create_ts_to' <> 'NULL'
    SET @_create_ts_to = '@create_ts_to'

IF '@update_ts_from' <> 'NULL'
    SET @_update_ts_from = '@update_ts_from'

IF '@update_ts_to' <> 'NULL'
    SET @_update_ts_to = '@update_ts_to'

IF '@counterparty_id' <> 'NULL'
    SET @_counterparty_id = '@counterparty_id'

IF '@trader_id' <> 'NULL'
    SET @_trader_id = '@trader_id'

IF '@contract_id' <> 'NULL'
    SET @_contract_id = '@contract_id'

IF '@header_physical_financial_flag' <> 'NULL'
    SET @_header_physical_financial_flag = '@header_physical_financial_flag'

IF '@header_buy_sell_flag' <> 'NULL'
    SET @_header_buy_sell_flag = '@header_buy_sell_flag'

IF '@source_deal_type_id' <> 'NULL'
    SET @_source_deal_type_id = '@source_deal_type_id'

IF '@template_id' <> 'NULL'
    SET @_template_id = '@template_id'

IF '@commodity_id' <> 'NULL'
    SET @_commodity_id = '@commodity_id'

IF '@deal_sub_type_type_id' <> 'NULL'
	SET @_deal_sub_type_type_id = '@deal_sub_type_type_id'

IF '@source_deal_header_id' <> 'NULL'
	SET @_source_deal_header_id = '@source_deal_header_id'

IF '@location_id' <> 'NULL'
	SET @_location_id = '@location_id'

IF '@detail_phy_fin_flag' <> 'NULL'
	SET @_detail_phy_fin_flag = '@detail_phy_fin_flag'

IF '@curve_id' <> 'NULL'
	SET @_curve_id = '@curve_id'

IF '@formula_curve_id' <> 'NULL'
	SET @_formula_curve_id = '@formula_curve_id'

IF '@buy_sell_flag' <> 'NULL'
	SET @_buy_sell_flag = '@buy_sell_flag'

IF '@counterparty_type' <> 'NULL'
	SET @_counterparty_type = '@counterparty_type'

IF '@deal_lock' <> 'NULL'
	SET @_deal_lock = '@deal_lock'

IF '@block_type' <> 'NULL'
	SET @_block_type = '@block_type'

IF '@legal_entity' <> 'NULL'
	SET @_legal_entity = '@legal_entity'

IF '@deal_id' <> 'NULL'
	SET @_deal_id = '@deal_id'

IF '@block_define_id' <> 'NULL'
	SET @_block_define_id = '@block_define_id'
--*/
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
       ssbm.logical_name,
       ssbm.fas_deal_type_value_id,
       ssbm.book_deal_type_map_id [sub_book_id],
	   ssbm.sub_book_group1,
	   ssbm.sub_book_group2,
	   ssbm.sub_book_group3,
	   ssbm.sub_book_group4
INTO #books
FROM portfolio_hierarchy book(NOLOCK)
INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON  book.parent_entity_id = stra.[entity_id]
INNER JOIN portfolio_hierarchy sub(NOLOCK) ON  stra.parent_entity_id = sub.[entity_id]
INNER JOIN source_system_book_map ssbm ON  ssbm.fas_book_id = book.[entity_id]
AND ('@sub_id' = 'NULL' OR sub.[entity_id] IN (@sub_id)) 
AND ('@stra_id' = 'NULL' OR stra.[entity_id] IN (@stra_id)) 
AND ('@book_id' = 'NULL' OR book.[entity_id] IN (@book_id))
AND ('@sub_book_id' = 'NULL' OR ssbm.book_deal_type_map_id IN (@sub_book_id))	

IF OBJECT_ID('tempdb..#temp_mdv_source_deal_header') IS NOT NULL
	DROP TABLE #temp_mdv_source_deal_header

CREATE TABLE #temp_mdv_source_deal_header(source_deal_header_id INT)

IF OBJECT_ID('tempdb..#temp_mdv_source_deal_detail') IS NOT NULL
	DROP TABLE #temp_mdv_source_deal_detail

CREATE TABLE #temp_mdv_source_deal_detail(source_deal_header_id INT, source_deal_detail_id INT)

SET @_sql = '
	INSERT INTO #temp_mdv_source_deal_header(source_deal_header_id)
	SELECT sdh.source_deal_header_id 
	FROM source_deal_header sdh
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	WHERE 1 = 1 ' +
		CASE WHEN @_source_deal_header_id IS NOT NULL THEN ' AND sdh.source_deal_header_id = ' + @_source_deal_header_id + '' ELSE '' END +
		CASE WHEN @_deal_id IS NOT NULL THEN ' AND sdh.deal_id = ''' + @_deal_id + '''' ELSE '' END +
		CASE WHEN @_deal_date_from IS NOT NULL THEN ' AND sdh.deal_date >= ''' + @_deal_date_from + '''' ELSE '' END +
		CASE WHEN @_deal_date_to IS NOT NULL THEN ' AND sdh.deal_date <= ''' + @_deal_date_to + '''' ELSE '' END +
		CASE WHEN @_create_ts_from IS NOT NULL THEN ' AND CAST(sdh.create_ts AS DATE) >= ''' + @_create_ts_from + '''' ELSE '' END +
		CASE WHEN @_create_ts_from IS NOT NULL THEN ' AND CAST(sdh.create_ts AS DATE) <= ''' + @_create_ts_to + '''' ELSE '' END +
		CASE WHEN @_update_ts_from IS NOT NULL THEN ' AND CAST(sdh.update_ts AS DATE) >= ''' + @_update_ts_from + '''' ELSE '' END +
		CASE WHEN @_update_ts_to IS NOT NULL THEN ' AND CAST(sdh.update_ts AS DATE) <= ''' + @_update_ts_to + '''' ELSE '' END +
		CASE WHEN @_counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id IN(' + @_counterparty_id + ')' ELSE '' END +
		CASE WHEN @_trader_id IS NOT NULL THEN ' AND sdh.trader_id IN(' + @_trader_id + ')' ELSE '' END +
		CASE WHEN @_contract_id IS NOT NULL THEN ' AND sdh.contract_id IN(' + @_contract_id + ')' ELSE '' END +
		CASE WHEN @_header_physical_financial_flag IS NOT NULL THEN ' AND sdh.physical_financial_flag = ''' + @_header_physical_financial_flag + '''' ELSE '' END +
		CASE WHEN @_header_buy_sell_flag IS NOT NULL THEN ' AND sdh.header_buy_sell_flag = ''' + @_header_buy_sell_flag + '''' ELSE '' END +
		CASE WHEN @_source_deal_type_id IS NOT NULL THEN ' AND sdh.source_deal_type_id = ' + @_source_deal_type_id + '' ELSE '' END +
		CASE WHEN @_deal_sub_type_type_id IS NOT NULL THEN ' AND sdh.deal_sub_type_type_id IN(' + @_deal_sub_type_type_id + ')' ELSE '' END +
		CASE WHEN @_template_id IS NOT NULL THEN ' AND sdh.template_id IN(' + @_template_id + ')' ELSE '' END +
		CASE WHEN @_commodity_id IS NOT NULL THEN ' AND sdh.commodity_id IN(' + @_commodity_id + ')' ELSE '' END +
		CASE WHEN @_counterparty_type IS NOT NULL THEN ' AND sc.int_ext_flag = ''' + @_counterparty_type + '''' ELSE '' END +
		CASE WHEN @_deal_lock IS NOT NULL THEN ' AND sdh.deal_locked = ''' + @_deal_lock + '''' ELSE '' END +
		CASE WHEN @_block_type IS NOT NULL THEN ' AND sdh.block_type = ' + @_block_type + '' ELSE '' END +
		CASE WHEN @_legal_entity IS NOT NULL THEN ' AND sdh.legal_entity = ' + @_legal_entity + '' ELSE '' END +
		CASE WHEN @_deal_id IS NOT NULL THEN ' AND sdh.deal_id = ''' + @_deal_id + '''' ELSE '' END +
		CASE WHEN @_block_define_id IS NOT NULL THEN ' AND sdh.block_define_id = ' + @_block_define_id + '' ELSE '' END
			
EXEC(@_sql)	

CREATE NONCLUSTERED INDEX MDV_SOURCE_DEAL_HEADER_ID ON #temp_mdv_source_deal_header (source_deal_header_id)

SET @_sql = '
INSERT INTO #temp_mdv_source_deal_detail(source_deal_header_id, source_deal_detail_id)
SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id
FROM source_deal_detail sdd
INNER JOIN #temp_mdv_source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
WHERE 1 = 1 ' +
	CASE WHEN @_term_start IS NOT NULL THEN ' AND sdd.term_start >= ''' + @_term_start + '''' ELSE '' END +
	CASE WHEN @_term_end IS NOT NULL THEN ' AND sdd.term_start <= ''' + @_term_end + '''' ELSE '' END +
	CASE WHEN @_curve_id IS NOT NULL THEN ' AND sdd.curve_id IN(' + @_curve_id + ')' ELSE '' END +
	CASE WHEN @_location_id IS NOT NULL THEN ' AND sdd.location_id IN(' + @_location_id + ')' ELSE '' END +
	CASE WHEN @_physical_financial_flag IS NOT NULL THEN ' AND sdd.physical_financial_flag = ''' + @_physical_financial_flag + '''' ELSE '' END +
	CASE WHEN @_buy_sell_flag IS NOT NULL THEN ' AND sdd.buy_sell_flag = ''' + @_buy_sell_flag + '''' ELSE '' END +
	CASE WHEN @_detail_phy_fin_flag IS NOT NULL THEN ' AND sdd.physical_financial_flag = ''' + @_detail_phy_fin_flag + '''' ELSE '' END +
	CASE WHEN @_formula_curve_id IS NOT NULL THEN ' AND sdd.formula_curve_id IN(' + @_formula_curve_id + ')' ELSE '' END 

EXEC(@_sql)

CREATE NONCLUSTERED INDEX MDV_SOURCE_DEAL_DETAIL_ID ON #temp_mdv_source_deal_detail (source_deal_detail_id)

SELECT books.stra_id stra_id,
       books.sub_id sub_id,
       books.book_id book_id,
       books.sub_name sub,
       books.stra_name stra,
       books.book_name book,
	   sb1.source_book_id book_identifier1_id,
       sb2.source_book_id  book_identifier2_id,
       sb3.source_book_id  book_identifier3_id,
       sb4.source_book_id  book_identifier4_id,
       sb1.source_book_name  book_identifier1,
       sb2.source_book_name  book_identifier2,
       sb3.source_book_name  book_identifier3,
       sb4.source_book_name  book_identifier4,
       fdtype.code [Type],
       sle.legal_entity_name,
       sdh.legal_entity,
       sdh.source_deal_header_id,
       sdh.deal_id,
       sdh.deal_date,
       sc.counterparty_name,
       ISNULL(nsc.counterparty_name, sc.counterparty_name) net_counterparty_name,
       sdt.source_deal_type_name deal_type_name,
       sdh.source_deal_type_id,
       sdty.source_deal_type_name + CASE 
                                         WHEN ssds.source_system_id = 2 THEN ''
                                         ELSE '.' + ssds.source_system_name
                                    END deal_sub_type_name,
       CASE 
            WHEN sdh.physical_financial_flag = 'p' THEN 'Physical'
            ELSE 'Financial'
       END header_physical_financial_flag,
       scom.commodity_name,
       sintp.code internal_portfolio_name,
       sdh.internal_portfolio_id,
       sdv_product.code product_name,
       sdh.product_id,
       sdh.reference,
       st.source_trader_id [trader_id],
       st.trader_name,
       sdh.ext_deal_id,
       sdh.structured_deal_id,
       sdh.description1,
       sdh.description2,
       sdh.description3,
       sc_broker.counterparty_name [broker_name],
       sdh.[create_user],
       sdh.[create_ts],
       sdh.[update_user],
       sdh.[update_ts],
       books.logical_name sub_book,
       sdh.entire_term_start,
       sdh.entire_term_end,
       CASE 
            WHEN sdh.option_flag = 'n' THEN 'No'
            WHEN sdh.option_flag = 'y' THEN 'Yes'
            ELSE sdh.option_flag
       END                                  option_flag,
       CASE 
            WHEN sdh.option_type = 'c' THEN 'Call'
            WHEN sdh.option_type = 'p' THEN 'Put'
            ELSE sdh.option_type
       END                                  option_type,
       CASE 
            WHEN sdh.option_excercise_type = 'e' THEN 'European'
            WHEN sdh.option_excercise_type = 'a' THEN 'American'
       END [option_excercise_type],
       sdh.internal_deal_type_value_id internal_deal_type_value_id,
       idtdt.internal_deal_type_subtype_type internal_deal_type,
       sdh.internal_deal_subtype_value_id internal_deal_subtype_value_id,
       idtsdt.internal_deal_type_subtype_type internal_deal_subtype,
       sdht.template_name [template],
       sdht.template_id,
       CASE 
            WHEN sdh.header_buy_sell_flag = 'b' THEN 'Buy'
            WHEN sdh.header_buy_sell_flag = 's' THEN 'Sell'
            ELSE sdh.header_buy_sell_flag
       END header_buy_sell_flag,
	   sdh.confirm_status_type confirm_status_type,
       sdv3.code confirm_status,
       sc.source_counterparty_id [counterparty_id],
	   sdv_deal_status.value_id [deal_status_id],
       sdv_deal_status.code [deal_status],
       sdh.option_settlement_date,
       CASE 
            WHEN sdh.deal_locked = 'n' THEN 'No'
            WHEN sdh.deal_locked = 'y' THEN 'Yes'
            ELSE NULL
       END [deal_lock],
       sdv_block.code [block_definition],
       sdh.block_define_id,
       sdv_pricing.code [pricing],
       cg.contract_id,
       cg.[contract_name] [contract_name],
       sdh.internal_desk_id,
       sdv_profile.code [internal_desk_name],
       sdh.close_reference_id [reference_deal],
       books.[sub_book_id],
       tz.TIMEZONE_ID [timezone_id],
       tz.TIMEZONE_NAME [timezone],
       sdh.deal_sub_type_type_id,
       sdh.commodity_id,
       sdh.inco_terms,
       sdv_it.code [inco_terms_name],
       sdh.counterparty_id2,
       sc2.counterparty_name [counterparty_name2],
       sdh.trader_id2,
       st2.trader_name [trader_name2],
       sdh.governing_law,
       sdv_gl.code [governing_law_desc],
       sdh.payment_term,
       sdv_pt.code [payment_term_desc],
       sdh.payment_days,
       cc_scheduler.name [scheduler_name],
       sdh.scheduler,
       CASE WHEN sdh.sample_control = 'y' THEN 'Yes' ELSE 'No' END [sample_control],
       sdd.source_deal_detail_id,
       sdd.fixed_price [fixed_price],
       sdd.leg [leg],
       sdd.term_start [term_start],
       sdd.term_end [term_end],
       spcd.curve_name               [curve_name],
       spcd.source_curve_def_id      [curve_id],
       ISNULL(sml.Location_Name, spcd.curve_name) [location],
       sml.source_minor_location_id  [location_id],
       CASE 
            WHEN sdd.buy_sell_flag = 'b' THEN 'Buy'
            ELSE 'Sell'
       END [buy_sell_flag],
       CASE 
            WHEN sdd.buy_sell_flag = 'b' THEN sdd.deal_volume
            ELSE (sdd.deal_volume * - 1)
       END [volume],
       su.uom_name [volume_uom],
       scu.currency_name [fixed_cost_currency],
       sdd.fixed_cost_currency_id,
       sdd.price_adder [adder],
       sdd.multiplier [multiplier],
       CASE 
            WHEN sdd.buy_sell_flag = 'b' THEN sdd.total_volume
            ELSE (sdd.total_volume * - 1)
       END [total_volume],
       su_pos.uom_name [position_uom],
       COALESCE(sdd.position_uom,spcd.display_uom_id, spcd.uom_id) [position_uom_id],
       sdd.fixed_cost [fixed_cost],
       CASE 
            WHEN fe.formula_source_type = 'u' THEN dbo.FNAFormulaFormat(fes.formula_sql, 'r')
            ELSE dbo.FNAFormulaFormat(fe.formula, 'r')
       END [formula],
       CASE 
            WHEN fe.formula IS NOT NULL THEN NULL
            ELSE spcd_formula.curve_name
       END [formula_curve],
       fixed_price_sc.currency_name [fixed_price_currency],
       sdd.fixed_price_currency_id,
       CASE 
            WHEN sdd.fixed_float_leg = 't' THEN 'Float'
            WHEN sdd.fixed_float_leg = 'f' THEN 'Fixed'
            ELSE NULL
       END [fixed/float],
       formula_sc.currency_name [formula_currency],
       sdd.formula_curve_id [formula_curve_id],
       sdd.formula_id [formula_id],
       sdd.price_multiplier,
       sdd.volume_multiplier2,
       CASE 
            WHEN sdd.pay_opposite = 'Y' THEN 'Yes'
            ELSE 'No'
       END pay_opposite,
       CASE 
			WHEN sdd.physical_financial_flag = 'p' THEN 'Physical'
			ELSE 'Financial'
	   END [physical_financial_flag],
	   sdd.physical_financial_flag [detail_phy_fin_flag],
       sdd.contract_expiration_date [contract_expiration_date],
       sdd.price_adder2,
       price_adder_sc.currency_name [price_adder_currency2],
       price_su.uom_name [price_uom],
       CASE sdv_pv_party.value_id
            WHEN 50 THEN sdv_pv_party.code + 'Group1'
            WHEN 51 THEN sdv_pv_party.code + 'Group2'
            WHEN 52 THEN sdv_pv_party.code + 'Group3'
            WHEN 53 THEN sdv_pv_party.code + 'Group4'
            ELSE sdv_pv_party.code
       END pv_party,
       settlement_sc.currency_name [settlement_currency],
       sdd.settlement_date,
       sdd.standard_yearly_volume,
       CASE 
            WHEN sdd.deal_volume_frequency = 'h' THEN 'Hourly'
            WHEN sdd.deal_volume_frequency = 'd' THEN 'Daily'
            WHEN sdd.deal_volume_frequency = 'm' THEN 'Monthly'
            WHEN sdd.deal_volume_frequency = 't' THEN 'Term'
            WHEN sdd.deal_volume_frequency = 'a' THEN 'Annually'
            WHEN sdd.deal_volume_frequency = 'x' THEN '15 Minutes'
            WHEN sdd.deal_volume_frequency = 'y' THEN '30 Minutes'
       END [volume_frequency],
       sc_adder.currency_name [adder_currency],
       CASE 
            WHEN sdd.lock_deal_detail = 'y' THEN 'Yes'
            WHEN sdd.lock_deal_detail = 'n' THEN 'No'
            ELSE NULL
       END lock_deal_detail,
       sdd.capacity,
       sdv_detail_profile.code detail_profile_code,
       sdv_o.value_id origin,
       sdv_o.code [origin_name],
       sdd.form [form],
       ctf.commodity_form_name [form_name],
       CASE 
            WHEN sdd.organic = 'y' THEN 'Yes'
            WHEN sdd.organic = 'n' THEN 'No'
            ELSE NULL
       END organic,
       sdv_att1.value_id  attribute1,
       sdv_att1.code [attribute1_name],
       sdv_att2.value_id attribute2,
       sdv_att2.code [attribute2_name],
       sdv_att3.value_id attribute3,
       sdv_att3.code [attribute3_name],
       sdv_att4.value_id attribute4,
       sdv_att4.code [attribute4_name],
       sdv_att5.value_id attribute5,
       sdv_att5.code [attribute5_name],
       sdd.detail_commodity_id,
       sdd_sc.commodity_name [detail_commodity_name],	   
       sdd_sc.commodity_group1 [commodity_group_id],
       sdv_gc.code [commodity_group_name],
       CASE 
            WHEN sdd.buy_sell_flag = 'b' THEN sdd.contractual_volume
            ELSE (sdd.contractual_volume * - 1)
       END [contractual_volume],
       sdd.contractual_uom_id,
       su_cont.uom_name [contractual_uom_name],
       CASE 
            WHEN sdd.buy_sell_flag = 'b' THEN sdd.actual_volume
            ELSE (sdd.actual_volume * - 1)
       END [actual_volume],
       sdd.detail_pricing,
       sdd.pricing_start,
       sdd.pricing_end,
       sdd.deal_detail_description,
       sdv_it2.code [detail_inco_term_name],
       sdd.detail_inco_terms [detail_inco_term],
       sdd.batch_id,
       CASE WHEN sdd.detail_sample_control = 'y' THEN 'Yes' ELSE 'No' END [detail_sample_control],
       sdv_cy.code crop_year,
       sdd.crop_year crop_year_id,
       sdd.lot,
       sdd.buyer_seller_option,
       sdv_bso.code [buyer_seller_option_name],
       CASE 
            WHEN mgd.match_group_detail_id IS NULL THEN 'No'
            ELSE 'Yes'
       END match_staus,
       mgs.shipment_status,
       CASE mgs.shipment_status
            WHEN 'p' THEN 'Pre-Allocation'
            WHEN 'a' THEN 'Allocation'
            WHEN 'l' THEN 'Live Shipment'
            WHEN 'c' THEN 'Completed'
            ELSE NULL
       END [shipment_status_desc],
       CASE 
            WHEN sdd.buy_sell_flag = 'b' THEN mgd.bookout_split_volume
            ELSE (mgd.bookout_split_volume * - 1)
       END [match_volume],
       sdg.source_deal_groups_name [deal_group_name],
       sdg.static_group_name,
	   sdd.status [deal_detail_status_id],
       sdv_dds.code [deal_detail_status],
       sdh.description4,
       sdh.deal_category_value_id,
       sdv_deal_cat.code [deal_category],
       sdh.block_type,
       sdv_block_type.code [block_name],
	   sdh.deal_reference_type_id,
	   sdv_deal_ref.code [deal_reference_name],
	   CASE sdh.term_frequency
	        WHEN 'm' THEN 'Monthly'
	        WHEN 'q' THEN 'Quarterly'
	        WHEN 'h' THEN 'Hourly'
	        WHEN 's' THEN 'Semi-Annually'
	        WHEN 'a' THEN 'Annually'
	        WHEN 'd' THEN 'Daily'
	        WHEN 'z' THEN 'term'
	   END	[term_frequency_name],
	   sdh.term_frequency,
	   sdh.counterparty_trader,
	   cc_trader.name [counterparty_trader_name],
	   sdh.internal_counterparty,
	   sc_internal.counterparty_name [internal_counterparty_name],
	   sdh.settlement_vol_type,
	   CASE sdh.settlement_vol_type
	        WHEN 'n' THEN 'Net'
	        WHEN 'g' THEN 'Gross'
	   END [settlement_vol_type_name],
	   sdd.option_strike_price,
	   sdd.block_description,
	   sdd.meter_id,
	   mi.recorderid [meter_name],
	   sdd.category [deal_detail_category_id],
	   sdv_detail_cat.code [deal_detail_category],
	   sdd.pricing_type,
	   sdd.pricing_period,
	   sdd.event_defination [event_definition],
	   CASE 
            WHEN sdd.buy_sell_flag = 'b' THEN sdd.schedule_volume
            ELSE (sdd.schedule_volume * - 1)
       END [schedule_volume],
       sdd.cycle,
       sdv_cycle.code [cycle_desc],       
       @_as_of_date as_of_date,
       @_deal_date_from [deal_date_from],
       @_deal_date_to [deal_date_to], 
       @_create_ts_from [create_ts_from],
       @_create_ts_to [create_ts_to],
       @_update_ts_from [update_ts_from],
       @_update_ts_to [update_ts_to],
	   CASE ISNULL(@_counterparty_type, sc.int_ext_flag) WHEN 'e' THEN 'External' WHEN 'i' THEN 'Internal' Else 'Broker' END [counterparty_type],
	   sc.type_of_entity,
	   sdv_entity.code [entity_name],
	   sdh.broker_id,
	   DAY(sdd.term_start) term_start_day,
	   MONTH(sdd.term_start) term_start_month,
	   DATENAME(m,sdd.term_start) term_start_month_name,
	   DATEPART(q,sdd.term_start) term_start_month_quarter,
	   YEAR(sdd.term_start) term_start_year,
	   books.sub_book_group1 sub_book_group1_id,
	   books.sub_book_group2 sub_book_group2_id,
	   books.sub_book_group3 sub_book_group3_id,
	   books.sub_book_group4 sub_book_group4_id,
	   sdv_sbg1.code sub_book_group1,
	   sdv_sbg2.code sub_book_group2,
	   sdv_sbg3.code sub_book_group3,
	   sdv_sbg4.code sub_book_group4,
	   psc.counterparty_name parent_counterparty_name,
	   sdh.arbitration,
	   sdh.clearing_counterparty_id,
	   sdh.confirmation_template,
	   sdh.confirmation_type,
	   sdh.counterparty2_trader,
	   sdd.no_of_strikes,
	   sdd.premium_settlement_date,
	   sdd.profile_id,
	   sdh.sdr,
	   sdh.underlying_options,
	   sdd.strike_granularity,
	   rg.code generator_id,
	   sdh.compliance_year,
	   status.code status,
	   sdh.status_date,
	   assignment_type.code assignment_type,
	   jurisdiction.code jurisdiction,
	   sdh.assigned_date,
	   sdh.assigned_by,
	   sdh.generation_source,
	   tier_type.code tier_type,
	   technology.code technology,
	   gc.gis_certificate_number_from,
	   gc.gis_certificate_number_to,
	   gc.certificate_number_from_int,
	   gc.certificate_number_to_int,
	   gc.gis_cert_date,
	   gis_cer_jur.code certificate_jurisdiction,
	   tier_type_jur.code certificate_tier_type,
	   gc.contract_expiration_date certificate_contract_expiration_date,
	   cert_year.code certification_year,
	   cert_entity.code certification_entity,
	   gen_state.code generation_state
--[__batch_report__]
FROM #temp_mdv_source_deal_header temp_sdh
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = temp_sdh.source_deal_header_id
INNER JOIN #books books 
	ON  books.source_system_book_id1 = sdh.source_system_book_id1
	AND books.source_system_book_id2 = sdh.source_system_book_id2
	AND books.source_system_book_id3 = sdh.source_system_book_id3
	AND books.source_system_book_id4 = sdh.source_system_book_id4
INNER JOIN #temp_mdv_source_deal_detail temp_sdd ON temp_sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp_sdd.source_deal_detail_id
INNER JOIN source_book sb1 ON sb1.source_book_id = sdh.source_system_book_id1
INNER JOIN source_book sb2 ON sb2.source_book_id = sdh.source_system_book_id2
INNER JOIN source_book sb3 ON sb3.source_book_id = sdh.source_system_book_id3
INNER JOIN source_book sb4 ON sb4.source_book_id = sdh.source_system_book_id4
LEFT JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id AND sdg.source_deal_header_id = sdh.source_deal_header_id
LEFT JOIN static_data_value sdv_deal_status ON sdv_deal_status.value_id = sdh.deal_status
LEFT JOIN static_data_value fdtype ON fdtype.value_id = books.fas_deal_type_value_id
LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id
LEFT JOIN source_counterparty sc_broker ON sc_broker.source_counterparty_id = sdh.broker_id
LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
LEFT JOIN source_counterparty nsc ON nsc.source_counterparty_id = sc.netting_parent_counterparty_id
LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
LEFT JOIN source_deal_type sdty ON sdty.source_deal_type_id = sdh.deal_sub_type_type_id AND ISNULL(sdty.sub_type, 'n') = 'y'
LEFT JOIN source_system_description ssds ON sdty.source_system_id = ssds.source_system_id
LEFT JOIN source_legal_entity sle ON sle.source_legal_entity_id = sdh.legal_entity
LEFT JOIN static_data_value sdv_product ON sdv_product.value_id = sdh.product_id
LEFT JOIN static_data_value sintp ON sintp.value_id = sdh.internal_portfolio_id AND sintp.[type_id] = 39800
LEFT JOIN source_commodity scom ON scom.source_commodity_id = sdh.commodity_id
LEFT JOIN internal_deal_type_subtype_types idtdt ON idtdt.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
LEFT JOIN internal_deal_type_subtype_types idtsdt ON idtsdt.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
LEFT JOIN static_data_value sdv3 ON sdv3.value_id = sdh.confirm_status_type
LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
LEFT JOIN static_data_value sdv_block ON sdv_block.value_id = sdh.block_define_id AND sdv_block.[type_id] = 10018
LEFT JOIN static_data_value sdv_pricing ON sdv_pricing.value_id = sdh.Pricing AND sdv_pricing.[type_id] = 1600
LEFT JOIN static_data_value sdv_profile ON sdv_profile.value_id = sdh.internal_desk_id AND sdv_profile.[type_id] = 17300
LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
LEFT JOIN time_zones tz ON tz.TIMEZONE_ID = sdh.timezone_id
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
LEFT JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
LEFT JOIN source_currency scu ON scu.source_currency_id = sdd.fixed_cost_currency_id
LEFT JOIN source_uom su_pos ON su_pos.source_uom_id = COALESCE(sdd.position_uom,spcd.display_uom_id, spcd.uom_id)	
LEFT JOIN formula_editor fe ON fe.formula_id = sdd.formula_id
LEFT JOIN formula_editor_sql fes ON fes.formula_id = fe.formula_id
LEFT JOIN source_price_curve_def spcd_formula ON spcd_formula.source_curve_def_id = sdd.formula_curve_id	
LEFT JOIN source_currency fixed_price_sc ON fixed_price_sc.source_currency_id = sdd.fixed_price_currency_id
LEFT JOIN source_currency formula_sc ON formula_sc.source_currency_id = sdd.formula_currency_id	
LEFT JOIN source_currency price_adder_sc ON price_adder_sc.source_currency_id = sdd.price_adder_currency2
LEFT JOIN source_uom price_su ON price_su.source_uom_id = sdd.price_uom_id
LEFT JOIN static_data_value sdv_pv_party ON sdv_pv_party.value_id = sdd.pv_party
LEFT JOIN static_data_value sdv_detail_profile ON sdv_detail_profile.value_id = sdd.profile_code
LEFT JOIN source_commodity sdd_sc ON sdd.detail_commodity_id = sdd_sc.source_commodity_id
LEFT JOIN dbo.static_data_value sdv_gc ON sdv_gc.value_id = sdd_sc.commodity_group1 AND sdv_gc.type_id = 29100
LEFT JOIN commodity_origin co ON sdd.origin = co.commodity_origin_id
LEFT JOIN static_data_value sdv_o ON sdv_o.value_id = co.origin
LEFT JOIN commodity_form cf ON cf.commodity_form_id = sdd.form
LEFT JOIN commodity_type_form ctf ON ctf.commodity_type_form_id = cf.form
LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = sdd.attribute1
LEFT JOIN commodity_attribute_form caf1 ON caf1.commodity_attribute_form_id = cfa1.attribute_form_id
LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.type_id = 43200
LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = sdd.attribute2
LEFT JOIN commodity_attribute_form caf2 ON caf2.commodity_attribute_form_id = cfa2.attribute_form_id
LEFT JOIN static_data_value sdv_att2 ON sdv_att2.value_id = caf2.commodity_attribute_value AND sdv_att2.type_id = 43200
LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = sdd.attribute3
LEFT JOIN commodity_attribute_form caf3 ON caf3.commodity_attribute_form_id = cfa3.attribute_form_id
LEFT JOIN static_data_value sdv_att3 ON sdv_att3.value_id = caf3.commodity_attribute_value AND sdv_att3.type_id = 43200
LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = sdd.attribute4
LEFT JOIN commodity_attribute_form caf4 ON caf4.commodity_attribute_form_id = cfa4.attribute_form_id
LEFT JOIN static_data_value sdv_att4 ON sdv_att4.value_id = caf4.commodity_attribute_value AND sdv_att4.type_id = 43200
LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = sdd.attribute5
LEFT JOIN commodity_attribute_form caf5 ON caf5.commodity_attribute_form_id = cfa5.attribute_form_id
LEFT JOIN static_data_value sdv_att5 ON sdv_att5.value_id = caf5.commodity_attribute_value AND sdv_att5.type_id = 43200
LEFT JOIN static_data_value sdv_it ON sdv_it.value_id = sdh.inco_terms AND sdv_it.[type_id] = 40200
LEFT JOIN static_data_value sdv_it2 ON sdv_it2.value_id = sdd.detail_inco_terms AND sdv_it2.[type_id] = 40200		
LEFT JOIN source_currency settlement_sc ON settlement_sc.source_currency_id = sdd.settlement_currency
LEFT JOIN source_uom su_cont ON su_cont.source_uom_id = sdd.deal_volume_uom_id
LEFT JOIN source_currency sc_adder ON sc_adder.source_currency_id = sdd.adder_currency_id	
LEFT JOIN source_counterparty sc2 ON sc2.source_counterparty_id = sdh.counterparty_id2
LEFT JOIN source_traders st2 ON st2.source_trader_id = sdh.trader_id2
LEFT JOIN static_data_value sdv_gl ON sdv_gl.value_id = sdh.governing_law
LEFT JOIN static_data_value sdv_pt ON sdv_pt.value_id = sdh.payment_term
LEFT JOIN counterparty_contacts cc_scheduler ON cc_scheduler.counterparty_contact_id = sdh.scheduler AND cc_scheduler.contact_type = -32300
LEFT JOIN static_data_value sdv_cy ON sdv_cy.value_id = sdd.crop_year AND sdv_cy.[type_id] = 10092
LEFT JOIN static_data_value sdv_bso ON sdv_bso.value_id = sdd.buyer_seller_option AND sdv_bso.[type_id] = 40400
LEFT JOIN match_group_detail mgd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
LEFT JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id
LEFT JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = mgh.match_group_shipment_id AND mgs.match_group_id = mgh.match_group_id
LEFT JOIN match_group mg ON mg.match_group_id = mgs.match_group_id
LEFT JOIN static_data_value sdv_dds ON sdv_dds.value_id = sdd.status AND sdv_dds.type_id = 25000
LEFT JOIN static_data_value sdv_deal_cat ON sdv_deal_cat.value_id = sdh.deal_category_value_id AND sdv_deal_cat.[type_id] = 475
LEFT JOIN static_data_value sdv_block_type ON sdv_block_type.value_id = sdh.block_type AND sdv_block_type.[type_id] = 12000
LEFT JOIN static_data_value sdv_deal_ref ON sdv_deal_ref.value_id = sdh.deal_reference_type_id AND sdv_deal_ref.[type_id] = 12500
LEFT JOIN counterparty_contacts cc_trader ON cc_trader.counterparty_contact_id = sdh.counterparty_trader AND cc_trader.contact_type = -32200
LEFT JOIN source_counterparty sc_internal ON sc_internal.source_counterparty_id = sdh.internal_counterparty
LEFT JOIN meter_id mi ON mi.meter_id = sdd.meter_id
LEFT JOIN static_data_value sdv_detail_cat ON sdv_detail_cat.value_id = sdd.category AND sdv_detail_cat.[type_id] = 18100
LEFT JOIN static_data_value sdv_cycle ON sdv_cycle.value_id = sdd.cycle AND sdv_cycle.[type_id] = 41000
LEFT JOIN static_data_value sdv_entity ON sdv_entity.value_id = sc.type_of_entity AND sdv_entity.[type_id] = 10020
LEFT JOIN source_deal_header sdh_close on sdh_close.source_deal_header_id=sdh.close_reference_id
LEFT JOIN static_data_value sdv_sbg1 ON sdv_sbg1.value_id = books.sub_book_group1
LEFT JOIN static_data_value sdv_sbg2 ON sdv_sbg2.value_id = books.sub_book_group2
LEFT JOIN static_data_value sdv_sbg3 ON sdv_sbg3.value_id = books.sub_book_group3
LEFT JOIN static_data_value sdv_sbg4 ON sdv_sbg4.value_id = books.sub_book_group4
LEFT JOIN source_counterparty AS psc ON  psc.source_counterparty_id = sc.parent_counterparty_id
LEFT JOIN static_data_value jurisdiction ON jurisdiction.value_id = sdh.state_value_id AND jurisdiction.type_id = 10002
LEFT JOIN static_data_value tier_type ON tier_type.value_id = sdh.tier_value_id AND tier_type.type_id = 15000
LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
LEFT JOIN static_data_value assignment_type ON assignment_type.value_id = sdh.assignment_type_value_id
LEFT JOIN static_data_value gen_state ON gen_state.value_id = rg.gen_state_value_id AND gen_state.type_id = 10016
LEFT JOIN static_data_value status ON status.value_id = sdh.status_value_id
LEFT JOIN static_data_value technology ON technology.value_id = rg.technology AND technology.type_id = 10009
LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
LEFT JOIN static_data_value gis_cer_jur ON gis_cer_jur.value_id = gc.state_value_id AND gis_cer_jur.type_id = 10002
LEFT JOIN static_data_value tier_type_jur ON tier_type_jur.value_id = gc.tier_type AND tier_type_jur.type_id = 15000
LEFT JOIN static_data_value cert_year ON cert_year.value_id = gc.year AND cert_year.type_id = 10092
LEFT JOIN static_data_value cert_entity ON cert_entity.value_id = gc.certification_entity AND cert_entity.type_id = 10011
WHERE ((sdh.deal_date <= CAST(@_as_of_date AS DATETIME) AND sdd.term_end >= CAST(@_as_of_date AS DATETIME)) OR @_as_of_date IS NULL)