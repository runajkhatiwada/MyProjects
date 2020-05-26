exec [dbo].spa_ixp_call_clr_function 
@parameter_xml = '<Root><PSRecordset paramName="PS_CurveID" paramValue="151"/><PSRecordset paramName="PS_PriceType" paramValue="m"/><PSRecordset paramName="PS_AsOfDate" paramValue="2019-10-20"/><PSRecordset paramName="PS_CurveStart" paramValue="null"/><PSRecordset paramName="PS_CurveEnd" paramValue="null"/></Root>'
,@ixp_rule_id=58,
@process_id='asdasd'

select * from ixp_rules


select top 10 * from adiha_process.sys.tables order by create_date desc

select * from adiha_process.dbo.ixp_datagenic_price_0_farrms_admin_9480F234_8E4A_4010_A5F6_E4D9B3B86019