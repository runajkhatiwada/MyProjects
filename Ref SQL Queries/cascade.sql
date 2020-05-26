DECLARE @xml XML = '
<GridXML>
	<GridHeader source_deal_header_id="249959" transfer_without_offset="0" transfer_only_offset="0" est_movement_date="2020-02-28">
		<GridRow counterparty_id="7599" contract_id="8151" trader_id="1154" sub_book="4067" template_id="2698" volume_per="10" pricing_options="d" transfer_date="2020-02-28" transfer_counterparty_id="7599" transfer_contract_id="8151" transfer_trader_id="1154" transfer_sub_book="4067" transfer_template_id="2698"/>
	</GridHeader>
	<GridHeader source_deal_header_id="249960" transfer_without_offset="0" transfer_only_offset="0" est_movement_date="2020-02-28">
		<GridRow counterparty_id="7599" contract_id="8151" trader_id="1154" sub_book="4067" template_id="2698" volume_per="10" pricing_options="d" transfer_date="2020-02-28" transfer_counterparty_id="7599" transfer_contract_id="8151" transfer_trader_id="1154" transfer_sub_book="4067" transfer_template_id="2698"/>
	</GridHeader>
	<GridHeader source_deal_header_id="249958" transfer_without_offset="0" transfer_only_offset="0" est_movement_date="2020-02-28">
		<GridRow counterparty_id="7648" contract_id="10265" trader_id="2159" sub_book="4067" volume_per="20" pricing_options="d" transfer_date="2020-02-28" transfer_counterparty_id="7648" transfer_contract_id="10265" transfer_trader_id="2159" transfer_sub_book="4067" transfer_template_id="2698"/>
		<GridRow counterparty_id="10923" contract_id="14285" trader_id="2159" sub_book="4067" volume_per="10" pricing_options="d" transfer_date="2020-02-28" transfer_counterparty_id="8894" transfer_contract_id="12907" transfer_trader_id="2357" transfer_sub_book="4067" transfer_template_id="2698"/>
	</GridHeader>
</GridXML>
'

DECLARE @idoc  INT
EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

SELECT DISTINCT 
	   A.deal.value('@source_deal_header_id', 'int'),
  	   B.trans.value('@counterparty_id', 'int')
FROM @xml.nodes('/GridXML/GridHeader') A(deal)
CROSS APPLY deal.nodes('GridRow') B(trans)