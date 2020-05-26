DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

EXEC spa_rfx_run_sql 39972, 39265, 'sub_id=1376,stra_id=1377,book_id=1378,sub_book_id=3348!3311!3347!3310!2248!3490!3360!3338!3323,trader_id=NULL,counterparty_id=NULL,contract_id=NULL,commodity_id=NULL,create_ts_from=NULL,create_ts_to=NULL,deal_date_from=NULL,deal_date_to=NULL,deal_detail_status_id=NULL,source_deal_header_id=NULL,deal_id=NULL,generator=NULL,generation_state=NULL,technology=NULL,fuel_type=NULL,header_buy_sell_flag=NULL,header_physical_financial_flag=NULL,product_classification=NULL,term_start=NULL,term_end=NULL,vintage_year_id=NULL,update_ts_from=NULL,update_ts_to=NULL,delivery_date_from=NULL,delivery_date_to=NULL,certificate_expiration_date_from=NULL,certificate_expiration_date_to=NULL,jurisdiction_id=NULL,tier_id=NULL,is_environmental=y', NULL,'t','runaj', 'y' , 0 , NULL
SELECT  *
FROM adiha_process.dbo.report_dataset_RDPV_runaj_6715E777_FC0F_4FA5_A8B1_EB32846D3BF7 [RDPV] 
WHERE 1 = 1 
GROUP BY  [RDPV].[vintage_year], [RDPV].[jurisdiction], [RDPV].[tier_type], [RDPV].[volume_uom]